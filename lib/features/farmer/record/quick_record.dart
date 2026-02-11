import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/expense/repo/categories_repository.dart';
import 'package:agriflock360/features/farmer/expense/repo/expenditure_repository.dart';
import 'package:agriflock360/features/farmer/record/repo/recording_repo.dart';
import 'package:agriflock360/features/farmer/record//views/use_batch_selection_view.dart';
import 'package:agriflock360/features/farmer/record/views/use_category_selection_view.dart';
import 'package:agriflock360/features/farmer/record/views/use_item_details_view.dart';
import 'package:agriflock360/features/farmer/record/views/use_success_view.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UseFromStorePageView extends StatefulWidget {
  final FarmModel? farm;

  const UseFromStorePageView({
    super.key,
    this.farm,
  });

  @override
  State<UseFromStorePageView> createState() => _UseFromStorePageViewState();
}

class _UseFromStorePageViewState extends State<UseFromStorePageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Repositories
  final _categoriesRepository = CategoriesRepository();
  final _batchMgtRepository = BatchMgtRepository();
  final _recordingRepo = RecordingRepo();

  // Data
  List<InventoryCategory> _categories = [];
  List<BatchListItem> _batches = [];

  // Selected values
  BatchListItem? _selectedBatch;
  InventoryCategory? _selectedCategory;
  CategoryItem? _selectedItem;
  double? _quantity;
  String? _methodOfAdministration;
  String? _notes;
  DateTime _selectedDate = DateTime.now();

  // Vaccination/Medicine details
  double? _dosesUsed;

  // Loading states
  bool _isLoadingCategories = true;
  bool _isLoadingBatches = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBatches();
    _loadCategories();
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
      ToastUtil.showError('Failed to load batches: $e');
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      final result = await _categoriesRepository.getCategories();

      switch (result) {
        case Success<List<InventoryCategory>>(data: final categories):
          setState(() {
            _categories = categories
                .where((cat) => cat.useFromStore && cat.categoryItems.any((item) => item.useFromStore))
                .toList();
            _isLoadingCategories = false;
          });
          break;
        case Failure(message: final error):
          setState(() => _isLoadingCategories = false);
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      ToastUtil.showError('Failed to load categories: $e');
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
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

  String _getRecordType() {
    final categoryName = _selectedCategory?.name.toLowerCase() ?? '';
    if (categoryName.contains('feed')) {
      return 'feed';
    } else if (categoryName.contains('vaccine')) {
      return 'vaccination';
    } else if (categoryName.contains('medication') || categoryName.contains('medicine')) {
      return 'medication';
    }
    return 'feed'; // default to feed
  }

  Future<void> _saveRecord() async {
    setState(() => _isSubmitting = true);

    try {
      final recordType = _getRecordType();
      Result result;

      if (recordType == 'feed') {
        // Feed record payload - specific fields for feed
        final recordData = {
          'batch_id': _selectedBatch!.id,
          if (_selectedBatch!.houseId != null) 'house_id': _selectedBatch!.houseId,
          'category_id': _selectedCategory!.id,
          'category_item_id': _selectedItem!.id,
          'description': _selectedItem!.categoryItemName,
          'quantity': _quantity ?? 0,
          'unit': 'kg',
          'date': _selectedDate.toUtc().toIso8601String(),
          if (_notes != null && _notes!.isNotEmpty) 'notes': _notes,
          'mortality_today': 0, // Default to 0, can be updated if UI captures this
        };

        LogUtil.warning('Feed Record Payload: $recordData');
        result = await _recordingRepo.createFeedingRecord(recordData);
      } else if (recordType == 'vaccination') {
        // Vaccination record payload - specific fields for vaccination
        final recordData = {
          'batch_id': _selectedBatch!.id,
          if (_selectedBatch!.houseId != null) 'house_id': _selectedBatch!.houseId,
          'category_id': _selectedCategory!.id,
          'category_item_id': _selectedItem!.id,
          'description': _selectedItem!.categoryItemName,
          'quantity': _quantity?.toInt() ?? 1,
          'unit': 'doses',
          'date': _selectedDate.toUtc().toIso8601String(),
          if (_notes != null && _notes!.isNotEmpty) 'notes': _notes,
          if (_methodOfAdministration != null) 'method_of_administration': _methodOfAdministration,
          'doses_used': _dosesUsed?.toInt() ?? _quantity?.toInt() ?? 1,
          'birds_vaccinated': _dosesUsed?.toInt() ?? _quantity?.toInt() ?? 1,
          'cost': 0,
          'supplier': '',
        };

        LogUtil.warning('Vaccination Record Payload: $recordData');
        result = await _recordingRepo.recordVaccination(recordData);
      } else {
        // Medication record payload - specific fields for medication
        final recordData = {
          'batch_id': _selectedBatch!.id,
          if (_selectedBatch!.houseId != null) 'house_id': _selectedBatch!.houseId,
          'category_id': _selectedCategory!.id,
          'category_item_id': _selectedItem!.id,
          'quantity': _quantity?.toInt() ?? 1,
          'unit': 'doses',
          'date': _selectedDate.toUtc().toIso8601String(),
          'dosage': '${_quantity ?? 1} dose(s)',
          if (_methodOfAdministration != null) 'administration_method': _methodOfAdministration,
          if (_notes != null && _notes!.isNotEmpty) 'reason': _notes,
          'birds_treated': _dosesUsed?.toInt() ?? 0,
          'treatment_duration_days': 1,
          'withdrawal_period_days': 0,
          'cost': 0,
          'supplier': '',
          if (_notes != null && _notes!.isNotEmpty) 'notes': _notes,
        };

        LogUtil.warning('Medication Record Payload: $recordData');
        result = await _recordingRepo.recordMedication(recordData);
      }

      switch (result) {
        case Success():
          ToastUtil.showSuccess('Record saved successfully!');
          if (mounted) {
            // Move to success page
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          break;
        case Failure(message: final error):
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      ToastUtil.showError('Failed to save record: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting
              ? null
              : () {
                  if (_currentPage > 0) {
                    _previousPage();
                  } else {
                    context.pop();
                  }
                },
        ),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_currentPage < 3)
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
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
                UseBatchSelectionView(
                  farm: widget.farm,
                  batches: _batches,
                  selectedBatch: _selectedBatch,
                  isLoadingBatches: _isLoadingBatches,
                  onBatchSelected: (batch) {
                    setState(() => _selectedBatch = batch);
                    _nextPage();
                  },
                ),

                // Step 2: Category Selection
                if (_selectedBatch != null)
                  UseCategorySelectionView(
                    categories: _categories,
                    isLoading: _isLoadingCategories,
                    selectedCategory: _selectedCategory,
                    batch: _selectedBatch!,
                    onCategorySelected: (category) {
                      setState(() => _selectedCategory = category);
                      _nextPage();
                    },
                    onBack: _previousPage,
                  ),

                // Step 3: Item Selection + Details
                if (_selectedBatch != null && _selectedCategory != null)
                  UseItemDetailsView(
                    batch: _selectedBatch!,
                    category: _selectedCategory!,
                    selectedItem: _selectedItem,
                    quantity: _quantity,
                    methodOfAdministration: _methodOfAdministration,
                    notes: _notes,
                    selectedDate: _selectedDate,
                    dosesUsed: _dosesUsed,
                    onItemSelected: (item) {
                      setState(() => _selectedItem = item);
                    },
                    onItemCleared: () {
                      setState(() => _selectedItem = null);
                    },
                    onSave: ({
                      required double quantity,
                      String? methodOfAdministration,
                      String? notes,
                      required DateTime selectedDate,
                      double? dosesUsed,
                    }) {
                      setState(() {
                        _quantity = quantity;
                        _methodOfAdministration = methodOfAdministration;
                        _notes = notes;
                        _selectedDate = selectedDate;
                        _dosesUsed = dosesUsed;
                      });
                      _saveRecord();
                    },
                    onBack: _previousPage,
                    isSubmitting: _isSubmitting,
                  ),

                // Step 4: Success
                if (_selectedBatch != null &&
                    _selectedCategory != null &&
                    _selectedItem != null &&
                    _quantity != null)
                  UseSuccessView(
                    batch: _selectedBatch!,
                    category: _selectedCategory!,
                    item: _selectedItem!,
                    quantity: _quantity!,
                    selectedDate: _selectedDate,
                    dosesUsed: _dosesUsed,
                    farm: widget.farm,
                    onDone: () => context.pop(true),
                  ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Quick recording From Store';
      case 1:
        return _selectedBatch?.batchName ?? 'Select Category';
      case 2:
        return _selectedCategory?.name ?? 'Item Details';
      case 3:
        return 'Success';
      default:
        return 'Quick recording From Store';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}