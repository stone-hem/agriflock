import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/product_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/batch/shared/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchProductsTab extends StatefulWidget {
  final BatchModel batch;

  const BatchProductsTab({super.key, required this.batch});

  @override
  State<BatchProductsTab> createState() => _BatchProductsTabState();
}

class _BatchProductsTabState extends State<BatchProductsTab> {
  final BatchMgtRepository _repository = BatchMgtRepository();

  ProductDashboard? _dashboard;
  List<Product> _recentProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load dashboard stats and recent products in parallel
      final dashboardFuture = _repository.getProductDashboard(days: 1000000);
      final productsFuture = _repository.getProducts(batchId: widget.batch.id);

      final results = await Future.wait([dashboardFuture, productsFuture]);

      setState(() {
        _dashboard = results[0] as ProductDashboard;
        _recentProducts = (results[1] as List<Product>)
            .take(10) // Show only recent 10 products
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadProductData();
  }

  Future<void> _navigateToRecordProduct() async {
    final result = await context.push('/batches/${widget.batch.id}/record-product');

    // Refresh data if product was recorded successfully
    if (result == true) {
      _loadProductData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProductData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Summary Metrics
              if (_dashboard != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '${_dashboard!.totalEggs}',
                        label: 'Total Eggs',
                        color: Colors.orange.shade100,
                        icon: Icons.egg,
                        textColor: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        value: _dashboard!.averageDailyEggs > 0
                            ? '${_dashboard!.averageDailyEggs.toStringAsFixed(0)}'
                            : 'N/A',
                        label: 'Avg Daily Eggs',
                        color: Colors.amber.shade100,
                        icon: Icons.trending_up,
                        textColor: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '${_dashboard!.totalBirdsSold}',
                        label: 'Birds Sold',
                        color: Colors.red.shade100,
                        icon: Icons.agriculture,
                        textColor: Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(), // placeholder for future metrics
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Recent Collections
              _buildSection(
                title: 'Recent Collections',
                context: context,
                children: _recentProducts.isEmpty
                    ? [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products recorded yet',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the button below to record your first product',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
                    : _recentProducts.map((product) {
                  return _ActivityItem(
                    icon: _getProductIcon(product.productType),
                    title: _getProductTitle(product),
                    subtitle: _getProductSubtitle(product),
                    time: _formatDate(product.collectionDate),
                    color: _getProductColor(product.productType),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToRecordProduct,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        foregroundColor: Colors.white,
        label: const Text('Record Product'),
      ),
    );
  }

  IconData _getProductIcon(String productType) {
    switch (productType.toLowerCase()) {
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

  Color _getProductColor(String productType) {
    switch (productType.toLowerCase()) {
      case 'eggs':
        return Colors.orange;
      case 'meat':
        return Colors.red.shade600;
      case 'other':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getProductTitle(Product product) {
    switch (product.productType.toLowerCase()) {
      case 'eggs':
        return 'Eggs Collection';
      case 'meat':
        return 'Meat (Birds Sold)';
      case 'other':
        return 'Other Product';
      default:
        return 'Product Recorded';
    }
  }

  String _getProductSubtitle(Product product) {
    switch (product.productType.toLowerCase()) {
      case 'eggs':
        final good = (product.eggsCollected ?? 0) - (product.crackedEggs ?? 0);
        return '${product.eggsCollected ?? 0} eggs collected (${product.crackedEggs ?? 0} cracked, $good good)';
      case 'meat':
        if (product.weight != null && product.weight!.isNotEmpty) {
          return '${product.birdsSold ?? 0} birds sold, ${product.weight} kg total';
        }
        return '${product.birdsSold ?? 0} birds sold';
      case 'other':
        return '${product.quantity ?? "0"} units recorded';
      default:
        return 'Product recorded';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return 'Today, ${DateUtil.toReadableDate(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateUtil.toReadableDate(date);
    }
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_recentProducts.isNotEmpty)
              TextButton(
                onPressed: () => context.push('/products'),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}