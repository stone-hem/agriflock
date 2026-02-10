import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/vet/models/my_order_list_item.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/date_util.dart';

class MyVetOrdersScreen extends StatefulWidget {
  const MyVetOrdersScreen({
    super.key,
  });

  @override
  State<MyVetOrdersScreen> createState() => _MyVetOrdersScreenState();
}

class _MyVetOrdersScreenState extends State<MyVetOrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final VetFarmerRepository _vetRepository = VetFarmerRepository();

  List<MyOrderListItem> _vetOrders = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;


  @override
  void initState() {
    super.initState();
    _loadVetOrders();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMore && !_isLoadingMore) {
          _loadMoreVetOrders();
        }
      }
    });
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
          break;
        case Failure(message: final error, :final statusCode, :final response):
          setState(() {
            _hasError = true;
            _errorMessage = error;
            _isLoading = false;
          });
          break;
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

    setState(() {
      _isLoadingMore = true;
    });

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
          break;
        case Failure():
          setState(() {
            _isLoadingMore = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshVetOrders() async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Refreshed ${data.length} orders'),
              backgroundColor: Colors.green,
            ),
          );
          break;
        case Failure(message: final error):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Refresh failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refresh error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelOrder(MyOrderListItem order) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performCancelOrder(order);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCancelOrder(MyOrderListItem order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
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
      final result = await _vetRepository.cancelVetOrder(
        order.id,
        'Cancelled by farmer',
      );

      Navigator.pop(context); // Close loading dialog

      switch (result) {
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ${order.orderNumber} cancelled'),
              backgroundColor: Colors.green,
            ),
          );
          await _refreshVetOrders();
          break;
        case Failure(message: final error):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel: $error'),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'REVIEWED':
        return Colors.blue;
      case 'SCHEDULED':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending Review';
      case 'REVIEWED':
        return 'Reviewed';
      case 'SCHEDULED':
        return 'Scheduled';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Helper to get first service name
  String _getFirstServiceName(MyOrderListItem order) {
    if (order.services.isNotEmpty) {
      return order.services.first.name;
    } else if (order.serviceCosts.isNotEmpty) {
      return order.serviceCosts.first.serviceName;
    }
    return 'Service';
  }

  // Helper to get first service code
  String _getFirstServiceCode(MyOrderListItem order) {
    if (order.services.isNotEmpty) {
      return order.services.first.code;
    } else if (order.serviceCosts.isNotEmpty) {
      return order.serviceCosts.first.serviceCode;
    }
    return 'SVC';
  }

  // Helper to get house and batch info
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

  // Helper to get bird type info
  String? _getBirdTypeInfo(MyOrderListItem order) {
    return order.birdTypeName ?? (order.firstBatch?.birdTypeName);
  }

  Widget _buildOrderCard(MyOrderListItem order) {
    final birdType = _getBirdTypeInfo(order);
    final vetSpecialization = order.vetSpecialization.isNotEmpty
        ? order.vetSpecialization.first
        : 'General';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFirstServiceName(order),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getFirstServiceCode(order)} • Order: ${order.orderNumber}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(order.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vet Info with Specialization
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.vetName,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        vetSpecialization,
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date & Time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  DateUtil.toMMDDYYYY(order.preferredDate),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  order.preferredTime.substring(0, 5),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Farm Info with Bird Type
            Row(
              children: [
                Icon(Icons.home_work, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getHouseBatchInfo(order),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      if (birdType != null)
                        Text(
                          birdType,
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Multiple Services Indicator
            if (order.services.length > 1 || order.serviceCosts.length > 1)
              Row(
                children: [
                  Icon(Icons.list, size: 16, color: Colors.purple.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${order.services.length + order.serviceCosts.length} services',
                      style: TextStyle(
                        color: Colors.purple.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Cost and Actions
            Row(
              children: [
                Icon(Icons.monetization_on, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'KES ${order.totalEstimatedCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context.push('/my-order-tracking', extra: order);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Track'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your vet orders...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadVetOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 96,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          const Text(
            'No Vet Orders Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'You don\'t have any  orders, you haven\'t placed any vet orders yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_vetOrders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _vetOrders.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _vetOrders.length) {
          return _buildLoadMoreIndicator();
        }
        return _buildOrderCard(_vetOrders[index]);
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Vet Orders'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVetOrders,
        child: Column(
          children: [
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
}