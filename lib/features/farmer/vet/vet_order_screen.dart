import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/widgets/reusable_dropdown.dart';
import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock/features/farmer/farm/repositories/farm_repository.dart';
import 'package:agriflock/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock/features/farmer/vet/models/vet_order_model.dart';
import 'package:agriflock/features/farmer/vet/models/vet_service_type.dart';
import 'package:agriflock/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:agriflock/features/farmer/vet/widgets/order_process.dart';
import 'package:agriflock/features/farmer/vet/widgets/vet_order_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock/core/utils/result.dart';

class VetOrderScreen extends StatefulWidget {
  final VetFarmer vet;

  const VetOrderScreen({super.key, required this.vet});

  @override
  State<VetOrderScreen> createState() => _VetOrderScreenState();
}

class _VetOrderScreenState extends State<VetOrderScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();
  final _formKey = GlobalKey<FormState>();

  // Selection states
  String? _selectedFarm;
  String? _selectedHouse;
  List<String> _selectedBatches = [];
  List<String> _selectedServices = [];
  String? _selectedPriority;

  // Manual birds count (used when no farm/house/batch selected)
  final _birdsCountController = TextEditingController();
  int? _manualBirdsCount;

  // Number of people (for PER_PERSON services)
  final _numberOfPeopleController = TextEditingController();
  int? _numberOfPeople;

  // Bird types (for manual mode)
  List<BirdType> _birdTypes = [];
  bool _isLoadingBirdTypes = false;
  final Set<String> _selectedBirdTypeIds = {};
  // Shared flock detail fields (apply to all selected bird types)
  final _birdAgeController = TextEditingController();
  final _birdMortalityController = TextEditingController();
  String _birdAgeUnit = 'days';

  // Payment mode (both modes)
  String? _selectedPaymentMode;
  static const List<String> _paymentModes = [
    'M-Pesa',
    'Cash',
    'Card',
    'Bank Transfer',
  ];

  // Estimate state
  bool _isLoadingEstimate = false;

  // Service types - Dynamic from API
  List<VetServiceType> _serviceTypes = [];
  bool _isLoadingServices = false;
  String? _servicesError;

  // Repositories
  final _farmRepository = FarmRepository();
  final _batchHouseRepository = BatchHouseRepository();

  // Data states
  FarmsResponse? _farmsResponse;
  List<House> _houses = [];
  List<BatchModel> _availableBatches = [];

  // Loading states
  bool _isLoadingFarms = false;
  bool _isLoadingHouses = false;
  bool _hasError = false;
  String? _errorMessage;

  final List<String> _priorities = [
    'NORMAL',
    'URGENT',
    'EMERGENCY',
  ];

  @override
  void initState() {
    super.initState();
    _loadFarms();
    _loadServiceTypes();
    _loadBirdTypes();
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

  Future<void> _loadServiceTypes() async {
    setState(() {
      _isLoadingServices = true;
      _servicesError = null;
    });

    try {
      final result = await _vetRepository.getVetServiceTypes();

      switch (result) {
        case Success<VetServiceTypesResponse>(data: final data):
          setState(() {
            _serviceTypes = data.serviceTypes;
            _isLoadingServices = false;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _isLoadingServices = false;
            _servicesError = error;
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _isLoadingServices = false;
        _servicesError = 'Failed to load service types: $e';
      });
    }
  }

  Future<void> _loadBirdTypes() async {
    setState(() => _isLoadingBirdTypes = true);
    final result = await _batchHouseRepository.getBirdTypes();
    if (!mounted) return;
    switch (result) {
      case Success<List<BirdType>>(data: final types):
        setState(() {
          _birdTypes = types;
          _isLoadingBirdTypes = false;
        });
        break;
      case Failure(message: final error):
        setState(() => _isLoadingBirdTypes = false);
        ApiErrorHandler.handle(error);
        break;
    }
  }

  void _toggleBirdType(BirdType type, bool selected) {
    setState(() {
      if (selected) {
        _selectedBirdTypeIds.add(type.id);
      } else {
        _selectedBirdTypeIds.remove(type.id);
      }
    });
  }

  List<BirdTypeEntry> _buildBirdTypeEntries() {
    final count = int.tryParse(_birdsCountController.text) ?? 0;
    final age = int.tryParse(_birdAgeController.text) ?? 0;
    final mortality = double.tryParse(_birdMortalityController.text) ?? 0;
    return _selectedBirdTypeIds.map((id) {
      final type = _birdTypes.firstWhere((t) => t.id == id);
      return BirdTypeEntry(
        birdTypeId: id,
        birdTypeName: type.name,
        count: count,
        ageValue: age,
        ageUnit: _birdAgeUnit,
        mortalityRate: mortality,
      );
    }).toList();
  }

  Future<void> _loadHousesForSelectedFarm() async {
    if (_selectedFarm == null) return;

    setState(() {
      _isLoadingHouses = true;
      _houses = [];
      _availableBatches = [];
      _selectedHouse = null;
      _selectedBatches.clear();
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
      _selectedBatches.clear();

      // Update available batches based on selected house
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

  void _onBatchSelected(String batchId, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedBatches.contains(batchId)) {
          _selectedBatches.add(batchId);
        }
      } else {
        _selectedBatches.remove(batchId);
      }
    });
  }

  /// Whether the user has selected farm details (farm + house + batches)
  bool get _hasFarmDetails => _selectedFarm != null && _selectedHouse != null && _selectedBatches.isNotEmpty;

  void _onServiceSelected(String serviceId, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedServices.contains(serviceId)) {
          _selectedServices.add(serviceId);
        }
      } else {
        _selectedServices.remove(serviceId);
      }
    });
  }

  Future<void> _getEstimate() async {
    if (_selectedPriority == null || _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select priority level and at least one service'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedPaymentMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mode of payment'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // If no farm details provided, birds count is required
    if (!_hasFarmDetails && (_manualBirdsCount == null || _manualBirdsCount! <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select farm details or enter the number of birds'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate number of people for PER_PERSON services
    final hasPerPersonService = _selectedServices.any((serviceId) {
      final service = _serviceTypes.firstWhere((s) => s.id == serviceId, orElse: () => _serviceTypes.first);
      return service.pricingType == 'PER_PERSON';
    });
    if (hasPerPersonService && (_numberOfPeople == null || _numberOfPeople! <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the number of people for the training/group session'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoadingEstimate = true;
    });

    // Calculate birds count from selected batches, or use manual count
    int birdsCount = 0;
    if (_selectedBatches.isNotEmpty) {
      for (final batchId in _selectedBatches) {
        final batch = _availableBatches.firstWhere(
              (b) => b.id == batchId,
          orElse: () => BatchModel(
            id: '',
            batchNumber: '',
            initialQuantity: 0,
            birdsAlive: 0,
            age: 0,
            type: '', birdTypeId: '', breed: '', startDate: DateTime.now(), currentWeight: 1, expectedWeight:0, feedingTime: '', feedingSchedule: [],
          ),
        );
        birdsCount += batch.birdsAlive;
      }
    } else {
      birdsCount = _manualBirdsCount ?? 0;
    }

    final birdTypeEntries =
        !_hasFarmDetails && _selectedBirdTypeIds.isNotEmpty
            ? _buildBirdTypeEntries()
            : null;

    final request = VetEstimateRequest(
      vetId: widget.vet.id,
      houseIds: _selectedHouse != null ? [_selectedHouse!] : null,
      batchIds: _selectedBatches.isNotEmpty ? _selectedBatches : null,
      serviceIds: _selectedServices,
      birdsCount: birdsCount,
      priorityLevel: _selectedPriority!,
      preferredDate: DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String()
          .split('T')
          .first,
      preferredTime: '09:00',
      termsAgreed: false,
      participantsCount: hasPerPersonService ? _numberOfPeople : null,
      paymentMode: _selectedPaymentMode,
      birdTypeDetails: birdTypeEntries,
    );

    final result = await _vetRepository.getVetOrderEstimate(request);

    setState(() {
      _isLoadingEstimate = false;
    });

    switch (result) {
      case Success<VetEstimateResponse>(data: final estimate):
      // Show bottom sheet with estimate
        _showOrderBottomSheet(estimate, request);
        break;
      case Failure(message: final error):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to get estimate: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
    }
  }

  void _showOrderBottomSheet(
      VetEstimateResponse estimate, VetEstimateRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VetOrderBottomSheet(
        estimate: estimate,
        vet: widget.vet,
        vetRepository: _vetRepository,
        onOrderSuccess: () {
          context.pop(); // Close bottom sheet
          context.pop(); // Go back to vet details
          context.pop(); // Go back to vet list
        },
        request: request,
      ),
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

  Widget _buildBirdTypeSection() {
    if (_isLoadingBirdTypes) {
      return _buildLoadingIndicator('Loading bird types...');
    }
    if (_birdTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type of Birds (Select all that apply)',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: _birdTypes.map((type) {
              final isSelected = _selectedBirdTypeIds.contains(type.id);
              return CheckboxListTile(
                title: Text(type.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                value: isSelected,
                onChanged: (v) => _toggleBirdType(type, v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                secondary: Icon(Icons.pets,
                    color: isSelected ? Colors.green : Colors.grey),
              );
            }).toList(),
          ),
        ),

        // Shared flock detail fields — shown once when any type is selected
        if (_selectedBirdTypeIds.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flock Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                ReusableInput(
                  controller: _birdMortalityController,
                  labelText: 'Mortality Rate (%)',
                  hintText: 'e.g. 2.5',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ReusableInput(
                        controller: _birdAgeController,
                        labelText: 'Age',
                        hintText:
                            _birdAgeUnit == 'days' ? 'e.g. 14' : 'e.g. 3',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        ToggleButtons(
                          isSelected: [
                            _birdAgeUnit == 'days',
                            _birdAgeUnit == 'weeks',
                          ],
                          onPressed: (index) {
                            setState(() {
                              _birdAgeUnit =
                                  index == 0 ? 'days' : 'weeks';
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          selectedColor: Colors.white,
                          fillColor: Colors.green,
                          color: Colors.grey.shade600,
                          constraints: const BoxConstraints(
                              minHeight: 36, minWidth: 56),
                          children: const [
                            Text('Days', style: TextStyle(fontSize: 12)),
                            Text('Weeks',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentModeSection() {
    return ReusableDropdown<String>(
      topLabel: 'Mode of Payment',
      value: _selectedPaymentMode,
      hintText: 'Select payment method',
      icon: Icons.payment,
      isExpanded: true,
      items: _paymentModes.map((mode) {
        IconData icon;
        switch (mode) {
          case 'M-Pesa':
            icon = Icons.phone_android;
            break;
          case 'Card':
            icon = Icons.credit_card;
            break;
          case 'Bank Transfer':
            icon = Icons.account_balance;
            break;
          default:
            icon = Icons.money;
        }
        return DropdownMenuItem<String>(
          value: mode,
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 10),
              Text(mode),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedPaymentMode = v),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a payment method';
        }
        return null;
      },
    );
  }

  Widget _buildFarmDetails() {
    if (_selectedFarm == null || _farmsResponse == null) return const SizedBox();

    final farm = _farmsResponse!.farms.firstWhere(
          (f) => f.id == _selectedFarm,
      orElse: () => _farmsResponse!.farms.first,
    );

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
      orElse: () => _houses.first,
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

  Widget _buildBatchSelection() {
    if (_selectedHouse == null || _availableBatches.isEmpty) {
      return _buildEmptyState('No batches available in this house');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Batches',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: _availableBatches.map((batch) {
              final isSelected = _selectedBatches.contains(batch.id);

              return CheckboxListTile(
                title: Text(
                  batch.batchNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text('${batch.birdsAlive} birds'),
                    const SizedBox(width: 12),
                    Text('${batch.age} days'),
                  ],
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  _onBatchSelected(batch.id, value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                secondary: Icon(
                  Icons.pets,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ),
        // Selected batches summary
        if (_selectedBatches.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Batches:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedBatches.map((batchId) {
                    final batch = _availableBatches.firstWhere(
                          (b) => b.id == batchId,
                    );
                    return Chip(
                      label: Text(batch.batchNumber),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        _onBatchSelected(batchId, false);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total birds: ${_selectedBatches.fold<int>(0, (sum, batchId) {
                    final batch = _availableBatches.firstWhere((b) => b.id == batchId);
                    return sum + batch.birdsAlive;
                  })}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServiceSelection() {
    if (_isLoadingServices) {
      return _buildLoadingIndicator('Loading service types...');
    }

    if (_servicesError != null) {
      return _buildErrorWidget(_servicesError!, _loadServiceTypes);
    }

    if (_serviceTypes.isEmpty) {
      return _buildEmptyState('No service types available');
    }

    final activeServices =
    _serviceTypes.where((service) => service.active).toList();

    if (activeServices.isEmpty) {
      return _buildEmptyState('No active services available');
    }

    // Check if any selected service requires number of people
    final hasPerPersonService = _selectedServices.any((serviceId) {
      final service = _serviceTypes.firstWhere((s) => s.id == serviceId, orElse: () => _serviceTypes.first);
      return service.pricingType == 'PER_PERSON';
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Services',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: activeServices.map((service) {
              final isSelected = _selectedServices.contains(service.id);

              // Build price display based on pricing type
              String priceText;
              switch (service.pricingType) {
                case 'PER_BIRD':
                  priceText = '${service.currency} ${service.perBirdRate?.toStringAsFixed(2) ?? '0.00'}/bird';
                  break;
                case 'PER_PERSON':
                  priceText = '${service.currency} ${service.perPersonRate?.toStringAsFixed(2) ?? '0.00'}/person';
                  break;
                default: // FIXED
                  priceText = '${service.currency} ${service.basePrice?.toStringAsFixed(2) ?? '0.00'}';
              }

              return CheckboxListTile(
                title: Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.description.isNotEmpty)
                      Text(
                        service.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Price: $priceText',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  _onServiceSelected(service.id, value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                secondary: Icon(
                  Icons.medical_services,
                  color: isSelected ? Colors.purple : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ),

        // Number of people input (for PER_PERSON services)
        if (hasPerPersonService) ...[
          const SizedBox(height: 12),
          ReusableInput(
            controller: _numberOfPeopleController,
            labelText: 'Number of People',
            hintText: 'Enter number of attendees',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _numberOfPeople = int.tryParse(value ?? '');
              });
            },
            validator: (value) {
              if (hasPerPersonService && (value == null || value.isEmpty)) {
                return 'Please enter the number of people';
              }
              if (hasPerPersonService && (int.tryParse(value ?? '') ?? 0) <= 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],

        // Selected services summary
        if (_selectedServices.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Services:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedServices.map((serviceId) {
                    final service = _serviceTypes.firstWhere(
                          (s) => s.id == serviceId,
                    );
                    return Chip(
                      label: Text(service.serviceName),
                      backgroundColor: Colors.purple.shade100,
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        _onServiceSelected(serviceId, false);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Veterinary Service'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vet Info Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.pets,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vet.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.vet.educationLevel,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey.shade500,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.vet.location.address!.formattedAddress,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (widget.vet.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order Details Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            'Service Booking',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Provide details for your veterinary service request. '
                            'The veterinarian will review your booking and contact you.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Farm Selection (Optional)
              _buildFarmSection(),
              const SizedBox(height: 20),

              // Service Selection
              _buildServiceSelection(),
              const SizedBox(height: 20),

              // Mode of Payment
              _buildPaymentModeSection(),
              const SizedBox(height: 20),

              // Priority Level
              ReusableDropdown<String>(
                topLabel: 'Priority Level',
                value: _selectedPriority,
                hintText: 'Select priority level',
                icon: Icons.priority_high,
                isExpanded: true,
                items: _priorities.map((String priority) {
                  String displayText = priority.toUpperCase();
                  Color? color;

                  if (priority == 'EMERGENCY') {
                    displayText = 'EMERGENCY';
                    color = Colors.red;
                  } else if (priority == 'URGENT') {
                    displayText = 'URGENT';
                    color = Colors.orange;
                  } else {
                    displayText = 'NORMAL';
                    color = Colors.green;
                  }

                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(displayText),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPriority = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select priority level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Get Estimate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingEstimate ? null : _getEstimate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoadingEstimate
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isLoadingEstimate ? 'Loading...' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Process Info
              const OrderProcess(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the optional farm → house → batch section, OR the manual birds count input.
  Widget _buildFarmSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Details (Optional)',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select your farm, house, and batches — or just enter the number of birds below.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        // Farm dropdown
        _buildFarmDropdown(),
        if (_selectedFarm != null) _buildFarmDetails(),
        if (_selectedFarm != null) FilledButton(onPressed: () {
          setState(() {
            _selectedFarm = null;
            _selectedHouse = null;
            _selectedBatches.clear();
          });
        }, child: Text('Clear Farm selection'),),

        // House dropdown
        if (_selectedFarm != null) const SizedBox(height: 16),

        // House dropdown
        if (_selectedFarm != null) ...[
          _buildHouseDropdown(),
          if (_selectedHouse != null) _buildHouseDetails(),
          if (_selectedHouse != null) const SizedBox(height: 16),
        ],

        // Batch selection
        if (_selectedHouse != null) ...[
          _buildBatchSelection(),
        ],

        // Manual birds count + bird type details — only shown when no farm is selected
        if (_selectedFarm == null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No farm set up yet? Provide your flock details below.',
                    style: TextStyle(fontSize: 12.5, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ReusableInput(
            controller: _birdsCountController,
            labelText: 'Total Number of Birds',
            hintText: 'Enter total number of birds',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _manualBirdsCount = int.tryParse(value ?? '');
              });
            },
            validator: (value) {
              if (!_hasFarmDetails) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of birds';
                }
                if ((int.tryParse(value) ?? 0) <= 0) {
                  return 'Please enter a valid number';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildBirdTypeSection(),
        ],
      ],
    );
  }

  Widget _buildFarmDropdown() {
    if (_isLoadingFarms) {
      return _buildLoadingIndicator('Loading farms...');
    }

    if (_hasError) {
      return _buildErrorWidget(_errorMessage ?? 'Failed to load farms', _loadFarms);
    }

    if (_farmsResponse == null || _farmsResponse!.farms.isEmpty) {
      return const SizedBox.shrink();
    }

    return ReusableDropdown<String>(
      value: _selectedFarm,
      topLabel: "Select a farm",
      hintText: 'Choose a farm',
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
          _selectedBatches.clear();
          _houses = [];
          _availableBatches = [];
        });
        if (newValue != null) {
          _loadHousesForSelectedFarm();
        }
      },
    );
  }

  Widget _buildHouseDropdown() {
    if (_isLoadingHouses) {
      return _buildLoadingIndicator('Loading houses...');
    }

    if (_houses.isEmpty) {
      return _buildEmptyState('No houses available in this farm');
    }

    return ReusableDropdown<String>(
      topLabel: "Select a house",
      value: _selectedHouse,
      hintText: 'Choose a poultry house',
      labelText: 'House',
      icon: Icons.home_work,
      isExpanded: true,
      items: _houses.map((house) {
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
      onChanged: _onHouseSelected,
    );
  }

  @override
  void dispose() {
    _birdsCountController.dispose();
    _numberOfPeopleController.dispose();
    _birdAgeController.dispose();
    _birdMortalityController.dispose();
    super.dispose();
  }
}