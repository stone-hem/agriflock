import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/core/widgets/reusable_time_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:flutter/material.dart';

class UseItemDetailsView extends StatefulWidget {
  final BatchListItem batch;
  final InventoryCategory category;
  final CategoryItem? selectedItem;
  final double? quantity;
  final String? methodOfAdministration;
  final String? notes;
  final DateTime selectedDate;
  final double? dosesUsed;
  final Function(CategoryItem) onItemSelected;
  final VoidCallback onItemCleared;
  final Function({
  required double quantity,
  String? methodOfAdministration,
  String? notes,
  required DateTime selectedDate,
  double? dosesUsed,
  }) onSave;
  final VoidCallback onBack;
  final bool isSubmitting;

  const UseItemDetailsView({
    super.key,
    required this.batch,
    required this.category,
    this.selectedItem,
    this.quantity,
    this.methodOfAdministration,
    this.notes,
    required this.selectedDate,
    this.dosesUsed,
    required this.onItemSelected,
    required this.onItemCleared,
    required this.onSave,
    required this.onBack,
    required this.isSubmitting,
  });

  @override
  State<UseItemDetailsView> createState() => _UseItemDetailsViewState();
}

class _UseItemDetailsViewState extends State<UseItemDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dosesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _searchQuery = '';
  String? _selectedMethodOfAdministration;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    if (widget.quantity != null) {
      _quantityController.text = widget.quantity.toString();
    }
    if (widget.dosesUsed != null) {
      _dosesController.text = widget.dosesUsed.toString();
    }
    if (widget.notes != null) {
      _notesController.text = widget.notes!;
    }
    if (widget.methodOfAdministration != null) {
      _selectedMethodOfAdministration = widget.methodOfAdministration;
    }
  }

  bool get _isVaccineOrMedicine {
    final categoryLower = widget.category.name.toLowerCase();
    return categoryLower.contains('vaccine') ||
        categoryLower.contains('medicine') ||
        categoryLower.contains('medication');
  }

  Color _getCategoryColor() {
    final lowerName = widget.category.name.toLowerCase();
    if (lowerName.contains('feed')) {
      return Colors.orange;
    } else if (lowerName.contains('vaccine')) {
      return Colors.blue;
    } else if (lowerName.contains('medication') || lowerName.contains('medicine')) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  IconData _getItemIcon(String itemName) {
    final lowerName = itemName.toLowerCase();
    if (lowerName.contains('vaccine')) {
      return Icons.vaccines;
    } else if (lowerName.contains('feed')) {
      return Icons.fastfood;
    } else if (lowerName.contains('medicine') || lowerName.contains('drug')) {
      return Icons.medication;
    } else if (lowerName.contains('vitamin') || lowerName.contains('supplement')) {
      return Icons.health_and_safety;
    } else if (lowerName.contains('equipment') || lowerName.contains('tool')) {
      return Icons.build_circle;
    } else {
      return Icons.inventory_2;
    }
  }

  List<CategoryItem> get _filteredItems {
    // First filter to only items that can be used from store
    final usableItems = widget.category.categoryItems.where((item) => item.useFromStore).toList();

    if (_searchQuery.isEmpty) {
      return usableItems;
    }
    return usableItems.where((item) {
      return item.categoryItemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleSave() {
    if (widget.selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final dosesUsed = _isVaccineOrMedicine && _dosesController.text.isNotEmpty
        ? double.tryParse(_dosesController.text)
        : null;

    // Parse date from controller (ISO format from CustomDateTextField)
    DateTime selectedDate = DateTime.now();
    if (_dateController.text.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(_dateController.text);
      } catch (e) {
        // Fallback to current date if parsing fails
        selectedDate = DateTime.now();
      }
    }

    // Combine date + time into a single DateTime
    final combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onSave(
      quantity: quantity,
      methodOfAdministration: _selectedMethodOfAdministration,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      selectedDate: combinedDateTime,
      dosesUsed: dosesUsed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final items = _filteredItems;

    return Column(
      children: [
        // Batch and category banner
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.pets, color: categoryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    widget.batch.batchName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${widget.batch.currentCount} birds',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.category.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
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
                  // Item selection section
                  if (widget.selectedItem == null) ...[
                    const Text(
                      'Select item from store',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Items list
                    if (items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No items found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return GestureDetector(
                            onTap: () => widget.onItemSelected(item),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getItemIcon(item.categoryItemName),
                                      size: 24,
                                      color: categoryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.categoryItemName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        if (item.description.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              item.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ] else ...[
                    // Selected item display and details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: categoryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getItemIcon(widget.selectedItem!.categoryItemName),
                              size: 24,
                              color: categoryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectedItem!.categoryItemName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: categoryColor,
                                  ),
                                ),
                                if (widget.selectedItem!.description.isNotEmpty)
                                  Text(
                                    widget.selectedItem!.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: categoryColor,
                            tooltip: 'Change item',
                            onPressed: widget.onItemCleared,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quantity input
                    const Text(
                      'How much did you use?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ReusableInput(
                      topLabel: 'Quantity Used',
                      icon: Icons.inventory_2,
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
                    const SizedBox(height: 16),

                    // Method of administration (for vaccines/medicines)
                    if (_isVaccineOrMedicine) ...[
                      const Text(
                        'Method of Administration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ReusableDropdown<String>(
                          value: _selectedMethodOfAdministration,
                          icon: Icons.medication_liquid,
                          topLabel: 'Select method of administration',
                          hintText: 'Select method',
                          items: [
                            'Drinking water',
                            'Injection',
                            'Spray',
                            'Eye drop',
                            'Oral',
                          ].map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedMethodOfAdministration = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Doses used
                      ReusableInput(
                        topLabel: 'Doses/Amount Used (Optional)',
                        icon: Icons.medical_information,
                        controller: _dosesController,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Amount must be greater than 0';
                            }
                          }
                          return null;
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Recommended: ${widget.batch.currentCount} doses (1 per bird)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Date selection
                    CustomDateTextField(
                      label: 'Date Used',
                      icon: Icons.calendar_today,
                      required: true,
                      initialDate: widget.selectedDate,
                      minYear: DateTime.now().year - 1,
                      maxYear: DateTime.now().year,
                      returnFormat: DateReturnFormat.isoString,
                      controller: _dateController,
                    ),
                    const SizedBox(height: 16),

                    // Time selection
                    ReusableTimeInput(
                      topLabel: 'Time Used',
                      icon: Icons.access_time,
                      initialTime: _selectedTime,
                      onTimeChanged: (time) {
                        setState(() => _selectedTime = time);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    ReusableInput(
                      topLabel: 'Notes (Optional)',
                      icon: Icons.note,
                      controller: _notesController,
                      hintText: 'Add any additional notes...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: widget.isSubmitting ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: widget.isSubmitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Save Record',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _dosesController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}