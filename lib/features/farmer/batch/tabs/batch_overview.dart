import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/farmer/batch/model/batch_mgt_model.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock/features/farmer/batch/shared/stat_card.dart';
import 'package:agriflock/main.dart';
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
  String _selectedPeriod = 'today'; // 'today', 'weekly', 'monthly', 'yearly', 'all_time'
  bool _showAllTime = false;

  String _currency='';


  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _loadBatchData();
  }

  Future<void> _loadCurrency() async {
    var currency = await secureStorage.getCurrency();
    setState(() {
      _currency = currency;
    });
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

  FinancialPeriodStats _getSelectedStats() {
    switch (_selectedPeriod) {
      case 'today':
        return _batchData!.financialStats.today;
      case 'weekly':
        return _batchData!.financialStats.weekly;
      case 'monthly':
        return _batchData!.financialStats.monthly;
      case 'yearly':
        return _batchData!.financialStats.yearly;
      case 'all_time':
        return _batchData!.financialStats.allTime;
      default:
        return _batchData!.financialStats.today;
    }
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'today':
        return 'Today';
      case 'weekly':
        return 'This Week';
      case 'monthly':
        return 'This Month';
      case 'yearly':
        return 'This Year';
      case 'all_time':
        return 'All Time';
      default:
        return 'Today';
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
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _batchData!.batch.batchNumber,
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

            // Financial Stats Section
            _buildFinancialStatsSection(context),
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

  Widget _buildFinancialStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Period Selection Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPeriodButton('today', 'Today'),
              const SizedBox(width: 8),
              _buildPeriodButton('weekly', 'Week'),
              const SizedBox(width: 8),
              _buildPeriodButton('monthly', 'Month'),
              const SizedBox(width: 8),
              _buildPeriodButton('yearly', 'Year'),
              const SizedBox(width: 8),
              _buildPeriodButton('all_time', 'All Time'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selected Period Stats
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Period Header
                Row(
                  children: [
                    Icon(
                      _getPeriodIcon(_selectedPeriod),
                      size: 24,
                      color: _getPeriodColor(_selectedPeriod),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getPeriodLabel(_selectedPeriod),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getSelectedStats().netProfit >= 0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getSelectedStats().netProfit >= 0
                            ? 'Profit: $_currency ${_getSelectedStats().netProfit.toStringAsFixed(2)}'
                            : 'Loss: $_currency ${_getSelectedStats().netProfit.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _getSelectedStats().netProfit >= 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Expandable Cost Breakdown
                _buildCostBreakdown(),
                const SizedBox(height: 16),

                // Income vs Expenditure Summary
                _buildIncomeExpenditureSummary(),
              ],
            ),
          ),
        ),

        // Quick Comparison Section
        if (_showAllTime)
          _buildAllTimeComparison(),
      ],
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? _getPeriodColor(period).withOpacity(0.1)
            : Colors.transparent,
        foregroundColor: isSelected
            ? _getPeriodColor(period)
            : Colors.grey.shade600,
        side: BorderSide(
          color: isSelected
              ? _getPeriodColor(period)
              : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildCostBreakdown() {
    final stats = _getSelectedStats();
    final totalExpenditure = stats.totalExpenditure;

    if (totalExpenditure == 0) {
      return const Text(
        'No expenses recorded for this period',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ExpansionTile(
      title: const Text(
        'Cost Breakdown',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      initiallyExpanded: true,
      children: [
        const SizedBox(height: 8),
        _buildCostItemRow(
          label: 'Feeding Cost',
          amount: stats.feedingCost,
          percentage: totalExpenditure > 0
              ? (stats.feedingCost / totalExpenditure * 100)
              : 0,
          color: Colors.orange,
        ),
        _buildCostItemRow(
          label: 'Vaccination Cost',
          amount: stats.vaccinationCost,
          percentage: totalExpenditure > 0
              ? (stats.vaccinationCost / totalExpenditure * 100)
              : 0,
          color: Colors.purple,
        ),
        _buildCostItemRow(
          label: 'Inventory Cost',
          amount: stats.inventoryCost,
          percentage: totalExpenditure > 0
              ? (stats.inventoryCost / totalExpenditure * 100)
              : 0,
          color: Colors.blue,
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Expenditure',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '$_currency ${totalExpenditure.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostItemRow({
    required String label,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '$_currency ${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: color,
                  minHeight: 4,
                ),
                const SizedBox(height: 4),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total expenditure',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenditureSummary() {
    final stats = _getSelectedStats();

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  label: 'Income',
                  value: '$_currency ${stats.productIncome.toStringAsFixed(2)}',
                  icon: Icons.arrow_upward,
                  color: Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                _buildSummaryItem(
                  label: 'Expenditure',
                  value: '$_currency ${stats.totalExpenditure.toStringAsFixed(2)}',
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stats.netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: 20,
                  color: stats.netProfit >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  stats.netProfit >= 0
                      ? 'Net Profit'
                      : 'Net Loss',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: stats.netProfit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTimeComparison() {
    final allTime = _batchData!.financialStats.allTime;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Time Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showAllTime = !_showAllTime;
                    });
                  },
                  icon: Icon(
                    _showAllTime ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildComparisonItem(
              label: 'Total Income',
              value: '$_currency ${allTime.productIncome.toStringAsFixed(2)}',
            ),
            _buildComparisonItem(
              label: 'Total Feeding Cost',
              value: '$_currency ${allTime.feedingCost.toStringAsFixed(2)}',
            ),
            _buildComparisonItem(
              label: 'Total Vaccination Cost',
              value: '$_currency ${allTime.vaccinationCost.toStringAsFixed(2)}',
            ),
            _buildComparisonItem(
              label: 'Overall Net',
              value: '$_currency ${allTime.netProfit.toStringAsFixed(2)}',
              isNet: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem({
    required String label,
    required String value,
    bool isNet = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isNet
                  ? (double.tryParse(value.replaceAll('\$', '')) ?? 0) >= 0
                  ? Colors.green
                  : Colors.red
                  : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'today':
        return Icons.today;
      case 'weekly':
        return Icons.date_range;
      case 'monthly':
        return Icons.calendar_month;
      case 'yearly':
        return Icons.calendar_today;
      case 'all_time':
        return Icons.history;
      default:
        return Icons.today;
    }
  }

  Color _getPeriodColor(String period) {
    switch (period) {
      case 'today':
        return Colors.blue;
      case 'weekly':
        return Colors.purple;
      case 'monthly':
        return Colors.green;
      case 'yearly':
        return Colors.orange;
      case 'all_time':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
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
      case 'vaccination':
        return Icons.medical_services;
      case 'feeding':
        return Icons.restaurant_menu;
      case 'batch_updated':
        return Icons.edit;
      case 'batch_created':
        return Icons.add_circle;
      default:
        return Icons.assignment;
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'product_recorded':
        return Colors.purple;
      case 'feed_recorded':
      case 'feeding':
        return Colors.green;
      case 'egg_collection':
        return Colors.orange;
      case 'weight_check':
        return Colors.blue;
      case 'bird_sale':
        return Colors.indigo;
      case 'vaccination':
        return Colors.pink;
      case 'batch_updated':
        return Colors.amber;
      case 'batch_created':
        return Colors.teal;
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