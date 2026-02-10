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
  final BatchListItem batch;

  const BatchReportScreen({super.key, required this.batch});

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
  String _selectedQuickRange = 'today';

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
    _startDate = DateTime(now.year, now.month, now.day);
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
        batchId: widget.batch.id,
        startDate: startDate,
        endDate: endDate,
        period: 'weekly',
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
      final result = await _batchMgtRepository.getBatchDetails(widget.batch.id);

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

  void _setQuickRange(String range) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (range) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        start = now.subtract(const Duration(days: 7));
    }

    setState(() {
      _selectedQuickRange = range;
      _startDate = start;
      _endDate = end;
      _startDateController.text = start.toIso8601String().split('T').first;
      _endDateController.text = end.toIso8601String().split('T').first;
    });

    _loadReport();
  }

  void _showCustomDatePicker() {
    setState(() {
      _selectedQuickRange = 'custom';
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomDatePickerSheet(
        startDateController: _startDateController,
        endDateController: _endDateController,
        startDate: _startDate,
        endDate: _endDate,
        onApply: (startDate, endDate) {
          setState(() {
            _startDate = startDate;
            _endDate = endDate;
            _selectedQuickRange = 'custom';
          });
          _loadReport();
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
          widget.batch.batchName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.black87,
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showCustomDatePicker,
                      icon: const Icon(Icons.edit_calendar, size: 16),
                      label: const Text('Select date range', style: TextStyle(fontSize: 14)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _buildQuickChip('Today', 'today'),
                      const SizedBox(width: 8),
                      _buildQuickChip('Last Week', 'week'),
                      const SizedBox(width: 8),
                      _buildQuickChip('Last Month', 'month'),
                      const SizedBox(width: 8),
                      _buildQuickChip('Last Year', 'year'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildReportContent(),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, String range) {
    final isSelected = _selectedQuickRange == range;
    return GestureDetector(
      onTap: () => _setQuickRange(range),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
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
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No report data available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text('Try adjusting the date range', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    final report = _reportData!.data.first;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildBatchHeader(report),
          const SizedBox(height: 20),
          _buildMortalityCard(report.mortality),
          const SizedBox(height: 16),
          _buildFeedCard(report.feed),
          const SizedBox(height: 16),
          _buildVaccinationCard(report.vaccination),
          const SizedBox(height: 16),
          _buildMedicationCard(report.medication),
          if (report.eggProduction != null) ...[
            const SizedBox(height: 16),
            _buildEggProductionCard(report.eggProduction!),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBatchHeader(BatchReportData report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: Icon(Icons.assessment, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.batchNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${report.farmName} - ${report.houseName}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderStat('Bird Type', report.birdType),
              _buildHeaderStat('Total Birds', '${report.totalBirds}'),
              _buildHeaderStat('Age', '${report.ageDays} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildMortalityCard(BatchMortality mortality) {
    return _buildSimpleCard(
      title: 'Mortality',
      icon: Icons.warning_amber,
      stats: [
        _StatData('Day', '${mortality.day}'),
        _StatData('Night', '${mortality.night}'),
        _StatData('24hrs', '${mortality.total24hrs}'),
        _StatData('Cumulative', '${mortality.cumulativeTotal}'),
        _StatData('Remaining', '${mortality.birdsRemaining}'),
      ],
      footer: mortality.reason.isNotEmpty
          ? Text('Reason: ${mortality.reason}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic))
          : null,
    );
  }

  Widget _buildFeedCard(BatchFeed feed) {
    return _buildSimpleCard(
      title: 'Feed',
      icon: Icons.fastfood,
      stats: [
        _StatData('Consumed', '${feed.bagsConsumed} kgs'),
        _StatData('Total', '${feed.totalBagsConsumed} kgs'),
        _StatData('In Store', '${feed.balanceInStore} kgs'),
        _StatData('Type', feed.feedType),
      ],
    );
  }

  Widget _buildVaccinationCard(BatchVaccination vaccination) {
    return _buildSimpleCard(
      title: 'Vaccination',
      icon: Icons.vaccines,
      stats: [
        _StatData('Done', '${vaccination.vaccinesDone.length}'),
        _StatData('Upcoming', '${vaccination.vaccinesUpcoming.length}'),
      ],
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vaccination.vaccinesDone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildVaccineChips('Completed', vaccination.vaccinesDone),
          ],
          if (vaccination.vaccinesUpcoming.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildVaccineChips('Upcoming', vaccination.vaccinesUpcoming),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BatchMedication medication) {
    return _buildSimpleCard(
      title: 'Medication',
      icon: Icons.medical_services,
      stats: [
        _StatData('Available', '${medication.medicationsAvailable.length}'),
      ],
      footer: medication.medicationsAvailable.isNotEmpty
          ? Wrap(
        spacing: 6,
        runSpacing: 6,
        children: medication.medicationsAvailable.take(5).map((med) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Text(med.toString(), style: const TextStyle(fontSize: 11)),
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
      stats: [
        _StatData('Trays', '${production.traysCollected}'),
        _StatData('Eggs', '${production.totalEggsCollected}'),
        _StatData('In Store', '${production.traysInStore}'),
        _StatData('Production', '${production.productionPercentage.toStringAsFixed(0)}%'),
        _StatData('Good', '${production.goodEggs}'),
        _StatData('Value', '$_currency ${production.totalValue.toStringAsFixed(0)}'),
      ],
    );
  }

  Widget _buildSimpleCard({
    required String title,
    required IconData icon,
    required List<_StatData> stats,
    Widget? footer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.map((stat) => _buildStatChip(stat.label, stat.value)).toList(),
          ),
          if (footer != null) ...[
            const SizedBox(height: 10),
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineChips(String label, List<dynamic> vaccines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: vaccines.take(3).map((vaccine) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(vaccine.toString(), style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
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

class _CustomDatePickerSheet extends StatefulWidget {
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime startDate, DateTime endDate) onApply;

  const _CustomDatePickerSheet({
    required this.startDateController,
    required this.endDateController,
    required this.startDate,
    required this.endDate,
    required this.onApply,
  });

  @override
  State<_CustomDatePickerSheet> createState() => _CustomDatePickerSheetState();
}

class _CustomDatePickerSheetState extends State<_CustomDatePickerSheet> {
  late TextEditingController _localStartController;
  late TextEditingController _localEndController;

  @override
  void initState() {
    super.initState();
    _localStartController = TextEditingController(text: widget.startDateController.text);
    _localEndController = TextEditingController(text: widget.endDateController.text);
  }

  void _applyFilters() {
    if (_localStartController.text.isEmpty || _localEndController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both start and end dates')));
      return;
    }

    try {
      final startDate = DateTime.parse(_localStartController.text);
      final endDate = DateTime.parse(_localEndController.text);

      if (startDate.isAfter(endDate)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start date cannot be after end date')));
        return;
      }

      widget.startDateController.text = _localStartController.text;
      widget.endDateController.text = _localEndController.text;
      widget.onApply(startDate, endDate);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid date format')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Custom Date Range', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CustomDateTextField(
              label: 'Start Date',
              icon: Icons.calendar_today,
              required: true,
              initialDate: widget.startDate,
              minYear: DateTime.now().year - 2,
              maxYear: DateTime.now().year,
              returnFormat: DateReturnFormat.isoString,
              controller: _localStartController,
            ),
            const SizedBox(height: 16),
            CustomDateTextField(
              label: 'End Date',
              icon: Icons.calendar_today,
              required: true,
              initialDate: widget.endDate,
              minYear: DateTime.now().year - 2,
              maxYear: DateTime.now().year,
              returnFormat: DateReturnFormat.isoString,
              controller: _localEndController,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 20),
                    SizedBox(width: 8),
                    Text('Apply', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localStartController.dispose();
    _localEndController.dispose();
    super.dispose();
  }
}