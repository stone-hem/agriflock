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
  final _itemCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currentStockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '10');
  final _reorderPointController = TextEditingController(text: '20');
  final _costController = TextEditingController();
  final _supplierController = TextEditingController();
  final _supplierContactController = TextEditingController();
  final _storageLocationController = TextEditingController();
  final _notesController = TextEditingController();

  final InventoryRepository _repository = InventoryRepository();
  List<InventoryCategory> _categories = [];
  bool _isLoadingCategories = true;
  String? _selectedCategoryId;
  String? _selectedUnit;
  DateTime? _selectedExpiryDate;
  DateTime? _lastRestockDate;

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
    _lastRestockDate = DateTime.now();
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

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
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
          itemCode: _itemCodeController.text,
          description: _descriptionController.text,
          unitOfMeasurement: _selectedUnit!,
          currentStock: double.parse(_currentStockController.text),
          minimumStockLevel: double.parse(_minStockController.text),
          reorderPoint: double.parse(_reorderPointController.text),
          costPerUnit: double.parse(_costController.text),
          supplier: _supplierController.text,
          supplierContact: _supplierContactController.text.isNotEmpty
              ? _supplierContactController.text
              : null,
          storageLocation: _storageLocationController.text.isNotEmpty
              ? _storageLocationController.text
              : null,
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
              context.pop(true); // Return success
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
              _buildSectionTitle('Item Name'),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Broiler Starter Feed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Item Code
              _buildSectionTitle('Item Code (Optional)'),
              TextFormField(
                controller: _itemCodeController,
                decoration: InputDecoration(
                  hintText: 'e.g., FEED-001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category
              _buildSectionTitle('Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  hintText: 'Select category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
              _buildSectionTitle('Description (Optional)'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Description of the item...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Unit of Measurement
              _buildSectionTitle('Unit of Measurement'),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: InputDecoration(
                  hintText: 'Select unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
              _buildSectionTitle('Current Stock'),
              TextFormField(
                controller: _currentStockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 100.0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                        _buildSectionTitle('Min Stock'),
                        TextFormField(
                          controller: _minStockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Min',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Reorder Point'),
                        TextFormField(
                          controller: _reorderPointController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Reorder',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Cost per Unit
              _buildSectionTitle('Cost per Unit (₵)'),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 2.50',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                },
              ),
              const SizedBox(height: 20),

              // Supplier Information
              _buildSectionTitle('Supplier Information'),
              TextFormField(
                controller: _supplierController,
                decoration: InputDecoration(
                  labelText: 'Supplier Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter supplier name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _supplierContactController,
                decoration: InputDecoration(
                  labelText: 'Supplier Contact (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Storage Location
              _buildSectionTitle('Storage Location (Optional)'),
              TextFormField(
                controller: _storageLocationController,
                decoration: InputDecoration(
                  hintText: 'e.g., Warehouse A, Shelf 3',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Expiry Date
              _buildSectionTitle('Expiry Date (Optional)'),
              InkWell(
                onTap: _selectExpiryDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedExpiryDate != null
                            ? '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year}'
                            : 'Select expiry date',
                        style: TextStyle(
                          color: _selectedExpiryDate != null
                              ? Colors.grey.shade800
                              : Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedExpiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedExpiryDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notes
              _buildSectionTitle('Notes (Optional)'),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any additional notes about this item...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _itemCodeController.dispose();
    _descriptionController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    _reorderPointController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    _supplierContactController.dispose();
    _storageLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}