import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/feeding_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/feeding_repo.dart';
import 'package:agriflock360/features/farmer/batch/shared/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchFeedTab extends StatefulWidget {
  final BatchModel batch;

  const BatchFeedTab({super.key, required this.batch});

  @override
  State<BatchFeedTab> createState() => _BatchFeedTabState();
}

class _BatchFeedTabState extends State<BatchFeedTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeedingRepository _repository = FeedingRepository();

  bool _isFabVisible = true;
  final Map<int, ScrollController> _scrollControllers = {};

  // State for each tab
  FeedDashboard? _dashboard;
  FeedingRecommendationsResponse? _recommendations;
  bool _isDashboardLoading = true;
  bool _isRecommendationsLoading = true;
  String? _dashboardError;
  String? _recommendationsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize scroll controllers
    for (int i = 0; i < _tabController.length; i++) {
      _scrollControllers[i] = ScrollController();
      _scrollControllers[i]!.addListener(() {
        _handleScroll(_scrollControllers[i]!);
      });
    }

    _tabController.addListener(_handleTabChange);

    // Load data for both tabs independently
    _loadDashboard();
    _loadRecommendations();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isDashboardLoading = true;
      _dashboardError = null;
    });

    try {
      final result = await _repository.getFeedDashboard(widget.batch.id);

      switch(result) {
        case Success<FeedDashboard>(data: final data):
          setState(() {
            _dashboard = data;
            _isDashboardLoading = false;
          });
          break;
        case Failure(message: final error, :final statusCode, :final response):
          setState(() {
            _dashboardError = error;
            _isDashboardLoading = false;
          });
          // Optionally handle the error using ApiErrorHandler
          // ApiErrorHandler.handle(error);
          break;
      }
    } finally {
      // Ensure loading state is reset even if there's an unexpected error
      if (_isDashboardLoading) {
        setState(() {
          _isDashboardLoading = false;
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isRecommendationsLoading = true;
      _recommendationsError = null;
    });

    try {
      final result = await _repository.getFeedingRecommendations(widget.batch.id);

      switch(result) {
        case Success<FeedingRecommendationsResponse>(data: final data):
          setState(() {
            _recommendations = data;
            _isRecommendationsLoading = false;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _recommendationsError = error;
            _isRecommendationsLoading = false;
          });
          // Optionally handle the error using ApiErrorHandler
          // ApiErrorHandler.handle(error);
          break;
      }
    } finally {
      // Ensure loading state is reset even if there's an unexpected error
      if (_isRecommendationsLoading) {
        setState(() {
          _isRecommendationsLoading = false;
        });
      }
    }
  }

  Future<void> _onRefreshDashboard() async {
    try {
      final result = await _repository.refreshFeedDashboard(widget.batch.id);

      switch(result) {
        case Success<FeedDashboard>(data: final data):
          setState(() {
            _dashboard = data;
            _dashboardError = null;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _dashboardError = error;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to refresh: $error')),
            );
          }
          break;
      }
    } catch (e) {
      // Handle any unexpected errors
      setState(() {
        _dashboardError = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    }
  }

  Future<void> _onRefreshRecommendations() async {
    try {
      final result = await _repository.refreshFeedingRecommendations(widget.batch.id);

      switch(result) {
        case Success<FeedingRecommendationsResponse>(data: final data):
          setState(() {
            _recommendations = data;
            _recommendationsError = null;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _recommendationsError = error;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to refresh: $error')),
            );
          }
          break;
      }
    } catch (e) {
      // Handle any unexpected errors
      setState(() {
        _recommendationsError = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    }
  }

  void _handleScroll(ScrollController controller) {
    if (controller.hasClients) {
      if (controller.position.pixels > 0 && _isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      } else if (controller.position.pixels <= 0 && !_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
  }

  void _handleTabChange() {
    final currentTab = _tabController.index;
    final currentController = _scrollControllers[currentTab];

    if (currentController != null && currentController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentController.position.pixels > 0 && _isFabVisible) {
          setState(() {
            _isFabVisible = false;
          });
        } else if (currentController.position.pixels <= 0 && !_isFabVisible) {
          setState(() {
            _isFabVisible = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feed Summary Cards
            _buildDashboardStats(),
            const SizedBox(height: 32),

            // Tabs
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(1),
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: [
                      _buildTabWithIcon(Icons.history, 'Recent Feedings'),
                      _buildTabWithIcon(Icons.schedule, 'Recommended Schedule'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRecentFeedingsTab(),
                        _buildRecommendedScheduleTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1 : 0,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await context.push('/batches/${widget.batch.id}/feed');
              // Refresh data if feeding was logged
              if (result == true) {
                _loadDashboard();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Log Feeding'),
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    if (_isDashboardLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_dashboardError != null || _dashboard == null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error loading dashboard', style: TextStyle(color: Colors.grey.shade600)),
            TextButton(
              onPressed: _loadDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${_dashboard!.dailyConsumptionKg}kg',
                label: 'Daily Consumption',
                color: Colors.orange.shade100,
                textColor: Colors.orange.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: '${_dashboard!.weeklyTotalKg}kg',
                label: 'Weekly Total',
                color: Colors.blue.shade100,
                textColor: Colors.blue.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${_dashboard!.avgPerBirdKg}kg',
                label: 'Avg per Bird',
                color: Colors.green.shade100,
                textColor: Colors.green.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: _dashboard!.fcrStatus,
                label: 'FCR',
                color: Colors.purple.shade100,
                textColor: Colors.purple.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentFeedingsTab() {
    return RefreshIndicator(
      onRefresh: _onRefreshDashboard,
      child: _isDashboardLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardError != null || _dashboard == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_dashboardError'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _dashboard!.recentFeedings.isEmpty
          ? Center(
        child: Text(
          'No recent feedings',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      )
          : ListView.builder(
        controller: _scrollControllers[0],
        itemCount: _dashboard!.recentFeedings.length,
        itemBuilder: (context, index) {
          final feeding = _dashboard!.recentFeedings[index];
          return _FeedingRecordItem(
            date: feeding.dayLabel,
            amount: '${feeding.amountKg}kg',
            type: '${feeding.date} at ${feeding.time}',
            efficiency: '${feeding.compliancePercentage}%',
          );
        },
      ),
    );
  }

  Widget _buildRecommendedScheduleTab() {
    return RefreshIndicator(
      onRefresh: _onRefreshRecommendations,
      child: _isRecommendationsLoading
          ? const Center(child: CircularProgressIndicator())
          : _recommendationsError != null || _recommendations == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_recommendationsError'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendations,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : ListView(
        controller: _scrollControllers[1],
        children: [
          // Current recommendation highlight
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current Stage: ${_recommendations!.currentRecommendation.stageName} (${_recommendations!.batchInfo.ageDays} days old)',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // All recommendations
          ..._recommendations!.allRecommendations.map((rec) {
            final isCurrent = rec.id == _recommendations!.currentRecommendation.id;
            return _RecommendedFeedingItem(
              stage: rec.stageName,
              feedType: rec.feedType,
              amount: '${double.parse(rec.quantityPerBirdPerDay) * 1000}g per bird/day',
              frequency: '${rec.timesPerDay} times daily',
              protein: '${rec.proteinPercentage}% CP',
              feedingTimes: rec.feedingTimes.slots,
              notes: rec.notes,
              isCurrent: isCurrent,
            );
          }).toList(),

          // Feeding Tips
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feeding Tips',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Provide fresh water at all times\n• Clean feeders regularly\n• Avoid sudden feed changes\n• Monitor feed consumption daily',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithIcon(IconData icon, String label) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _FeedingRecordItem extends StatelessWidget {
  final String date;
  final String amount;
  final String type;
  final String efficiency;

  const _FeedingRecordItem({
    required this.date,
    required this.amount,
    required this.type,
    required this.efficiency,
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
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant, size: 18, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  efficiency,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedFeedingItem extends StatelessWidget {
  final String stage;
  final String feedType;
  final String amount;
  final String frequency;
  final String protein;
  final List<String> feedingTimes;
  final String? notes;
  final bool isCurrent;

  const _RecommendedFeedingItem({
    required this.stage,
    required this.feedType,
    required this.amount,
    required this.frequency,
    required this.protein,
    required this.feedingTimes,
    this.notes,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? Colors.green.shade300 : Colors.grey.shade200,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isCurrent ? Colors.green : Colors.orange).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 18,
                  color: isCurrent ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          stage,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feedType,
                      style: TextStyle(
                        color: (isCurrent ? Colors.green : Colors.orange).shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Feeding times
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: feedingTimes
                .map((time) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _FeedInfoRow(
                  icon: Icons.scale,
                  label: 'Amount',
                  value: amount,
                ),
                const SizedBox(height: 6),
                _FeedInfoRow(
                  icon: Icons.schedule,
                  label: 'Frequency',
                  value: frequency,
                ),
                const SizedBox(height: 6),
                _FeedInfoRow(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Protein',
                  value: protein,
                ),
                if (notes != null) ...[
                  const SizedBox(height: 6),
                  _FeedInfoRow(
                    icon: Icons.note,
                    label: 'Notes',
                    value: notes!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FeedInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}