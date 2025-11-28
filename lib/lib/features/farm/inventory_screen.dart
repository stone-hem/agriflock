// lib/inventory/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InventoryScreen extends StatefulWidget {
  final String farmId;

  const InventoryScreen({super.key, required this.farmId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      id: '1',
      name: 'Broiler Starter Feed',
      category: 'Feed',
      currentStock: 450.5,
      unit: 'kg',
      minStockLevel: 100.0,
      costPerUnit: 2.50,
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
    ),
    InventoryItem(
      id: '2',
      name: 'Grower Feed',
      category: 'Feed',
      currentStock: 320.0,
      unit: 'kg',
      minStockLevel: 150.0,
      costPerUnit: 2.30,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryItem(
      id: '3',
      name: 'Newcastle Vaccine',
      category: 'Vaccines',
      currentStock: 50.0,
      unit: 'doses',
      minStockLevel: 20.0,
      costPerUnit: 1.80,
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
    ),
    InventoryItem(
      id: '4',
      name: 'Vitamin Supplement',
      category: 'Supplements',
      currentStock: 5.0,
      unit: 'kg',
      minStockLevel: 2.0,
      costPerUnit: 15.00,
      lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
    ),
    InventoryItem(
      id: '5',
      name: 'Antibiotics',
      category: 'Medication',
      currentStock: 12.0,
      unit: 'packets',
      minStockLevel: 5.0,
      costPerUnit: 8.50,
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
    ),
    InventoryItem(
      id: '6',
      name: 'Disinfectant',
      category: 'Cleaning',
      currentStock: 8.0,
      unit: 'liters',
      minStockLevel: 3.0,
      costPerUnit: 12.00,
      lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
    ),
    InventoryItem(
      id: '7',
      name: 'Feed Additives',
      category: 'Supplements',
      currentStock: 2.5,
      unit: 'kg',
      minStockLevel: 1.0,
      costPerUnit: 25.00,
      lastUpdated: DateTime.now().subtract(const Duration(days: 14)),
    ),
    InventoryItem(
      id: '8',
      name: 'Water Sanitizer',
      category: 'Cleaning',
      currentStock: 15.0,
      unit: 'liters',
      minStockLevel: 5.0,
      costPerUnit: 6.50,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void _showAdjustStockDialog(InventoryItem item) {
    final TextEditingController adjustmentController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    String _adjustmentType = 'add';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adjust Stock'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Stock: ${item.currentStock} ${item.unit}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Adjustment Type
                    const Text(
                      'Adjustment Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Add Stock'),
                            selected: _adjustmentType == 'add',
                            onSelected: (selected) {
                              setState(() {
                                _adjustmentType = 'add';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Remove Stock'),
                            selected: _adjustmentType == 'remove',
                            onSelected: (selected) {
                              setState(() {
                                _adjustmentType = 'remove';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Adjustment Amount
                    TextFormField(
                      controller: adjustmentController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount (${item.unit})',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Reason
                    TextFormField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason for adjustment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (adjustmentController.text.isNotEmpty &&
                        double.tryParse(adjustmentController.text) != null) {
                      _adjustStock(
                        item,
                        double.parse(adjustmentController.text),
                        _adjustmentType,
                        reasonController.text,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Adjust Stock'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _adjustStock(InventoryItem item, double amount, String type, String reason) {
    setState(() {
      final index = _inventoryItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        if (type == 'add') {
          _inventoryItems[index] = _inventoryItems[index].copyWith(
            currentStock: _inventoryItems[index].currentStock + amount,
            lastUpdated: DateTime.now(),
          );
        } else {
          _inventoryItems[index] = _inventoryItems[index].copyWith(
            currentStock: _inventoryItems[index].currentStock - amount,
            lastUpdated: DateTime.now(),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock ${type == 'add' ? 'added to' : 'removed from'} ${item.name}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showItemDetails(InventoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Category', item.category),
                _buildDetailRow('Current Stock', '${item.currentStock} ${item.unit}'),
                _buildDetailRow('Minimum Stock', '${item.minStockLevel} ${item.unit}'),
                _buildDetailRow('Cost per Unit', '₵${item.costPerUnit}'),
                _buildDetailRow('Total Value', '₵${(item.currentStock * item.costPerUnit).toStringAsFixed(2)}'),
                _buildDetailRow('Last Updated', _formatDate(item.lastUpdated)),
                const SizedBox(height: 16),
                _buildStockStatus(item),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAdjustStockDialog(item);
              },
              child: const Text('Adjust Stock'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStockStatus(InventoryItem item) {
    final status = item.currentStock <= item.minStockLevel
        ? 'Low Stock'
        : item.currentStock <= item.minStockLevel * 2
        ? 'Adequate'
        : 'Good';

    final color = item.currentStock <= item.minStockLevel
        ? Colors.red
        : item.currentStock <= item.minStockLevel * 2
        ? Colors.orange
        : Colors.green;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 8),
          Text(
            'Stock Status: $status',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
             context.push('/farms/inventory/add');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Items',
                    _inventoryItems.length.toString(),
                    Icons.inventory_2,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Low Stock',
                    _inventoryItems.where((item) => item.currentStock <= item.minStockLevel).length.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Inventory List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _inventoryItems.length,
              itemBuilder: (context, index) {
                final item = _inventoryItems[index];
                return _buildInventoryItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryItem(InventoryItem item) {
    final isLowStock = item.currentStock <= item.minStockLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(item.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(item.category),
            color: _getCategoryColor(item.category),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${item.currentStock} ${item.unit} • Min: ${item.minStockLevel} ${item.unit}',
            ),
            Text(
              '₵${item.costPerUnit} per ${item.unit}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLowStock)
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 20,
              ),
            Text(
              (item.currentStock * item.costPerUnit).toStringAsFixed(2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () => _showItemDetails(item),
        onLongPress: () => _showAdjustStockDialog(item),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Feed':
        return Colors.orange;
      case 'Vaccines':
        return Colors.green;
      case 'Medication':
        return Colors.red;
      case 'Supplements':
        return Colors.blue;
      case 'Cleaning':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Feed':
        return Icons.grain;
      case 'Vaccines':
        return Icons.medical_services;
      case 'Medication':
        return Icons.medication;
      case 'Supplements':
        return Icons.health_and_safety;
      case 'Cleaning':
        return Icons.clean_hands;
      default:
        return Icons.inventory_2;
    }
  }
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double currentStock;
  final String unit;
  final double minStockLevel;
  final double costPerUnit;
  final DateTime lastUpdated;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.unit,
    required this.minStockLevel,
    required this.costPerUnit,
    required this.lastUpdated,
  });

  InventoryItem copyWith({
    String? name,
    String? category,
    double? currentStock,
    String? unit,
    double? minStockLevel,
    double? costPerUnit,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      unit: unit ?? this.unit,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}