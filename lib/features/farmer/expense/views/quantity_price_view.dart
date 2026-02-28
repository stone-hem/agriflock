import 'package:agriflock/core/widgets/custom_date_text_field.dart';
import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/core/widgets/reusable_time_input.dart';
import 'package:agriflock/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';

class QuantityPriceView extends StatefulWidget {
  final CategoryItem item;
  final InventoryCategory category;
  final double? quantity;
  final double? unitPrice;
  final double? totalPrice;
  final DateTime selectedDate;
  final Function({
  required double quantity,
  required double unitPrice,
  required double totalPrice,
  required DateTime selectedDate,
  }) onContinue;
  final VoidCallback onBack;

  const QuantityPriceView({
    super.key,
    required this.item,
    required this.category,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    required this.selectedDate,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<QuantityPriceView> createState() => _QuantityPriceViewState();
}

class _QuantityPriceViewState extends State<QuantityPriceView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  late TextEditingController _dateController;

  String? _methodOfAdministration;
  double _totalPrice = 0.0;
  String _currency='';
  TimeOfDay _selectedTime = TimeOfDay.now();



  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _quantityController = TextEditingController(
      text: widget.quantity?.toString() ?? '',
    );
    _unitPriceController = TextEditingController(
      text: widget.unitPrice?.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: widget.selectedDate.toIso8601String(),
    );
    _totalPrice = widget.totalPrice ?? 0.0;

    _quantityController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);
  }


  Future<void> _loadCurrency() async {
    var currency = await secureStorage.getCurrency();
    setState(() {
      _currency = currency;
    });
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    setState(() {
      _totalPrice = quantity * unitPrice;
    });
  }

  Color _getCategoryColor() {
    final lowerName = widget.category.name.toLowerCase();
    if (lowerName.contains('feed')) {
      return Colors.orange;
    } else if (lowerName.contains('vaccine')) {
      return Colors.blue;
    } else if (lowerName.contains('medication') || lowerName.contains('medicine')) {
      return Colors.red;
    } else if (lowerName.contains('equipment')) {
      return Colors.purple;
    } else if (lowerName.contains('service')) {
      return Colors.teal;
    } else {
      return Colors.green;
    }
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final unitPrice = double.parse(_unitPriceController.text);

    final parsedDate = DateTime.parse(_dateController.text);
    final combinedDateTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onContinue(
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: _totalPrice,
      selectedDate: combinedDateTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Column(
      children: [
        // Item info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: categoryColor.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getItemIcon(),
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.categoryItemName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    if (widget.item.description.isNotEmpty)
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How much did you spent?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity
                  ReusableInput(
                    topLabel: 'Quantity *',
                    icon: Icons.format_list_numbered,
                    controller: _quantityController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Quantity must be greater than 0';
                      }
                      return null;
                    },
                  ),

                  // Unit Price
                  ReusableInput(
                    topLabel: 'Unit Price ($_currency) *',
                    icon: Icons.attach_money,
                    controller: _unitPriceController,
                    hintText: '0.00',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter unit price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                  ),

                  // Total (calculated)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '$_currency ${_totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date
                  CustomDateTextField(
                    label: 'Date *',
                    icon: Icons.calendar_today,
                    required: true,
                    initialDate: widget.selectedDate,
                    minYear: DateTime.now().year - 1,
                    maxYear: DateTime.now().year,
                    returnFormat: DateReturnFormat.isoString,
                    controller: _dateController,
                  ),

                  // Time
                  ReusableTimeInput(
                    topLabel: 'Time *',
                    icon: Icons.access_time,
                    initialTime: _selectedTime,
                    onTimeChanged: (time) {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getItemIcon() {
    final lowerName = widget.item.categoryItemName.toLowerCase();
    if (lowerName.contains('vaccine')) {
      return Icons.vaccines;
    } else if (lowerName.contains('feed')) {
      return Icons.fastfood;
    } else if (lowerName.contains('medicine')) {
      return Icons.medication;
    } else {
      return Icons.inventory_2;
    }
  }



  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}