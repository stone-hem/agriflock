import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_mgt_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/report/models/batch_report_model.dart';
import 'package:agriflock360/features/farmer/report/repo/report_repo.dart';
import 'package:agriflock360/main.dart';
import 'package:flutter/material.dart';

class BatchReportScreen extends StatefulWidget {
  final String batchId;

  const BatchReportScreen({super.key, required this.batchId});

  @override
  State<BatchReportScreen> createState() => _BatchReportScreenState();
}

class _BatchReportScreenState extends State<BatchReportScreen>
    with SingleTickerProviderStateMixin {
  final _reportRepository = ReportRepository();
  late TabController _tabController;

  // Filter state
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  String _selectedPeriod = 'daily'; // daily, weekly, monthly, yearly, all_time

  // Report state
  BatchReportResponse? _reportData;
  bool _isLoadingReport = false;
  String? _reportError;
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
    var currency = await secureStorage.getCurrency();
    setState(() {
      _currency = currency;
    });
  }

  Future<void> _loadReport() async {
    if (!mounted) return;

    setState(() {
      _isLoadingReport = true;
      _reportError = null;
    });

    try {
      final startDate = DateTime.parse(_startDateController.text);
      final endDate = DateTime.parse(_endDateController.text);

      final result = await _reportRepository.getBatchReport(
        batchId: widget.batchId,
        startDate: startDate,
        endDate: endDate,
        period: _selectedPeriod,
      );

      if (!mounted) return;

      switch (result) {
        case Success<BatchReportResponse>(data: final response):
          setState(() {
            _reportData = response;
            _isLoadingReport = false;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _reportError = error;
            _isLoadingReport = false;
          });
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reportError = e.toString();
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
      final result = await _batchMgtRepository.getBatchDetails(widget.batchId);

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
              primary: Colors.green.shade700,
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Batch Report',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.green,
          indicatorWeight: 3,
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range and Period Chips Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
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
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: IconButton(
                        onPressed: _showDateRangePicker,
                        icon: Icon(Icons.edit_calendar, color: Colors.green.shade700, size: 20),
                        tooltip: 'Select Date Range',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Selected Date Range Display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade100, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${DateUtil.toShortDateWithDay(_startDate)} - ${DateUtil.toShortDateWithDay(_endDate)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedPeriod.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
          gradient: isSelected
              ? LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade400],
          )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.green.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
              : null,
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
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_reportError != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_reportError', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reportData == null || _reportData!.data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No report data available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text('Try adjusting the date range or period',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _buildGroupedReports();
  }

  Widget _buildGroupedReports() {
    final reports = _reportData!.data;

    // Group reports by date
    final Map<String, List<BatchReportData>> groupedReports = {};
    for (var report in reports) {
      final dateKey = DateUtil.toMMDDYYYY(report.reportDate);
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
            // Date Header with Gradient
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade400],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      DateUtil.toShortDateWithDay(reportDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dateReports.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Report Cards for this date
            ...dateReports.map((report) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildReportCard(report),
            )),
          ],
        );
      },
    );
  }

  Widget _buildReportCard(BatchReportData report) {
    final isLayers = report.birdType.toLowerCase().contains('layers');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            isLayers ? Colors.amber.shade50 : Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLayers ? Colors.amber.shade200 : Colors.blue.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLayers ? Colors.amber : Colors.blue).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batch Header with Gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isLayers ? Colors.amber.shade100 : Colors.blue.shade100,
                  isLayers ? Colors.orange.shade100 : Colors.indigo.shade100,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isLayers ? Icons.egg : Icons.pets,
                    color: isLayers ? Colors.amber.shade700 : Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.batchNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${report.farmName} - ${report.houseName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '${report.ageDays} days',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLayers ? Colors.amber.shade800 : Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.totalBirds} birds',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Report Sections
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Mortality Section
                _buildMortalityCard(report.mortality),
                const SizedBox(height: 12),

                // Feed Section
                _buildFeedCard(report.feed),
                const SizedBox(height: 12),

                // Weight Info Row
                // if (report.expectedWeight != null || report.actualWeight != null)
                //   _buildWeightCard(report),

                const SizedBox(height: 12),

                // Vaccination Section
                _buildVaccinationCard(report.vaccination),
                const SizedBox(height: 12),

                // Medication Section
                _buildMedicationCard(report.medication),

                // Egg Production for Layers
                if (report.eggProduction != null && report.eggProduction!.totalEggsCollected > 0) ...[
                  const SizedBox(height: 12),
                  _buildEggProductionCard(report.eggProduction!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMortalityCard(BatchMortality mortality) {
    final hasMortality = mortality.total24hrs > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasMortality
              ? [Colors.red.shade50, Colors.orange.shade50]
              : [Colors.green.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasMortality ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasMortality ? Icons.warning_amber : Icons.check_circle,
                color: hasMortality ? Colors.red.shade700 : Colors.green.shade700,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Mortality',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasMortality ? Colors.red.shade800 : Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  'Day',
                  '${mortality.day}',
                  icon: Icons.wb_sunny,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'Night',
                  '${mortality.night}',
                  icon: Icons.nightlight_round,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  '24hrs',
                  '${mortality.total24hrs}',
                  icon: Icons.access_time,
                  color: hasMortality ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: ${mortality.cumulativeTotal} | Alive: ${mortality.birdsRemaining}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                if (mortality.reason.isNotEmpty)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mortality.reason,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(BatchFeed feed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fastfood, color: Colors.brown.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                'Feed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.brown.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  feed.feedType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  'Consumed',
                  '${feed.bagsConsumed} kg',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'In Store',
                  '${feed.balanceInStore} kg',
                  icon: Icons.inventory,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Day: ${feed.bagsConsumedDay} kg | Night: ${feed.bagsConsumedNight} kg',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                if (feed.feedVariance.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: feed.feedVariance.toLowerCase().contains('above')
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      feed.feedVariance,
                      style: TextStyle(
                        fontSize: 9,
                        color: feed.feedVariance.toLowerCase().contains('above')
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard(BatchReportData report) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.indigo.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          // Expanded(
          //   child: _buildStatChip(
          //     'Expected',
          //     '${report.expectedWeight?.toStringAsFixed(2) ?? '0.00'} kg',
          //     icon: Icons.monitor_weight,
          //     color: Colors.purple,
          //   ),
          // ),
          // const SizedBox(width: 8),
          // Expanded(
          //   child: _buildStatChip(
          //     'Actual',
          //     '${report.actualWeight?.toStringAsFixed(2) ?? '0.00'} kg',
          //     icon: Icons.scale,
          //     color: Colors.indigo,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(BatchVaccination vaccination) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vaccines, color: Colors.blue.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                'Vaccination',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _buildStatusDot(Colors.green, vaccination.vaccinesDone.length),
                  const SizedBox(width: 4),
                  _buildStatusDot(Colors.orange, vaccination.vaccinesUpcoming.length),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              if (vaccination.vaccinesDone.isNotEmpty)
                ...vaccination.vaccinesDone.map((v) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 10),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          v.toString(),
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
              if (vaccination.vaccinesUpcoming.isNotEmpty && vaccination.vaccinesDone.isNotEmpty)
                const SizedBox(width: 4),
              if (vaccination.vaccinesUpcoming.isNotEmpty)
                ...vaccination.vaccinesUpcoming.map((v) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange, size: 10),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          v.toString(),
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.orange.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
              if (vaccination.vaccinesDone.length + vaccination.vaccinesUpcoming.length > 5)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '+${vaccination.vaccinesDone.length + vaccination.vaccinesUpcoming.length - 5} more',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BatchMedication medication) {
    final inUse = medication.inUse;
    if (inUse.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.teal.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                'Medication',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...inUse.take(2).map((med) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.medicineName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${med.dosage} - ${med.quantityUsed} ${med.unit}',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'In Use',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ),
              ],
            ),
          )),
          if (inUse.length > 2)
            Center(
              child: Text(
                '+${inUse.length - 2} more medications',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEggProductionCard(EggProduction production) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.egg, color: Colors.amber.shade800, size: 16),
              const SizedBox(width: 8),
              Text(
                'Egg Production',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${production.productionPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  'Trays',
                  '${production.traysCollected}',
                  icon: Icons.inbox,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'Eggs',
                  '${production.totalEggsCollected}',
                  icon: Icons.circle,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good: ${production.goodEggs}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          if (production.partialBroken > 0)
                            _buildDefectChip('Partial', production.partialBroken, Colors.orange),
                          if (production.completeBroken > 0)
                            _buildDefectChip('Broken', production.completeBroken, Colors.red),
                          if (production.smallDeformed > 0)
                            _buildDefectChip('Small', production.smallDeformed, Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Value',
                      style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                    ),
                    Text(
                      '$_currency ${production.totalValue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefectChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusDot(Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, {required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade400],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Period Selection
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

          // Main Financial Card
          _buildFinancialMainCard(),
        ],
      ),
    );
  }

  Widget _buildFinancialPeriodButton(String period, String label) {
    final isSelected = _selectedFinancialPeriod == period;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFinancialPeriod = period;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green.shade600 : Colors.grey.shade100,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildFinancialMainCard() {
    final stats = _getSelectedFinancialStats();
    final totalExpenditure = stats.totalExpenditure;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Period Header with Profit/Loss
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    stats.netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      stats.netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: stats.netProfit >= 0 ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFinancialPeriodLabel(_selectedFinancialPeriod),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          stats.netProfit >= 0 ? 'Profit' : 'Loss',
                          style: TextStyle(
                            fontSize: 12,
                            color: stats.netProfit >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_currency ${stats.netProfit.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: stats.netProfit >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        'Net ${stats.netProfit >= 0 ? 'Profit' : 'Loss'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Income vs Expenditure
            Row(
              children: [
                Expanded(
                  child: _buildFinancialStatCard(
                    label: 'Income',
                    value: '$_currency ${stats.productIncome.toStringAsFixed(2)}',
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialStatCard(
                    label: 'Expenditure',
                    value: '$_currency ${stats.totalExpenditure.toStringAsFixed(2)}',
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Cost Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Cost Breakdown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCostBar(
                    label: 'Feeding',
                    amount: stats.feedingCost,
                    percentage: totalExpenditure > 0 ? stats.feedingCost / totalExpenditure : 0,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildCostBar(
                    label: 'Vaccination',
                    amount: stats.vaccinationCost,
                    percentage: totalExpenditure > 0 ? stats.vaccinationCost / totalExpenditure : 0,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildCostBar(
                    label: 'Inventory',
                    amount: stats.inventoryCost,
                    percentage: totalExpenditure > 0 ? stats.inventoryCost / totalExpenditure : 0,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Expenditure',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_currency ${totalExpenditure.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostBar({
    required String label,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '$_currency ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}% of total',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}