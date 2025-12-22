import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddBatchScreen extends StatefulWidget {
  const AddBatchScreen({super.key});

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birdsAliveController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _expectedWeightController = TextEditingController();

  // New controllers for house
  final _newHouseNameController = TextEditingController();
  final _newHouseCapacityController = TextEditingController();

  String? _selectedBreed;
  String? _selectedType;
  String? _selectedFeedingTime;
  String? _selectedHouse;
  DateTime? _startDate;

  // New state variables for house
  bool _isAddingNewHouse = false;
  List<String> _existingHouses = [
    'House A - Broiler Section',
    'House B - Layer Section',
    'House C - Breeding Section',
    'House D - Free Range',
    'House E - Quarantine'
  ];

  final List<String> _breeds = [
    'Broiler',
    'Layer',
    'Heritage Breed',
    'Free Range',
    'Organic'
  ];

  final List<String> _types = [
    'Meat Production',
    'Egg Production',
    'Breeding',
    'Dual Purpose'
  ];

  final Map<String, List<String>> _feedingTimes = {
    'Day': ['06:00', '11:00', '16:00'],
    'Night': ['18:00', '22:00', '02:00', '06:00'],
    'Both': ['06:00', '11:00', '16:00', '18:00', '22:00', '02:00']
  };

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
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('Add New Batch'),
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
          TextButton(
            onPressed: _saveBatch,
            child: const Text(
              'Save',
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
              // Batch Image Upload
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets_outlined, color: Colors.grey.shade500),
                      const SizedBox(height: 8),
                      Text(
                        'Add Batch Photo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Batch Name
              Text(
                'Batch Name',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter batch name';
                  }
                  return null;
                },
                labelText: 'Name',
                hintText: 'e.g., Spring Broiler Batch 2024',
              ),
              const SizedBox(height: 20),

              // House Selection
              Text(
                'House Assignment',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isAddingNewHouse ? 'Add New House' : 'Select Existing House',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Switch(
                            value: _isAddingNewHouse,
                            onChanged: (value) {
                              setState(() {
                                _isAddingNewHouse = value;
                                if (!value) {
                                  // Clear new house form when switching back
                                  _newHouseNameController.clear();
                                  _newHouseCapacityController.clear();
                                }
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (!_isAddingNewHouse) ...[
                        // Existing House Selection
                        DropdownButtonFormField<String>(
                          value: _selectedHouse,
                          decoration: InputDecoration(
                            hintText: 'Select an existing house',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Select house...'),
                            ),
                            ..._existingHouses.map((String house) {
                              return DropdownMenuItem<String>(
                                value: house,
                                child: Text(house),
                              );
                            }).toList(),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedHouse = newValue;
                            });
                          },
                          validator: (value) {
                            if (!_isAddingNewHouse && (value == null || value.isEmpty)) {
                              return 'Please select a house';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        // New House Form
                        Column(
                          children: [
                            ReusableInput(
                              controller: _newHouseNameController,
                              labelText: 'House Name',
                              hintText: 'e.g., House F - New Section',
                              validator: (value) {
                                if (_isAddingNewHouse && (value == null || value.isEmpty)) {
                                  return 'Please enter house name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ReusableInput(
                              controller: _newHouseCapacityController,
                              labelText: 'Capacity (birds)',
                              hintText: 'e.g., 5000',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (_isAddingNewHouse && (value == null || value.isEmpty)) {
                                  return 'Please enter capacity';
                                }
                                if (_isAddingNewHouse && int.tryParse(value!) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: _addNewHouse,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add House'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Breed Selection
              Text(
                'Breed',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedBreed,
                decoration: InputDecoration(
                  hintText: 'Select breed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _breeds.map((String breed) {
                  return DropdownMenuItem<String>(
                    value: breed,
                    child: Text(breed),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBreed = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a breed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Type Selection
              Text(
                'Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  hintText: 'Select type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Start Date
              Text(
                'Start Date',
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
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        _startDate == null
                            ? 'Select start date'
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        style: TextStyle(
                          color: _startDate == null
                              ? Colors.grey.shade600
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Age
              Text(
                'Age (days)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _ageController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age in days';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                labelText: 'Age',
                hintText: 'e.g., 21',
              ),
              const SizedBox(height: 20),

              // Birds Alive
              Text(
                'Birds Alive',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _birdsAliveController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of birds alive';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                labelText: 'Birds Alive',
                hintText: 'e.g., 1000',
              ),
              const SizedBox(height: 20),

              // Current Weight
              Text(
                'Current Weight (kg)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _currentWeightController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
                labelText: 'weight',
                hintText: 'e.g., 1.5',
              ),
              const SizedBox(height: 20),

              // Expected Weight
              Text(
                'Expected Weight (kg)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _expectedWeightController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expected weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
                labelText: 'Weight',
                hintText: 'e.g., 2.5',
              ),
              const SizedBox(height: 20),

              // Feeding Time Selection
              Text(
                'Feeding Time',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedFeedingTime,
                decoration: InputDecoration(
                  hintText: 'Select feeding time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _feedingTimes.keys.map((String time) {
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFeedingTime = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select feeding time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Display Feeding Times
              if (_selectedFeedingTime != null) ...[
                Text(
                  'Feeding Schedule:',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedFeedingTime Feeding Times:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _feedingTimes[_selectedFeedingTime]!
                            .map((time) => Chip(
                          label: Text(
                            time,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 32),

              // Additional Information
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch Management',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'After creating your batch, you can:\n'
                            '• Track growth progress\n'
                            '• Monitor feeding schedules\n'
                            '• Record health checks\n'
                            '• Update weight metrics\n'
                            '• Generate performance reports',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _addNewHouse() {
    if (_newHouseNameController.text.isNotEmpty &&
        _newHouseCapacityController.text.isNotEmpty) {
      final newHouseName = '${_newHouseNameController.text} (Capacity: ${_newHouseCapacityController.text})';

      setState(() {
        _existingHouses.add(newHouseName);
        _selectedHouse = newHouseName;
        _isAddingNewHouse = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New house "$newHouseName" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  void _saveBatch() {
    if (_formKey.currentState!.validate()) {
      // Get house information
      String houseInfo = '';
      if (_isAddingNewHouse) {
        houseInfo = 'New House: ${_newHouseNameController.text} (Capacity: ${_newHouseCapacityController.text})';
      } else {
        houseInfo = 'Existing House: $_selectedHouse';
      }

      // TODO: Implement save batch logic with house information
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Batch "${_nameController.text}" created successfully!'),
              Text(
                houseInfo,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _birdsAliveController.dispose();
    _currentWeightController.dispose();
    _expectedWeightController.dispose();
    _newHouseNameController.dispose();
    _newHouseCapacityController.dispose();
    super.dispose();
  }
}