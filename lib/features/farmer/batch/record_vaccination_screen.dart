import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/core/widgets/reusable_time_input.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/expense/repo/categories_repository.dart';
import 'package:agriflock360/features/farmer/expense/repo/expenditure_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VaccinationRecordScreen extends StatefulWidget {
  final String batchId;
  final String? farmId;
  final String? houseId;

  const VaccinationRecordScreen({
    super.key,
    required this.batchId,
    this.farmId,
    this.houseId,
  });

  @override
  State<VaccinationRecordScreen> createState() => _VaccinationRecordScreenState();
}

class _VaccinationRecordScreenState extends State<VaccinationRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _categoriesRepository = CategoriesRepository();
  final _expenditureRepository = ExpenditureRepository();

  // Page controllers for each tab
  final _schedulePageController = PageController();
  final _quickRecordPageController = PageController();

  // Form keys
  final _scheduleFormKey = GlobalKey<FormState>();
  final _quickRecordFormKey = GlobalKey<FormState>();

  // Schedule tab controllers
  final _scheduleQuantityController = TextEditingController();
  final _scheduleNotesController = TextEditingController();
  final _scheduleDateController = TextEditingController();

  // Quick record tab controllers
  final _quickQuantityController = TextEditingController();
  final _quickDosesController = TextEditingController();
  final _quickNotesController = TextEditingController();
  final _quickDateController = TextEditingController();

  // State
  InventoryCategory? _vaccineCategory;
  List<CategoryItem> _vaccineItems = [];

  // Schedule tab state
  int _scheduleCurrentPage = 0;
  CategoryItem? _scheduleSelectedItem;
  String? _scheduleMethodOfAdministration;
  TimeOfDay _scheduleTime = TimeOfDay.now();

  // Quick record tab state
  int _quickCurrentPage = 0;
  CategoryItem? _quickSelectedItem;
  String? _quickMethodOfAdministration;
  TimeOfDay _quickTime = TimeOfDay.now();

  bool _isLoadingCategories = true;
  bool _isSaving = false;
  String? _error;

  final List<String> _administrationMethods = [
    'Drinking Water',
    'Eye Drop',
    'Injection',
    'Spray',
    'Wing Web Stab',
    'Oral',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _error = null;
    });

    try {
      final result = await _categoriesRepository.getCategories();

      switch (result) {
        case Success<List<InventoryCategory>>(data: final categories):
          final vaccineCategory = categories.firstWhere(
            (cat) => cat.name.toLowerCase().contains('vaccine'),
            orElse: () => categories.first,
          );

          final vaccineItems = vaccineCategory.categoryItems
              .where((item) => item.useFromStore)
              .toList();

          setState(() {
            _vaccineCategory = vaccineCategory;
            _vaccineItems = vaccineItems;
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

  // Schedule tab navigation
  void _scheduleNextPage() {
    _schedulePageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _schedulePreviousPage() {
    _schedulePageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Quick record tab navigation
  void _quickNextPage() {
    _quickRecordPageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _quickPreviousPage() {
    _quickRecordPageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _scheduleVaccination() async {
    if (_scheduleSelectedItem == null) {
      ToastUtil.showError('Please select a vaccine');
      return;
    }

    if (!_scheduleFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
      if (_scheduleDateController.text.isNotEmpty) {
        try {
          selectedDate = DateTime.parse(_scheduleDateController.text);
        } catch (e) {
          selectedDate = DateTime.now().add(const Duration(days: 1));
        }
      }

      // Combine date and time
      final combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _scheduleTime.hour,
        _scheduleTime.minute,
      );

      final recordData = {
        if (widget.farmId != null) 'farm_id': widget.farmId,
        'batch_id': widget.batchId,
        if (widget.houseId != null) 'house_id': widget.houseId,
        'category_id': _vaccineCategory!.id,
        'category_item_id': _scheduleSelectedItem!.id,
        'description': _scheduleSelectedItem!.categoryItemName,
        'quantity': double.parse(_scheduleQuantityController.text),
        'unit': 'doses',
        'scheduled_date': combinedDateTime.toUtc().toIso8601String(),
        'status': 'scheduled',
        if (_scheduleNotesController.text.isNotEmpty)
          'notes': _scheduleNotesController.text,
        if (_scheduleMethodOfAdministration != null)
          'method_of_administration': _scheduleMethodOfAdministration,
      };

      LogUtil.info('Schedule Vaccination Payload: $recordData');

      final result = await _expenditureRepository.createExpenditure(recordData);

      switch (result) {
        case Success():
          ToastUtil.showSuccess('Vaccination scheduled successfully!');
          if (mounted) context.pop(true);
          break;
        case Failure(response: final response):
          ApiErrorHandler.handle(response);
          break;
      }
    } catch (e) {
      ToastUtil.showError('Failed to schedule vaccination: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _recordVaccination() async {
    if (_quickSelectedItem == null) {
      ToastUtil.showError('Please select a vaccine');
      return;
    }

    if (!_quickRecordFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      DateTime selectedDate = DateTime.now();
      if (_quickDateController.text.isNotEmpty) {
        try {
          selectedDate = DateTime.parse(_quickDateController.text);
        } catch (e) {
          selectedDate = DateTime.now();
        }
      }

      // Combine date and time
      final combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _quickTime.hour,
        _quickTime.minute,
      );

      final recordData = {
        if (widget.farmId != null) 'farm_id': widget.farmId,
        'batch_id': widget.batchId,
        if (widget.houseId != null) 'house_id': widget.houseId,
        'category_id': _vaccineCategory!.id,
        'category_item_id': _quickSelectedItem!.id,
        'description': _quickSelectedItem!.categoryItemName,
        'quantity': double.parse(_quickQuantityController.text),
        'unit': 'doses',
        'date': combinedDateTime.toUtc().toIso8601String(),
        if (_quickNotesController.text.isNotEmpty)
          'notes': _quickNotesController.text,
        if (_quickMethodOfAdministration != null)
          'method_of_administration': _quickMethodOfAdministration,
        if (_quickDosesController.text.isNotEmpty)
          'doses_used': double.parse(_quickDosesController.text),
      };

      LogUtil.info('Record Vaccination Payload: $recordData');

      final result = await _expenditureRepository.createExpenditure(recordData);

      switch (result) {
        case Success():
          ToastUtil.showSuccess('Vaccination recorded successfully!');
          if (mounted) context.pop(true);
          break;
        case Failure(response: final response):
          ApiErrorHandler.handle(response);
          break;
      }
    } catch (e) {
      ToastUtil.showError('Failed to record vaccination: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Vaccination'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () {
            // Check if we need to go back in PageView first
            if (_tabController.index == 0 && _scheduleCurrentPage > 0) {
              _schedulePreviousPage();
            } else if (_tabController.index == 1 && _quickCurrentPage > 0) {
              _quickPreviousPage();
            } else {
              context.pop();
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1.5),
              ),
              labelColor: Colors.blue.shade700,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: [
                _buildTab(Icons.calendar_today, 'Schedule New'),
                _buildTab(Icons.check_circle, 'Quick Record'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildScheduleTab(),
                    _buildQuickRecordTab(),
                  ],
                ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
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

  // ==================== SCHEDULE TAB ====================
  Widget _buildScheduleTab() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_scheduleCurrentPage + 1) / 2,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        Expanded(
          child: PageView(
            controller: _schedulePageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              setState(() => _scheduleCurrentPage = page);
            },
            children: [
              _buildVaccineSelectionPage(
                selectedItem: _scheduleSelectedItem,
                onSelect: (item) {
                  setState(() => _scheduleSelectedItem = item);
                  _scheduleNextPage();
                },
                color: Colors.blue,
              ),
              _buildScheduleDetailsPage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _scheduleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Schedule Vaccination',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Plan a future vaccination for your batch',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected vaccine card
            if (_scheduleSelectedItem != null)
              _buildSelectedItemCard(_scheduleSelectedItem!, Colors.blue, _schedulePreviousPage),
            const SizedBox(height: 20),

            // Administration Method
            ReusableDropdown<String>(
              topLabel: 'Administration Method',
              value: _scheduleMethodOfAdministration,
              hintText: 'Select method',
              items: _administrationMethods.map((method) {
                return DropdownMenuItem<String>(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                setState(() => _scheduleMethodOfAdministration = value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select administration method';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Quantity
            ReusableInput(
              topLabel: 'Quantity',
              icon: Icons.inventory_2,
              controller: _scheduleQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Enter quantity',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Scheduled Date (from tomorrow)
            CustomDateTextField(
              label: 'Scheduled Date',
              icon: Icons.calendar_today,
              required: true,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              minYear: DateTime.now().year,
              maxYear: DateTime.now().year + 1,
              returnFormat: DateReturnFormat.isoString,
              controller: _scheduleDateController,
              customValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date';
                }
                try {
                  final date = DateTime.parse(value);
                  final tomorrow = DateTime.now().add(const Duration(days: 1));
                  final tomorrowStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
                  if (date.isBefore(tomorrowStart)) {
                    return 'Date must be from tomorrow onwards';
                  }
                } catch (e) {
                  return 'Invalid date';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Scheduled Time
            ReusableTimeInput(
              topLabel: 'Scheduled Time',
              showIconOutline: true,
              initialTime: TimeOfDay.now(),
              onTimeChanged: (time) {
                _scheduleTime = time;
              },
            ),
            const SizedBox(height: 20),

            // Notes
            ReusableInput(
              topLabel: 'Notes (Optional)',
              icon: Icons.note,
              controller: _scheduleNotesController,
              maxLines: 3,
              hintText: 'Special instructions...',
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _scheduleVaccination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule),
                          SizedBox(width: 8),
                          Text('Schedule Vaccination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== QUICK RECORD TAB ====================
  Widget _buildQuickRecordTab() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_quickCurrentPage + 1) / 2,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        Expanded(
          child: PageView(
            controller: _quickRecordPageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              setState(() => _quickCurrentPage = page);
            },
            children: [
              _buildVaccineSelectionPage(
                selectedItem: _quickSelectedItem,
                onSelect: (item) {
                  setState(() => _quickSelectedItem = item);
                  _quickNextPage();
                },
                color: Colors.green,
              ),
              _buildQuickRecordDetailsPage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickRecordDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _quickRecordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.green.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Record',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Record a completed vaccination',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected vaccine card
            if (_quickSelectedItem != null)
              _buildSelectedItemCard(_quickSelectedItem!, Colors.green, _quickPreviousPage),
            const SizedBox(height: 20),

            // Administration Method
            ReusableDropdown<String>(
              topLabel: 'Administration Method',
              value: _quickMethodOfAdministration,
              hintText: 'Select method',
              items: _administrationMethods.map((method) {
                return DropdownMenuItem<String>(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                setState(() => _quickMethodOfAdministration = value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select administration method';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Quantity
            ReusableInput(
              topLabel: 'Quantity Used',
              icon: Icons.inventory_2,
              controller: _quickQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Enter quantity',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Doses (optional)
            ReusableInput(
              topLabel: 'Doses Administered (Optional)',
              icon: Icons.medical_information,
              controller: _quickDosesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Number of doses',
            ),
            const SizedBox(height: 20),

            // Completed Date
            CustomDateTextField(
              label: 'Completed Date',
              icon: Icons.calendar_today,
              required: true,
              initialDate: DateTime.now(),
              minYear: DateTime.now().year - 1,
              maxYear: DateTime.now().year,
              returnFormat: DateReturnFormat.isoString,
              controller: _quickDateController,
            ),
            const SizedBox(height: 20),

            // Completed Time
            ReusableTimeInput(
              topLabel: 'Completed Time',
              showIconOutline: true,
              initialTime: TimeOfDay.now(),
              onTimeChanged: (time) {
                _quickTime = time;
              },
            ),
            const SizedBox(height: 20),

            // Notes
            ReusableInput(
              topLabel: 'Notes (Optional)',
              icon: Icons.note,
              controller: _quickNotesController,
              maxLines: 3,
              hintText: 'Observations, reactions...',
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _recordVaccination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle),
                          SizedBox(width: 8),
                          Text('Record Vaccination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SHARED WIDGETS ====================
  Widget _buildVaccineSelectionPage({
    required CategoryItem? selectedItem,
    required Function(CategoryItem) onSelect,
    required Color color,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Vaccine',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the vaccine to administer',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          if (_vaccineItems.isEmpty)
            _buildEmptyState(color)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _vaccineItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _vaccineItems[index];
                final isSelected = selectedItem?.id == item.id;

                return GestureDetector(
                  onTap: () => onSelect(item),
                  child: _buildItemCard(item, isSelected, color),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemCard(CategoryItem item, Color color, VoidCallback onEdit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.vaccines, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryItemName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: color),
            onPressed: onEdit,
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
            child: Icon(Icons.vaccines, size: 24, color: color),
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
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            'No vaccines available',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            'Please add vaccines to your inventory first',
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _schedulePageController.dispose();
    _quickRecordPageController.dispose();
    _scheduleQuantityController.dispose();
    _scheduleNotesController.dispose();
    _scheduleDateController.dispose();
    _quickQuantityController.dispose();
    _quickDosesController.dispose();
    _quickNotesController.dispose();
    _quickDateController.dispose();
    super.dispose();
  }
}
