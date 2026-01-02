import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_mgt_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/batch/shared/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchOverview extends StatefulWidget {
  final String batchId;

  const BatchOverview({super.key, required this.batchId});

  @override
  State<BatchOverview> createState() => _BatchOverviewState();
}

class _BatchOverviewState extends State<BatchOverview> {
  final BatchMgtRepository _repository = BatchMgtRepository();
  BatchMgtResponse? _batchData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBatchData();
  }

  Future<void> _loadBatchData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final res = await _repository.getBatchDetails(widget.batchId);

      switch(res) {
        case Success<BatchMgtResponse>(data:final data):
          setState(() {
            _batchData = data;
          });
        case Failure<BatchMgtResponse>(message:final message):
          setState(() {
            _error = message;
          });
      }


    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
      final res = await _repository.refreshBatchDetails(widget.batchId);
      switch(res) {
        case Success<BatchMgtResponse>(data:final data):
          setState(() {
            _batchData = data;
          });
        case Failure<BatchMgtResponse>(message:final message):
          setState(() {
            _error = message;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message),)
            );
          }
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
              onPressed: _loadBatchData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_batchData == null) {
      return const Center(child: Text('No data available'));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: Colors.green,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _batchData!.batch.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _batchData!.batch.breed,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_batchData!.batch.houseName} • ${_batchData!.batch.farmName}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
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
                            color: _getStatusColor(_batchData!.batch.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _batchData!.batch.statusLabel,
                            style: TextStyle(
                              color: _getStatusColor(_batchData!.batch.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Metrics
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: '${_batchData!.stats.totalBirds}',
                    label: 'Total Birds',
                    color: Colors.blue.shade100,
                    icon: Icons.agriculture,
                    textColor: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    value: '${_batchData!.stats.ageDays}',
                    label: 'Days Old',
                    color: Colors.orange.shade100,
                    icon: Icons.calendar_today,
                    textColor: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: '${_batchData!.stats.mortality}',
                    label: 'Mortality',
                    color: Colors.red.shade100,
                    icon: Icons.flag,
                    textColor: Colors.red.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    value: _batchData!.stats.liveBirds,
                    label: 'Live Birds',
                    color: Colors.green.shade100,
                    icon: Icons.verified_user,
                    textColor: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity
            _buildSection(
              title: 'Recent Activity',
              context: context,
              children: _batchData!.recentActivities.isEmpty
                  ? [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No recent activities',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ]
                  : _batchData!.recentActivities
                  .map((activity) => _ActivityItem(
                icon: _getActivityIcon(activity.activityType),
                title: activity.title,
                subtitle: activity.description,
                time: _formatTime(activity.createdAt),
                color: _getActivityColor(activity.activityType),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade800;
      case 'completed':
        return Colors.blue.shade800;
      case 'archived':
        return Colors.grey.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'product_recorded':
        return Icons.inventory;
      case 'feed_recorded':
        return Icons.restaurant;
      case 'egg_collection':
        return Icons.egg;
      case 'weight_check':
        return Icons.monitor_weight;
      case 'bird_sale':
        return Icons.sell;
      default:
        return Icons.assignment;
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'product_recorded':
        return Colors.purple;
      case 'feed_recorded':
        return Colors.green;
      case 'egg_collection':
        return Colors.orange;
      case 'weight_check':
        return Colors.blue;
      case 'bird_sale':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
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
            TextButton(
              onPressed: () => context.push('/activity'),
              child: const Text('View all'),
            )
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}