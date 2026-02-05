import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/disclaimer_widget.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsFlowScreen extends StatefulWidget {
  const ReportsFlowScreen({super.key});

  @override
  State<ReportsFlowScreen> createState() => _ReportsFlowScreenState();
}

class _ReportsFlowScreenState extends State<ReportsFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Repositories
  final _farmRepository = FarmRepository();
  final _batchMgtRepository = BatchMgtRepository();

  // Data
  List<FarmModel> _farms = [];
  List<BatchListItem> _batches = [];

  // Selected values
  String? _selectedReportType; // 'batch' or 'farm'

  // Loading states
  bool _isLoadingFarms = false;
  bool _isLoadingBatches = false;

  void _selectReportType(String type) {
    setState(() {
      _selectedReportType = type;
    });

    if (type == 'batch') {
      // For batch reports, load all batches directly
      _loadAllBatches();
    } else {
      // For farm reports, load farms
      _loadFarms();
    }
  }

  Future<void> _loadFarms() async {
    setState(() => _isLoadingFarms = true);

    try {
      final result = await _farmRepository.getAllFarmsWithStats();

      switch (result) {
        case Success<FarmsResponse>(data: final response):
          if (mounted) {
            setState(() {
              _farms = response.farms;
              _isLoadingFarms = false;
            });
            _nextPage();
          }
          break;
        case Failure(message: final error):
          if (mounted) {
            setState(() => _isLoadingFarms = false);
            ApiErrorHandler.handle(error);
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFarms = false);
      }
    }
  }

  Future<void> _loadAllBatches() async {
    setState(() => _isLoadingBatches = true);

    try {
      final result = await _batchMgtRepository.getBatches(
        currentStatus: 'active',
      );

      switch (result) {
        case Success<BatchListResponse>(data: final response):
          if (mounted) {
            setState(() {
              _batches = response.batches;
              _isLoadingBatches = false;
            });
            _nextPage();
          }
          break;
        case Failure(message: final error):
          if (mounted) {
            setState(() => _isLoadingBatches = false);
            ApiErrorHandler.handle(error);
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBatches = false);
      }
    }
  }

  void _onFarmSelected(FarmModel farm) {
    // Farm report - navigate directly to farm reports screen with selected farm
    context.push('/farm-reports', extra: farm);
  }

  void _onBatchSelected(BatchListItem batch) {
    context.push('/batch-report', extra: batch);
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentPage > 0) {
              _previousPage();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / 2,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),

          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                // Step 1: Report Type Selection
                _buildReportTypeSelection(),

                // Step 2: Farm Selection (for farm reports) or Batch Selection (for batch reports)
                if (_selectedReportType == 'farm')
                  _buildFarmSelection()
                else
                  _buildBatchSelection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Select Report Type';
      case 1:
        return _selectedReportType == 'farm' ? 'Select Farm' : 'Select Batch';
      default:
        return 'Reports';
    }
  }

  Widget _buildReportTypeSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DisclaimerWidget(
            title: 'Quick Reports',
            message: 'View detailed reports for your batches or entire farms.',
          ),
          const SizedBox(height: 24),
          const Text(
            'What would you like to view?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type of report you want to generate',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          _buildReportTypeCard(
            icon: Icons.inventory_2,
            title: 'Batch Report',
            subtitle: 'View detailed report for a specific batch',
            description: 'Mortality, feed, vaccination, medication & egg production data',
            color: Colors.blue,
            isLoading: _isLoadingFarms && _selectedReportType == 'batch',
            onTap: () => _selectReportType('batch'),
          ),
          const SizedBox(height: 16),
          _buildReportTypeCard(
            icon: Icons.agriculture,
            title: 'Farm Report',
            subtitle: 'View aggregated report for an entire farm',
            description: 'Summary of all batches with key metrics',
            color: Colors.green,
            isLoading: _isLoadingFarms && _selectedReportType == 'farm',
            onTap: () => _selectReportType('farm'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmSelection() {
    if (_isLoadingFarms) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_farms.isEmpty) {
      return _buildEmptyFarmsState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _farms.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Farm',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a farm to view its report',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }

        final farm = _farms[index - 1];
        return _buildFarmCard(farm);
      },
    );
  }

  Widget _buildEmptyFarmsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.agriculture, size: 64, color: Colors.green.shade600),
              const SizedBox(height: 16),
              Text(
                'No Farms Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a farm first to generate reports',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmCard(FarmModel farm) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onFarmSelected(farm),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.agriculture,
                  size: 24,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.farmName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (farm.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              farm.location!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchSelection() {
    if (_isLoadingBatches) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_batches.isEmpty) {
      return _buildEmptyBatchesState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _batches.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Batch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a batch to view its detailed report',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }

        final batch = _batches[index - 1];
        return _buildBatchCard(batch);
      },
    );
  }

  Widget _buildEmptyBatchesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2, size: 64, color: Colors.blue.shade600),
              const SizedBox(height: 16),
              Text(
                'No Active Batches',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This farm has no active batches. Create a batch to generate reports.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchCard(BatchListItem batch) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onBatchSelected(batch),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getBatchTypeColor(batch.birdType?.name ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getBatchTypeIcon(batch.birdType?.name ?? ''),
                  size: 24,
                  color: _getBatchTypeColor(batch.birdType?.name ?? ''),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.batchName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(Icons.pets, '${batch.birdsAlive} birds'),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.calendar_today, '${batch.age} days'),
                      ],
                    ),
                    if (batch.house?.name != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          batch.house!.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
    _pageController.dispose();
    super.dispose();
  }
}
