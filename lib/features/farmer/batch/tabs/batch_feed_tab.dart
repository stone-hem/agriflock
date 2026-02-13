import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/feeding_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/feeding_repo.dart';
import 'package:agriflock360/features/farmer/batch/shared/stat_card.dart';
import 'package:agriflock360/features/farmer/batch/tabs/widgets/feeding_record_item.dart';
import 'package:agriflock360/features/farmer/batch/tabs/widgets/recommended_feeding_tem.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchFeedTab extends StatefulWidget {
  final BatchModel batch;

  const BatchFeedTab({super.key, required this.batch});

  @override
  State<BatchFeedTab> createState() => _BatchFeedTabState();
}

class _BatchFeedTabState extends State<BatchFeedTab> {
  final FeedingRepository _repository = FeedingRepository();
  final ScrollController _scrollController = ScrollController();

  bool _isFabVisible = true;
  bool _isRecommendationsExpanded = false;
  bool _isRecentFeedingsExpanded = false;

  // State for dashboard (always loaded for stats)
  FeedDashboard? _dashboard;
  bool _isDashboardLoading = true;
  String? _dashboardError;

  // State for recommendations (lazy loaded)
  FeedingRecommendationsResponse? _recommendations;
  bool _isRecommendationsLoading = false;
  String? _recommendationsError;
  bool _hasLoadedRecommendations = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isDashboardLoading = true;
      _dashboardError = null;
    });

    try {
      final result = await _repository.getFeedDashboard(widget.batch.id);

      switch (result) {
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
          break;
      }
    } finally {
      if (_isDashboardLoading) {
        setState(() {
          _isDashboardLoading = false;
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    if (_hasLoadedRecommendations && _recommendations != null) {
      return; // Already loaded
    }

    setState(() {
      _isRecommendationsLoading = true;
      _recommendationsError = null;
    });

    try {
      final result =
      await _repository.getFeedingRecommendations(widget.batch.id);

      switch (result) {
        case Success<FeedingRecommendationsResponse>(data: final data):
          setState(() {
            _recommendations = data;
            _isRecommendationsLoading = false;
            _hasLoadedRecommendations = true;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _recommendationsError = error;
            _isRecommendationsLoading = false;
          });
          break;
      }
    } finally {
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

      switch (result) {
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
      final result =
      await _repository.refreshFeedingRecommendations(widget.batch.id);

      switch (result) {
        case Success<FeedingRecommendationsResponse>(data: final data):
          setState(() {
            _recommendations = data;
            _recommendationsError = null;
            _hasLoadedRecommendations = true;
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

  void _handleScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.position.pixels > 0 && _isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      } else if (_scrollController.position.pixels <= 0 && !_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
  }

  void _toggleRecommendations() {
    setState(() {
      _isRecommendationsExpanded = !_isRecommendationsExpanded;
    });

    if (_isRecommendationsExpanded && !_hasLoadedRecommendations) {
      _loadRecommendations();
    }
  }

  void _toggleRecentFeedings() {
    setState(() {
      _isRecentFeedingsExpanded = !_isRecentFeedingsExpanded;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboard();
          if (_hasLoadedRecommendations) {
            await _onRefreshRecommendations();
          }
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Feed Summary Cards
                _buildDashboardStats(),
                const SizedBox(height: 32),

                // Expandable Sections
                _buildRecommendedScheduleSection(),
                const SizedBox(height: 16),
                _buildRecentFeedingsSection(),
                const SizedBox(height: 80), // Extra padding for FAB
              ],
            ),
          ),
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
              final result =
              await context.push('/batches/${widget.batch.id}/feed');
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
            Text('Error loading dashboard',
                style: TextStyle(color: Colors.grey.shade600)),
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

  Widget _buildRecommendedScheduleSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleRecommendations,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.blue.shade700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended Feeding Schedule',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isRecommendationsExpanded
                              ? 'Tap to collapse'
                              : 'Tap to view feeding guidelines',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isRecommendationsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: _buildRecommendedScheduleContent(),
            ),
            crossFadeState: _isRecommendationsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedScheduleContent() {
    if (_isRecommendationsLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommendationsError != null || _recommendations == null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _recommendationsError ?? 'Failed to load recommendations',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRecommendations,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current recommendation highlight
          Container(
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
          const SizedBox(height: 16),

          // All recommendations
          ..._recommendations!.allRecommendations.map((rec) {
            final isCurrent =
                rec.id == _recommendations!.currentRecommendation.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RecommendedFeedingItem(
                stage: rec.stageName,
                feedType: rec.feedType,
                amount:
                '${double.parse(rec.quantityPerBirdPerDay) * 1000}g per bird/day',
                frequency: '${rec.timesPerDay} times daily',
                protein: '${rec.proteinPercentage}% CP',
                feedingTimes: rec.feedingTimes.slots,
                notes: rec.notes,
                isCurrent: isCurrent,
              ),
            );
          }).toList(),

          // Feeding Tips
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }

  Widget _buildRecentFeedingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleRecentFeedings,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.history,
                      color: Colors.orange.shade700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Feedings',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isRecentFeedingsExpanded
                              ? 'Tap to collapse'
                              : 'Tap to view feeding history',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isRecentFeedingsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: _buildRecentFeedingsContent(),
            ),
            crossFadeState: _isRecentFeedingsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFeedingsContent() {
    if (_isDashboardLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_dashboardError != null || _dashboard == null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _dashboardError ?? 'Failed to load recent feedings',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboard,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_dashboard!.recentFeedings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.feed_outlined,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No recent feedings',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: _dashboard!.recentFeedings.map((feeding) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FeedingRecordItem(
              date: feeding.dayLabel,
              amount: '${feeding.amountKg}kg',
              type: '${feeding.date} at ${feeding.time}',
              efficiency: '${feeding.compliancePercentage}%',
            ),
          );
        }).toList(),
      ),
    );
  }
}