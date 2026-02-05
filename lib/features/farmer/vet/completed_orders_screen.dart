import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/vet/models/completed_orders_model.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:agriflock360/core/utils/log_util.dart';

class CompletedOrdersScreen extends StatefulWidget {
  const CompletedOrdersScreen({super.key});

  @override
  State<CompletedOrdersScreen> createState() => _CompletedOrdersScreenState();
}

class _CompletedOrdersScreenState extends State<CompletedOrdersScreen> {
  final VetFarmerRepository _repository = VetFarmerRepository();

  late List<CompletedOrder> _completedOrders = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _errorMessage = '';

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = true;

  // Filter states
  String _selectedFilter = 'all'; // 'all', 'needs_payment', 'needs_rating', 'paid_rated'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCompletedOrders();
  }

  Future<void> _loadCompletedOrders({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isRefreshing = true;
        _currentPage = 1;
        _hasMoreData = true;
      });
    } else {
      if (!_hasMoreData) return;
      setState(() => _isLoading = true);
    }

    try {
      final result = await _repository.getCompletedOrders(
        page: _currentPage,
        limit: 10,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      switch(result) {
        case Success<CompletedOrdersResponse>(data:final response):
          setState(() {
            if (refresh || _currentPage == 1) {
              _completedOrders = response.orders;
            } else {
              _completedOrders.addAll(response.orders);
            }

            if (response.meta != null) {
              _totalPages = response.meta!.totalPages;
              _hasMoreData = _currentPage < _totalPages;
            }

            _isLoading = false;
            _isRefreshing = false;
            _errorMessage = '';
          });
        case Failure<CompletedOrdersResponse>():
          setState(() {
            _errorMessage = result.message;
            _isLoading = false;
            _isRefreshing = false;
          });

          if (!refresh) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
      }


    } finally {
      if (!refresh) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load completed orders'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _currentPage++;
    });

    await _loadCompletedOrders();
  }

  void _showPaymentDialog(CompletedOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vet: ${order.vetName}'),
            const SizedBox(height: 16),
            Text(
              'Total Amount:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            Text(
              '${order.currency} ${order.totalEstimatedCost.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildFeeBreakdown(order),
            const SizedBox(height: 16),
            const Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodItem(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              subtitle: 'Pay with Visa, MasterCard, or Amex',
            ),
            _buildPaymentMethodItem(
              icon: Icons.mobile_friendly,
              title: 'Mobile Money',
              subtitle: 'M-Pesa, Airtel Money, etc.',
            ),
            _buildPaymentMethodItem(
              icon: Icons.account_balance,
              title: 'Bank Transfer',
              subtitle: 'Direct bank transfer',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _processPayment(order);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(CompletedOrder order) {
    double rating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Rate Your Experience'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.vetName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'How would you rate this service?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            rating = (index + 1).toDouble();
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          size: 30,
                          color: index < rating
                              ? Colors.amber
                              : Colors.grey.shade400,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    rating == 0
                        ? 'Tap a star to rate'
                        : '${rating.toStringAsFixed(1)} Stars',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: rating == 0 ? Colors.grey : Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Comment
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Additional Comments (Optional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your feedback helps improve our service and helps other farmers.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: rating == 0
                    ? null
                    : () {
                  _submitRating(order, rating, commentController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Submit Rating'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: () {},
      ),
    );
  }

  Widget _buildFeeBreakdown(CompletedOrder order) {
    return Column(
      children: [
        _buildFeeItem('Service Fee', order.serviceFee),
        _buildFeeItem('Mileage Fee', order.mileageFee),
        if (order.prioritySurcharge > 0)
          _buildFeeItem('Priority Surcharge', order.prioritySurcharge),
        const Divider(),
        _buildFeeItem('Total Estimated', order.totalEstimatedCost, isTotal: true),
      ],
    );
  }

  Widget _buildFeeItem(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(CompletedOrder order) {
    // TODO: Implement actual payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment of ${order.currency} ${order.totalEstimatedCost.toStringAsFixed(2)} completed!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Simulate updating the order
    setState(() {
      final index = _completedOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _completedOrders[index] = order;
      }
    });
  }

  void _submitRating(CompletedOrder order, double rating, String comment) {
    // TODO: Implement actual rating submission to API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildOrderCard(CompletedOrder order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.vetName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (order.vetSpecialization.isNotEmpty)
                        Text(
                          order.vetSpecialization.join(', '),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order Number
            Text(
              'Order: ${order.orderNumber}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Completed Date
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completed on ${order.completedAt.split('T')[0]}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // House & Batch
            if (order.houses.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home_work, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.houses.map((h) => h.name).join(', '),
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),

            // Services
            if (order.services.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services: ${order.services.map((s) => s.name).join(', ')}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
              ),

            // Cost
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total: ${order.currency} ${order.totalEstimatedCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment Status
            Row(
              children: [
                Icon(
                  order.isPaid ? Icons.payment : Icons.payment_outlined,
                  size: 16,
                  color: order.isPaid ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  order.isPaid ? 'Payment Complete' : 'Payment Pending',
                  style: TextStyle(
                    color: order.isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                if (!order.isPaid)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showPaymentDialog(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, size: 18),
                          SizedBox(width: 8),
                          Text('Pay Now'),
                        ],
                      ),
                    ),
                  ),
                if (!order.isPaid)
                  const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showRatingDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 18),
                        SizedBox(width: 8),
                        Text('Rate Service'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<CompletedOrder> get _filteredOrders {
    switch (_selectedFilter) {
      case 'needs_payment':
        return _completedOrders.where((order) => !order.isPaid).toList();
      case 'paid_rated':
        return _completedOrders.where((order) => order.isPaid).toList();
      default:
        return _completedOrders;
    }
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Unable to Load Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadCompletedOrders(refresh: true),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Completed Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No orders found for "$_searchQuery"'
                : 'Your completed veterinary services will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: () {
                  setState(() => _searchQuery = '');
                  _loadCompletedOrders(refresh: true);
                },
                child: const Text('Clear Search'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;

    return Scaffold(
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
            const Text('Agriflock 360'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: RefreshIndicator(
        onRefresh: () => _loadCompletedOrders(refresh: true),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.amber.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Completed Services',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Review completed veterinary services, make payments, and rate your experience',
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

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search orders...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _searchQuery = '');
                      _loadCompletedOrders(refresh: true);
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  if (value.isEmpty) {
                    _loadCompletedOrders(refresh: true);
                  }
                },
                onSubmitted: (value) {
                  _loadCompletedOrders(refresh: true);
                },
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      value: _completedOrders.length.toString(),
                      label: 'Total Services',
                      icon: Icons.medical_services,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      value: _completedOrders
                          .where((o) => o.isPaid)
                          .length
                          .toString(),
                      label: 'Paid',
                      icon: Icons.payment,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All Orders',
                      selected: _selectedFilter == 'all',
                      onTap: () {
                        setState(() => _selectedFilter = 'all');
                      },
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Needs Payment',
                      selected: _selectedFilter == 'needs_payment',
                      onTap: () {
                        setState(() => _selectedFilter = 'needs_payment');
                      },
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Paid',
                      selected: _selectedFilter == 'paid_rated',
                      onTap: () {
                        setState(() => _selectedFilter = 'paid_rated');
                      },
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Orders List
              Text(
                'Completed Orders',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${filteredOrders.length} service${filteredOrders.length == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),

              if (_isLoading && !_isRefreshing)
                _buildLoadingIndicator()
              else if (_errorMessage.isNotEmpty && _completedOrders.isEmpty)
                _buildErrorState()
              else if (filteredOrders.isEmpty)
                  _buildEmptyState()
                else
                  Column(
                    children: [
                      ...filteredOrders.map(_buildOrderCard),
                      if (_hasMoreData && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                            onPressed: _loadMoreOrders,
                            child: const Text('Load More Orders'),
                          ),
                        ),
                      if (_isLoading && _completedOrders.isNotEmpty)
                        _buildLoadingIndicator(),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      labelStyle: TextStyle(
        color: selected ? Colors.white : color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}