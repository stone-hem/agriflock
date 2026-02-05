import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';

/// A reusable dialog for adding or editing a house.
///
/// Usage:
/// ```dart
/// // To add a new house:
/// AddEditHouseDialog.show(
///   context: context,
///   farm: myFarm,
///   onSuccess: () => _reloadData(),
/// );
///
/// // To edit an existing house:
/// AddEditHouseDialog.show(
///   context: context,
///   farm: myFarm,
///   house: existingHouse,
///   onSuccess: () => _reloadData(),
/// );
/// ```
class AddEditHouseDialog extends StatefulWidget {
  final FarmModel farm;
  final House? house;
  final VoidCallback onSuccess;

  const AddEditHouseDialog({
    super.key,
    required this.farm,
    this.house,
    required this.onSuccess,
  });

  /// Static method to show the dialog conveniently
  static Future<void> show({
    required BuildContext context,
    required FarmModel farm,
    House? house,
    required VoidCallback onSuccess,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddEditHouseDialog(
        farm: farm,
        house: house,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<AddEditHouseDialog> createState() => _AddEditHouseDialogState();
}

class _AddEditHouseDialogState extends State<AddEditHouseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;
  final _repository = BatchHouseRepository();
  bool _isLoading = false;

  bool get isEditMode => widget.house != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.house?.houseName ?? '');
    _capacityController = TextEditingController(
      text: widget.house?.capacity.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.house?.description ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isEditMode ? Icons.edit : Icons.add_home,
              color: Colors.green.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isEditMode ? 'Edit House' : 'Add New House',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Farm info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.farm.farmName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ReusableInput(
                controller: _nameController,
                labelText: 'House Name',
                topLabel: 'House Name *',
                hintText: 'e.g., House A, Broiler House 1',
                icon: Icons.home_work,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter house name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ReusableInput(
                controller: _capacityController,
                labelText: 'Capacity',
                topLabel: 'House Capacity *',
                hintText: 'Enter maximum bird capacity',
                suffixText: 'birds',
                icon: Icons.groups,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter capacity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Capacity must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ReusableInput(
                topLabel: 'Description (Optional)',
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter house description or notes',
                icon: Icons.description,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveHouse,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isEditMode ? Icons.save : Icons.add,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(isEditMode ? 'Update' : 'Add House'),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _saveHouse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final houseData = {
        'name': _nameController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      };

      if (!isEditMode) {
        await _repository.createHouse(widget.farm.id, houseData);
        ToastUtil.showSuccess('House created successfully');
      } else {
        await _repository.updateHouse(
          widget.farm.id,
          widget.house!.id!,
          houseData,
        );
        ToastUtil.showSuccess('House updated successfully');
      }

      if (context.mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
