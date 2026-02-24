import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/core/widgets/reusable_time_input.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/expense/repo/categories_repository.dart';
import 'package:agriflock360/features/farmer/record/repo/recording_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LogFeedingScreen extends StatefulWidget {
  final String batchId;
  final String? farmId;
  final String? houseId;
  final String? breedId;

  const LogFeedingScreen({
    super.key,
    required this.batchId,
    this.farmId,
    this.houseId,
    this.breedId,
  });

  @override
  State<LogFeedingScreen> createState() => _LogFeedingScreenState();
}

class _LogFeedingScreenState extends State<LogFeedingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoriesRepository = CategoriesRepository();
  final _recordingRepository = RecordingRepo();
  final _pageController = PageController();

  // Controllers
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();


  // State
  int _currentPage = 0;
  InventoryCategory? _feedCategory;
  List<CategoryItem> _feedItems = [];
  CategoryItem? _selectedFeedItem;
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isLoadingCategories = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _error = null;
    });

    try {
      final result = await _categoriesRepository.getCategories(breedId: widget.breedId);

      switch (result) {
        case Success<List<InventoryCategory>>(data: final categories):
          final feedCategory = categories.firstWhere(
            (cat) => cat.name.toLowerCase().contains('feed'),
            orElse: () => categories.first,
          );

          final feedItems = feedCategory.categoryItems
              .where((item) => item.useFromStore)
              .toList();

          setState(() {
            _feedCategory = feedCategory;
            _feedItems = feedItems;
            _isLoadingCategories = false;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _error = error;
            _isLoadingCategories = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingCategories = false;
      });
    }
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

  Future<void> _logFeeding() async {
    if (_selectedFeedItem == null) {
      ToastUtil.showError('Please select a feed type');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      DateTime selectedDate = DateTime.now();
      if (_dateController.text.isNotEmpty) {
        try {
          selectedDate = DateTime.parse(_dateController.text);
        } catch (e) {
          selectedDate = DateTime.now();
        }
      }

      // Combine date and time
      final combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final recordData = {
        'batch_id': widget.batchId,
        if (widget.houseId != null) 'house_id': widget.houseId,
        'category_id': _feedCategory!.id,
        'category_item_id': _selectedFeedItem!.id,
        'description': _selectedFeedItem!.categoryItemName,
        'quantity': double.parse(_quantityController.text),
        'unit': 'kg',
        'date': combinedDateTime.toUtc().toIso8601String(),
    if (_notesController.text.isNotEmpty) 'notes': _notesController.text
    };

      LogUtil.info('Log Feeding Payload: $recordData');

      final result = await _recordingRepository.createFeedingRecord(recordData);

      switch (result) {
        case Success():
          ToastUtil.showSuccess('Feeding logged successfully!');
          if (mounted) context.pop(true);
          break;
        case Failure(response: final response):
          ApiErrorHandler.handle(response);
          break;
      }
    } catch (e) {
      ToastUtil.showError('Failed to log feeding: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPage == 0 ? 'Select Feed' : 'Log Feeding'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () {
            if (_currentPage > 0) {
              _previousPage();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : Column(
                  children: [
                    // Progress indicator
                    LinearProgressIndicator(
                      value: (_currentPage + 1) / 2,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                        },
                        children: [
                          _buildFeedSelectionPage(),
                          _buildDetailsPage(),
                        ],
                      ),
                    ),
                  ],
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
            onPressed: _loadCategories,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Feed Type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type of feed you are logging',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          if (_feedItems.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _feedItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _feedItems[index];
                final isSelected = _selectedFeedItem?.id == item.id;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFeedItem = item);
                    _nextPage();
                  },
                  child: _buildItemCard(item, isSelected, Colors.orange),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected item card
            if (_selectedFeedItem != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.fastfood, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFeedItem!.categoryItemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (_selectedFeedItem!.description.isNotEmpty)
                            Text(
                              _selectedFeedItem!.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: _previousPage,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Quantity
            ReusableInput(
              topLabel: 'Feed Quantity (kg)',
              icon: Icons.scale,
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Enter feed quantity in kg',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter feed quantity';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Quantity must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Date
            CustomDateTextField(
              label: 'Feeding Date',
              icon: Icons.calendar_today,
              required: true,
              minYear: DateTime.now().year - 1,
              maxYear: DateTime.now().year,
              returnFormat: DateReturnFormat.isoString,
              controller: _dateController,
            ),
            const SizedBox(height: 20),

            // Time
            ReusableTimeInput(
              topLabel: 'Feeding Time',
              showIconOutline: true,
              initialTime: TimeOfDay.now(),
              onTimeChanged: (time) {
                _selectedTime = time;
              },
            ),
            const SizedBox(height: 20),

            // Mortality Rate
            ReusableInput(
              topLabel: 'Mortality Now (Optional)',
              icon: Icons.note,
              controller: _notesController,
              maxLines: 3,
              hintText: 'Number of chicks that have died at this time...',
            ),
            const SizedBox(height: 32),
            // Notes
            ReusableInput(
              topLabel: 'Notes (Optional)',
              icon: Icons.note,
              controller: _notesController,
              maxLines: 3,
              hintText: 'Any observations or special notes...',
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _logFeeding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
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
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text(
                            'Log Feeding',
                            style: TextStyle(
                              fontSize: 16,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber, size: 48, color: Colors.orange.shade600),
          const SizedBox(height: 12),
          Text(
            'No feed items available',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please add feed items to your inventory first',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(CategoryItem item, bool isSelected, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fastfood, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryItemName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : Colors.grey.shade800,
                  ),
                ),
                if (item.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
