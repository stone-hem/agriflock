import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/report/models/batch_report_model.dart';
import 'package:agriflock360/features/farmer/report/repo/report_repo.dart';
import 'package:agriflock360/features/farmer/report/views/batch_report_view.dart';
import 'package:agriflock360/features/farmer/report/views/report_batch_selection_view.dart';
import 'package:agriflock360/features/farmer/report/views/report_date_filter_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickReportScreen extends StatefulWidget {
  final FarmModel? farm;

  const QuickReportScreen({
    super.key,
    this.farm,
  });

  @override
  State<QuickReportScreen> createState() => _QuickReportScreenState();
}

class _QuickReportScreenState extends State<QuickReportScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Repositories
  final _batchMgtRepository = BatchMgtRepository();
  final _reportRepository = ReportRepository();
  final _secureStorage = SecureStorage();

  // Data
  List<BatchListItem> _batches = [];
  BatchListItem? _selectedBatch;
  BatchReportResponse? _reportData;

  // Date filters
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _period = 'weekly';

  // Loading states
  bool _isLoadingBatches = true;
  bool _isLoadingReport = false;
  String? _reportError;
  String _currency = 'KES';

  @override
  void initState() {
    super.initState();
    _loadBatches();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final userDataMap = await _secureStorage.getUserDataAsMap();
    if (userDataMap != null && userDataMap['currency'] != null) {
      setState(() {
        _currency = userDataMap['currency'];
      });
    }
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoadingBatches = true);

    try {
      final result = await _batchMgtRepository.getBatches(
        farmId: widget.farm?.id,
        currentStatus: 'active',
      );

      switch (result) {
        case Success<BatchListResponse>(data: final response):
          setState(() {
            _batches = response.batches;
            _isLoadingBatches = false;
          });
          break;
        case Failure(message: final error):
          setState(() => _isLoadingBatches = false);
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() => _isLoadingBatches = false);
    }
  }

  Future<void> _loadReport() async {
    if (_selectedBatch == null) return;

    setState(() {
      _isLoadingReport = true;
      _reportError = null;
    });

    try {
      final result = await _reportRepository.getBatchReport(
        batchId: _selectedBatch!.id,
        startDate: _startDate,
        endDate: _endDate,
        period: _period,
      );

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
      setState(() {
        _reportError = e.toString();
        _isLoadingReport = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
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

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Quick Report';
      case 1:
        return 'Date Range';
      case 2:
        return _selectedBatch?.batchName ?? 'Report';
      default:
        return 'Quick Report';
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
          if (_currentPage < 2)
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
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
                // Step 1: Batch Selection
                ReportBatchSelectionView(
                  batches: _batches,
                  selectedBatch: _selectedBatch,
                  isLoading: _isLoadingBatches,
                  onBatchSelected: (batch) {
                    setState(() => _selectedBatch = batch);
                    _nextPage();
                  },
                ),

                // Step 2: Date Filter
                if (_selectedBatch != null)
                  ReportDateFilterView(
                    startDate: _startDate,
                    endDate: _endDate,
                    period: _period,
                    onApply: ({
                      required DateTime startDate,
                      required DateTime endDate,
                      required String period,
                    }) {
                      setState(() {
                        _startDate = startDate;
                        _endDate = endDate;
                        _period = period;
                      });
                      _loadReport();
                      _nextPage();
                    },
                    onBack: _previousPage,
                  ),

                // Step 3: Report View
                if (_selectedBatch != null)
                  BatchReportView(
                    batch: _selectedBatch!,
                    reportData: _reportData,
                    isLoading: _isLoadingReport,
                    error: _reportError,
                    onBack: _previousPage,
                    onRetry: _loadReport,
                    currency: _currency,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
