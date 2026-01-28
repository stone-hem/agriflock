import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/product_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/product_repo.dart';
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
  final ProductRepo _repository = ProductRepo();

  ProductDashboard? _dashboard;
  List<Product> _recentProducts = [];
  bool _isLoading = true;
  bool _loadingDashboard = false;
  bool _loadingProducts = false;
  String? _dashboardError;
  String? _productsError;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    setState(() {
      _isLoading = true;
      _dashboardError = null;
      _productsError = null;
      _loadingDashboard = true;
      _loadingProducts = true;
    });

    // Load dashboard stats and recent products separately
    await Future.wait([
      _loadDashboardData(),
      _loadProductsData(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final result = await _repository.getProductDashboard(days: 1000000);

      switch (result) {
        case Success<ProductDashboard>(data: final data):
          setState(() {
            _dashboard = data;
            _dashboardError = null;
          });
        case Failure<ProductDashboard>(message: final message):
          setState(() {
            _dashboard = null;
            _dashboardError = message;
          });
      }
    } finally {
      setState(() {
        _loadingDashboard = false;
      });
    }
  }

  Future<void> _loadProductsData() async {
    try {
      final result = await _repository.getProducts(batchId: widget.batch.id);

      switch (result) {
        case Success<List<Product>>(data: final data):
          setState(() {
            _recentProducts = data.take(10).toList();
            _productsError = null;
          });
        case Failure<List<Product>>(message: final message):
          setState(() {
            _recentProducts = [];
            _productsError = message;
          });
      }
    } finally {
      setState(() {
        _loadingProducts = false;
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

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to load data',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade800,
              minimumSize: const Size(double.infinity, 36),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
              // Summary Metrics Section
              _buildSection(
                title: 'Product Summary',
                context: context,
                isLoading: _loadingDashboard,
                error: _dashboardError,
                onRetry: _loadDashboardData,
                children: [
                  if (_dashboardError != null)
                    _buildErrorWidget(_dashboardError!, _loadDashboardData)
                  else if (_dashboard != null) ...[
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
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Recent Collections Section
              _buildSection(
                title: 'Recent Collections',
                context: context,
                isLoading: _loadingProducts,
                error: _productsError,
                onRetry: _loadProductsData,
                children: [
                  if (_productsError != null)
                    _buildErrorWidget(_productsError!, _loadProductsData)
                  else if (_recentProducts.isEmpty)
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
                    )
                  else
                    ..._recentProducts.map((product) {
                      return _ActivityItem(
                        icon: _getProductIcon(product.productType),
                        title: _getProductTitle(product),
                        subtitle: _getProductSubtitle(product),
                        time: _formatDate(product.collectionDate),
                        color: _getProductColor(product.productType),
                      );
                    }).toList(),
                ],
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
    required bool isLoading,
    required String? error,
    required VoidCallback onRetry,
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
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          Container(
            padding: const EdgeInsets.all(20),
            child: const Center(child: CircularProgressIndicator()),
          )
        else
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
              color: color.withAlpha(40),
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