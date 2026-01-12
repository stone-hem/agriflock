import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
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
import 'package:agriflock360/core/widgets/reusable_input.dart';

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

  // Selection states
  String? _selectedFarm;
  String? _selectedHouse;
  String? _selectedBatch;
  String? _selectedServiceType;
  String? _selectedPriority;

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

  Future<void> _getEstimate() async {
    if (_selectedPriority == null || _selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select priority level and service type'),
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

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoadingEstimate = true;
    });

    final request = VetEstimateRequest(
      vetId: widget.vet.id,
      houseId: _selectedHouse,
      batchId: _selectedBatch,
      serviceId: _selectedServiceType,
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
        _showOrderBottomSheet(estimate,request);
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

  void _showOrderBottomSheet(VetEstimateResponse estimate,VetEstimateRequest request) {
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
        }, request:request ,
      ),
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
                                    widget.vet.location.address,
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
              Text(
                'Select Farm',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              _buildFarmDropdown(),
              const SizedBox(height: 20),

              // House Selection
              if (_selectedFarm != null) ...[
                Text(
                  'Select House',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHouseDropdown(),
                const SizedBox(height: 20),
              ],

              // Batch Selection
              if (_selectedHouse != null && _availableBatches.isNotEmpty) ...[
                Text(
                  'Select Batch',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBatchDropdown(),
                const SizedBox(height: 20),
              ],

              // Service Type
              Text(
                'Service Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              _buildServiceTypeDropdown(),
              const SizedBox(height: 20),

              // Priority Level
              Text(
                'Priority Level',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableDropdown<String>(
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
                    Icons.calculate,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isLoadingEstimate
                        ? 'loading...'
                        : 'Next',
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

  Widget _buildServiceTypeDropdown() {
    if (_isLoadingServices) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading service types...'),
          ],
        ),
      );
    }

    if (_servicesError != null) {
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
                _servicesError!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            TextButton(
              onPressed: _loadServiceTypes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_serviceTypes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Text('No service types available'),
      );
    }

    final activeServices =
    _serviceTypes.where((service) => service.active).toList();

    if (activeServices.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Text('No active services available'),
      );
    }

    return ReusableDropdown<String>(
      value: _selectedServiceType,
      labelText: 'Service Type',
      hintText: 'Select type of service needed',
      icon: Icons.medical_services,
      items: activeServices.map((service) {
        return DropdownMenuItem<String>(
          value: service.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                service.serviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${service.currency} ${service.basePrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (service.description.isNotEmpty)
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedServiceType = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select service type';
        }
        return null;
      },
    );
  }

  Widget _buildFarmDropdown() {
    if (_isLoadingFarms) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading farms...'),
          ],
        ),
      );
    }

    if (_hasError) {
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
                _errorMessage ?? 'Failed to load farms',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            TextButton(
              onPressed: _loadFarms,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_farmsResponse == null || _farmsResponse!.farms.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Text('No farms available'),
      );
    }

    return ReusableDropdown<String>(
      value: _selectedFarm,
      hintText: 'Choose a farm',
      labelText: 'Farm',
      icon: Icons.agriculture,
      isExpanded: true,
      items: _farmsResponse!.farms.map((farm) {
        return DropdownMenuItem<String>(
          value: farm.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                farm.farmName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (farm.location != null)
                Text(
                  farm.location!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
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
    if (_isLoadingHouses) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading houses...'),
          ],
        ),
      );
    }

    if (_houses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Text('No houses available in this farm'),
      );
    }

    return ReusableDropdown<String>(
      value: _selectedHouse,
      hintText: 'Choose a poultry house',
      labelText: 'house',
      icon: Icons.home_work,
      isExpanded: true,
      items: _houses.map((house) {
        final batchCount = house.batches.length;
        final currentBirds = house.currentBirds;
        final capacity = house.capacity;
        final utilization = capacity > 0 ? (currentBirds / capacity * 100) : 0;

        return DropdownMenuItem<String>(
          value: house.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                house.houseName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Capacity: $currentBirds/$capacity birds',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$batchCount batch${batchCount == 1 ? '' : 'es'} • ${utilization.toStringAsFixed(1)}% utilized',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
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

  Widget _buildBatchDropdown() {
    return ReusableDropdown<String>(
      value: _selectedBatch,
      hintText: 'Choose a batch from selected house',
      labelText: 'batch',
      icon: Icons.egg,
      isExpanded: true,
      items: _availableBatches.map((batch) {
        final mortalityRate = batch.initialQuantity > 0
            ? ((batch.initialQuantity - batch.birdsAlive) /
            batch.initialQuantity *
            100)
            .toStringAsFixed(1)
            : '0.0';

        return DropdownMenuItem<String>(
          value: batch.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                batch.batchName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Icon(Icons.pets, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${batch.birdsAlive}/${batch.initialQuantity} birds',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today,
                      size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${batch.age} weeks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Text(
                '${batch.type} • Mortality: $mortalityRate%',
                style: TextStyle(
                  fontSize: 11,
                  color: _getMortalityColor(double.parse(mortalityRate)),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBatch = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a batch';
        }
        return null;
      },
    );
  }

  Color _getMortalityColor(double mortalityRate) {
    if (mortalityRate < 2) return Colors.green;
    if (mortalityRate < 5) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}