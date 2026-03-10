import 'package:agriflock/app_routes.dart';
import 'package:agriflock/core/utils/date_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:agriflock/core/widgets/search_input.dart';
import 'package:agriflock/features/farmer/vet/models/completed_orders_model.dart';
import 'package:agriflock/features/farmer/vet/models/my_order_list_item.dart';
import 'package:agriflock/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore_for_file: deprecated_member_use

// ignore_for_file: deprecated_member_use

class MyVetOrdersCombinedScreen extends StatefulWidget {
  final int initialTab;

  const MyVetOrdersCombinedScreen({super.key, this.initialTab = 0});

  @override
  State<MyVetOrdersCombinedScreen> createState() =>
      _MyVetOrdersCombinedScreenState();
}

class _MyVetOrdersCombinedScreenState
    extends State<MyVetOrdersCombinedScreen> {
  bool _isNoSubscription = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    try {
      final state = await SecureStorage().getSubscriptionState();
      if (mounted) {
        setState(() => _isNoSubscription =
            state == 'no_subscription_plan' ||
            state == 'expired_subscription_plan');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/logos/Logo_0725.png',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.green,
                  child: const Icon(Icons.image, size: 24, color: Colors.white54),
                ),
              ),
              const SizedBox(width: 8),
              const Text('My Vet Orders'),
            ],
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: 'Active Orders'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        bottomNavigationBar: _isNoSubscription
            ? GestureDetector(
                onTap: () => context.push(AppRoutes.subscriptionPlans),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: Colors.orange.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium,
                          color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You need a plan to manage your farms and batches. '
                          'Tap to subscribe and unlock full access.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 13, color: Colors.orange.shade700),
                    ],
                  ),
                ),
              )
            : null,
        body: const TabBarView(
          children: [
            _ActiveOrdersTab(),
            _CompletedOrdersTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active Orders Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveOrdersTab extends StatefulWidget {
  const _ActiveOrdersTab();

  @override
  State<_ActiveOrdersTab> createState() => _ActiveOrdersTabState();
}

class _ActiveOrdersTabState extends State<_ActiveOrdersTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final VetFarmerRepository _vetRepository = VetFarmerRepository();

  List<MyOrderListItem> _vetOrders = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadVetOrders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMore && !_isLoadingMore) _loadMoreVetOrders();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadVetOrders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final result = await _vetRepository.getFarmerVetOrders(
        page: 1,
        limit: _itemsPerPage,
      );
      switch (result) {
        case Success<List<MyOrderListItem>>(data: final data):
          setState(() {
            _vetOrders = data;
            _isLoading = false;
            _currentPage = 1;
            _hasMore = data.length >= _itemsPerPage;
          });
        case Failure():
          setState(() {
            _hasError = true;
            _errorMessage = result.message;
            _isLoading = false;
          });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreVetOrders() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final result = await _vetRepository.getFarmerVetOrders(
        page: _currentPage + 1,
        limit: _itemsPerPage,
      );
      switch (result) {
        case Success<List<MyOrderListItem>>(data: final data):
          setState(() {
            _vetOrders.addAll(data);
            _currentPage++;
            _hasMore = data.length >= _itemsPerPage;
            _isLoadingMore = false;
          });
        case Failure():
          setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    try {
      final result = await _vetRepository.refreshFarmerVetOrders(
        page: 1,
        limit: _itemsPerPage,
      );
      switch (result) {
        case Success<List<MyOrderListItem>>(data: final data):
          setState(() {
            _vetOrders = data;
            _currentPage = 1;
            _hasMore = data.length >= _itemsPerPage;
          });
        case Failure():
          break;
      }
    } catch (_) {}
  }

  Future<void> _cancelOrder(MyOrderListItem order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
            'Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, Cancel')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Cancelling order...'),
          ],
        ),
      ),
    );

    try {
      final result =
          await _vetRepository.cancelVetOrder(order.id, 'Cancelled by farmer');
      if (!mounted) return;
      Navigator.pop(context);

      switch (result) {
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Order ${order.orderNumber} cancelled'),
            backgroundColor: Colors.green,
          ));
          await _refresh();
        case Failure(message: final err):
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to cancel: $err'),
            backgroundColor: Colors.red,
          ));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'REVIEWED':
        return Colors.blue;
      case 'SCHEDULED':
        return Colors.purple;
      case 'ACCEPTED':
        return Colors.teal;
      case 'IN_PROGRESS':
        return Colors.indigo;
      case 'PAYMENT_PENDING':
        return Colors.amber.shade700;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending Review';
      case 'REVIEWED':
        return 'Reviewed';
      case 'SCHEDULED':
        return 'Scheduled';
      case 'ACCEPTED':
        return 'Accepted';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'PAYMENT_PENDING':
        return 'Payment Pending';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getFirstServiceName(MyOrderListItem order) {
    if (order.services.isNotEmpty) return order.services.first.name;
    if (order.serviceCosts.isNotEmpty) return order.serviceCosts.first.serviceName;
    return 'Service';
  }

  String _getFirstServiceCode(MyOrderListItem order) {
    if (order.services.isNotEmpty) return order.services.first.code;
    if (order.serviceCosts.isNotEmpty) return order.serviceCosts.first.serviceCode;
    return 'SVC';
  }

  String _getHouseBatchInfo(MyOrderListItem order) {
    final house = order.firstHouse;
    final batch = order.firstBatch;
    if (house != null && batch != null) {
      return '${house.name} • ${batch.name} (${order.birdsCount} birds)';
    } else if (house != null) {
      return '${house.name} (${order.birdsCount} birds)';
    } else if (batch != null) {
      return '${batch.name} (${order.birdsCount} birds)';
    }
    return '${order.birdsCount} birds';
  }

  Widget _buildOrderCard(MyOrderListItem order) {
    final birdType = order.birdTypeName ?? order.firstBatch?.birdTypeName;
    final vetSpec = order.vetSpecialization.isNotEmpty
        ? order.vetSpecialization.first
        : 'General';
    final isToday = DateUtil.isToday(order.preferredDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getFirstServiceName(order),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                          '${_getFirstServiceCode(order)} • Order: ${order.orderNumber}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(order.status)),
                  ),
                  child: Text(
                    _statusText(order.status),
                    style: TextStyle(
                        color: _statusColor(order.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (order.serviceCosts.isNotEmpty) ...[
              const Text('Services:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              ...order.serviceCosts.map((svc) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text('• ${svc.serviceName}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700))),
                        Text('KES ${svc.cost.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.vetName,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 14)),
                      Text(vetSpec,
                          style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 12,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(DateUtil.toMMDDYYYY(order.preferredDate),
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(order.preferredTime.substring(0, 5),
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text('Today',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.home_work, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getHouseBatchInfo(order),
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 14)),
                      if (birdType != null)
                        Text(birdType,
                            style: TextStyle(
                                color: Colors.green.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Estimated Cost',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('KES ${order.totalEstimatedCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
                const Spacer(),
                if (order.status == 'PENDING' || order.status == 'REVIEWED')
                  OutlinedButton(
                    onPressed: () => _cancelOrder(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                if (order.status == 'PAYMENT_PENDING') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/vet-service-payment', extra: {
                      'orderId': order.id,
                      'orderNumber': order.orderNumber,
                      'vetName': order.vetName,
                      'amount': order.totalEstimatedCost,
                      'currency': 'KES',
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Pay'),
                  ),
                ],
                if (order.status == 'ACCEPTED' || order.status == 'IN_PROGRESS') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isToday
                        ? () => context.push('/my-order-tracking', extra: order)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Track'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if ((order.status == 'ACCEPTED' || order.status == 'IN_PROGRESS') && !isToday)
              Text('* Tracking is only available on the scheduled day',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your vet orders...'),
        ],
      ));
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Failed to load orders',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(_errorMessage ?? 'An unknown error occurred',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVetOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      );
    }
    if (_vetOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 96, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text('No Active Orders',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text("You don't have any active vet orders yet.",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _vetOrders.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _vetOrders.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: _isLoadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink()),
            );
          }
          return _buildOrderCard(_vetOrders[index]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Completed Orders Tab
// ─────────────────────────────────────────────────────────────────────────────

class _CompletedOrdersTab extends StatefulWidget {
  const _CompletedOrdersTab();

  @override
  State<_CompletedOrdersTab> createState() => _CompletedOrdersTabState();
}

class _CompletedOrdersTabState extends State<_CompletedOrdersTab>
    with AutomaticKeepAliveClientMixin {
  final VetFarmerRepository _repository = VetFarmerRepository();

  List<CompletedOrder> _completedOrders = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _errorMessage = '';
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCompletedOrders();
  }

  Future<void> _loadCompletedOrders({bool refresh = false}) async {
    if (refresh) {
      setState(() => _isRefreshing = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final result = await _repository.getCompletedOrders(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      switch (result) {
        case Success<List<CompletedOrder>>(data: final response):
          setState(() {
            _completedOrders = response;
            _isLoading = false;
            _isRefreshing = false;
            _errorMessage = '';
          });
        case Failure<List<CompletedOrder>>():
          setState(() {
            _errorMessage = result.message;
            _isLoading = false;
            _isRefreshing = false;
          });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load completed orders';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  List<CompletedOrder> get _filteredOrders {
    switch (_selectedFilter) {
      case 'needs_payment':
        return _completedOrders.where((o) => !o.isPaid).toList();
      case 'paid_rated':
        return _completedOrders.where((o) => o.isPaid).toList();
      default:
        return _completedOrders;
    }
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
            Text('Total Amount:',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            Text(
              '${order.currency} ${order.totalEstimatedCost.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildFeeBreakdown(order),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/vet-service-payment', extra: {
                'orderId': order.id,
                'orderNumber': order.orderNumber,
                'vetName': order.vetName,
                'amount': order.totalEstimatedCost,
                'currency': order.currency,
              });
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
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rate Your Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(order.vetName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('How would you rate this service?',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () =>
                          setDialogState(() => rating = (index + 1).toDouble()),
                      icon: Icon(
                        Icons.star,
                        size: 30,
                        color:
                            index < rating ? Colors.amber : Colors.grey.shade400,
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
                      color: rating == 0 ? Colors.grey : Colors.amber.shade800),
                ),
                const SizedBox(height: 24),
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
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: rating == 0
                  ? null
                  : () {
                      _submitRating(order, rating, commentController.text);
                      Navigator.pop(context);
                    },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  static const _disputeReasons = [
    ('vet_no_show', 'Vet did not show up'),
    ('poor_service_quality', 'Poor service quality'),
    ('payment_not_received', 'Payment not received'),
    ('incorrect_charges', 'Incorrect charges'),
    ('other', 'Other'),
  ];

  void _showDisputeDialog(CompletedOrder order) {
    String? selectedReasonCode;
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('File a Dispute'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order: ${order.orderNumber}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
                Text('Vet: ${order.vetName}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 14),
                const Text('Reason',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ..._disputeReasons.map((r) => RadioListTile<String>(
                      value: r.$1,
                      groupValue: selectedReasonCode,
                      title: Text(r.$2, style: const TextStyle(fontSize: 13)),
                      onChanged: (v) => setD(() => selectedReasonCode = v),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    )),
                const SizedBox(height: 12),
                const Text('Description',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    hintText:
                        'Describe the issue in detail (e.g. vet did not arrive at scheduled time)…',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedReasonCode == null ||
                      descController.text.trim().isEmpty
                  ? null
                  : () {
                      final reason = selectedReasonCode!;
                      final description = descController.text.trim();
                      Navigator.pop(ctx);
                      _submitDispute(order, reason, description);
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Submit Dispute'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitDispute(
      CompletedOrder order, String reason, String description) async {
    final loadingCtrl = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Submitting dispute…'),
          ],
        ),
      ),
    );

    final result = await _repository.submitDispute(
      orderId: order.id,
      reason: reason,
      description: description,
    );

    if (!mounted) return;
    Navigator.pop(context); // close loading dialog

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dispute submitted. We will review it shortly.'),
            backgroundColor: Colors.orange.shade700,
            action: SnackBarAction(
              label: 'View Disputes',
              textColor: Colors.white,
              onPressed: () => context.push('/my-disputes'),
            ),
          ),
        );
      },
      failure: (msg, _, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      },
    );
  }

  Future<void> _submitRating(
      CompletedOrder order, double rating, String comment) async {
    final result = await _repository.rateVetOrder(
      vetId: order.vetId,
      orderId: order.id,
      rating: rating,
      reviewComment: comment.isNotEmpty ? comment : null,
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: Colors.green),
        );
      },
      failure: (message, _, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      },
    );
  }

  Widget _buildFeeBreakdown(CompletedOrder order) {
    return Column(
      children: [
        _feeItem('Service Fee', order.serviceFee),
        _feeItem('Mileage Fee', order.mileageFee),
        if (order.prioritySurcharge > 0)
          _feeItem('Priority Surcharge', order.prioritySurcharge),
        const Divider(),
        _feeItem('Total Estimated', order.totalEstimatedCost, isTotal: true),
      ],
    );
  }

  Widget _feeItem(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Colors.green : null)),
        ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.vetName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (order.vetSpecialization.isNotEmpty)
                        Text(
                          order.vetSpecialization.join(', '),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text('Completed',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Order: ${order.orderNumber}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text('Completed on ${order.completedAt.split('T')[0]}',
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 14)),
              ],
            ),
            if (order.houses.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.home_work, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(order.houses.map((h) => h.name).join(', '),
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 14)),
                  ),
                ],
              ),
            ],
            if (order.services.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Services: ${order.services.map((s) => s.name).join(', ')}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.monetization_on,
                    size: 16, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                    'Total: ${order.currency} ${order.totalEstimatedCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showRatingDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 18),
                        SizedBox(width: 8),
                        Text('Rate'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showDisputeDialog(order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 16),
                      SizedBox(width: 4),
                      Text('Report'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filteredOrders = _filteredOrders;

    return RefreshIndicator(
      onRefresh: () => _loadCompletedOrders(refresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchInput(
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
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      if (value.isEmpty) _loadCompletedOrders(refresh: true);
                    },
                    onSubmitted: (_) => _loadCompletedOrders(refresh: true),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          value: _completedOrders.length.toString(),
                          label: 'Total',
                          icon: Icons.medical_services,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
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
                  const SizedBox(height: 12),
                  // Disputes shortcut
                  OutlinedButton.icon(
                    onPressed: () => context.push('/my-disputes'),
                    icon: const Icon(Icons.gavel_outlined, size: 16),
                    label: const Text('View My Disputes'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (_isLoading && !_isRefreshing)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage.isNotEmpty && _completedOrders.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(_errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadCompletedOrders(refresh: true),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredOrders.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('No Completed Orders',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No orders found for "$_searchQuery"'
                          : 'Your completed veterinary services will appear here',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildOrderCard(filteredOrders[index]),
                  childCount: filteredOrders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard({
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
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String filterValue, Color color) {
    final selected = _selectedFilter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = filterValue),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      labelStyle: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.bold),
    );
  }
}
