import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecordExpenditureScreen extends StatefulWidget {
  final String batchId;
  final BatchModel? batch;

  const RecordExpenditureScreen({
    super.key,
    required this.batchId,
    this.batch,
  });

  @override
  State<RecordExpenditureScreen> createState() => _RecordExpenditureScreenState();
}

class _RecordExpenditureScreenState extends State<RecordExpenditureScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _selectedType;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _selectedDateController = TextEditingController();
  String? _selectedUnit;
  final TextEditingController _supplierController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool _isSubmitting = false;
  String? _errorMessage;

  // Poultry farm expenditure types
  final List<String> _expenditureTypes = [
    'Feed',
    'Medication',
    'Vaccines',
    'Utilities',
    'Labor',
    'Equipment',
    'Transport',
    'Other',
  ];


  final List<String> _units = [
    'bag',
    'kg',
    'liter',
    'dose',
    'unit',
    'hour',
    'day',
    'month',
    'other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _supplierController.dispose();
    _selectedDateController.dispose();
    super.dispose();
  }

  Future<void> _submitExpenditure() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API call
      // await _repository.recordExpenditure(
      //   batchId: widget.batchId,
      //   type: _selectedType!,
      //   description: _descriptionController.text,
      //   amount: double.parse(_amountController.text),
      //   quantity: int.parse(_quantityController.text),
      //   unit: _selectedUnit!,
      //   date: _selectedDate,
      //   supplier: _supplierController.text.isNotEmpty ? _supplierController.text : null,
      // );

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Return success
      if (mounted) {
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to record expenditure: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'feed':
        return Icons.fastfood;
      case 'medication':
      case 'vaccines':
        return Icons.medical_services;
      case 'utilities':
        return Icons.bolt;
      case 'labor':
        return Icons.people;
      case 'equipment':
        return Icons.build;
      case 'transport':
        return Icons.local_shipping;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Record Expenditure'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Batch Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.agriculture, size: 20, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recording for',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            widget.batch?.batchName ?? 'Batch ${widget.batchId}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Expenditure Type
              ReusableDropdown<String>(
                value: _selectedType,
                topLabel: 'Expenditure Type *',
                icon: Icons.category,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select expenditure type';
                  }
                  return null;
                },
                hintText: 'Select type',
                items: _expenditureTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getTypeIcon(type), size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Text(type),
                      ],
                    ),
                  );
                }).toList(),
              ),


              // Description
              ReusableInput(
                topLabel: 'Description *',
                icon: Icons.description,
                maxLines: 2,
                hintText: 'e.g., Layer mash feed purchase',
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              ReusableInput(
                topLabel: 'Amount (Ksh) *',
                icon: Icons.attach_money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
                hintText: '0.00',
                prefixText: 'Ksh ',
                keyboardType: TextInputType.number,
                controller: _amountController,
              ),

              // Amount and Quantity Row
              Row(
                children: [
                  Expanded(
                    child: ReusableInput(
                      topLabel: 'Quantity',
                      icon: Icons.format_list_numbered,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Quantity must be greater than 0';
                        }
                        return null;
                      },
                      hintText: '1',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ReusableDropdown<String>(
                      value: _selectedUnit,
                      hintText: 'Unit',
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select unit';
                        }
                        return null;
                      },
                      items: _units.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              // Date
              CustomDateTextField(
                label: 'Date',
                hintText: 'Select date',
                icon: Icons.calendar_today,
                required: true,
                minYear: DateTime.now().year - 1,
                returnFormat: DateReturnFormat.dateTime,
                initialDate: DateTime.now(),
                maxYear: DateTime.now().year,
                controller: _selectedDateController,
                onChanged: (value) {
                  if (value != null) {
                    _selectedDate = value;
                  }
                },
              ),

              // Supplier
              ReusableInput(
                topLabel: 'Supplier (Optional)',
                icon: Icons.store,
                controller: _supplierController,
                hintText: 'e.g., FeedCo Ltd',
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitExpenditure,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Record Expenditure',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}