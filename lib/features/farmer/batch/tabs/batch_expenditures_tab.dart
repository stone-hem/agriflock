import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/expenditure_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/batch/shared/stat_card.dart';
import 'package:agriflock360/features/farmer/expense/model/expenditure_model.dart' as expense_model;
import 'package:agriflock360/features/farmer/expense/repo/expenditure_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchExpendituresTab extends StatefulWidget {
  final BatchModel batch;

  const BatchExpendituresTab({super.key, required this.batch});

  @override
  State<BatchExpendituresTab> createState() => _BatchExpendituresTabState();
}

class _BatchExpendituresTabState extends State<BatchExpendituresTab> {
  final BatchMgtRepository _batchRepository = BatchMgtRepository();
  final ExpenditureRepository _expenditureRepository = ExpenditureRepository();

  ExpenditureDashboard? _dashboard;
  List<expense_model.Expenditure> _recentExpenditures = [];
  bool _isLoading = true;
  bool _loadingDashboard = false;
  bool _loadingExpenditures = false;
  String? _dashboardError;
  String? _expendituresError;

  // Totals
  double _totalAmount = 0;
  int _totalItems = 0;
  Map<String, double> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadExpenditureData();
  }

  Future<void> _loadExpenditureData() async {
    setState(() {
      _isLoading = true;
      _dashboardError = null;
      _expendituresError = null;
      _loadingDashboard = true;
      _loadingExpenditures = true;
      _totalAmount = 0;
      _totalItems = 0;
      _categoryTotals = {};
    });

    await Future.wait([
      _loadDashboardData(),
      _loadExpendituresData(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load expenditures to calculate dashboard stats
      final result = await _expenditureRepository.getExpenditures(
        batchId: widget.batch.id,
      );

      switch (result) {
        case Success<expense_model.ExpenditureResponse>(data: final response):
          _calculateDashboardStats(response.data);
          break;
        case Failure(message: final error):
          setState(() {
            _dashboard = null;
            _dashboardError = 'Failed to load expenditure data: $error';
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _dashboard = null;
        _dashboardError = 'Failed to load expenditure data: $e';
      });
    } finally {
      setState(() {
        _loadingDashboard = false;
      });
    }
  }

  void _calculateDashboardStats(List<expense_model.Expenditure> expenditures) {
    double totalAmount = 0;
    int totalItems = expenditures.length;
    Map<String, double> categoryTotals = {};

    // Calculate totals
    for (final exp in expenditures) {
      totalAmount += exp.amount;

      // Group by category
      final categoryName = exp.category.name;
      categoryTotals.update(
        categoryName,
            (value) => value + exp.amount,
        ifAbsent: () => exp.amount,
      );
    }

    // Calculate days since batch started (for average daily cost)
    final daysSinceStart = DateTime.now().difference(widget.batch.startDate).inDays; // Fallback to 30 days if no start date

    final averageDailyCost = daysSinceStart > 0
        ? totalAmount / daysSinceStart
        : totalAmount;

    // Get top categories
    double feedCost = 0;
    double medicationCost = 0;
    double utilitiesCost = 0;
    double laborCost = 0;
    double otherCost = 0;

    for (final entry in categoryTotals.entries) {
      final categoryName = entry.key.toLowerCase();
      if (categoryName.contains('feed')) {
        feedCost = entry.value;
      } else if (categoryName.contains('medication') ||
          categoryName.contains('vaccine') ||
          categoryName.contains('medicine')) {
        medicationCost = entry.value;
      } else if (categoryName.contains('utility') ||
          categoryName.contains('utilities') ||
          categoryName.contains('electricity') ||
          categoryName.contains('water')) {
        utilitiesCost = entry.value;
      } else if (categoryName.contains('labor') ||
          categoryName.contains('labour')) {
        laborCost = entry.value;
      } else {
        otherCost += entry.value;
      }
    }

    setState(() {
      _totalAmount = totalAmount;
      _totalItems = totalItems;
      _categoryTotals = categoryTotals;

      _dashboard = ExpenditureDashboard(
        totalAmount: totalAmount,
        averageDailyCost: averageDailyCost,
        categoryBreakdown: categoryTotals,
        feedCost: feedCost,
        medicationCost: medicationCost,
        utilitiesCost: utilitiesCost,
        laborCost: laborCost,
        otherCost: otherCost,
      );
      _dashboardError = null;
    });
  }

  Future<void> _loadExpendituresData() async {
    try {
      final result = await _expenditureRepository.getExpenditures(
        batchId: widget.batch.id,
      );

      switch (result) {
        case Success<expense_model.ExpenditureResponse>(data: final response):
        // Sort by date descending (most recent first)
          final sortedExpenditures = List<expense_model.Expenditure>.from(response.data)
            ..sort((a, b) => b.date.compareTo(a.date));

          // Take only recent items (first 10)
          final recentItems = sortedExpenditures.take(10).toList();

          setState(() {
            _recentExpenditures = recentItems;
            _expendituresError = null;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _recentExpenditures = [];
            _expendituresError = 'Failed to load expenditures: $error';
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _recentExpenditures = [];
        _expendituresError = 'Failed to load expenditures: $e';
      });
    } finally {
      setState(() {
        _loadingExpenditures = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadExpenditureData();
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

  IconData _getExpenditureIcon(expense_model.ExpenditureCategory category) {
    final categoryName = category.name.toLowerCase();
    if (categoryName.contains('feed')) {
      return Icons.fastfood;
    } else if (categoryName.contains('medication') ||
        categoryName.contains('vaccine') ||
        categoryName.contains('medicine')) {
      return Icons.medical_services;
    } else if (categoryName.contains('cleaning')) {
      return Icons.clean_hands;
    } else if (categoryName.contains('utility') ||
        categoryName.contains('utilities') ||
        categoryName.contains('electricity') ||
        categoryName.contains('water')) {
      return Icons.bolt;
    } else if (categoryName.contains('labor') ||
        categoryName.contains('labour')) {
      return Icons.people;
    } else if (categoryName.contains('equipment') ||
        categoryName.contains('tool')) {
      return Icons.build;
    } else if (categoryName.contains('transport')) {
      return Icons.local_shipping;
    } else {
      return Icons.account_balance_wallet;
    }
  }

  Color _getExpenditureColor(expense_model.ExpenditureCategory category) {
    final categoryName = category.name.toLowerCase();
    if (categoryName.contains('feed')) {
      return Colors.orange;
    } else if (categoryName.contains('medication') ||
        categoryName.contains('vaccine') ||
        categoryName.contains('medicine')) {
      return Colors.red;
    } else if (categoryName.contains('cleaning')) {
      return Colors.blue;
    } else if (categoryName.contains('utility') ||
        categoryName.contains('utilities') ||
        categoryName.contains('electricity') ||
        categoryName.contains('water')) {
      return Colors.yellow.shade700;
    } else if (categoryName.contains('labor') ||
        categoryName.contains('labour')) {
      return Colors.purple;
    } else if (categoryName.contains('equipment') ||
        categoryName.contains('tool')) {
      return Colors.brown;
    } else if (categoryName.contains('transport')) {
      return Colors.teal;
    } else {
      return Colors.green;
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
      return 'Today, ${DateUtil.toMMDDYYYY(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateUtil.toMMDDYYYY(date);
    }
  }

  String _formatCurrency(double amount) {
    return 'Ksh ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Widget _buildCategoryBreakdown() {
    if (_categoryTotals.isEmpty) {
      return const SizedBox();
    }

    // Sort categories by amount (descending)
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...sortedCategories.take(5).map((entry) {
          final percentage = _totalAmount > 0
              ? (entry.value / _totalAmount * 100).toStringAsFixed(1)
              : '0';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: LinearProgressIndicator(
                    value: _totalAmount > 0 ? entry.value / _totalAmount : 0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getExpenditureColorForCategory(entry.key),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    '$percentage%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getExpenditureColorForCategory(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('feed')) {
      return Colors.orange;
    } else if (lowerName.contains('medication') ||
        lowerName.contains('vaccine') ||
        lowerName.contains('medicine')) {
      return Colors.red;
    } else if (lowerName.contains('utility') ||
        lowerName.contains('utilities') ||
        lowerName.contains('electricity') ||
        lowerName.contains('water')) {
      return Colors.blue;
    } else if (lowerName.contains('labor') ||
        lowerName.contains('labour')) {
      return Colors.green;
    } else {
      return Colors.purple;
    }
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
                title: 'Expenditure Summary',
                context: context,
                isLoading: _loadingDashboard,
                error: _dashboardError,
                onRetry: _loadDashboardData,
                children: [
                  if (_dashboardError != null)
                    _buildErrorWidget(_dashboardError!, _loadDashboardData)
                  else if (_dashboard != null) ...[
                    // Total Expenditure
                    StatCard(
                      value: _formatCurrency(_dashboard!.totalAmount),
                      label: 'Total Expenditure',
                      color: Colors.red.shade100,
                      icon: Icons.account_balance_wallet,
                      textColor: Colors.red.shade800,
                    ),

                    const SizedBox(height: 12),

                    // Stats Row 1: Items Count and Days Active
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            value: _totalItems.toString(),
                            label: 'Total Expenses',
                            color: Colors.blue.shade100,
                            icon: Icons.receipt,
                            textColor: Colors.blue.shade800,
                            valueFontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: DateTime.now()
                                .difference(widget.batch.startDate!)
                                .inDays
                                .toString(),
                            label: 'Days Active',
                            color: Colors.green.shade100,
                            icon: Icons.calendar_today,
                            textColor: Colors.green.shade800,
                            valueFontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Average Daily Cost
                    StatCard(
                      value: _formatCurrency(_dashboard!.averageDailyCost),
                      label: 'Avg Daily Cost',
                      color: Colors.amber.shade100,
                      icon: Icons.timeline,
                      textColor: Colors.amber.shade800,
                      valueFontSize: 12,
                    ),

                    const SizedBox(height: 12),

                    // Top Category Breakdown
                    _buildCategoryBreakdown(),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Recent Expenditures Section
              _buildSection(
                title: 'Recent Expenditures',
                context: context,
                isLoading: _loadingExpenditures,
                error: _expendituresError,
                onRetry: _loadExpendituresData,
                children: [
                  if (_expendituresError != null)
                    _buildErrorWidget(_expendituresError!, _loadExpendituresData)
                  else if (_recentExpenditures.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No expenditures recorded yet',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add expenses to track your batch costs',
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
                    ..._recentExpenditures.map((expenditure) {
                      return _ExpenditureItem(
                        icon: _getExpenditureIcon(expenditure.category),
                        title: expenditure.description,
                        subtitle: '${expenditure.category.name} • ${expenditure.quantity} ${expenditure.unit}',
                        amount: _formatCurrency(expenditure.amount),
                        time: _formatDate(expenditure.date),
                        color: _getExpenditureColor(expenditure.category),
                        supplier: expenditure.supplier,
                      );
                    }).toList(),
                ],
              ),

              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add expenditure screen with batch pre-selected
          // You'll need to implement this navigation
          context.push('/record-expenditure');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
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

class _ExpenditureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final Color color;
  final String? supplier;

  const _ExpenditureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    required this.color,
    this.supplier,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (supplier != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Supplier: $supplier',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}