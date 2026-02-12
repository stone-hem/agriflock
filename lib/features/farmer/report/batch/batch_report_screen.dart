import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
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
              primary: Colors.black87,
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
      backgroundColor: Colors.grey.shade50,
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
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.green,
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
          color: isSelected ? Colors.green : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade300,
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
            ElevatedButton(onPressed: _loadReport, child: const Text('Retry')),
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
            Text('Try adjusting the date range or period', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
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
            // Date Header
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
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
              child: _buildReportCard(report),
            )),
          ],
        );
      },
    );
  }

  Widget _buildReportCard(BatchReportData report) {
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
          // Batch Header
          _buildBatchHeader(report),
          const Divider(height: 1),

          // Report Sections
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMortalityCard(report.mortality),
                const SizedBox(height: 12),
                _buildFeedCard(report.feed),
                const SizedBox(height: 12),
                _buildVaccinationCard(report.vaccination),
                const SizedBox(height: 12),
                _buildMedicationCard(report.medication),
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

  Widget _buildBatchHeader(BatchReportData report) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assessment, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.batchNumber,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${report.farmName} - ${report.houseName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${report.ageDays} days',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${report.totalBirds} birds',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMortalityCard(BatchMortality mortality) {
    return _buildSimpleCard(
      title: 'Mortality',
      icon: Icons.warning_amber,
      iconColor: mortality.total24hrs > 0 ? Colors.orange : Colors.grey.shade700,
      stats: [
        _StatData('Day', '${mortality.day}'),
        _StatData('Night', '${mortality.night}'),
        _StatData('24hrs', '${mortality.total24hrs}'),
        _StatData('Total', '${mortality.cumulativeTotal}'),
        _StatData('Alive', '${mortality.birdsRemaining}'),
      ],
      footer: mortality.reason.isNotEmpty
          ? Text(
        'Reason: ${mortality.reason}',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
      )
          : null,
    );
  }

  Widget _buildFeedCard(BatchFeed feed) {
    return _buildSimpleCard(
      title: 'Feed',
      icon: Icons.fastfood,
      iconColor: Colors.grey.shade700,
      stats: [
        _StatData('Consumed', '${feed.bagsConsumed} kgs'),
        _StatData('Day', '${feed.bagsConsumedDay} kgs'),
        _StatData('Night', '${feed.bagsConsumedNight} kgs'),
        _StatData('Total', '${feed.totalBagsConsumed} kgs'),
        _StatData('In Store', '${feed.balanceInStore} kgs'),
      ],
      footer: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feed.feedType,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          if (feed.feedVariance.isNotEmpty)
            Flexible(
              child: Text(
                feed.feedVariance,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(BatchVaccination vaccination) {
    return _buildSimpleCard(
      title: 'Vaccination',
      icon: Icons.vaccines,
      iconColor: Colors.grey.shade700,
      stats: [
        _StatData('Completed', '${vaccination.vaccinesDone.length}'),
        _StatData('Upcoming', '${vaccination.vaccinesUpcoming.length}'),
      ],
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vaccination.vaccinesDone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildVaccineChips('Completed', vaccination.vaccinesDone, Colors.green.shade50),
          ],
          if (vaccination.vaccinesUpcoming.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildVaccineChips('Upcoming', vaccination.vaccinesUpcoming, Colors.orange.shade50),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BatchMedication medication) {
    final inUse = medication.inUse;
    return _buildSimpleCard(
      title: 'Medication',
      icon: Icons.medical_services,
      iconColor: inUse.isNotEmpty ? Colors.blue.shade700 : Colors.grey.shade700,
      stats: [
        _StatData('In Use', '${inUse.length}'),
        _StatData('Available', '${medication.medicationsAvailable.length}'),
      ],
      footer: inUse.isNotEmpty
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: inUse.map((med) {
          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dosage: ${med.dosage}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${med.quantityUsed} ${med.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      )
          : null,
    );
  }

  Widget _buildEggProductionCard(EggProduction production) {
    return _buildSimpleCard(
      title: 'Egg Production',
      icon: Icons.egg,
      iconColor: Colors.amber.shade700,
      stats: [
        _StatData('Trays', '${production.traysCollected}'),
        _StatData('Eggs', '${production.totalEggsCollected}'),
        _StatData('Good', '${production.goodEggs}'),
        _StatData('Rate', '${production.productionPercentage.toStringAsFixed(1)}%'),
        _StatData('Value', '$_currency ${production.totalValue.toStringAsFixed(0)}'),
      ],
      footer: production.partialBroken + production.completeBroken + production.smallDeformed > 0
          ? Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          if (production.partialBroken > 0)
            _buildDefectChip('Partial Broken', production.partialBroken),
          if (production.completeBroken > 0)
            _buildDefectChip('Complete Broken', production.completeBroken),
          if (production.smallDeformed > 0)
            _buildDefectChip('Small/Deformed', production.smallDeformed),
        ],
      )
          : null,
    );
  }

  Widget _buildDefectChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 10,
          color: Colors.red.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSimpleCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_StatData> stats,
    Widget? footer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.map((stat) => _buildStatChip(stat.label, stat.value)).toList(),
          ),
          if (footer != null) ...[
            const SizedBox(height: 8),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineChips(String label, List<dynamic> vaccines, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: vaccines.take(5).map((vaccine) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: bgColor.withOpacity(0.3)),
              ),
              child: Text(
                vaccine.toString(),
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ],
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
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Period Header with net profit/loss
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade700),
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
        backgroundColor: isSelected ? Colors.black87 : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade600,
        side: BorderSide(color: isSelected ? Colors.black87 : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          percentage: totalExpenditure > 0 ? (stats.feedingCost / totalExpenditure * 100) : 0,
        ),
        _buildFinancialCostItemRow(
          label: 'Vaccination Cost',
          amount: stats.vaccinationCost,
          percentage: totalExpenditure > 0 ? (stats.vaccinationCost / totalExpenditure * 100) : 0,
        ),
        _buildFinancialCostItemRow(
          label: 'Inventory Cost',
          amount: stats.inventoryCost,
          percentage: totalExpenditure > 0 ? (stats.inventoryCost / totalExpenditure * 100) : 0,
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '$_currency ${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: Colors.grey.shade700,
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}% of total expenditure',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
        side: BorderSide(color: Colors.grey.shade300),
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

  @override
  void dispose() {
    _tabController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}

class _StatData {
  final String label;
  final String value;

  _StatData(this.label, this.value);
}