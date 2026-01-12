import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:agriflock360/features/farmer/vet/models/order_screen.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_order_model.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:agriflock360/features/farmer/vet/widgets/order_process.dart';
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
  final _additionalNotesController = TextEditingController();
  final _selectedDateController = TextEditingController();

  // Selection states
  String? _selectedFarm;
  String? _selectedHouse;
  String? _selectedBatch;
  String? _selectedServiceType;
  String? _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _termsAgreed = false;

  // Estimate state
  VetEstimateResponse? _estimate;
  bool _isLoadingEstimate = false;
  bool _isSubmittingOrder = false;

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

  // Service types - You might want to fetch these from API
  final Map<String, String> _services = {
    'routine_checkup': 'Routine Check-up',
    'vaccination': 'Vaccination Service',
    'emergency': 'Emergency Visit',
    'diagnosis': 'Disease Diagnosis',
    'consultation': 'Consultation',
    'treatment': 'Treatment',
    'post_mortem': 'Post-mortem Examination',
    'certification': 'Health Certification',
  };

  final List<String> _priorities = [
    'NORMAL',
    'URGENT',
    'EMERGENCY',
  ];

  @override
  void initState() {
    super.initState();
    _loadFarms();
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
      _estimate = null;
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
      _estimate = null;

      // Update available batches based on selected house
      if (houseId != null) {
        final selectedHouse = _houses.firstWhere(
              (house) => house.id == houseId,
          orElse: () => _houses.isNotEmpty ? _houses.first : House(
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

    setState(() {
      _isLoadingEstimate = true;
      _estimate = null;
    });

    final request = VetEstimateRequest(
      vetId: widget.vet.id,
      houseId: _selectedHouse,
      batchId: _selectedBatch,
      serviceId: _selectedServiceType,
      priorityLevel: _selectedPriority!,
      preferredDate: _selectedDate?.toIso8601String().split('T').first ??
          DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String()
              .split('T')
              .first,
      preferredTime: _selectedTime?.format(context) ?? '09:00',
      reasonForVisit: _reasonController.text,
      additionalNotes: _additionalNotesController.text.isNotEmpty
          ? _additionalNotesController.text
          : null,
      termsAgreed: _termsAgreed,
    );

    final result = await _vetRepository.getVetOrderEstimate(request);

    switch (result) {
      case Success<VetEstimateResponse>(data: final data):
        setState(() {
          _estimate = data;
          _isLoadingEstimate = false;
        });
        break;
      case Failure(message: final error):
        setState(() {
          _isLoadingEstimate = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get estimate: $error'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a preferred date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a preferred time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingOrder = true;
    });

    final request = VetOrderRequest(
      vetId: widget.vet.id,
      houseId: _selectedHouse,
      batchId: _selectedBatch,
      serviceId: _selectedServiceType,
      priorityLevel: _selectedPriority!,
      preferredDate: _selectedDate!.toIso8601String().split('T').first,
      preferredTime: _selectedTime!.format(context),
      reasonForVisit: _reasonController.text,
      additionalNotes: _additionalNotesController.text.isNotEmpty
          ? _additionalNotesController.text
          : null,
      termsAgreed: _termsAgreed,
    );

    final result = await _vetRepository.submitVetOrder(request);

    setState(() {
      _isSubmittingOrder = false;
    });

    switch (result) {
      case Success<VetOrderResponse>(data: final data):
      // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Order Submitted Successfully!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  data.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                if (data.referenceNumber != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            'Reference Number',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            data.referenceNumber!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${data.currency} ${data.totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop(); // Go back to vet details
                  context.pop(); // Go back to vet list
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;
      case Failure(message: final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit order: $error'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
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
                        child: Center(
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
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
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
              ReusableDropdown<String>(
                value: _selectedServiceType,
                labelText: 'Service Type',
                hintText: 'Select type of service needed',
                icon: Icons.medical_services,
                items: _services.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedServiceType = newValue;
                    _estimate = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select service type';
                  }
                  return null;
                },
              ),
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
                    _estimate = null;
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
              if (_selectedServiceType != null && _selectedPriority != null)
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
                        : const Icon(Icons.calculate, size: 20),
                    label: Text(
                      _isLoadingEstimate
                          ? 'Getting Estimate...'
                          : 'Get Cost Estimate',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_selectedServiceType != null && _selectedPriority != null)
                const SizedBox(height: 20),

              // Estimate Display
              if (_estimate != null) _buildEstimateCard(),
              if (_estimate != null) const SizedBox(height: 20),


              CustomDateTextField(
                label: 'Preferred Date',
                hintText: 'Enter your preferred date',
                icon: Icons.calendar_today,
                required: true,
                minYear: DateTime.now().year - 1,
                returnFormat: DateReturnFormat.dateTime,
                maxYear: DateTime.now().year,
                controller: _selectedDateController,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDate = value;
                      _estimate = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Preferred Time
              Text(
                'Preferred Time',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? 'Select preferred time'
                            : _selectedTime!.format(context),
                        style: TextStyle(
                          color: _selectedTime == null
                              ? Colors.grey.shade600
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
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
                onChanged: (value) {
                  setState(() {
                    _estimate = null;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Additional Notes
              Text(
                'Additional Notes (Optional)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _additionalNotesController,
                labelText: 'Additional Notes',
                hintText: 'Any additional information or special requirements...',
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    _estimate = null;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Terms and Conditions
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _termsAgreed,
                            onChanged: (value) {
                              setState(() {
                                _termsAgreed = value ?? false;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'I agree to the terms and conditions',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By submitting this order, you agree to:\n'
                            '• Payment terms and conditions\n'
                            '• Service terms and conditions\n'
                            '• Privacy and data protection agreement\n'
                            '• Cancellation policy\n'
                            '• All applicable laws and regulations',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmittingOrder ||
                      !_termsAgreed ||
                      _estimate == null
                      ? null
                      : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmittingOrder
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'Submit Booking Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Process Info
              OrderProcess(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
          _estimate = null;
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
          _estimate = null;
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

  Widget _buildEstimateCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Cost Estimate',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEstimateItem('Consultation Fee:', _estimate!.consultationFee),
            _buildEstimateItem('Service Fee:', _estimate!.serviceFee),
            _buildEstimateItem('Mileage Fee:', _estimate!.mileageFee),
            if (_estimate!.prioritySurcharge > 0)
              _buildEstimateItem(
                'Priority Surcharge:',
                _estimate!.prioritySurcharge,
                isSurcharge: true,
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Estimated Cost:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_estimate!.currency} ${_estimate!.estimatedCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (_estimate!.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                _estimate!.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }



  Widget _buildEstimateItem(String label, double amount,
      {bool isSurcharge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color:
                isSurcharge ? Colors.orange.shade700 : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_estimate?.currency ?? 'KES'} ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color:
              isSurcharge ? Colors.orange.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }


  Color _getMortalityColor(double mortalityRate) {
    if (mortalityRate < 2) return Colors.green;
    if (mortalityRate < 5) return Colors.orange;
    return Colors.red;
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _estimate = null;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }
}