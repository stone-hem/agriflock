import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/farm/models/inventory_models.dart';
import 'package:agriflock360/features/farmer/farm/repositories/inventory_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/result.dart';

class AddInventoryItemScreen extends StatefulWidget {
  final String farmId;

  const AddInventoryItemScreen({super.key, required this.farmId});

  @override
  State<AddInventoryItemScreen> createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _costController = TextEditingController();
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  final _expiryDateController = TextEditingController();

  final InventoryRepository _repository = InventoryRepository();
  List<InventoryCategory> _categories = [];
  bool _isLoadingCategories = true;
  String? _selectedCategoryId;
  String? _selectedUnit;
  DateTime? _selectedExpiryDate;

  final List<String> _units = [
    'kg',
    'grams',
    'liters',
    'ml',
    'packets',
    'doses',
    'bottles',
    'bags',
    'pieces',
    'boxes',
    'cartons',
    'units',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    final result = await _repository.getInventoryCategories(activeOnly: true);

    setState(() {
      _isLoadingCategories = false;
    });

    switch (result) {
      case Success<List<InventoryCategory>>(data: final categories):
        setState(() {
          _categories = categories;
          if (categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }
        });
      case Failure<List<InventoryCategory>>(message: final message):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load categories: $message'),
              backgroundColor: Colors.red,
            ),
          );
        }
    }
  }


  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a unit of measurement'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final request = CreateInventoryItemRequest(
          categoryId: _selectedCategoryId!,
          farmId: widget.farmId,
          itemName: _nameController.text,
          description: _descriptionController.text,
          unitOfMeasurement: _selectedUnit!,
          currentStock: double.parse(_currentStockController.text),
          minimumStockLevel: double.parse(_minStockController.text),
          reorderPoint: double.parse(_reorderPointController.text),
          cost: double.parse(_costController.text),
          supplier: _supplierController.text,
          expiryDate: _selectedExpiryDate,
          notes: _notesController.text,
        );

        final result = await _repository.createInventoryItem(request);

        Navigator.of(context).pop(); // Close loading dialog

        switch (result) {
          case Success<InventoryItem>(data: final item):
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.itemName} added to inventory'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pushReplacement('${AppRoutes.farmsInventory}/${widget.farmId}');
            }
          case Failure<InventoryItem>(message: final message):
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to add item: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            }
        }
      } catch (e) {
        Navigator.of(context).pop(); // Close loading dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add Inventory Item'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _addItem,
            child: const Text(
              'Add Item',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Farm Info Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.agriculture, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add New Inventory Item',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Farm ID: ${widget.farmId}',
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
              const SizedBox(height: 24),

              // Item Name
              ReusableInput(
                topLabel: 'Item Name',
                controller: _nameController,
                hintText: 'e.g., Broiler Starter Feed',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                }, labelText: 'Name',
              ),
              const SizedBox(height: 20),

              // Category
              ReusableDropdown<String>(
                topLabel: 'Category',
                value: _selectedCategoryId,
                hintText: 'Select category',
                items: _categories.map((InventoryCategory category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              ReusableInput(
                topLabel: 'Description (Optional)',
                controller: _descriptionController,
                maxLines: 3,
                hintText: 'Description of the item...', labelText: 'Description',

              ),
              const SizedBox(height: 20),

              // Unit of Measurement
              ReusableDropdown<String>(
                topLabel: 'Unit of Measurement',
                value: _selectedUnit,
                hintText: 'Select unit',
                items: _units.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnit = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Current Stock
              ReusableInput(
                topLabel: 'Current Stock',
                controller: _currentStockController,
                keyboardType: TextInputType.number,
                hintText: 'e.g., 100.0',
                labelText: 'Current Stock',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current stock';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final stock = double.parse(value);
                  if (stock < 0) {
                    return 'Stock cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Stock Levels
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReusableInput(
                          topLabel: 'Minimum Stock',
                          controller: _minStockController,
                          keyboardType: TextInputType.number,
                          hintText: 'Min',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid';
                            }
                            final minStock = double.parse(value);
                            if (minStock < 0) {
                              return 'Must be ≥ 0';
                            }
                            return null;
                          }, labelText: 'Min Stock',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReusableInput(
                          controller: _reorderPointController,
                          keyboardType: TextInputType.number,
                          hintText: 'Reorder',
                          topLabel: 'Reorder Point',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid';
                            }
                            final reorder = double.parse(value);
                            if (reorder < 0) {
                              return 'Must be ≥ 0';
                            }
                            return null;
                          }, labelText: 'Reorder',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Cost per Unit
              ReusableInput(
                topLabel: 'Cost per Unit',
                controller: _costController,
                keyboardType: TextInputType.number,
                hintText: 'e.g., 2.50',

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost per unit';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final cost = double.parse(value);
                  if (cost < 0) {
                    return 'Cost cannot be negative';
                  }
                  return null;
                }, labelText: 'Cost per Unit',
              ),
              const SizedBox(height: 20),

              // Supplier Information
              ReusableInput(
                controller: _supplierController,
                labelText: 'Supplier Name(Optional)',
                topLabel: 'Supplier Information(Optional)',
                hintText: '',
              ),
              const SizedBox(height: 12),

              // Expiry Date
              CustomDateTextField(
                label: 'Expiry Date (Optional)',
                icon: Icons.calendar_today,
                required: true,
                minYear: DateTime.now().year - 1,
                returnFormat: DateReturnFormat.dateTime,
                initialDate: DateTime.now(),
                maxYear: DateTime.now().year,
                controller: _expiryDateController,
                onChanged: (value) {
                  if (value != null) {
                    _selectedExpiryDate = value;
                  }
                },
              ),
              const SizedBox(height: 20),

              // Notes
              ReusableInput(
                topLabel: 'Notes (Optional)',
                controller: _notesController,
                maxLines: 3,
                hintText: 'Any additional notes about this item...', labelText: 'Notes'
              ),
              const SizedBox(height: 32),

              // Information Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Management',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Proper inventory management helps you:\n'
                            '• Track stock levels and avoid shortages\n'
                            '• Monitor inventory costs\n'
                            '• Plan purchases effectively\n'
                            '• Reduce waste and optimize usage\n'
                            '• Generate inventory reports',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    _reorderPointController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }
}