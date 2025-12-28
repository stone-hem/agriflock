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

      await _repository.createProduct(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getProductLabel()} recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
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
                          color: Colors.green.withValues(alpha: 0.1),
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
                _buildTextField(
                  controller: _quantityController,
                  label: 'Number of Eggs Collected',
                  hint: 'e.g., 245',
                  keyboardType: TextInputType.number,
                  icon: Icons.egg,
                  isRequired: true,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _crackedEggsController,
                  label: 'Cracked or Broken Eggs',
                  hint: 'e.g., 5',
                  keyboardType: TextInputType.number,
                  icon: Icons.broken_image,
                  isRequired: false,
                ),
              ],

              if (_selectedProductType == 'meat') ...[
                _buildTextField(
                  controller: _quantityController,
                  label: 'Number of Birds Sold',
                  hint: 'e.g., 12',
                  keyboardType: TextInputType.number,
                  icon: Icons.agriculture,
                  isRequired: true,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _weightController,
                  label: 'Total Weight (kg) - Optional',
                  hint: 'e.g., 28.5',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  icon: Icons.monitor_weight,
                  isRequired: false,
                ),
              ],

              if (_selectedProductType == 'other') ...[
                _buildTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  hint: 'e.g., 50',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  icon: Icons.inventory,
                  isRequired: true,
                ),
              ],

              const SizedBox(height: 20),

              // Price (common for all types)
              _buildTextField(
                controller: _priceController,
                label: 'Price per Unit',
                hint: 'e.g., 10.50',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                icon: Icons.attach_money,
                isRequired: true,
              ),

              const SizedBox(height: 24),

              // Date & Time
              Text(
                'Date & Time',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: _dateTimeTile(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: _dateTimeTile(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: _selectedTime.format(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'e.g., Grade A eggs, sold to local market...',
                maxLines: 3,
                icon: Icons.note_add,
                isRequired: false,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required IconData icon,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            if (value != null && value.isNotEmpty) {
              if (keyboardType == TextInputType.number ||
                  keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
                if (num.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (num.parse(value) < 0) {
                  return 'Value cannot be negative';
                }
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _dateTimeTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
    super.dispose();
  }
}