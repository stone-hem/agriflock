import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
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

class _BatchReportScreenState extends State<BatchReportScreen> {
  final _reportRepository = ReportRepository();

  // Filter state
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  String _selectedQuickRange = 'week';

  // Report state
  BatchReportResponse? _reportData;
  bool _isLoadingReport = false;
  String? _reportError;
  String _currency = 'KES';

  // Default filter values
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
    _loadCurrency();
    _loadReport();
  }

  void _initializeDefaults() {
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();

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
      ),
      bottomNavigationBar: const ExpenseMarqueeBannerCompact(),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                        label: const Text('Custom', style: TextStyle(fontSize: 12)),
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
                        const SizedBox(width: 8),
                        _buildQuickChip('Today', 'today'),
                        const SizedBox(width: 8),
                        _buildQuickChip('Last Week', 'week'),
                        const SizedBox(width: 8),
                        _buildQuickChip('Last Month', 'month'),
                        const SizedBox(width: 8),
                        _buildQuickChip('Last Year', 'year'),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
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
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check_circle, size: 14, color: Colors.blue.shade700),
            if (isSelected) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                child: Icon(Icons.assessment, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.batchNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    Text('${report.farmName} - ${report.houseName}', style: TextStyle(fontSize: 13, color: Colors.blue.shade600)),
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
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.blue.shade600)),
        ],
      ),
    );
  }

  Widget _buildMortalityCard(BatchMortality mortality) {
    return _buildSimpleCard(
      title: 'Mortality',
      icon: Icons.warning_amber,
      color: Colors.red,
      stats: [
        _StatData('Day', '${mortality.day}', Colors.orange),
        _StatData('Night', '${mortality.night}', Colors.indigo),
        _StatData('24hrs', '${mortality.total24hrs}', Colors.red),
        _StatData('Cumulative', '${mortality.cumulativeTotal}', Colors.purple),
        _StatData('Remaining', '${mortality.birdsRemaining}', Colors.green),
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
      color: Colors.orange,
      stats: [
        _StatData('Consumed', '${feed.bagsConsumed} bags', Colors.orange),
        _StatData('Total', '${feed.totalBagsConsumed} bags', Colors.amber),
        _StatData('In Store', '${feed.balanceInStore} bags', Colors.green),
        _StatData('Type', feed.feedType, Colors.blue),
      ],
    );
  }

  Widget _buildVaccinationCard(BatchVaccination vaccination) {
    return _buildSimpleCard(
      title: 'Vaccination',
      icon: Icons.vaccines,
      color: Colors.blue,
      stats: [
        _StatData('Done', '${vaccination.vaccinesDone.length}', Colors.green),
        _StatData('Upcoming', '${vaccination.vaccinesUpcoming.length}', Colors.orange),
      ],
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vaccination.vaccinesDone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildVaccineChips('Completed', vaccination.vaccinesDone, Colors.green),
          ],
          if (vaccination.vaccinesUpcoming.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildVaccineChips('Upcoming', vaccination.vaccinesUpcoming, Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BatchMedication medication) {
    return _buildSimpleCard(
      title: 'Medication',
      icon: Icons.medical_services,
      color: Colors.purple,
      stats: [
        _StatData('Available', '${medication.medicationsAvailable.length}', Colors.purple),
      ],
      footer: medication.medicationsAvailable.isNotEmpty
          ? Wrap(
              spacing: 6,
              runSpacing: 6,
              children: medication.medicationsAvailable.take(5).map((med) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text(med.toString(), style: TextStyle(fontSize: 11, color: Colors.purple.shade700)),
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
      color: Colors.amber,
      stats: [
        _StatData('Trays', '${production.traysCollected}', Colors.amber),
        _StatData('Eggs', '${production.totalEggsCollected}', Colors.orange),
        _StatData('In Store', '${production.traysInStore}', Colors.green),
        _StatData('Production', '${production.productionPercentage.toStringAsFixed(0)}%', Colors.blue),
        _StatData('Good', '${production.goodEggs}', Colors.green),
        _StatData('Value', '$_currency ${production.totalValue.toStringAsFixed(0)}', Colors.purple),
      ],
    );
  }

  Widget _buildSimpleCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<_StatData> stats,
    Widget? footer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.map((stat) => _buildStatChip(stat.label, stat.value, stat.color)).toList(),
          ),
          if (footer != null) ...[
            const SizedBox(height: 10),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineChips(String label, List<dynamic> vaccines, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: vaccines.take(3).map((vaccine) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(vaccine.toString(), style: TextStyle(fontSize: 10, color: color), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}

class _StatData {
  final String label;
  final String value;
  final Color color;

  _StatData(this.label, this.value, this.color);
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
                  backgroundColor: Colors.blue,
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