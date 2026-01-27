import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_order_model.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_service_type.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:agriflock360/features/farmer/vet/widgets/order_process.dart';
import 'package:agriflock360/features/farmer/vet/widgets/vet_order_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/result.dart';

class VetOrderScreen extends StatefulWidget {
  final VetFarmer vet;

  const VetOrderScreen({super.key, required this.vet});

  @override
  State<VetOrderScreen> createState() => _VetOrderScreenState();
}

class _VetOrderScreenState extends State<VetOrderScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _batchCountController = TextEditingController();

  // Selection states
  String? _selectedFarm;
  String? _selectedHouse;
  List<String> _selectedBatches = [];
  List<String> _selectedServices = [];
  String? _selectedPriority;

  // Manual batch count
  bool _useManualBatchCount = false;
  int? _manualBatchCount;

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

  Future<void> _loadHousesForSelectedFarm() async {
    if (_selectedFarm == null) return;

    setState(() {
      _isLoadingHouses = true;
      _houses = [];
      _availableBatches = [];
      _selectedHouse = null;
      _selectedBatches.clear();
      _useManualBatchCount = false;
      _batchCountController.clear();
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
      _useManualBatchCount = false;
      _batchCountController.clear();

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
      // If user selects any batch, disable manual count
      if (_selectedBatches.isNotEmpty) {
        _useManualBatchCount = false;
        _batchCountController.clear();
      }
    });
  }

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
        ),
      );
      return;
    }

    if (_selectedFarm == null || _selectedHouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select farm and house'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate batch selection or manual count
    if (_selectedBatches.isEmpty && !_useManualBatchCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select batches or enable manual batch count'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_useManualBatchCount && (_manualBatchCount == null || _manualBatchCount! <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid batch count'),
          backgroundColor: Colors.orange,
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

    // Calculate birds count
    int birdsCount = 0;
    if (_selectedBatches.isNotEmpty) {
      for (final batchId in _selectedBatches) {
        final batch = _availableBatches.firstWhere(
              (b) => b.id == batchId,
          orElse: () => BatchModel(
            id: '',
            batchName: '',
            initialQuantity: 0,
            birdsAlive: 0,
            age: 0,
            type: '', birdTypeId: '', breed: '', startDate: DateTime.now(), currentWeight: 1, expectedWeight:0, feedingTime: '', feedingSchedule: [],
          ),
        );
        birdsCount += batch.birdsAlive;
      }
    } else if (_useManualBatchCount) {
      birdsCount = _manualBatchCount!;
    }

    final request = VetEstimateRequest(
      vetId: widget.vet.id,
      houseIds: [?_selectedHouse],
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
      reasonForVisit: _reasonController.text,
      termsAgreed: false,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get estimate: $error'),
            backgroundColor: Colors.red,
          ),
        );
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
            children: [
              // Checkbox list for batches
              if (_availableBatches.isNotEmpty)
                ..._availableBatches.map((batch) {
                  final isSelected = _selectedBatches.contains(batch.id);

                  return CheckboxListTile(
                    title: Text(
                      batch.batchName,
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
                }),

              // Manual batch count option
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _useManualBatchCount,
                          onChanged: (bool? value) {
                            setState(() {
                              _useManualBatchCount = value ?? false;
                              if (_useManualBatchCount) {
                                // Clear selected batches when using manual count
                                _selectedBatches.clear();
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Enter manual batch count',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_useManualBatchCount)
                      Padding(
                        padding: const EdgeInsets.only(left: 40, top: 12),
                        child: ReusableInput(
                          controller: _batchCountController,
                          labelText: 'Number of Birds',
                          hintText: 'Enter total number of birds',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _manualBatchCount = int.tryParse(value ?? '');
                            });
                          },
                          validator: (value) {
                            if (_useManualBatchCount && (value == null || value.isEmpty)) {
                              return 'Please enter batch count';
                            }
                            if (_useManualBatchCount && (int.tryParse(value ?? '') ?? 0) <= 0) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
                      label: Text(batch.batchName),
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
        if (_useManualBatchCount && _manualBatchCount != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Manual batch count: $_manualBatchCount birds',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
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
                      'Price: ${service.currency} ${service.basePrice}',
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
      backgroundColor: Colors.grey.shade50,
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

              // Farm Selection
              _buildFarmDropdown(),
              if (_selectedFarm != null) _buildFarmDetails(),
              const SizedBox(height: 20),

              // House Selection
              if (_selectedFarm != null) ...[
                _buildHouseDropdown(),
                if (_selectedHouse != null) _buildHouseDetails(),
                const SizedBox(height: 20),
              ],

              // Batch Selection
              if (_selectedHouse != null) ...[
                _buildBatchSelection(),
                const SizedBox(height: 20),
              ],

              // Service Selection
              _buildServiceSelection(),
              const SizedBox(height: 20),

              // Priority Level
              ReusableDropdown<String>(
                topLabel: 'Priority Level',
                value: _selectedPriority,
                hintText: 'Select priority level',
                icon: Icons.priority_high,
                labelText: 'Priority Level',
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

              // Reason for Visit
              Text(
                'Reason for Visit',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _reasonController,
                labelText: 'Reason',
                hintText: 'Describe the reason for the veterinary visit...',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the reason for visit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

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

  Widget _buildFarmDropdown() {
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
      topLabel: "Select a farm",
      hintText: 'Choose a farm',
      labelText: 'Farm',
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
          _useManualBatchCount = false;
          _batchCountController.clear();
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a poultry house';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _batchCountController.dispose();
    super.dispose();
  }
}