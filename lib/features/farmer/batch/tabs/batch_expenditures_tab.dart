import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/expenditure_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/batch/shared/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchExpendituresTab extends StatefulWidget {
  final BatchModel batch;

  const BatchExpendituresTab({super.key, required this.batch});

  @override
  State<BatchExpendituresTab> createState() => _BatchExpendituresTabState();
}

class _BatchExpendituresTabState extends State<BatchExpendituresTab> {
  final BatchMgtRepository _repository = BatchMgtRepository();

  ExpenditureDashboard? _dashboard;
  List<Expenditure> _recentExpenditures = [];
  bool _isLoading = true;
  bool _loadingDashboard = false;
  bool _loadingExpenditures = false;
  String? _dashboardError;
  String? _expendituresError;

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
      // For now, create mock data - replace with actual API call
      // final result = await _repository.getExpenditureDashboard(batchId: widget.batch.id);

      // Mock data - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _dashboard = ExpenditureDashboard(
          totalAmount: 125000,
          averageDailyCost: 1250,
          categoryBreakdown: {
            'feed': 60000,
            'medication': 25000,
            'utilities': 15000,
            'labor': 20000,
            'other': 5000,
          },
          feedCost: 60000,
          medicationCost: 25000,
          utilitiesCost: 15000,
          laborCost: 20000,
          otherCost: 5000,
        );
        _dashboardError = null;
      });
    } catch (e) {
      setState(() {
        _dashboard = null;
        _dashboardError = 'Failed to load expenditure data';
      });
    } finally {
      setState(() {
        _loadingDashboard = false;
      });
    }
  }

  Future<void> _loadExpendituresData() async {
    try {
      // For now, create mock data - replace with actual API call
      // final result = await _repository.getExpenditures(batchId: widget.batch.id);

      // Mock data - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _recentExpenditures = [
          Expenditure(
            id: '1',
            batchId: widget.batch.id,
            type: 'feed',
            category: 'recurring',
            description: 'Layer mash feed purchase',
            amount: 15000,
            quantity: 50,
            unit: 'bags',
            date: DateTime.now().subtract(const Duration(days: 1)),
            supplier: 'FeedCo Ltd',
            receiptNumber: 'RC-001',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Expenditure(
            id: '2',
            batchId: widget.batch.id,
            type: 'medication',
            category: 'recurring',
            description: 'Vaccines and antibiotics',
            amount: 5000,
            quantity: 100,
            unit: 'doses',
            date: DateTime.now().subtract(const Duration(days: 3)),
            supplier: 'Vet Supplies',
            receiptNumber: 'RC-002',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          Expenditure(
            id: '3',
            batchId: widget.batch.id,
            type: 'utilities',
            category: 'recurring',
            description: 'Electricity bill for heaters',
            amount: 8000,
            quantity: 1,
            unit: 'bill',
            date: DateTime.now().subtract(const Duration(days: 7)),
            supplier: 'Power Utility',
            receiptNumber: 'RC-003',
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
            updatedAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ];
        _expendituresError = null;
      });
    } catch (e) {
      setState(() {
        _recentExpenditures = [];
        _expendituresError = 'Failed to load expenditures';
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

  Future<void> _navigateToRecordExpenditure() async {
    final result = await context.push(
      '/batches/${widget.batch.id}/record-expenditure',
      extra: widget.batch, // Pass the batch as extra
    );

    if (result == true) {
      _loadExpenditureData(); // Refresh data after recording
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

  IconData _getExpenditureIcon(String type) {
    switch (type.toLowerCase()) {
      case 'feed':
        return Icons.fastfood;
      case 'medication':
        return Icons.medical_services;
      case 'utilities':
        return Icons.bolt;
      case 'labor':
        return Icons.people;
      case 'equipment':
        return Icons.build;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getExpenditureColor(String type) {
    switch (type.toLowerCase()) {
      case 'feed':
        return Colors.orange.shade600;
      case 'medication':
        return Colors.red.shade600;
      case 'utilities':
        return Colors.blue.shade600;
      case 'labor':
        return Colors.green.shade600;
      case 'equipment':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
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

  String _formatCurrency(double amount) {
    return 'Ksh ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
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

                    // Daily Average & Category Breakdown
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            value: _formatCurrency(_dashboard!.averageDailyCost),
                            label: 'Avg Daily Cost',
                            color: Colors.amber.shade100,
                            icon: Icons.timeline,
                            textColor: Colors.amber.shade800,
                            valueFontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: _dashboard!.categoryBreakdown.length.toString(),
                            label: 'Categories',
                            color: Colors.blue.shade100,
                            icon: Icons.category,
                            textColor: Colors.blue.shade800,
                            valueFontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Category Breakdown Cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            value: _formatCurrency(_dashboard!.feedCost),
                            label: 'Feed Cost',
                            color: Colors.orange.shade100,
                            icon: Icons.fastfood,
                            textColor: Colors.orange.shade800,
                            valueFontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: _formatCurrency(_dashboard!.medicationCost),
                            label: 'Medication',
                            color: Colors.red.shade100,
                            icon: Icons.medical_services,
                            textColor: Colors.red.shade800,
                            valueFontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            value: _formatCurrency(_dashboard!.utilitiesCost),
                            label: 'Utilities',
                            color: Colors.blue.shade100,
                            icon: Icons.bolt,
                            textColor: Colors.blue.shade800,
                            valueFontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: _formatCurrency(_dashboard!.laborCost),
                            label: 'Labor',
                            color: Colors.green.shade100,
                            icon: Icons.people,
                            textColor: Colors.green.shade800,
                            valueFontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
                              'Tap the button below to record your first expenditure',
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
                        icon: _getExpenditureIcon(expenditure.type),
                        title: expenditure.description,
                        subtitle: '${expenditure.type.toUpperCase()} • ${expenditure.quantity} ${expenditure.unit}',
                        amount: _formatCurrency(expenditure.amount),
                        time: _formatDate(expenditure.date),
                        color: _getExpenditureColor(expenditure.type),
                        supplier: expenditure.supplier,
                      );
                    }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToRecordExpenditure,
        backgroundColor: Colors.red, // Different color to distinguish
        icon: const Icon(Icons.add),
        foregroundColor: Colors.white,
        label: const Text('Record Expenditure'),
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