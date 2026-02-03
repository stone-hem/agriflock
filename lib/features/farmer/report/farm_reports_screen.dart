import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:agriflock360/features/farmer/report/models/batch_report_model.dart';
import 'package:agriflock360/features/farmer/report/models/farm_batch_report_model.dart';
import 'package:agriflock360/features/farmer/report/repo/report_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FarmReportsScreen extends StatefulWidget {
  const FarmReportsScreen({super.key});

  @override
  State<FarmReportsScreen> createState() => _FarmReportsScreenState();
}

class _FarmReportsScreenState extends State<FarmReportsScreen> {
  final _farmRepository = FarmRepository();
  final _reportRepository = ReportRepository();
  final _secureStorage = SecureStorage();

  // Data
  FarmsResponse? _farmsResponse;
  FarmModel? _selectedFarm;
  FarmBatchReportResponse? _reportData;

  // Date filters
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String _selectedPeriod = 'monthly';

  // Loading states
  bool _isLoadingFarms = true;
  bool _isLoadingReport = false;
  String? _error;
  String _currency = 'KES';

  final List<Map<String, String>> _periods = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _loadFarms();
    _loadCurrency();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    _startDateController.text = startOfMonth.toIso8601String().split('T').first;
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

  Future<void> _loadFarms() async {
    setState(() {
      _isLoadingFarms = true;
      _error = null;
    });

    try {
      final result = await _farmRepository.getAllFarmsWithStats();

      switch (result) {
        case Success<FarmsResponse>(data: final response):
          setState(() {
            _farmsResponse = response;
            _isLoadingFarms = false;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _error = error;
            _isLoadingFarms = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingFarms = false;
      });
    }
  }

  Future<void> _loadReport() async {
    if (_selectedFarm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farm')),
      );
      return;
    }

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
        farmId: _selectedFarm!.id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Farm Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingFarms
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _farmsResponse == null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFarmSelector(),
                      const SizedBox(height: 20),
                      _buildDateFilters(),
                      const SizedBox(height: 20),
                      _buildPeriodSelector(),
                      const SizedBox(height: 20),
                      _buildGenerateButton(),
                      if (_reportData != null) ...[
                        const SizedBox(height: 24),
                        _buildReportContent(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFarms,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Farm',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        if (_farmsResponse == null || _farmsResponse!.farms.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade600),
                const SizedBox(width: 12),
                const Text('No farms available'),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFarm?.id,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Choose a farm'),
                ),
                isExpanded: true,
                items: _farmsResponse!.farms.map((farm) {
                  return DropdownMenuItem<String>(
                    value: farm.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.agriculture,
                              color: Colors.green.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  farm.farmName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (farm.location != null)
                                  Text(
                                    farm.location!,
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
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFarm = _farmsResponse!.farms.firstWhere(
                      (f) => f.id == value,
                    );
                    _reportData = null;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomDateTextField(
                label: 'Start Date',
                icon: Icons.calendar_today,
                required: true,
                initialDate: DateTime.now().subtract(const Duration(days: 30)),
                minYear: DateTime.now().year - 2,
                maxYear: DateTime.now().year,
                returnFormat: DateReturnFormat.isoString,
                controller: _startDateController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDateTextField(
                label: 'End Date',
                icon: Icons.calendar_today,
                required: true,
                initialDate: DateTime.now(),
                minYear: DateTime.now().year - 2,
                maxYear: DateTime.now().year,
                returnFormat: DateReturnFormat.isoString,
                controller: _endDateController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            final isSelected = _selectedPeriod == period['value'];
            return GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = period['value']!);
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
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoadingReport ? null : _loadReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoadingReport
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment),
                  SizedBox(width: 8),
                  Text(
                    'Generate Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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

  Widget _buildBatchReportCard(BatchReportData batch) {
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
              _buildBatchStat('Feed', '${batch.feed.bagsConsumed} bags', Colors.orange),
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

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
