import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/expense/repo/categories_repository.dart';
import 'package:agriflock360/features/farmer/expense/repo/expenditure_repository.dart';
import 'package:agriflock360/features/farmer/expense/views/category_selection_view.dart';
import 'package:agriflock360/features/farmer/expense/views/item_selection_view.dart';
import 'package:agriflock360/features/farmer/expense/views/quantity_price_view.dart';
import 'package:agriflock360/features/farmer/expense/views/usage_choice_view.dart';
import 'package:agriflock360/features/farmer/expense/views/batch_selection_view.dart';
import 'package:agriflock360/features/farmer/expense/views/success_view.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyInputsPageView extends StatefulWidget {
  final FarmModel? farm;

  const BuyInputsPageView({
    super.key,
    this.farm,
  });

  @override
  State<BuyInputsPageView> createState() => _BuyInputsPageViewState();
}

class _BuyInputsPageViewState extends State<BuyInputsPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Repositories
  final _categoriesRepository = CategoriesRepository();
  final _batchMgtRepository = BatchMgtRepository();
  final _expenditureRepository = ExpenditureRepository();

  // Data
  List<InventoryCategory> _categories = [];
  List<BatchListItem> _batches = [];

  // Selected values
  InventoryCategory? _selectedCategory;
  CategoryItem? _selectedItem;
  double? _quantity;
  double? _unitPrice;
  double? _totalPrice;
  String? _methodOfAdministration;
  DateTime _selectedDate = DateTime.now();

  // Usage choice
  bool _useNow=true; // true = use now, false = store

  // Batch selection (if use now)
  BatchListItem? _selectedBatch;

  // Vaccination details (if applicable)
  double? _dosesUsed;

  // Loading states
  bool _isLoadingCategories = true;
  bool _isLoadingBatches = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBatches();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      final result = await _categoriesRepository.getCategories();

      switch (result) {
        case Success<List<InventoryCategory>>(data: final categories):
          setState(() {
            _categories = categories;
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

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      // If on batch selection (page 4) and usage choice was skipped, go back to quantity page
      if (_currentPage == 4 &&
          _selectedCategory != null &&
          _selectedItem != null &&
          (!_selectedCategory!.useFromStore || !_selectedItem!.useFromStore)) {
        _goToPage(2); // Go back to quantity/price page
        return;
      }
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitExpense() async {
    setState(() => _isSubmitting = true);

    try {
      final expenditureData = {
        if (widget.farm != null) 'farm_id': widget.farm!.id,
        'category_id': _selectedCategory!.id,
        'category_item_id': _selectedItem!.id,
        'description': _selectedItem!.categoryItemName,
        'amount': _totalPrice,
        'quantity': _quantity,
        'unit': 'unit', // You can add unit selection if needed
        'date': _selectedDate.toUtc().toIso8601String(),
        'notes': null,
        if (_methodOfAdministration != null) 'method_of_administration': _methodOfAdministration,
        if (_selectedBatch != null) 'batch_id': _selectedBatch!.id,
        if (_selectedBatch != null && _selectedBatch!.houseId != null) 'house_id': _selectedBatch!.houseId,
        'used_immediately': _useNow,
        if (_dosesUsed != null) 'doses_used': _dosesUsed,
      };

      LogUtil.warning(expenditureData);


      final result = await _expenditureRepository.createExpenditure(expenditureData);

      switch (result) {
        case Success():
        // Move to success page
          _nextPage();
          break;
        case Failure(message: final error):
          ApiErrorHandler.handle(error);
          setState(() => _isSubmitting = false);
          break;
      }
    } catch (e) {
      ToastUtil.showError('Failed to record expense: $e');
      setState(() => _isSubmitting = false);
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
          if (_currentPage < 5)
            LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
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
                // Step 1: Category Selection
                CategorySelectionView(
                  categories: _categories,
                  isLoading: _isLoadingCategories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    LogUtil.warning(category);
                    setState(() => _selectedCategory = category);
                    _nextPage();
                  },
                ),

                // Step 2: Item Selection
                if(_selectedCategory != null)
                ItemSelectionView(
                  category: _selectedCategory!,
                  selectedItem: _selectedItem,
                  onItemSelected: (item) {
                    setState(() => _selectedItem = item);
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),

                // Step 3: Quantity & Price
                if(_selectedItem != null)
                QuantityPriceView(
                  item: _selectedItem!,
                  category: _selectedCategory!,
                  quantity: _quantity,
                  unitPrice: _unitPrice,
                  totalPrice: _totalPrice,
                  methodOfAdministration: _methodOfAdministration,
                  selectedDate: _selectedDate,
                  onContinue: ({
                    required double quantity,
                    required double unitPrice,
                    required double totalPrice,
                    String? methodOfAdministration,
                    String? notes,
                    required DateTime selectedDate,
                  }) {
                    setState(() {
                      _quantity = quantity;
                      _unitPrice = unitPrice;
                      _totalPrice = totalPrice;
                      _methodOfAdministration = methodOfAdministration;
                      _selectedDate = selectedDate;
                    });
                    // Check if category and item can use from store
                    // If not, skip usage choice and go directly to batch selection
                    if (_selectedCategory!.useFromStore && _selectedItem!.useFromStore) {
                      _nextPage();
                    } else {
                      // Cannot store, use immediately - skip to batch selection
                      setState(() => _useNow = true);
                      _goToPage(4); // Skip usage choice, go to batch selection
                    }
                  },
                  onBack: _previousPage,
                ),

                // Step 4: Usage Choice (only shown if useFromStore is true for both category and item)
                if(_selectedItem != null  && _quantity != null && _totalPrice != null)
                UsageChoiceView(
                  item: _selectedItem!,
                  quantity: _quantity!,
                  totalPrice: _totalPrice!,
                  onChoice: (useNow) {
                    setState(() => _useNow = useNow);
                    if (useNow) {
                      // Go to batch selection
                      _nextPage();
                    } else {
                      // Submit directly (store)
                      _submitExpense();
                    }
                  },
                  onBack: _previousPage,
                ),

                // Step 5: Batch Selection (if use now)
                if (_useNow == true && _selectedItem != null && _selectedCategory != null && _quantity != null && _totalPrice != null)
                  BatchSelectionView(
                    farm: widget.farm,
                    batches: _batches,
                    selectedBatch: _selectedBatch,
                    isLoadingBatches: _isLoadingBatches,
                    item: _selectedItem!,
                    category: _selectedCategory!,
                    quantity: _quantity!,
                    onBatchSelected: (batch) {
                      setState(() => _selectedBatch = batch);
                    },
                    onSave: ({double? dosesUsed}) {
                      setState(() => _dosesUsed = dosesUsed);
                      _submitExpense();
                    },
                    onBack: _previousPage,
                    isSubmitting: _isSubmitting,
                  ),

                // Step 6: Success
                if(_selectedItem != null && _selectedCategory != null && _quantity != null && _totalPrice != null)
                SuccessView(
                  useNow: _useNow,
                  item: _selectedItem!,
                  category: _selectedCategory!,
                  quantity: _quantity!,
                  totalPrice: _totalPrice!,
                  selectedDate: _selectedDate,
                  batch: _selectedBatch,
                  dosesUsed: _dosesUsed,
                  farm: widget.farm,
                  onDone: () => context.pop(true),
                ),
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
        return 'Buy Inputs';
      case 1:
        return _selectedCategory?.name ?? 'Select Item';
      case 2:
        return _selectedItem?.categoryItemName ?? 'Quantity & Price';
      case 3:
        return _selectedItem?.categoryItemName ?? 'Usage';
      case 4:
        return 'Select Batch';
      case 5:
        return 'Success';
      default:
        return 'Buy Inputs';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}