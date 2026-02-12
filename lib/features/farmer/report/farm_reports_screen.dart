import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
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
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  String _selectedPeriod = 'daily'; // daily, weekly, monthly, yearly, all_time

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

  // Default filter values
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedFarm = widget.farm;
    _initializeDefaults();
    _loadCurrency();
    _loadReport();
    _loadFinancialData();
  }

  void _initializeDefaults() {
    final now = DateTime.now();
    // Default: last 7 days with daily period
    _startDate = now.subtract(const Duration(days: 6));
    _endDate = now;

    _startDateController = TextEditingController(
      text: _startDate.toIso8601String().split('T').first,
    );
    _endDateController = TextEditingController(
      text: _endDate.toIso8601String().split('T').first,
    );
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
    if (!mounted) return;

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

      if (!mounted) return;

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
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingReport = false;
        });
      }
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

  void _setPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadReport();
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _startDateController.text = _startDate.toIso8601String().split('T').first;
        _endDateController.text = _endDate.toIso8601String().split('T').first;
      });
      _loadReport();
    }
  }

  String _formatDate(DateTime date) {
    return DateUtil.toDDMMYYYY(date);
  }

  String _formatDateShort(DateTime date) {
    return DateUtil.toDDMMYYYY(date);
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
    return Column(
      children: [
        // Fixed Filter Section
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 12),
              Align(
                alignment: .topRight,
                child: FilledButton.icon(
                  onPressed: _showDateRangePicker,
                  icon: const Icon(Icons.edit_calendar, size: 20),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ), label: Text('Select Date range'),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                margin: EdgeInsets.only(left: 20),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Period ${DateUtil.toShortDateWithDay(_startDate)} - ${DateUtil.toShortDateWithDay(_endDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _buildPeriodChip('Daily', 'daily'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Weekly', 'weekly'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Monthly', 'monthly'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Yearly', 'yearly'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('All Time', 'all_time'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // Scrollable Report Content
        Expanded(child: _buildReportContent()),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => _setPeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    if (_isLoadingReport) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: _buildErrorState(),
      );
    }

    if (_reportData == null || _reportData!.data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: _buildEmptyReport(),
      );
    }

    return _buildGroupedReports();
  }

  Widget _buildGroupedReports() {
    final reports = _reportData!.data;

    // Group reports by date
    final Map<String, List<FarmBatchReportData>> groupedReports = {};
    for (var report in reports) {
      final dateKey = DateUtil.toDDMMYYYY(report.reportDate);
      if (!groupedReports.containsKey(dateKey)) {
        groupedReports[dateKey] = [];
      }
      groupedReports[dateKey]!.add(report);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = groupedReports.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dateReports = groupedReports[dateKey]!;
        final reportDate = dateReports.first.reportDate;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          DateUtil.toShortDateWithDay(reportDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${dateReports.length} ${dateReports.length == 1 ? 'report' : 'reports'})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // Report Cards for this date
            ...dateReports.map((report) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildFarmReportCard(report),
            )),
          ],
        );
      },
    );
  }

  Widget _buildFarmReportCard(FarmBatchReportData report) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm Header
          _buildFarmHeader(report),
          const Divider(height: 1),

          // Farm Summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFarmSummarySection(report.farmSummary),

                // Batch Reports
                if (report.batches.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.list_alt, size: 18, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Batch Reports (${report.batches.length})',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...report.batches.map((batch) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBatchReportCard(batch),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmHeader(FarmBatchReportData report) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Report Period: ${report.reportPeriod}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmSummarySection(FarmSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assessment, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            const Text(
              'Farm Summary',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Metadata
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              _buildSummaryStatChip('Batches', '${summary.metadata.totalBatches}', Colors.blue),
              const SizedBox(width: 8),
              _buildSummaryStatChip('Houses', '${summary.metadata.totalHouses}', Colors.purple),
              const SizedBox(width: 8),
              _buildSummaryStatChip('Active', '${summary.metadata.activeBatches}', Colors.green),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Key Metrics
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMetricCard(
              'Mortality (24h)',
              '${summary.mortality.total24hrs}',
              Icons.warning_amber,
              summary.mortality.total24hrs > 0 ? Colors.orange : Colors.grey,
            ),
            // _buildMetricCard(
            //   'Feed Consumed',
            //   '${summary.feed.totalBagsConsumed} kgs',
            //   Icons.fastfood,
            //   Colors.brown,
            // ),
            _buildMetricCard(
              'Medications',
              '${summary.medication.items.length}',
              Icons.medical_services,
              summary.medication.items.isNotEmpty ? Colors.blue : Colors.grey,
            ),
            _buildMetricCard(
              'Vaccinations',
              '${summary.vaccination.vaccinesDone.length}',
              Icons.vaccines,
              Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryStatChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
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
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchReportCard(BatchReport batch) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
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
                  size: 18,
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${batch.birdType} - ${batch.houseName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${batch.totalBirds} birds',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${batch.ageDays} days',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBatchStatChip(
                'Mortality',
                '${batch.mortality.cumulativeTotal}',
                batch.mortality.cumulativeTotal > 0 ? Colors.red : Colors.grey,
              ),
              _buildBatchStatChip(
                'Feed',
                '${batch.feed.bagsConsumed} kgs',
                Colors.orange,
              ),
              _buildBatchStatChip(
                'Vaccines',
                '${batch.vaccination.vaccinesDone.length}',
                Colors.blue,
              ),
              if (batch.medication.medicationsAvailable.isNotEmpty)
                _buildBatchStatChip(
                  'Medications',
                  '${batch.medication.medicationsAvailable.length}',
                  Colors.purple,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildEmptyReport() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'No report data available',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting the date range or period',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Color _getBatchTypeColor(String birdType) {
    switch (birdType.toLowerCase()) {
      case 'broiler':
      case 'broilers':
        return Colors.orange;
      case 'layer':
      case 'layers':
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
      case 'broilers':
        return Icons.restaurant;
      case 'layer':
      case 'layers':
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