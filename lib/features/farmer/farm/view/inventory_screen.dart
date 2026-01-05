import 'package:agriflock360/features/farmer/farm/models/inventory_models.dart';
import 'package:agriflock360/features/farmer/farm/repositories/inventory_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/result.dart';

class InventoryScreen extends StatefulWidget {
  final String farmId;

  const InventoryScreen({super.key, required this.farmId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryRepository _repository = InventoryRepository();

  List<InventoryItem> _inventoryItems = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalItems = 0;
  int _lowStockCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore || _isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
      });
    }

    try {
      final result = await _repository.getInventoryItems(
        page: loadMore ? _currentPage + 1 : 1,
        limit: 20,
        farmId: widget.farmId,
      );

      switch (result) {
        case Success<InventoryResponse>(data: final data):
          setState(() {
            if (loadMore) {
              _inventoryItems.addAll(data.items);
              _currentPage++;
            } else {
              _inventoryItems = data.items;
              _currentPage = data.page;
            }
            _hasMore = data.hasMore;
            _totalItems = data.total;
            _error = null;

            // Calculate low stock count
            _lowStockCount = _inventoryItems.where((item) => item.isLowStock).length;
          });
        case Failure<InventoryResponse>(message: final message):
          setState(() {
            if (!loadMore) {
              _error = message;
            }
          });
          if (loadMore) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load more items: $message'),
                backgroundColor: Colors.red,
              ),
            );
          }
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    final result = await _repository.refreshInventory(
      limit: 20,
      farmId: widget.farmId,
    );

    switch (result) {
      case Success<InventoryResponse>(data: final data):
        setState(() {
          _inventoryItems = data.items;
          _currentPage = data.page;
          _hasMore = data.hasMore;
          _totalItems = data.total;
          _error = null;
          _lowStockCount = _inventoryItems.where((item) => item.isLowStock).length;
        });
      case Failure<InventoryResponse>(message: final message):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh: $message'),
              backgroundColor: Colors.red,
            ),
          );
        }
    }
  }

  Future<void> _showAdjustStockDialog(InventoryItem item) async {
    final TextEditingController adjustmentController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    String _adjustmentType = 'add';
    String? _batchId;

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
                      item.itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Stock: ${item.currentStock} ${item.unitOfMeasurement}',
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
                        labelText: 'Amount (${item.unitOfMeasurement})',
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
                  onPressed: () async {
                    if (adjustmentController.text.isNotEmpty &&
                        double.tryParse(adjustmentController.text) != null &&
                        reasonController.text.isNotEmpty) {
                      final amount = double.parse(adjustmentController.text);
                      if (amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Amount must be greater than 0'),
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
                        final request = AdjustStockRequest(
                          adjustmentAmount: amount,
                          adjustmentType: _adjustmentType,
                          reason: reasonController.text,
                          batchId: _batchId,
                        );

                        final result = await _repository.adjustStock(item.id, request);

                        Navigator.of(context).pop(); // Close loading dialog
                        Navigator.of(context).pop(); // Close adjustment dialog

                        switch (result) {
                          case Success<InventoryItem>(data: final updatedItem):
                          // Update local list
                            final index = _inventoryItems.indexWhere((i) => i.id == item.id);
                            if (index != -1) {
                              setState(() {
                                _inventoryItems[index] = updatedItem;
                                _lowStockCount = _inventoryItems.where((item) => item.isLowStock).length;
                              });
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Stock ${_adjustmentType == 'add' ? 'added to' : 'removed from'} ${item.itemName}',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          case Failure<InventoryItem>(message: final message):
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to adjust stock: $message'),
                                backgroundColor: Colors.red,
                              ),
                            );
                        }
                      } catch (e) {
                        Navigator.of(context).pop(); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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

  void _showItemDetails(InventoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.itemName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Category', item.category.name),
                _buildDetailRow('Item Code', item.itemCode.isNotEmpty ? item.itemCode : 'N/A'),
                _buildDetailRow('Current Stock', '${item.currentStock} ${item.unitOfMeasurement}'),
                _buildDetailRow('Minimum Stock', '${item.minimumStockLevel} ${item.unitOfMeasurement}'),
                _buildDetailRow('Reorder Point', '${item.reorderPoint} ${item.unitOfMeasurement}'),
                _buildDetailRow('Cost per Unit', '₵${item.costPerUnit.toStringAsFixed(2)}'),
                _buildDetailRow('Total Value', '₵${item.totalValue.toStringAsFixed(2)}'),
                _buildDetailRow('Supplier', item.supplier),
                if (item.storageLocation != null)
                  _buildDetailRow('Location', item.storageLocation!),
                if (item.lastRestockDate != null)
                  _buildDetailRow('Last Restock', _formatDate(item.lastRestockDate!)),
                if (item.expiryDate != null)
                  _buildDetailRow('Expiry Date', _formatDate(item.expiryDate!)),
                if (item.notes.isNotEmpty)
                  _buildDetailRow('Notes', item.notes),
                _buildDetailRow('Status', item.formattedStatus),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatus(InventoryItem item) {
    Color color;
    IconData icon;
    String statusText;

    if (item.currentStock <= item.minimumStockLevel) {
      color = Colors.red;
      icon = Icons.warning;
      statusText = 'Low Stock';
    } else if (item.needsReorder) {
      color = Colors.orange;
      icon = Icons.info;
      statusText = 'Needs Reorder';
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
      statusText = 'Good Stock';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            'Stock Status: $statusText',
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
            const SizedBox(width: 12),
            const Text('Inventory'),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/farms/inventory/add/${widget.farmId}');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading && _inventoryItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _inventoryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadInventory(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_inventoryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No inventory items',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first inventory item',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.push('/farms/inventory/add/${widget.farmId}');
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Summary Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Items',
                    _totalItems.toString(),
                    Icons.inventory_2,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Low Stock',
                    _lowStockCount.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Inventory List
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = _inventoryItems[index];
              return _buildInventoryItem(item);
            },
            childCount: _inventoryItems.length,
          ),
        ),

        // Loading More Indicator
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // Load More Button
        if (_hasMore && !_isLoading && !_isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _loadInventory(loadMore: true),
                  child: const Text('Load More Items'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryItem(InventoryItem item) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(item.category.name).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(item.category.name),
            color: _getCategoryColor(item.category.name),
            size: 24,
          ),
        ),
        title: Text(
          item.itemName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.currentStock} ${item.unitOfMeasurement} • Min: ${item.minimumStockLevel}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category.name,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.supplier.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Supplier: ${item.supplier}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₵${item.totalValue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            if (item.isLowStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.red.shade600,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Low Stock',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
    switch (category.toLowerCase()) {
      case 'feed':
        return Colors.orange;
      case 'vaccines':
        return Colors.green;
      case 'medication':
        return Colors.red;
      case 'supplements':
        return Colors.blue;
      case 'cleaning':
      case 'cleaning supplies':
        return Colors.purple;
      case 'bedding':
        return Colors.brown;
      case 'equipment':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'feed':
        return Icons.grain;
      case 'vaccines':
        return Icons.medical_services;
      case 'medication':
        return Icons.medication;
      case 'supplements':
        return Icons.health_and_safety;
      case 'cleaning':
      case 'cleaning supplies':
        return Icons.clean_hands;
      case 'bedding':
        return Icons.bed;
      case 'equipment':
        return Icons.build;
      default:
        return Icons.inventory_2;
    }
  }
}