import 'package:agriflock360/features/farmer/more/models/activity_model.dart';
import 'package:agriflock360/features/farmer/more/repo/activity_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/result.dart';

class RecentActivityScreen extends StatefulWidget {
  const RecentActivityScreen({super.key});

  @override
  State<RecentActivityScreen> createState() => _RecentActivityScreenState();
}

class _RecentActivityScreenState extends State<RecentActivityScreen> {
  final ActivityRepository _repository = ActivityRepository();

  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalActivities = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities({bool loadMore = false}) async {
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
      final result = await _repository.getActivities(
        page: loadMore ? _currentPage + 1 : 1,
        limit: 20,
      );

      switch (result) {
        case Success<ActivityResponse>(data: final data):
          setState(() {
            if (loadMore) {
              _activities.addAll(data.activities);
              _currentPage++;
            } else {
              _activities = data.activities;
              _currentPage = data.page;
            }
            _hasMore = data.hasMore;
            _totalActivities = data.total;
            _error = null;
          });
        case Failure<ActivityResponse>(message: final message):
          setState(() {
            if (!loadMore) {
              _error = message;
            }
          });
          if (loadMore) {
            // Show snackbar for load more errors
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load more activities: $message'),
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
    final result = await _repository.refreshActivities(limit: 20);

    switch (result) {
      case Success<ActivityResponse>(data: final data):
        setState(() {
          _activities = data.activities;
          _currentPage = data.page;
          _hasMore = data.hasMore;
          _totalActivities = data.total;
          _error = null;
        });
      case Failure<ActivityResponse>(message: final message):
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

  // Group activities by date
  Map<String, List<ActivityModel>> _groupActivitiesByDate() {
    final Map<String, List<ActivityModel>> grouped = {};

    for (final activity in _activities) {
      final date = activity.createdAt;
      String dateKey;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final activityDate = DateTime(date.year, date.month, date.day);

      if (activityDate == today) {
        dateKey = 'Today';
      } else if (activityDate == yesterday) {
        dateKey = 'Yesterday';
      } else if (now.difference(date).inDays < 7) {
        dateKey = _getWeekday(date.weekday);
      } else {
        dateKey = '${date.day}/${date.month}/${date.year}';
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(activity);
    }

    return grouped;
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'batch_created':
      case 'batch_updated':
        return Icons.add_circle_outline;
      case 'farm_created':
      case 'farm_updated':
      case 'farm_deleted':
        return Icons.agriculture;
      case 'houses':
        return Icons.home;
      case 'vaccination':
        return Icons.medical_services;
      case 'feeding':
        return Icons.restaurant;
      case 'egg_collection':
        return Icons.egg;
      case 'weight_check':
        return Icons.monitor_weight;
      case 'bird_sale':
        return Icons.sell;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'batch_created':
        return Colors.green;
      case 'batch_updated':
        return Colors.blue;
      case 'farm_created':
        return Colors.orange;
      case 'farm_deleted':
        return Colors.red;
      case 'houses':
        return Colors.purple;
      case 'vaccination':
        return Colors.red.shade400;
      case 'feeding':
        return Colors.amber.shade700;
      case 'egg_collection':
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
            const Text('Recent Activity'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeaderSection(context),
            ),

            if (_isLoading && _activities.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )

            else if (_error != null && _activities.isEmpty)
              SliverFillRemaining(
                child: Center(
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
                        onPressed: () => _loadActivities(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )

            else if (_activities.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No activities yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )

              else
                ..._buildActivitySections(),

            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            if (_hasMore && !_isLoading && !_isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: TextButton(
                      onPressed: () => _loadActivities(loadMore: true),
                      child: const Text('Load More'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.lightGreen.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Activity',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'All recent farm activities',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track everything happening on your farm',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (_totalActivities > 0)
            Text(
              '$_totalActivities activities recorded',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildActivitySections() {
    final groupedActivities = _groupActivitiesByDate();
    final widgets = <Widget>[];

    groupedActivities.forEach((date, activities) {
      widgets.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              date,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );

      widgets.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final activity = activities[index];
              return _buildActivityItem(activity);
            },
            childCount: activities.length,
          ),
        ),
      );
    });

    return widgets;
  }

  Widget _buildActivityItem(ActivityModel activity) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.activityType).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(activity.activityType),
              size: 20,
              color: _getActivityColor(activity.activityType),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                if (activity.description.isNotEmpty)
                  Text(
                    activity.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 4),
                // Show additional metadata if available
                if (activity.batchName != null)
                  Text(
                    'Batch: ${activity.batchName!}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                if (activity.initialCount != null)
                  Text(
                    'Initial Count: ${activity.initialCount!} birds',
                    style: TextStyle(
                      color: Colors.grey.shade500,
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
                _formatTimeAgo(activity.createdAt),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatTime(activity.createdAt),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: activity.status == 'completed'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: activity.status == 'completed'
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
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