import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_mgt_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/report/models/farm_batch_report_model.dart';
import 'package:agriflock360/features/farmer/report/repo/report_repo.dart';
import 'package:flutter/material.dart';

class FarmReportsScreen extends StatefulWidget {
  final FarmModel farm;

  const FarmReportsScreen({super.key, required this.farm});

  @override
  State<FarmReportsScreen> createState() => _FarmReportsScreenState();
}

class _FarmReportsScreenState extends State<FarmReportsScreen>
    with SingleTickerProviderStateMixin {
  final _reportRepository = ReportRepository();
  final _secureStorage = SecureStorage();
  late TabController _tabController;

  // Data
  late FarmModel _selectedFarm;
  FarmBatchReportResponse? _reportData;

  // Date filters
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String _selectedPeriod = 'monthly';

  // Loading states
  bool _isLoadingReport = false;
  String? _error;
  String _currency = 'KES';

  // Financial report state
  final BatchMgtRepository _batchMgtRepository = BatchMgtRepository();
  BatchMgtResponse? _financialData;
  bool _isLoadingFinancial = false;
  String? _financialError;
  String _selectedFinancialPeriod = 'today';

  final List<Map<String, String>> _periods = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedFarm = widget.farm;
    _initializeDates();
    _loadCurrency();
    _loadReport();
    _loadFinancialData();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _startDateController.text = today.toIso8601String().split('T').first;
    _endDateController.text = now.toIso8601String().split('T').first;
  }

  Future<void> _loadCurrency() async {
    final userDataMap = await _secureStorage.getUserDataAsMap();
    if (userDataMap != null && userDataMap['currency'] != null) {
      setState(() {
        _currency = userDataMap['currency'];
      });
    }
  }

  Future<void> _loadReport() async {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date range')),
      );
      return;
    }

    setState(() {
      _isLoadingReport = true;
      _error = null;
    });

    try {
      final startDate = DateTime.parse(_startDateController.text);
      final endDate = DateTime.parse(_endDateController.text);

      final result = await _reportRepository.getFarmBatchReports(
        farmId: _selectedFarm.id,
        startDate: startDate,
        endDate: endDate,
        period: _selectedPeriod,
      );

      switch (result) {
        case Success<FarmBatchReportResponse>(data: final response):
          setState(() {
            _reportData = response;
            _isLoadingReport = false;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _error = error;
            _isLoadingReport = false;
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingReport = false;
      });
    }
  }

  Future<void> _loadFinancialData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFinancial = true;
      _financialError = null;
    });

    try {
      final result = await _batchMgtRepository.getFarmFinancialStats(_selectedFarm.id);

      if (!mounted) return;

      switch (result) {
        case Success<BatchMgtResponse>(data: final data):
          setState(() {
            _financialData = data;
            _isLoadingFinancial = false;
          });
          break;
        case Failure<BatchMgtResponse>(message: final message):
          setState(() {
            _financialError = message;
            _isLoadingFinancial = false;
          });
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _financialError = e.toString();
          _isLoadingFinancial = false;
        });
      }
    }
  }

  void _showFiltersBottomSheet() {
    // Create temporary controllers with current values
    final tempStartController = TextEditingController(text: _startDateController.text);
    final tempEndController = TextEditingController(text: _endDateController.text);
    String tempPeriod = _selectedPeriod;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Filter Report',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date Range
                    Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomDateTextField(
                      label: 'Start Date',
                      icon: Icons.calendar_today,
                      required: true,
                      initialDate: DateTime.now().subtract(const Duration(days: 30)),
                      minYear: DateTime.now().year - 2,
                      maxYear: DateTime.now().year,
                      returnFormat: DateReturnFormat.isoString,
                      controller: tempStartController,
                    ),
                    CustomDateTextField(
                      label: 'End Date',
                      icon: Icons.calendar_today,
                      required: true,
                      initialDate: DateTime.now(),
                      minYear: DateTime.now().year - 2,
                      maxYear: DateTime.now().year,
                      returnFormat: DateReturnFormat.isoString,
                      controller: tempEndController,
                    ),
                    const SizedBox(height: 20),

                    // Period Selector
                    Text(
                      'Report Period',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _periods.map((period) {
                        final isSelected = tempPeriod == period['value'];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempPeriod = period['value']!;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              period['label']!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              tempStartController.dispose();
                              tempEndController.dispose();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Apply filters
                              setState(() {
                                _startDateController.text = tempStartController.text;
                                _endDateController.text = tempEndController.text;
                                _selectedPeriod = tempPeriod;
                              });
                              tempStartController.dispose();
                              tempEndController.dispose();
                              Navigator.pop(context);
                              _loadReport();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  FinancialPeriodStats _getSelectedFinancialStats() {
    if (_financialData == null) {
      return const FinancialPeriodStats(
        feedingCost: 0,
        vaccinationCost: 0,
        inventoryCost: 0,
        totalExpenditure: 0,
        productIncome: 0,
        netProfit: 0,
      );
    }
    switch (_selectedFinancialPeriod) {
      case 'today':
        return _financialData!.financialStats.today;
      case 'weekly':
        return _financialData!.financialStats.weekly;
      case 'monthly':
        return _financialData!.financialStats.monthly;
      case 'yearly':
        return _financialData!.financialStats.yearly;
      case 'all_time':
        return _financialData!.financialStats.allTime;
      default:
        return _financialData!.financialStats.today;
    }
  }

  String _getFinancialPeriodLabel(String period) {
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_selectedFarm.farmName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersBottomSheet,
            tooltip: 'Filter Report',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade700,
          tabs: const [
            Tab(text: 'Production Report'),
            Tab(text: 'Financial Report'),
          ],
        ),
      ),
      bottomNavigationBar: const ExpenseMarqueeBannerCompact(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductionTab(),
          _buildFinancialTab(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Production Report Tab
  // ──────────────────────────────────────────────

  Widget _buildProductionTab() {
    return RefreshIndicator(
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFarmHeader(),
            const SizedBox(height: 16),

            // Current filter summary
            _buildCurrentFilterSummary(),

            if (_isLoadingReport) ...[
              const SizedBox(height: 40),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ] else if (_reportData != null) ...[
              const SizedBox(height: 24),
              _buildReportContent(),
            ] else if (_error != null) ...[
              const SizedBox(height: 40),
              _buildErrorState(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentFilterSummary() {
    final startDate = _startDateController.text.isNotEmpty
        ? DateTime.parse(_startDateController.text)
        : null;
    final endDate = _endDateController.text.isNotEmpty
        ? DateTime.parse(_endDateController.text)
        : null;

    final periodLabel = _periods.firstWhere(
          (p) => p['value'] == _selectedPeriod,
      orElse: () => {'label': 'Monthly'},
    )['label'];

    return GestureDetector(
      onTap: _showFiltersBottomSheet,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, size: 20, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$periodLabel Report',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  if (startDate != null && endDate != null)
                    Text(
                      '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.tune, size: 18, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            'Failed to load report',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _error ?? 'An error occurred',
            style: TextStyle(
              fontSize: 13,
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadReport,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.agriculture,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFarm.farmName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                if (_selectedFarm.location != null)
                  Text(
                    _selectedFarm.location!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green.shade600),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_reportData == null || _reportData!.data.isEmpty) {
      return _buildEmptyReport();
    }

    final report = _reportData!.data.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),

        // Farm summary card
        _buildFarmSummaryCard(report),
        const SizedBox(height: 16),

        // Batch reports
        if (report.batches.isNotEmpty) ...[
          Text(
            'Batch Reports (${report.batches.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ...report.batches.map((batch) => _buildBatchReportCard(batch)),
        ],
      ],
    );
  }

  Widget _buildEmptyReport() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No report data available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting the date range',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _showFiltersBottomSheet,
            icon: const Icon(Icons.filter_list),
            label: const Text('Change Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmSummaryCard(FarmBatchReportData report) {
    final summary = report.farmSummary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.agriculture, color: Colors.green.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.farmName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    Text(
                      'Report Period: ${report.reportPeriod}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem('Total Batches', '${summary.metadata.totalBatches}', Colors.blue),
              _buildSummaryItem('Houses', '${summary.metadata.totalHouses}', Colors.purple),
              _buildSummaryItem('Active', '${summary.metadata.activeBatches}', Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryItem(
                'Mortality (24h)',
                '${summary.mortality.total24hrs}',
                Colors.red,
              ),
              _buildSummaryItem(
                'Medications',
                '${summary.medication.items.length}',
                Colors.orange,
              ),
              _buildSummaryItem(
                'Vaccinations',
                '${summary.vaccination.vaccinesDone.length}',
                Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchReportCard(BatchReport batch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getBatchTypeColor(batch.birdType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getBatchTypeIcon(batch.birdType),
                  color: _getBatchTypeColor(batch.birdType),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.batchNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${batch.birdType} - ${batch.houseName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${batch.totalBirds} birds',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${batch.ageDays} days old',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBatchStat('Mortality', '${batch.mortality.cumulativeTotal}', Colors.red),
              _buildBatchStat('Feed', '${batch.feed.bagsConsumed} kgs', Colors.orange),
              _buildBatchStat('Vaccinations', '${batch.vaccination.vaccinesDone.length}', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatchTypeColor(String birdType) {
    switch (birdType.toLowerCase()) {
      case 'broiler':
        return Colors.orange;
      case 'layer':
        return Colors.blue;
      case 'kienyeji':
        return Colors.brown;
      default:
        return Colors.green;
    }
  }

  IconData _getBatchTypeIcon(String birdType) {
    switch (birdType.toLowerCase()) {
      case 'broiler':
        return Icons.restaurant;
      case 'layer':
        return Icons.egg;
      case 'kienyeji':
        return Icons.eco;
      default:
        return Icons.pets;
    }
  }

  // ──────────────────────────────────────────────
  // Financial Report Tab
  // ──────────────────────────────────────────────

  Widget _buildFinancialTab() {
    if (_isLoadingFinancial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_financialError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_financialError', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFinancialData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_financialData == null) {
      return const Center(child: Text('No financial data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Period Selection Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFinancialPeriodButton('today', 'Today'),
                const SizedBox(width: 8),
                _buildFinancialPeriodButton('weekly', 'Week'),
                const SizedBox(width: 8),
                _buildFinancialPeriodButton('monthly', 'Month'),
                const SizedBox(width: 8),
                _buildFinancialPeriodButton('yearly', 'Year'),
                const SizedBox(width: 8),
                _buildFinancialPeriodButton('all_time', 'All Time'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Selected Period Stats Card
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
                  // Period Header with net profit/loss
                  Row(
                    children: [
                      Icon(
                        _getFinancialPeriodIcon(_selectedFinancialPeriod),
                        size: 24,
                        color: _getFinancialPeriodColor(_selectedFinancialPeriod),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getFinancialPeriodLabel(_selectedFinancialPeriod),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getSelectedFinancialStats().netProfit >= 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getSelectedFinancialStats().netProfit >= 0
                              ? 'Profit: $_currency ${_getSelectedFinancialStats().netProfit.toStringAsFixed(2)}'
                              : 'Loss: $_currency ${_getSelectedFinancialStats().netProfit.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _getSelectedFinancialStats().netProfit >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cost Breakdown
                  _buildFinancialCostBreakdown(),
                  const SizedBox(height: 16),

                  // Income vs Expenditure Summary
                  _buildFinancialIncomeExpenditureSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialPeriodButton(String period, String label) {
    final isSelected = _selectedFinancialPeriod == period;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedFinancialPeriod = period;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? _getFinancialPeriodColor(period).withOpacity(0.1)
            : Colors.transparent,
        foregroundColor: isSelected
            ? _getFinancialPeriodColor(period)
            : Colors.grey.shade600,
        side: BorderSide(
          color: isSelected
              ? _getFinancialPeriodColor(period)
              : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildFinancialCostBreakdown() {
    final stats = _getSelectedFinancialStats();
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
        _buildFinancialCostItemRow(
          label: 'Feeding Cost',
          amount: stats.feedingCost,
          percentage: totalExpenditure > 0
              ? (stats.feedingCost / totalExpenditure * 100)
              : 0,
          color: Colors.orange,
        ),
        _buildFinancialCostItemRow(
          label: 'Vaccination Cost',
          amount: stats.vaccinationCost,
          percentage: totalExpenditure > 0
              ? (stats.vaccinationCost / totalExpenditure * 100)
              : 0,
          color: Colors.purple,
        ),
        _buildFinancialCostItemRow(
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

  Widget _buildFinancialCostItemRow({
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
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      '$_currency ${amount.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.w600, color: color),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialIncomeExpenditureSummary() {
    final stats = _getSelectedFinancialStats();

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
                _buildFinancialSummaryItem(
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
                _buildFinancialSummaryItem(
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
                  stats.netProfit >= 0 ? 'Net Profit' : 'Net Loss',
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

  Widget _buildFinancialSummaryItem({
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  IconData _getFinancialPeriodIcon(String period) {
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

  Color _getFinancialPeriodColor(String period) {
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

  @override
  void dispose() {
    _tabController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
