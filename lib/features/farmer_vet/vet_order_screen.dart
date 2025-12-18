import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer_vet/models/vet_officer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetOrderScreen extends StatefulWidget {
  final VetOfficer vet;

  const VetOrderScreen({super.key, required this.vet});

  @override
  State<VetOrderScreen> createState() => _VetOrderScreenState();
}

class _VetOrderScreenState extends State<VetOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  // Selection states
  String? _selectedHouse;
  String? _selectedBatch;
  String? _selectedServiceType;
  String? _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Mock data structures
  final List<FarmHouse> _farmHouses = [
    FarmHouse(
      id: '1',
      name: 'Main Poultry House',
      location: 'Farm Plot A',
      batches: [
        FarmBatch(
          id: '1',
          name: 'Batch 123 - Broilers',
          birdCount: 1000,
          ageWeeks: 5,
          birdType: 'Broilers',
          healthStatus: 'Healthy',
        ),
        FarmBatch(
          id: '2',
          name: 'Batch 124 - Layers',
          birdCount: 500,
          ageWeeks: 20,
          birdType: 'Layers',
          healthStatus: 'Good Production',
        ),
      ],
    ),
    FarmHouse(
      id: '2',
      name: 'Secondary Poultry House',
      location: 'Farm Plot B',
      batches: [
        FarmBatch(
          id: '3',
          name: 'Batch 125 - Broilers',
          birdCount: 1500,
          ageWeeks: 3,
          birdType: 'Broilers',
          healthStatus: 'Recently Vaccinated',
        ),
        FarmBatch(
          id: '4',
          name: 'Batch 126 - Breeders',
          birdCount: 200,
          ageWeeks: 30,
          birdType: 'Breeders',
          healthStatus: 'Excellent',
        ),
      ],
    ),
    FarmHouse(
      id: '3',
      name: 'Quarantine House',
      location: 'Isolated Area',
      batches: [
        FarmBatch(
          id: '5',
          name: 'Batch 127 - Recovery',
          birdCount: 50,
          ageWeeks: 8,
          birdType: 'Mixed',
          healthStatus: 'Under Treatment',
        ),
      ],
    ),
  ];

  // Service pricing data
  final Map<String, double> _servicePrices = {
    'Routine Check-up': 2000.0,
    'Vaccination Service': 3500.0,
    'Emergency Visit': 8000.0,
    'Disease Diagnosis': 5000.0,
    'Consultation': 1500.0,
    'Treatment': 4500.0,
    'Post-mortem Examination': 2500.0,
    'Health Certification': 3000.0,
  };

  final List<String> _priorities = [
    'Normal',
    'Urgent',
    'Emergency',
  ];

  // Mileage calculation constants (Kenya rates)
  static const double _mileageRatePerKm = 80.0; // KES per km
  static const double _minimumMileageFee = 500.0; // Minimum charge
  static const double _emergencySurcharge = 0.5; // 50% for emergency priority

  // Calculate total cost
  double get _consultationFee {
    // Extract numeric value from string like "\$75"
    final feeString = widget.vet.consultationFee.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(feeString) ?? 0.0;
  }

  double get _serviceFee {
    return _selectedServiceType != null
        ? (_servicePrices[_selectedServiceType] ?? 0.0)
        : 0.0;
  }

  double get _mileageFee {
    // Parse distance from string like "2.5 km"
    final distanceString = widget.vet.distance.replaceAll(RegExp(r'[^0-9.]'), '');
    final distance = double.tryParse(distanceString) ?? 0.0;

    double fee = distance * _mileageRatePerKm;
    return fee < _minimumMileageFee ? _minimumMileageFee : fee;
  }

  double get _prioritySurcharge {
    if (_selectedPriority == 'Emergency') {
      return (_serviceFee + _consultationFee) * _emergencySurcharge;
    } else if (_selectedPriority == 'Urgent') {
      return (_serviceFee + _consultationFee) * 0.25; // 25% for urgent
    }
    return 0.0;
  }

  double get _totalCost {
    return _consultationFee + _serviceFee + _mileageFee + _prioritySurcharge;
  }

  // Get filtered batches based on selected house
  List<FarmBatch> get _availableBatches {
    if (_selectedHouse == null) return [];
    final selectedHouse = _farmHouses.firstWhere(
          (house) => house.id == _selectedHouse,
      orElse: () => _farmHouses.first,
    );
    return selectedHouse.batches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _submitOrder,
            child: const Text(
              'Submit Order',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
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
                          color: widget.vet.avatarColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.pets,
                            color: widget.vet.avatarColor,
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
                            ),
                            Text(
                              widget.vet.specialization,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.grey.shade500,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.vet.clinic,
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
                            'Order Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please provide details for your veterinary service request. '
                            'The veterinarian will review your order and contact you to confirm.',
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

              // House Selection
              Text(
                'Select House',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedHouse,
                decoration: InputDecoration(
                  hintText: 'Choose a poultry house',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: Icon(Icons.home_work, color: Colors.grey.shade600),
                ),
                items: _farmHouses.map((FarmHouse house) {
                  return DropdownMenuItem<String>(
                    value: house.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          house.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          house.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${house.batches.length} ${house.batches.length == 1 ? 'batch' : 'batches'} available',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHouse = newValue;
                    _selectedBatch = null; // Reset batch when house changes
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a poultry house';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Batch Selection (only shows if house is selected)
              if (_selectedHouse != null) ...[
                Text(
                  'Select Batch',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedBatch,
                  decoration: InputDecoration(
                    hintText: 'Choose a batch from selected house',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: Icon(Icons.egg, color: Colors.grey.shade600),
                  ),
                  items: _availableBatches.map((FarmBatch batch) {
                    return DropdownMenuItem<String>(
                      value: batch.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            batch.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.pets, size: 12, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${batch.birdCount} birds',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${batch.ageWeeks} weeks',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Status: ${batch.healthStatus}',
                            style: TextStyle(
                              fontSize: 11,
                              color: _getHealthStatusColor(batch.healthStatus),
                              fontWeight: FontWeight.w500,
                            ),
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
                ),
                const SizedBox(height: 20),
              ],

              // Service Type with pricing
              Text(
                'Service Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: InputDecoration(
                  hintText: 'Select type of service needed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _servicePrices.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          'KES ${entry.value.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
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
              ),
              const SizedBox(height: 20),

              // Priority with surcharge info
              Text(
                'Priority Level',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  hintText: 'Select priority',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _priorities.map((String priority) {
                  String surchargeInfo = '';
                  Color? color;

                  if (priority == 'Emergency') {
                    surchargeInfo = ' (+50% surcharge)';
                    color = Colors.red;
                  } else if (priority == 'Urgent') {
                    surchargeInfo = ' (+25% surcharge)';
                    color = Colors.orange;
                  } else {
                    surchargeInfo = ' (No surcharge)';
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
                        Text(priority),
                        const SizedBox(width: 8),
                        Text(
                          surchargeInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
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

              // Billing Summary Card
              if (_selectedServiceType != null || _selectedPriority != null)
                Card(
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
                        _buildCostItem('Consultation Fee:', _consultationFee),
                        _buildCostItem('Service Fee:', _serviceFee),
                        _buildCostItem(
                          'Mileage Fee (${widget.vet.distance} @ KES $_mileageRatePerKm/km):',
                          _mileageFee,
                          description: 'Minimum charge: KES $_minimumMileageFee',
                        ),
                        if (_prioritySurcharge > 0)
                          _buildCostItem(
                            '${_selectedPriority} Surcharge:',
                            _prioritySurcharge,
                            isSurcharge: true,
                          ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Estimated Cost:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'KES ${_totalCost.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '* This is an estimate. Final cost may vary based on actual requirements.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_selectedServiceType != null || _selectedPriority != null)
                const SizedBox(height: 20),

              // Preferred Date
              Text(
                'Preferred Date',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
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
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select preferred date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey.shade600
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
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
                hintText: 'Describe the reason for ordering veterinary service...',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the reason for visit';
                  }
                  return null;
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
                controller: _notesController,
                labelText: 'Notes',
                hintText: 'Any additional information the vet should know...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),

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
                            value: true,
                            onChanged: (value) {},
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
                            '• Consultation fee of ${widget.vet.consultationFee}\n'
                            '• Service fee based on selected service type\n'
                            '• Mileage charges as per Kenya standard rates\n'
                            '• Priority surcharges where applicable\n'
                            '• Cancellation policy (24 hours notice required)\n'
                            '• Payment terms (due upon service completion)\n'
                            '• Privacy and data protection agreement',
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
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Order Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Process Info
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.green.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            'Request Process',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildProcessStep(1, 'Submit Request', 'You fill out this form'),
                      _buildProcessStep(2, 'Vet Review', 'Dr. ${widget.vet.name.split(' ').last} reviews your request'),
                      _buildProcessStep(3, 'Vet Accepts/Declines', 'Vet responds within 24 hours'),
                      _buildProcessStep(4, 'Schedule Visit', 'Date and time confirmed'),
                      _buildProcessStep(5, 'Service Delivered', 'Vet visits your farm'),
                      _buildProcessStep(6, 'Payment', 'Pay after service completion'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostItem(String label, double amount, {String? description, bool isSurcharge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSurcharge ? Colors.orange.shade700 : Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                if (description != null)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            'KES ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSurcharge ? Colors.orange.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'excellent':
      case 'good production':
        return Colors.green;
      case 'under treatment':
        return Colors.orange;
      case 'sick':
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      // Create order summary
      final orderSummary = OrderSummary(
        vet: widget.vet,
        house: _farmHouses.firstWhere((h) => h.id == _selectedHouse),
        batch: _availableBatches.firstWhere((b) => b.id == _selectedBatch),
        serviceType: _selectedServiceType!,
        priority: _selectedPriority!,
        date: _selectedDate!,
        time: _selectedTime!,
        reason: _reasonController.text,
        notes: _notesController.text,
        consultationFee: _consultationFee,
        serviceFee: _serviceFee,
        mileageFee: _mileageFee,
        prioritySurcharge: _prioritySurcharge,
        totalCost: _totalCost,
      );

      // Process the order
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order submitted for ${widget.vet.name}'),
              Text('Total Cost: KES ${_totalCost.toStringAsFixed(0)}'),
              Text('Service: $_selectedServiceType'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // You can pass the orderSummary to next screen or save it
      print('Order Summary: $orderSummary');

      // Navigate back to home
      context.pop();
      context.pop();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

// Supporting data models
class FarmHouse {
  final String id;
  final String name;
  final String location;
  final List<FarmBatch> batches;

  FarmHouse({
    required this.id,
    required this.name,
    required this.location,
    required this.batches,
  });
}

class FarmBatch {
  final String id;
  final String name;
  final int birdCount;
  final int ageWeeks;
  final String birdType;
  final String healthStatus;

  FarmBatch({
    required this.id,
    required this.name,
    required this.birdCount,
    required this.ageWeeks,
    required this.birdType,
    required this.healthStatus,
  });
}

class OrderSummary {
  final VetOfficer vet;
  final FarmHouse house;
  final FarmBatch batch;
  final String serviceType;
  final String priority;
  final DateTime date;
  final TimeOfDay time;
  final String reason;
  final String notes;
  final double consultationFee;
  final double serviceFee;
  final double mileageFee;
  final double prioritySurcharge;
  final double totalCost;

  OrderSummary({
    required this.vet,
    required this.house,
    required this.batch,
    required this.serviceType,
    required this.priority,
    required this.date,
    required this.time,
    required this.reason,
    required this.notes,
    required this.consultationFee,
    required this.serviceFee,
    required this.mileageFee,
    required this.prioritySurcharge,
    required this.totalCost,
  });
}