import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:flutter/material.dart';

class QuantityPriceView extends StatefulWidget {
  final CategoryItem item;
  final InventoryCategory category;
  final double? quantity;
  final double? unitPrice;
  final double? totalPrice;
  final String? methodOfAdministration;
  final String? notes;
  final DateTime selectedDate;
  final String paymentMethod;
  final Function({
  required double quantity,
  required double unitPrice,
  required double totalPrice,
  String? methodOfAdministration,
  String? notes,
  required DateTime selectedDate,
  required String paymentMethod,
  }) onContinue;
  final VoidCallback onBack;

  const QuantityPriceView({
    super.key,
    required this.item,
    required this.category,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.methodOfAdministration,
    this.notes,
    required this.selectedDate,
    required this.paymentMethod,
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
  late TextEditingController _notesController;
  late TextEditingController _dateController;

  String? _methodOfAdministration;
  String _paymentMethod = 'Cash';
  double _totalPrice = 0.0;

  final List<String> _administrationMethods = [
    'Water',
    'Feed',
    'Injection',
    'Spray',
    'Other',
  ];

  final List<String> _paymentMethods = [
    'Cash',
    'Mobile Money',
    'Bank Transfer',
    'Credit',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.quantity?.toString() ?? '',
    );
    _unitPriceController = TextEditingController(
      text: widget.unitPrice?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.notes ?? '');
    _dateController = TextEditingController(
      text: widget.selectedDate.toIso8601String(),
    );
    _methodOfAdministration = widget.methodOfAdministration;
    _paymentMethod = widget.paymentMethod;
    _totalPrice = widget.totalPrice ?? 0.0;

    _quantityController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);
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

  bool _isVaccineOrMedicine() {
    final categoryLower = widget.category.name.toLowerCase();
    return categoryLower.contains('vaccine') ||
        categoryLower.contains('medicine') ||
        categoryLower.contains('medication');
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

    widget.onContinue(
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: _totalPrice,
      methodOfAdministration: _methodOfAdministration,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      selectedDate: DateTime.parse(_dateController.text),
      paymentMethod: _paymentMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final showAdministrationMethod = _isVaccineOrMedicine();

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
                    'How much did you buy?',
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
                    topLabel: 'Unit Price (KES) *',
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
                          'KES ${_totalPrice.toStringAsFixed(2)}',
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

                  // Method of administration (for vaccines/medicines)
                  if (showAdministrationMethod)
                    ReusableDropdown<String>(
                      value: _methodOfAdministration,
                      topLabel: 'Method of Administration',
                      icon: Icons.local_hospital,
                      hintText: 'Select method',
                      items: _administrationMethods.map((method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Row(
                            children: [
                              Icon(
                                _getAdministrationIcon(method),
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Text(method),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _methodOfAdministration = value);
                      },
                    ),

                  // Notes
                  ReusableInput(
                    topLabel: 'Notes (Optional)',
                    icon: Icons.notes,
                    controller: _notesController,
                    hintText: 'Any additional notes...',
                    maxLines: 3,
                  ),

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

                  // Payment method
                  ReusableDropdown<String>(
                    value: _paymentMethod,
                    topLabel: 'Payment Method *',
                    icon: Icons.payment,
                    hintText: 'Select payment method',
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Row(
                          children: [
                            Icon(
                              _getPaymentIcon(method),
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Text(method),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentMethod = value);
                      }
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

  IconData _getAdministrationIcon(String method) {
    switch (method.toLowerCase()) {
      case 'water':
        return Icons.water_drop;
      case 'feed':
        return Icons.fastfood;
      case 'injection':
        return Icons.medication_liquid;
      case 'spray':
        return Icons.water;
      default:
        return Icons.medical_services;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'mobile money':
        return Icons.phone_android;
      case 'bank transfer':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}