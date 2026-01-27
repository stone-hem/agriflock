import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/expense/repo/categories_repository.dart';
import 'package:agriflock360/features/farmer/expense/repo/expenditure_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecordExpenditureScreen extends StatefulWidget {
  final FarmModel? farm; // Optional farm passed from previous screen

  const RecordExpenditureScreen({
    super.key,
    this.farm,
  });

  @override
  State<RecordExpenditureScreen> createState() => _RecordExpenditureScreenState();
}

class _RecordExpenditureScreenState extends State<RecordExpenditureScreen> {
  final _formKey = GlobalKey<FormState>();

  // Repositories
  final _farmRepository = FarmRepository();
  final _batchHouseRepository = BatchHouseRepository();
  final _categoriesRepository = CategoriesRepository();
  final _expenditureRepository = ExpenditureRepository();

  // Selection states
  String? _selectedFarm;
  String? _selectedHouse;
  String? _selectedBatch;

  // Data states
  FarmsResponse? _farmsResponse;
  List<House> _houses = [];
  List<BatchModel> _availableBatches = [];
  List<InventoryCategory> _categories = [];

  // Loading states
  bool _isLoadingFarms = false;
  bool _isLoadingHouses = false;
  bool _isLoadingCategories = false;
  bool _hasError = false;
  String? _errorMessage;

  // Form fields
  String? _selectedCategoryId;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _selectedDateController = TextEditingController();
  String? _selectedUnit;
  final TextEditingController _supplierController = TextEditingController();

  bool _isSubmitting = false;
  String? _submitErrorMessage;

  final List<String> _units = [
    'bag',
    'kg',
    'liter',
    'dose',
    'unit',
    'hour',
    'day',
    'month',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Load categories first
    _loadCategories();

    // If farm is passed, use it
    if (widget.farm != null) {
      setState(() {
        _selectedFarm = widget.farm!.id;
      });
      _loadHousesForSelectedFarm();
    } else {
      // Otherwise load all farms
      _loadFarms();
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

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
          setState(() {
            _isLoadingCategories = false;
            _errorMessage = 'Failed to load categories: $error';
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
        _errorMessage = 'Failed to load categories: $e';
      });
    }
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

  void _onHouseSelected(String? houseId) {
    setState(() {
      _selectedHouse = houseId;
      _selectedBatch = null;

      // Extract batches from selected house
      if (houseId != null) {
        final selectedHouse = _houses.firstWhere(
              (house) => house.id == houseId,
          orElse: () => _houses.isNotEmpty
              ? _houses.first
              : House(
            id: '',
            houseName: '',
            capacity: 0,
            batches: [],
          ),
        );
        _availableBatches = selectedHouse.batches;
      } else {
        _availableBatches = [];
      }
    });
  }

  Future<void> _submitExpenditure() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if(_selectedDateController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),));
    }

    final DateTime? selectedDate =DateUtil.parseDDMMYYYY(_selectedDateController.text);


    setState(() {
      _isSubmitting = true;
      _submitErrorMessage = null;
    });


    try {
      // Prepare expenditure data
      final expenditureData = {
        'farm_id': _selectedFarm,
        if (_selectedHouse != null) 'house_id': _selectedHouse,
        if (_selectedBatch != null) 'batch_id': _selectedBatch,
        'category_id': _selectedCategoryId!,
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'quantity': int.parse(_quantityController.text),
        'unit': _selectedUnit!,
        'date': DateUtil.toISO8601(selectedDate!),
        if (_supplierController.text.isNotEmpty) 'supplier': _supplierController.text,
      };

      final result = await _expenditureRepository.createExpenditure(expenditureData);

      switch (result) {
        case Success():
        // Return success
          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expenditure recorded successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(true); // Return true to indicate success
          }
          break;
        case Failure(message: final error):
          setState(() {
            _submitErrorMessage = error;
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _submitErrorMessage = 'Failed to record expenditure: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildFarmDetails() {
    if (_selectedFarm == null) return const SizedBox();

    FarmModel? farm;
    if (widget.farm != null && widget.farm!.id == _selectedFarm) {
      farm = widget.farm;
    } else if (_farmsResponse != null) {
      farm = _farmsResponse!.farms.firstWhere(
            (f) => f.id == _selectedFarm,
        orElse: () => _farmsResponse!.farms.first,
      );
    }

    if (farm == null) return const SizedBox();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            farm.farmName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (farm.location != null && farm.location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      farm.location!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHouseDetails() {
    if (_selectedHouse == null) return const SizedBox();

    final house = _houses.firstWhere(
          (h) => h.id == _selectedHouse,
      orElse: () => _houses.isNotEmpty ? _houses.first : House(
        id: '',
        houseName: '',
        capacity: 0,
        batches: [],
      ),
    );

    final batchCount = house.batches.length;
    final currentBirds = house.currentBirds;
    final capacity = house.capacity;
    final utilization = capacity > 0 ? (currentBirds / capacity * 100) : 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            house.houseName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  'Capacity: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '$currentBirds/$capacity birds',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Text(
                  'Batches: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '$batchCount batch${batchCount == 1 ? '' : 'es'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Utilization: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${utilization.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: utilization > 80 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchDetails() {
    if (_selectedBatch == null) return const SizedBox();

    final batch = _availableBatches.firstWhere(
          (b) => b.id == _selectedBatch,
      orElse: () => _availableBatches.isNotEmpty ? _availableBatches.first : BatchModel(
        id: '',
        batchName: '',
        initialQuantity: 0,
        birdsAlive: 0,
        age: 0,
        type: '',
        birdTypeId: '',
        breed: '',
        startDate: DateTime.now(),
        currentWeight: 1,
        expectedWeight: 0,
        feedingTime: '',
        feedingSchedule: [],
      ),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            batch.batchName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  'Birds: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${batch.birdsAlive} alive',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Age: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${batch.age} days',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (batch.type.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Text(
                    'Type: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    batch.type,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFarmDropdown() {
    // If farm is passed from previous screen, don't show dropdown
    if (widget.farm != null) {
      return Container();
    }

    if (_isLoadingFarms) {
      return _buildLoadingIndicator('Loading farms...');
    }

    if (_hasError) {
      return _buildErrorWidget(_errorMessage ?? 'Failed to load farms', _loadFarms);
    }

    if (_farmsResponse == null || _farmsResponse!.farms.isEmpty) {
      return _buildEmptyState('No farms available');
    }

    return ReusableDropdown<String>(
      value: _selectedFarm,
      hintText: 'Choose a farm',
      topLabel: 'Farm *',
      icon: Icons.agriculture,
      isExpanded: true,
      items: _farmsResponse!.farms.map((farm) {
        return DropdownMenuItem<String>(
          value: farm.id,
          child: Text(
            farm.farmName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
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
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a farm';
        }
        return null;
      },
    );
  }

  Widget _buildHouseDropdown() {
    if (_selectedFarm == null) return const SizedBox();

    if (_isLoadingHouses) {
      return _buildLoadingIndicator('Loading houses...');
    }

    if (_houses.isEmpty) {
      return _buildEmptyState('No houses available in this farm');
    }

    return ReusableDropdown<String>(
      value: _selectedHouse,
      hintText: 'Choose a poultry house (Optional)',
      topLabel: 'House',
      icon: Icons.home_work,
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            'None (General farm expenditure)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        ..._houses.map((house) {
          return DropdownMenuItem<String>(
            value: house.id,
            child: Text(
              house.houseName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ],
      onChanged: _onHouseSelected,
    );
  }

  Widget _buildBatchDropdown() {
    if (_selectedHouse == null) return const SizedBox();

    if (_availableBatches.isEmpty) {
      return _buildEmptyState('No batches available in this house');
    }

    return ReusableDropdown<String>(
      value: _selectedBatch,
      hintText: 'Choose a batch (Optional)',
      topLabel: 'Batch',
      icon: Icons.pets,
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            'None (General house expenditure)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        ..._availableBatches.map((batch) {
          return DropdownMenuItem<String>(
            value: batch.id,
            child: Text(
              batch.batchName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          );
        }),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _selectedBatch = newValue;
        });
      },
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return _buildLoadingIndicator('Loading categories...');
    }

    if (_categories.isEmpty) {
      return _buildErrorWidget(
        'No categories available. Please try again.',
        _loadCategories,
      );
    }

    return ReusableDropdown<String>(
      value: _selectedCategoryId,
      topLabel: 'Expenditure Category *',
      icon: Icons.category,
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select expenditure category';
        }
        return null;
      },
      hintText: 'Select category',
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category.name),
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Text(message),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('feed')) {
      return Icons.fastfood;
    } else if (lowerName.contains('medication') || lowerName.contains('vaccine') || lowerName.contains('medicine')) {
      return Icons.medical_services;
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

  String _getExpenditureContext() {
    if (_selectedBatch != null) {
      return 'Batch: ${_availableBatches.firstWhere((b) => b.id == _selectedBatch, orElse: () => _availableBatches.isNotEmpty ? _availableBatches.first : BatchModel(id: '', batchName: 'Unknown', initialQuantity: 0, birdsAlive: 0, age: 0, type: '', birdTypeId: '', breed: '', startDate: DateTime.now(), currentWeight: 1, expectedWeight: 0, feedingTime: '', feedingSchedule: [])).batchName}';
    } else if (_selectedHouse != null) {
      return 'House: ${_houses.firstWhere((h) => h.id == _selectedHouse, orElse: () => _houses.isNotEmpty ? _houses.first : House(id: '', houseName: 'Unknown', capacity: 0, batches: [])).houseName}';
    } else if (_selectedFarm != null) {
      FarmModel? farm;
      if (widget.farm != null && widget.farm!.id == _selectedFarm) {
        farm = widget.farm;
      } else if (_farmsResponse != null) {
        farm = _farmsResponse!.farms.firstWhere(
              (f) => f.id == _selectedFarm,
          orElse: () => _farmsResponse!.farms.first,
        );
      }
      return 'Farm: ${farm?.farmName ?? 'Unknown'}';
    }
    return 'Recording expenditure';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Record Expenditure'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expenditure Context Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.agriculture, size: 20, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recording for',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _getExpenditureContext(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_selectedBatch != null || _selectedHouse != null || _selectedFarm != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${_selectedBatch != null ? 'Batch-level' : _selectedHouse != null ? 'House-level' : 'Farm-level'} expenditure',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_submitErrorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _submitErrorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Farm Selection (only if not passed from previous screen)
              _buildFarmDropdown(),
              if (_selectedFarm != null) _buildFarmDetails(),
              const SizedBox(height: 20),

              // House Selection (optional)
              if (_selectedFarm != null) ...[
                _buildHouseDropdown(),
                if (_selectedHouse != null) _buildHouseDetails(),
                const SizedBox(height: 20),
              ],

              // Batch Selection (optional)
              if (_selectedHouse != null) ...[
                _buildBatchDropdown(),
                if (_selectedBatch != null) _buildBatchDetails(),
                const SizedBox(height: 20),
              ],

              // Expenditure Category
              _buildCategoryDropdown(),
              const SizedBox(height: 20),

              // Description
              ReusableInput(
                topLabel: 'Description *',
                icon: Icons.description,
                maxLines: 2,
                hintText: 'e.g., Layer mash feed purchase',
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),

              // Amount
              ReusableInput(
                topLabel: 'Amount (Ksh) *',
                icon: Icons.attach_money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
                hintText: '0.00',
                keyboardType: TextInputType.number,
                controller: _amountController,
              ),

              // Quantity and Unit Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ReusableInput(
                      topLabel: 'Quantity',
                      icon: Icons.format_list_numbered,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Quantity must be greater than 0';
                        }
                        return null;
                      },
                      hintText: '1',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ReusableDropdown<String>(
                      value: _selectedUnit,
                      hintText: 'Unit',
                      topLabel: 'Unit',
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select unit';
                        }
                        return null;
                      },
                      items: _units.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              // Date
              CustomDateTextField(
                label: 'Date',
                icon: Icons.calendar_today,
                required: true,
                minYear: DateTime.now().year - 1,
                returnFormat: DateReturnFormat.isoString,
                maxYear: DateTime.now().year,
                controller: _selectedDateController,
              ),

              // Supplier
              ReusableInput(
                topLabel: 'Supplier (Optional)',
                icon: Icons.store,
                controller: _supplierController,
                hintText: 'e.g., FeedCo Ltd',
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _selectedFarm == null) ? null : _submitExpenditure,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Record Expenditure',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _supplierController.dispose();
    _selectedDateController.dispose();
    super.dispose();
  }
}