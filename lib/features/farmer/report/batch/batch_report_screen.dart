import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/report/models/batch_report_model.dart';
import 'package:agriflock360/features/farmer/report/repo/report_repo.dart';
import 'package:flutter/material.dart';

class BatchReportScreen extends StatefulWidget {
  final BatchListItem batch;

  const BatchReportScreen({
    super.key,
    required this.batch,
  });

  @override
  State<BatchReportScreen> createState() => _BatchReportScreenState();
}

class _BatchReportScreenState extends State<BatchReportScreen> {
  final _reportRepository = ReportRepository();
  final _secureStorage = SecureStorage();

  // Filter state
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  bool _isFilterExpanded = false;

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
    final userDataMap = await _secureStorage.getUserDataAsMap();
    if (userDataMap != null && userDataMap['currency'] != null) {
      if (mounted) {
        setState(() {
          _currency = userDataMap['currency'];
        });
      }
    }
  }

  Future<void> _loadReport() async {
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
        period: 'weekly', // Default period
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

  void _applyFilters() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    try {
      final startDate = DateTime.parse(_startDateController.text);
      final endDate = DateTime.parse(_endDateController.text);

      if (startDate.isAfter(endDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Start date cannot be after end date')),
        );
        return;
      }

      setState(() {
        _startDate = startDate;
        _endDate = endDate;
        _isFilterExpanded = false;
      });

      _loadReport();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid date format')),
      );
    }
  }

  void _setQuickRange(String range) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (range) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        end = now;
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
      _startDateController.text = start.toIso8601String().split('T').first;
      _endDateController.text = end.toIso8601String().split('T').first;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.batch.batchName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Active filters chips
          _buildActiveFiltersChips(),

          // Collapsible filter section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isFilterExpanded ? null : 0,
            child: _isFilterExpanded ? _buildFilterSection() : const SizedBox.shrink(),
          ),

          // Report content
          Expanded(
            child: _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_isLoadingReport) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reportError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_reportError'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReport,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reportData == null || _reportData!.data.isEmpty) {
      return Center(
        child: Column(
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
              'Try adjusting the date range',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final report = _reportData!.data.first;
    return ListView(
      padding: const EdgeInsets.all(20),
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
      ],
    );
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              const Text(
                'Active Filters',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isFilterExpanded = !_isFilterExpanded;
                  });
                },
                icon: Icon(
                  _isFilterExpanded ? Icons.expand_less : Icons.tune,
                  size: 18,
                ),
                label: Text(
                  _isFilterExpanded ? 'Hide Filters' : 'Edit Filters',
                  style: const TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                icon: Icons.calendar_today,
                label: '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick select buttons
            const Text(
              'Quick Select',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickButton('Today', 'today'),
                const SizedBox(width: 8),
                _buildQuickButton('Week', 'week'),
                const SizedBox(width: 8),
                _buildQuickButton('Month', 'month'),
                const SizedBox(width: 8),
                _buildQuickButton('Year', 'year'),
              ],
            ),
            const SizedBox(height: 20),

            // Custom date range
            const Text(
              'Custom Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CustomDateTextField(
              label: 'Start Date',
              icon: Icons.calendar_today,
              required: true,
              initialDate: _startDate,
              minYear: DateTime.now().year - 2,
              maxYear: DateTime.now().year,
              returnFormat: DateReturnFormat.isoString,
              controller: _startDateController,
            ),
            const SizedBox(height: 12),
            CustomDateTextField(
              label: 'End Date',
              icon: Icons.calendar_today,
              required: true,
              initialDate: _endDate,
              minYear: DateTime.now().year - 2,
              maxYear: DateTime.now().year,
              returnFormat: DateReturnFormat.isoString,
              controller: _endDateController,
            ),
            const SizedBox(height: 20),

            // Apply button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_alt, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assessment, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.batchNumber,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      '${report.farmName} - ${report.houseName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade600,
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
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMortalityCard(BatchMortality mortality) {
    return _buildReportCard(
      title: 'Mortality',
      icon: Icons.warning_amber,
      color: Colors.red,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Day', '${mortality.day}', Colors.orange),
              _buildStatItem('Night', '${mortality.night}', Colors.indigo),
              _buildStatItem('24hrs', '${mortality.total24hrs}', Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('Cumulative', '${mortality.cumulativeTotal}', Colors.purple),
              _buildStatItem('Remaining', '${mortality.birdsRemaining}', Colors.green),
            ],
          ),
          if (mortality.reason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Reason: ${mortality.reason}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(BatchFeed feed) {
    return _buildReportCard(
      title: 'Feed',
      icon: Icons.fastfood,
      color: Colors.orange,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Consumed', '${feed.bagsConsumed} bags', Colors.orange),
              _buildStatItem('Total', '${feed.totalBagsConsumed} bags', Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('In Store', '${feed.balanceInStore} bags', Colors.green),
              _buildStatItem('Type', feed.feedType, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(BatchVaccination vaccination) {
    return _buildReportCard(
      title: 'Vaccination',
      icon: Icons.vaccines,
      color: Colors.blue,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Done', '${vaccination.vaccinesDone.length}', Colors.green),
              _buildStatItem('Upcoming', '${vaccination.vaccinesUpcoming.length}', Colors.orange),
            ],
          ),
          if (vaccination.vaccinesDone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildVaccineList('Completed', vaccination.vaccinesDone, Colors.green),
          ],
          if (vaccination.vaccinesUpcoming.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildVaccineList('Upcoming', vaccination.vaccinesUpcoming, Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BatchMedication medication) {
    return _buildReportCard(
      title: 'Medication',
      icon: Icons.medical_services,
      color: Colors.purple,
      child: Column(
        children: [
          _buildStatItem(
            'Available',
            '${medication.medicationsAvailable.length}',
            Colors.purple,
          ),
          if (medication.medicationsAvailable.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: medication.medicationsAvailable.map((med) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      med.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEggProductionCard(EggProduction production) {
    return _buildReportCard(
      title: 'Egg Production',
      icon: Icons.egg,
      color: Colors.amber,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Trays', '${production.traysCollected}', Colors.amber),
              _buildStatItem('Total Eggs', '${production.totalEggsCollected}', Colors.orange),
              _buildStatItem('Pieces', '${production.piecesCollected}', Colors.brown),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('In Store', '${production.traysInStore} trays', Colors.green),
              _buildStatItem('Production', '${production.productionPercentage.toStringAsFixed(1)}%', Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('Broken', '${production.partialBroken + production.completeBroken}', Colors.red),
              _buildStatItem('Good Eggs', '${production.goodEggs}', Colors.green),
              _buildStatItem('Value', '$_currency ${production.totalValue.toStringAsFixed(2)}', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineList(String label, List<dynamic> vaccines, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: vaccines.take(5).map((vaccine) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vaccine.toString(),
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, String range) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _setQuickRange(range),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}