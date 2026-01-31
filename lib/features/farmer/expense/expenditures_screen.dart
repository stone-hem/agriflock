import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/expense/model/expenditure_model.dart';
import 'package:agriflock360/features/farmer/expense/repo/expenditure_repository.dart';

class ExpendituresScreen extends StatefulWidget {
  const ExpendituresScreen({super.key});

  @override
  State<ExpendituresScreen> createState() => _ExpendituresScreenState();
}

class _ExpendituresScreenState extends State<ExpendituresScreen> {
  final _farmRepository = FarmRepository();
  final _batchHouseRepository = BatchHouseRepository();
  final _expenditureRepository = ExpenditureRepository();

  // Selection states
  String? _selectedFarm;
  String? _selectedHouse;
  String? _selectedBatch;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Data states
  FarmsResponse? _farmsResponse;
  List<House> _houses = [];
  List<BatchModel> _availableBatches = [];
  List<Expenditure> _expenditures = [];

  // Loading states
  bool _isLoadingFarms = false;
  bool _isLoadingHouses = false;
  bool _isLoadingExpenditures = false;
  bool _hasError = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Totals
  double _totalAmount = 0;
  int _totalItems = 0;

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingNextPage = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingNextPage &&
          _hasMore) {
        _loadMoreExpenditures();
      }
    });
  }

  void _initializeData() {
    _loadFarms();
    _loadExpenditures(reset: true);
  }

  Future<void> _loadFarms() async {
    setState(() {
      _isLoadingFarms = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final result = await _farmRepository.getAllFarmsWithStats();

      switch (result) {
        case Success<FarmsResponse>(data: final data):
          setState(() {
            _farmsResponse = data;
            _isLoadingFarms = false;
          });
          break;
        case Failure(message: final error, :final statusCode, :final response):
          setState(() {
            _hasError = true;
            _errorMessage = error;
            _isLoadingFarms = false;
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load farms: $e';
        _isLoadingFarms = false;
      });
    }
  }

  Future<void> _loadHousesForSelectedFarm() async {
    if (_selectedFarm == null) return;

    setState(() {
      _isLoadingHouses = true;
      _houses = [];
      _availableBatches = [];
      _selectedHouse = null;
      _selectedBatch = null;
    });

    try {
      final result = await _batchHouseRepository.getAllHouses(_selectedFarm!);

      switch (result) {
        case Success<List<House>>(data: final houses):
          setState(() {
            _houses = houses;
            _isLoadingHouses = false;
          });
          // Load expenditures after houses are loaded
          _loadExpenditures(reset: true);
          break;
        case Failure(message: final error):
          setState(() {
            _isLoadingHouses = false;
            _errorMessage = 'Failed to load houses: $error';
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _isLoadingHouses = false;
        _errorMessage = 'Failed to load houses: $e';
      });
    }
  }

  Future<void> _loadExpenditures({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _expenditures = [];
        _hasMore = true;
        _totalAmount = 0;
        _totalItems = 0;
        _isLoadingNextPage = false;
      });
    }

    if (!_hasMore && !reset) return;

    setState(() {
      _isLoadingExpenditures = true;
    });

    try {
      final result = await _expenditureRepository.getExpenditures(
        farmId: _selectedFarm,
        houseId: _selectedHouse,
        batchId: _selectedBatch,
        categoryId: _selectedCategory,
        startDate: _startDateController.text.isNotEmpty
            ? _startDateController.text
            : null,
        endDate: _endDateController.text.isNotEmpty
            ? _endDateController.text
            : null,
        searchQuery: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      );

      switch (result) {
        case Success<ExpenditureResponse>(data: final response):
          setState(() {
            if (reset) {
              _expenditures = response.data;
            } else {
              _expenditures.addAll(response.data);
            }
            _isLoadingExpenditures = false;
            _isLoadingMore = false;
            _isLoadingNextPage = false;
            _hasMore = response.data.length >= _itemsPerPage;

            // Calculate totals
            _totalAmount = _expenditures.fold(0, (sum, exp) => sum + exp.amount);
            _totalItems = response.count;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _isLoadingExpenditures = false;
            _isLoadingMore = false;
            _isLoadingNextPage = false;
            _errorMessage = 'Failed to load expenditures: $error';
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _isLoadingExpenditures = false;
        _isLoadingMore = false;
        _isLoadingNextPage = false;
        _errorMessage = 'Failed to load expenditures: $e';
      });
    }
  }

  Future<void> _loadMoreExpenditures() async {
    if (_isLoadingNextPage || !_hasMore) return;

    setState(() {
      _isLoadingNextPage = true;
      _currentPage++;
    });

    await _loadExpenditures();
  }

  Future<void> _deleteExpenditure(String expenditureId) async {
    try {
      final result = await _expenditureRepository.deleteExpenditure(expenditureId);

      switch (result) {
        case Success():
        // Remove from list
          setState(() {
            _expenditures.removeWhere((exp) => exp.id == expenditureId);
            // Recalculate totals
            _totalAmount = _expenditures.fold(0, (sum, exp) => sum + exp.amount);
            _totalItems--;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expenditure deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          break;
        case Failure(message: final error):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete expenditure: $error'),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete expenditure: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(Expenditure expenditure) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expenditure'),
        content: Text(
          'Are you sure you want to delete "${expenditure.description}"?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteExpenditure(expenditure.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedFarm = null;
      _selectedHouse = null;
      _selectedBatch = null;
      _selectedCategory = null;
      _houses = [];
      _availableBatches = [];
      _searchController.clear();
      _startDateController.clear();
      _endDateController.clear();
    });
    _loadExpenditures(reset: true);
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              if (_selectedFarm != null ||
                  _selectedHouse != null ||
                  _selectedBatch != null ||
                  _startDateController.text.isNotEmpty ||
                  _endDateController.text.isNotEmpty ||
                  _searchController.text.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Farm Dropdown
          if (_farmsResponse != null && _farmsResponse!.farms.isNotEmpty)
            ReusableDropdown(
              value: _selectedFarm,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('All Farms'),
                  ),
                ),
                ..._farmsResponse!.farms.map((farm) {
                  return DropdownMenuItem<String>(
                    value: farm.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(farm.farmName),
                    ),
                  );
                }),
              ],
              hintText: 'All Farms',
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFarm = newValue;
                  _selectedHouse = null;
                  _selectedBatch = null;
                  _houses = [];
                  _availableBatches = [];
                });
                if (newValue != null) {
                  _loadHousesForSelectedFarm();
                } else {
                  _loadExpenditures(reset: true);
                }
              },
            ),

          const SizedBox(height: 8),

          // House Dropdown
          if (_houses.isNotEmpty)
            ReusableDropdown(
              value: _selectedHouse,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('All Houses'),
                  ),
                ),
                ..._houses.map((house) {
                  return DropdownMenuItem<String>(
                    value: house.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(house.houseName),
                    ),
                  );
                }),
              ],
              hintText: 'All Houses',
              onChanged: (String? newValue) {
                setState(() {
                  _selectedHouse = newValue;
                  _selectedBatch = null;
                  _availableBatches = [];

                  if (newValue != null) {
                    final selectedHouse = _houses.firstWhere(
                      (house) => house.id == newValue,
                    );
                    _availableBatches = selectedHouse.batches;
                  }
                });
                _loadExpenditures(reset: true);
              },
            ),

          if (_houses.isNotEmpty) const SizedBox(height: 8),

          // Batch Dropdown
          if (_selectedHouse != null && _availableBatches.isNotEmpty)
            ReusableDropdown(
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('All Batches'),
                  ),
                ),
                ..._availableBatches.map((batch) {
                  return DropdownMenuItem<String>(
                    value: batch.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(batch.batchName),
                    ),
                  );
                }).toList(),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBatch = newValue;
                });
                _loadExpenditures(reset: true);
              },
              hintText: 'All Batches',
              value: _selectedBatch,
            ),

          if (_selectedHouse != null && _availableBatches.isNotEmpty)
            const SizedBox(height: 12),

          // Search
          ReusableInput(
            controller: _searchController,
            hintText: 'Search expenditures...',
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _loadExpenditures(reset: true);
                    },
                  )
                : null,
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (value == _searchController.text) {
                  _loadExpenditures(reset: true);
                }
              });
            },
          ),

          const SizedBox(height: 12),
          CustomDateTextField(
            label: 'Start Date',
            icon: Icons.calendar_today,
            controller: _startDateController,
            minYear: 2023,
            maxYear: DateTime.now().year,
            returnFormat: DateReturnFormat.isoString,
          ),
          const SizedBox(height: 12),
          CustomDateTextField(
            label: 'End Date',
            icon: Icons.calendar_today,
            controller: _endDateController,
            minYear: 2023,
            maxYear: DateTime.now().year,
            returnFormat: DateReturnFormat.isoString,
          ),

          const SizedBox(height: 12),

          // Apply Date Filter Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _loadExpenditures(reset: true),
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text('Apply Date Filter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_isLoadingExpenditures && _expenditures.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.lightBlue.shade50],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              value: 'Ksh ${_totalAmount.toStringAsFixed(2)}',
              label: 'Total Amount',
              icon: Icons.attach_money,
              color: Colors.blue.shade100,
              textColor: Colors.blue.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: '$_totalItems',
              label: 'Total Expenses',
              icon: Icons.receipt,
              color: Colors.green.shade100,
              textColor: Colors.green.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: _expenditures.isEmpty
                  ? '0'
                  : (_totalAmount / _expenditures.length).toStringAsFixed(2),
              label: 'Average Cost',
              icon: Icons.trending_up,
              color: Colors.purple.shade100,
              textColor: Colors.purple.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: textColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpendituresList() {
    if (_isLoadingExpenditures && _expenditures.isEmpty) {
      return _buildLoadingIndicator('Loading expenditures...');
    }

    if (_expenditures.isEmpty) {
      return _buildEmptyState('No expenditures found');
    }

    return Column(
      children: [
        ..._expenditures.map((expenditure) => _ExpenditureCard(
          expenditure: expenditure,
          onDelete: () => _showDeleteDialog(expenditure),
        )),
        if (_isLoadingNextPage)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        if (_hasMore && !_isLoadingNextPage && _expenditures.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: _loadMoreExpenditures,
                child: const Text('Load More'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFarms,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (_farmsResponse != null && _farmsResponse!.farms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  final farm = _selectedFarm != null
                      ? _farmsResponse!.farms.firstWhere((f) => f.id == _selectedFarm)
                      : _farmsResponse!.farms.first;
                  context.push('/record-expenditure', extra: farm);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Expenditure'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 30,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text('Expenditures'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadExpenditures(reset: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadExpenditures(reset: true),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              _buildFilterSection(),

              // Stats Section
              _buildStatsSection(),

              // Expenditures List
              _buildExpendituresList(),

              // Bottom padding
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _farmsResponse != null && _farmsResponse!.farms.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                final farm = _selectedFarm != null
                    ? _farmsResponse!.farms.firstWhere((f) => f.id == _selectedFarm)
                    : _farmsResponse!.farms.first;
                context.push('/record-expenditure', extra: farm);
              },
              icon: const Icon(Icons.add),
              label: const Text('New Expense'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

class _ExpenditureCard extends StatelessWidget {
  final Expenditure expenditure;
  final VoidCallback onDelete;

  const _ExpenditureCard({
    required this.expenditure,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Delete Icon
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expenditure.category.name).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(expenditure.category.name),
                    size: 20,
                    color: _getCategoryColor(expenditure.category.name),
                  ),
                ),
                const SizedBox(width: 12),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expenditure.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expenditure.category.name,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateUtil.toMMDDYYYY(expenditure.date),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount and Delete Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Ksh ${expenditure.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      color: Colors.grey.shade500,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details Divider
          Divider(height: 1, color: Colors.grey.shade200),

          // Details Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Quantity
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.format_list_numbered,
                    label: 'Quantity',
                    value: '${expenditure.quantity} ${expenditure.unit}',
                  ),
                ),

                // Supplier
                if (expenditure.supplier != null) ...[
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.store,
                      label: 'Supplier',
                      value: expenditure.supplier!,
                    ),
                  ),
                ],

                // Inventory Status
                if (expenditure.inventoryItem != null) ...[
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.inventory_2,
                      label: 'Inventory',
                      value: expenditure.inventoryItem!.status.replaceAll('_', ' '),
                      valueColor: expenditure.inventoryItem!.status == 'low_stock'
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.grey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('feed')) {
      return Icons.fastfood;
    } else if (lowerName.contains('medication') || lowerName.contains('vaccine') || lowerName.contains('medicine')) {
      return Icons.medical_services;
    } else if (lowerName.contains('cleaning')) {
      return Icons.clean_hands;
    } else if (lowerName.contains('utility') || lowerName.contains('utilities') || lowerName.contains('electricity') || lowerName.contains('water')) {
      return Icons.bolt;
    } else if (lowerName.contains('labor') || lowerName.contains('labour')) {
      return Icons.people;
    } else if (lowerName.contains('equipment') || lowerName.contains('tool')) {
      return Icons.build;
    } else if (lowerName.contains('transport')) {
      return Icons.local_shipping;
    } else {
      return Icons.account_balance_wallet;
    }
  }

  Color _getCategoryColor(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('feed')) {
      return Colors.orange;
    } else if (lowerName.contains('medication') || lowerName.contains('vaccine') || lowerName.contains('medicine')) {
      return Colors.red;
    } else if (lowerName.contains('cleaning')) {
      return Colors.blue;
    } else if (lowerName.contains('utility') || lowerName.contains('utilities') || lowerName.contains('electricity') || lowerName.contains('water')) {
      return Colors.yellow.shade700;
    } else if (lowerName.contains('labor') || lowerName.contains('labour')) {
      return Colors.purple;
    } else if (lowerName.contains('equipment') || lowerName.contains('tool')) {
      return Colors.brown;
    } else if (lowerName.contains('transport')) {
      return Colors.teal;
    } else {
      return Colors.green;
    }
  }
}