import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/product_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
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
  final BatchMgtRepository _repository = BatchMgtRepository();

  String? _selectedProductType = 'eggs';
  final List<Map<String, String>> _productTypes = [
    {'value': 'eggs', 'label': 'Eggs'},
    {'value': 'meat', 'label': 'Meat (Birds Sold)'},
    {'value': 'other', 'label': 'Other'},
  ];

  final _quantityController = TextEditingController();
  final _crackedEggsController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _selectedDateController = TextEditingController();


  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Set default cracked eggs to 0
    _crackedEggsController.text = '0';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Combine date and time
      final collectionDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Create request based on product type
      CreateProductRequest request;

      if (_selectedProductType == 'eggs') {
        request = CreateProductRequest(
          productType: _selectedProductType!,
          batchId: widget.batchId,
          eggsCollected: int.parse(_quantityController.text),
          crackedEggs: int.tryParse(_crackedEggsController.text) ?? 0,
          price: num.parse(_priceController.text),
          collectionDate: collectionDateTime.toIso8601String(),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
      } else if (_selectedProductType == 'meat') {
        request = CreateProductRequest(
          productType: _selectedProductType!,
          batchId: widget.batchId,
          birdsSold: int.parse(_quantityController.text),
          weight: _weightController.text.isNotEmpty
              ? num.parse(_weightController.text)
              : null,
          price: num.parse(_priceController.text),
          collectionDate: collectionDateTime.toIso8601String(),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
      } else {
        // other
        request = CreateProductRequest(
          productType: _selectedProductType!,
          batchId: widget.batchId,
          quantity: num.parse(_quantityController.text),
          price: num.parse(_priceController.text),
          collectionDate: collectionDateTime.toIso8601String(),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
      }

      // Call repository with proper Result pattern handling
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

            // Delay pop slightly to show success message
            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              context.pop(true); // Return true to indicate success
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
      // Fallback for unexpected errors
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

  // Validation functions
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
      backgroundColor: Colors.grey.shade50,
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
              Text(
                'Product Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProductType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.category, color: Colors.grey.shade600),
                ),
                items: _productTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductType = value;
                    // Reset cracked eggs when switching product types
                    if (value == 'eggs') {
                      _crackedEggsController.text = '0';
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // Conditional Fields based on Product Type
              if (_selectedProductType == 'eggs') ...[
                ReusableInput(
                  controller: _quantityController,
                  labelText: 'Number of Eggs Collected',
                  hintText: 'e.g., 245',
                  keyboardType: TextInputType.number,
                  icon: Icons.egg,
                  validator: (value) => _validatePositiveNumber(value, 'Eggs collected'),
                ),
                const SizedBox(height: 20),
                ReusableInput(
                  controller: _crackedEggsController,
                  labelText: 'Cracked or Broken Eggs',
                  hintText: 'e.g., 5',
                  keyboardType: TextInputType.number,
                  icon: Icons.broken_image,
                  validator: (value) => _validateNonNegativeNumber(value, 'Cracked eggs'),
                ),
              ],

              if (_selectedProductType == 'meat') ...[
                ReusableInput(
                  controller: _quantityController,
                  labelText: 'Number of Birds Sold',
                  hintText: 'e.g., 12',
                  keyboardType: TextInputType.number,
                  icon: Icons.agriculture,
                  validator: (value) => _validatePositiveNumber(value, 'Birds sold'),
                ),
                const SizedBox(height: 20),
                ReusableInput(
                  controller: _weightController,
                  labelText: 'Total Weight (kg) - Optional',
                  hintText: 'e.g., 28.5',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  icon: Icons.monitor_weight,
                ),
              ],

              if (_selectedProductType == 'other') ...[
                ReusableInput(
                  controller: _quantityController,
                  labelText: 'Quantity',
                  hintText: 'e.g., 50',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  icon: Icons.inventory,
                  validator: (value) => _validatePositiveNumber(value, 'Quantity'),
                ),
              ],

              const SizedBox(height: 20),

              // Price (common for all types)
              ReusableInput(
                controller: _priceController,
                labelText: 'Price per Unit',
                hintText: 'e.g., 10.50',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                icon: Icons.attach_money,
                validator: _validatePrice,
              ),

              const SizedBox(height: 24),

              // Date & Time

                  CustomDateTextField(
                    label: 'Date & Time',
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
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectTime,
                    child: _dateTimeTile(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: _selectedTime.format(context),
                    ),
                  ),


              const SizedBox(height: 24),

              // Notes
              ReusableInput(
                controller: _notesController,
                labelText: 'Notes (Optional)',
                hintText: 'e.g., Grade A eggs, sold to local market...',
                maxLines: 3,
                icon: Icons.note_add,
              ),

              const SizedBox(height: 40),
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
      case 'meat':
        return Icons.agriculture;
      case 'other':
        return Icons.inventory;
      default:
        return Icons.production_quantity_limits;
    }
  }

  Widget _dateTimeTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _crackedEggsController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _selectedDateController.dispose();
    super.dispose();
  }
}