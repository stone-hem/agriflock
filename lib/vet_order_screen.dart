// vet_order_details_screen.dart
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetOrderDetailsScreen extends StatefulWidget {
  const VetOrderDetailsScreen({super.key});

  @override
  State<VetOrderDetailsScreen> createState() => _VetOrderDetailsScreenState();
}

class _VetOrderDetailsScreenState extends State<VetOrderDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedBatch;
  String? _selectedReason;
  String? _selectedDisease;
  String? _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isVaccination = false;
  String? _selectedAnimalType = 'Poultry';

  // Data lists
  final List<String> _batches = [
    'Batch 101 - Broilers (1000 birds)',
    'Batch 102 - Layers (500 birds)',
    'Batch 103 - Broilers (1500 birds)',
    'Batch 104 - Breeders (200 birds)',
    'Batch 105 - Broilers (800 birds)',
    'Batch 106 - Layers (600 birds)',
  ];

  final List<String> _reasons = [
    'Vaccination',
    'Routine Check-up',
    'Emergency Visit',
    'Disease Diagnosis',
    'Consultation',
    'Post-mortem Examination'
  ];

  final Map<String, List<String>> _diseases = {
    'Poultry': [
      'Newcastle Disease',
      'Avian Influenza',
      'Infectious Bronchitis',
      'Gumboro Disease',
      'Fowl Pox',
      'Marek\'s Disease',
      'Coccidiosis',
      'Salmonellosis',
      'E. coli Infection',
      'Mycoplasmosis',
    ]
  };

  final List<String> _priorities = [
    'Normal (Within 3 days)',
    'Urgent (Within 24 hours)',
    'Emergency (Immediate)',
  ];

  // Sample vet data
  final Map<String, dynamic> _vet = {
    'name': 'Dr. Try Vet',
    'specialization': 'Small Animal Medicine',
    'clinic': 'Happy Paws Veterinary Clinic',
    'consultationFee': 75.0,
    'avatarColor': Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar replacement
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Order Veterinary Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _submitOrder,
                    child: const Text(
                      'Send Request',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _vet['avatarColor'].withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.pets,
                                    color: _vet['avatarColor'],
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _vet['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _vet['specialization'],
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
                                          _vet['clinic'],
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  '\$${_vet['consultationFee'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
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
                                    'The veterinarian will review your request and respond within 24 hours.',
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

                      // Batch Selection
                      Text(
                        'Select Batch *',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBatch,
                        decoration: InputDecoration(
                          hintText: 'Choose a batch',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _batches.map((String batch) {
                          return DropdownMenuItem<String>(
                            value: batch,
                            child: Text(batch),
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

                      // Reason for Visit
                      Text(
                        'Reason for Visit *',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedReason,
                        decoration: InputDecoration(
                          hintText: 'Select reason for veterinary visit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _reasons.map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedReason = newValue;
                            _isVaccination = newValue == 'Vaccination';
                            if (!_isVaccination) {
                              _selectedDisease = null;
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select reason for visit';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Animal Type (for disease selection)
                      if (_isVaccination)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAnimalTypeChip('Poultry'),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Disease Selection (for vaccination only)
                      if (_isVaccination && _selectedAnimalType != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Disease to Vaccinate Against *',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDisease,
                              decoration: InputDecoration(
                                hintText: 'Select disease',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              items: _diseases[_selectedAnimalType]!.map((String disease) {
                                return DropdownMenuItem<String>(
                                  value: disease,
                                  child: Text(disease),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDisease = newValue;
                                });
                              },
                              validator: (value) {
                                if (_isVaccination && (value == null || value.isEmpty)) {
                                  return 'Please select disease for vaccination';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Priority Level
                      Text(
                        'Priority Level *',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPriority,
                        decoration: InputDecoration(
                          hintText: 'Select priority level',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _priorities.map((String priority) {
                          Color? color;
                          String icon = '';
                          if (priority.contains('Emergency')) {
                            color = Colors.red;
                            icon = '🆘';
                          } else if (priority.contains('Urgent')) {
                            color = Colors.orange;
                            icon = '⚠️';
                          } else {
                            color = Colors.green;
                            icon = '🕐';
                          }

                          return DropdownMenuItem<String>(
                            value: priority,
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Add this line
                              children: [
                                Text(icon),
                                const SizedBox(width: 12),
                                Flexible( // Change from Expanded to Flexible
                                  child: Text(priority),
                                ),
                                const SizedBox(width: 8), // Add spacing
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
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

                      // Preferred Date
                      Text(
                        'Preferred Date *',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                        'Preferred Time *',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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

                      // Detailed Reason
                      Text(
                        'Detailed Description *',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ReusableInput(
                        controller: _reasonController,
                        labelText: 'Describe the issue in detail',
                        hintText: 'Provide detailed information about what\'s happening with your animals...',
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a detailed description';
                          }
                          if (value.length < 20) {
                            return 'Please provide more details (at least 20 characters)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Symptoms (if not vaccination)
                      if (!_isVaccination)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Symptoms Observed',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ReusableInput(
                              controller: _symptomsController,
                              labelText: 'List symptoms',
                              hintText: 'Fever, loss of appetite, coughing, etc...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Additional Notes
                      Text(
                        'Additional Notes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ReusableInput(
                        controller: _notesController,
                        labelText: 'Notes',
                        hintText: 'Any other information the vet should know...',
                        maxLines: 3,
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '• Consultation fee: \$${_vet['consultationFee'].toStringAsFixed(2)}\n'
                                    '• Request will be sent to ${_vet['name']} for approval\n'
                                    '• Vet will respond within 24 hours\n'
                                    '• Cancellation requires 12 hours notice\n'
                                    '• Payment due after service completion\n'
                                    '• Travel charges may apply based on distance',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
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
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Send Request to Vet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                              _buildProcessStep(2, 'Vet Review', 'Dr. ${_vet['name'].split(' ').last} reviews your request'),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalTypeChip(String type) {
    final isSelected = _selectedAnimalType == type;
    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedAnimalType = type;
          _selectedDisease = null;
        });
      },
      selectedColor: Colors.green,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Confirm Order Request'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send request to ${_vet['name']}?'),
              const SizedBox(height: 16),
              if (_selectedBatch != null) Text('Batch: $_selectedBatch'),
              if (_selectedReason != null) Text('Reason: $_selectedReason'),
              if (_selectedDisease != null) Text('Disease: $_selectedDisease'),
              if (_selectedPriority != null) Text('Priority: $_selectedPriority'),
              if (_selectedDate != null)
                Text('Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              if (_selectedTime != null)
                Text('Time: ${_selectedTime!.format(context)}'),
              const SizedBox(height: 8),
              Text(
                'Consultation Fee: \$${_vet['consultationFee'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Send Request'),
            ),
          ],
        ),
      );
    }
  }

  void _processOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✅ Request Sent Successfully!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your request has been sent to ${_vet['name']}. '
                  'You will be notified when the vet responds.',
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      context.pop();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}