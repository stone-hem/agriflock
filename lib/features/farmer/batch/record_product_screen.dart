import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/widgets/custom_date_text_field.dart';
import 'package:agriflock/core/widgets/reusable_dropdown.dart';
import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/core/widgets/reusable_time_input.dart';
import 'package:agriflock/features/farmer/batch/model/product_model.dart';
import 'package:agriflock/features/farmer/batch/repo/product_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecordProductScreen extends StatefulWidget {
  final String batchId;
  final Map<String, dynamic>? batch; // Optional: pass batch for name display

  const RecordProductScreen({
    super.key,
    required this.batchId,
    this.batch,
  });

  @override
  State<RecordProductScreen> createState() => _RecordProductScreenState();
}

class _RecordProductScreenState extends State<RecordProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductRepo _repository = ProductRepo();

  String? _selectedProductType = 'eggs';
  final List<Map<String, String>> _productTypes = [
    {'value': 'eggs', 'label': 'Eggs'},
    {'value': 'chicken', 'label': 'Chicken'},
    {'value': 'manure', 'label': 'Manure'},
    {'value': 'other', 'label': 'Other'},
  ];

  bool _isSold = false;

  final _quantityController = TextEditingController();
  final _crackedEggsController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _selectedDateController = TextEditingController();
  final _smallDeformedEggsController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      DateTime selectedScheduledDate = DateTime.parse(_selectedDateController.text);
      DateTime selectedCompletedTime = DateTime(
        selectedScheduledDate.year,
        selectedScheduledDate.month,
        selectedScheduledDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      CreateProductRequest request;

      if (_selectedProductType == 'eggs') {
        request = CreateProductRequest(
          productType: _selectedProductType!,
          batchId: widget.batchId,
          isSold: _isSold,
          eggsCollected: int.parse(_quantityController.text),
          crackedEggs: int.tryParse(_crackedEggsController.text) ?? 0,
          partialBrokenEggs: int.tryParse(_crackedEggsController.text) ?? 0,
          smallDeformedEggs: int.tryParse(_smallDeformedEggsController.text) ?? 0,
          price: _isSold ? num.parse(_priceController.text) : null,
          collectionDate: selectedCompletedTime.toUtc().toIso8601String(),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
      } else if (_selectedProductType == 'chicken') {
        request = CreateProductRequest(
          productType: _selectedProductType!,
          batchId: widget.batchId,
          isSold: _isSold,
          birdsSold: int.parse(_quantityController.text),
          weight: _weightController.text.isNotEmpty
              ? num.parse(_weightController.text)
              : null,
          price: _isSold ? num.parse(_priceController.text) : null,
          collectionDate: selectedCompletedTime.toUtc().toIso8601String(),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
      } else {
        // manure or other
        request = CreateProductRequest(
          productType: _selectedProductType!,
          batchId: widget.batchId,
          isSold: _isSold,
          quantity: num.parse(_quantityController.text),
          price: _isSold ? num.parse(_priceController.text) : null,
          collectionDate: selectedCompletedTime.toUtc().toIso8601String(),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
      }

      final result = await _repository.createProduct(request);

      switch (result) {
        case Success _:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_getProductLabel()} recorded successfully!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              context.pop(true);
            }
          }

        case Failure(message: final errorMessage):
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save: $errorMessage'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _getProductLabel() {
    final type = _productTypes.firstWhere(
      (t) => t['value'] == _selectedProductType,
      orElse: () => {'label': 'Product'},
    );
    return type['label']!;
  }

  String? _validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final numValue = num.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid number';
    }
    if (numValue <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  String? _validateNonNegativeNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final numValue = num.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid number';
    }
    if (numValue < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (!_isSold) return null;
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = num.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final batchName = widget.batch?['name'] ?? 'Batch #${widget.batchId}';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('Record Product'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveRecord,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
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
              // Batch Info Header
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getHeaderIcon(),
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batchName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Recording ${_getProductLabel().toLowerCase()} for this batch',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Product Type
              ReusableDropdown<String>(
                topLabel: 'Product Type',
                value: _selectedProductType,
                icon: Icons.category,
                items: _productTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductType = value;
                    _quantityController.clear();
                    _crackedEggsController.clear();
                    _weightController.clear();
                  });
                },
                hintText: 'type',
              ),
              const SizedBox(height: 24),

              // Conditional Fields based on Product Type
              if (_selectedProductType == 'eggs') ...[
                ReusableInput(
                  controller: _quantityController,
                  topLabel: 'Number of Eggs Collected',
                  labelText: 'Number of Eggs Collected',
                  hintText: 'e.g., 245',
                  keyboardType: TextInputType.number,
                  icon: Icons.egg,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => _validatePositiveNumber(value, 'Eggs collected'),
                ),
                const SizedBox(height: 20),
                ReusableInput(
                  topLabel: 'Cracked or Broken Eggs',
                  controller: _crackedEggsController,
                  labelText: 'Cracked or Broken Eggs',
                  hintText: 'e.g., 5',
                  keyboardType: TextInputType.number,
                  icon: Icons.broken_image,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => _validateNonNegativeNumber(value, 'Cracked eggs'),
                ),
                const SizedBox(height: 20),
                ReusableInput(
                  topLabel: 'Small or Deformed Eggs',
                  controller: _smallDeformedEggsController,
                  labelText: 'Small or Deformed Eggs',
                  hintText: 'e.g., 5',
                  keyboardType: TextInputType.number,
                  icon: Icons.shape_line,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => _validateNonNegativeNumber(value, 'Small/deformed eggs'),
                ),
              ],

              if (_selectedProductType == 'chicken') ...[
                ReusableInput(
                  controller: _quantityController,
                  topLabel: 'Number of Chickens',
                  labelText: 'Number of Chickens',
                  hintText: 'e.g., 12',
                  keyboardType: TextInputType.number,
                  icon: Icons.agriculture,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => _validatePositiveNumber(value, 'Number of chickens'),
                ),
                const SizedBox(height: 20),
                ReusableInput(
                  controller: _weightController,
                  topLabel: 'Total Weight (kg)',
                  labelText: 'Total Weight (kg) - Optional',
                  hintText: 'e.g., 28.5',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  icon: Icons.monitor_weight,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
              ],

              if (_selectedProductType == 'manure') ...[
                ReusableInput(
                  controller: _quantityController,
                  topLabel: 'Quantity (Bags)',
                  labelText: 'Quantity (Bags)',
                  hintText: 'e.g., 10',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  icon: Icons.inventory_2,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => _validatePositiveNumber(value, 'Quantity'),
                ),
              ],

              if (_selectedProductType == 'other') ...[
                ReusableInput(
                  controller: _quantityController,
                  topLabel: 'Quantity',
                  labelText: 'Quantity',
                  hintText: 'e.g., 50',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  icon: Icons.inventory,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => _validatePositiveNumber(value, 'Quantity'),
                ),
              ],

              const SizedBox(height: 24),

              // Was this product sold?
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sell, size: 18, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Was this product sold?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isSold,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            _isSold = value;
                            if (!value) _priceController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (_isSold) ...[
                const SizedBox(height: 16),
                ReusableInput(
                  controller: _priceController,
                  topLabel: 'Price',
                  labelText: 'Price',
                  hintText: 'e.g., 10.50',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  icon: Icons.attach_money,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: _validatePrice,
                ),
              ],

              const SizedBox(height: 24),

              // Date & Time
              CustomDateTextField(
                label: 'Date',
                icon: Icons.calendar_today,
                required: true,
                initialDate: DateTime.now(),
                minYear: DateTime.now().year - 1,
                returnFormat: DateReturnFormat.isoString,
                maxYear: DateTime.now().year,
                controller: _selectedDateController,
              ),
              const SizedBox(height: 12),

              ReusableTimeInput(
                topLabel: 'Time',
                showIconOutline: true,
                suffixText: '12 hr format',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
                onTimeChanged: (time) {
                  _selectedTime = time;
                },
              ),

              const SizedBox(height: 24),

              // Notes
              ReusableInput(
                controller: _notesController,
                topLabel: 'Notes',
                labelText: 'Notes (Optional)',
                hintText: 'e.g., Grade A eggs, sold to local market...',
                maxLines: 3,
                icon: Icons.note_add,
                autocorrect: false,
                enableSuggestions: false,
              ),

              const SizedBox(height: 40),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Record Product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  IconData _getHeaderIcon() {
    switch (_selectedProductType) {
      case 'eggs':
        return Icons.egg;
      case 'chicken':
        return Icons.agriculture;
      case 'manure':
        return Icons.inventory_2;
      case 'other':
        return Icons.inventory;
      default:
        return Icons.production_quantity_limits;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _crackedEggsController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _selectedDateController.dispose();
    _smallDeformedEggsController.dispose();
    super.dispose();
  }
}
