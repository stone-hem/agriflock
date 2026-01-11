import 'dart:io';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class AddBatchScreen extends StatefulWidget {
  final FarmModel farm;
  final String? houseId;
  final List<House>? houses;

  const AddBatchScreen({
    super.key,
    required this.farm,
    this.houseId,
    this.houses,
  });

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hatchController = TextEditingController();
  final _initialQuantityController = TextEditingController();
  final _birdsAliveController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _expectedWeightController = TextEditingController();
  final _notesController = TextEditingController();
  final _repository = BatchHouseRepository();

  String? _selectedBirdTypeId;
  String? _selectedBatchType;
  String? _selectedFeedingTime;
  String? _selectedHouse;
  DateTime? _hatchDate;
  File? _batchPhotoFile;
  bool _isLoading = false;
  bool _isLoadingBirdTypes = false;

  List<House> _houses = [];
  List<BirdType> _birdTypes = [];
  final List<String> _batchTypes = [
    'Meat Production',
    'Egg Production',
    'Breeding',
    'Dual Purpose',
  ];

  final Map<String, List<String>> _feedingTimes = {
    'Day': ['06:00', '11:00', '16:00'],
    'Night': ['18:00', '22:00', '02:00', '06:00'],
    'Both': ['06:00', '11:00', '16:00', '18:00', '22:00', '02:00'],
  };

  @override
  void initState() {
    super.initState();
    _loadHouses();
    _loadBirdTypes();
    _initializeForm();
  }

  Future<void> _loadHouses() async {
    try {
      if (widget.houses != null) {
        setState(() {
          _houses = widget.houses!;
        });
      } else {
        final result = await _repository.getAllHouses(widget.farm.id);

        switch (result) {
          case Success(data: final houses):
            setState(() {
              _houses = houses;
            });

          case Failure(:final response, :final message):
          // Handle with full response for detailed error handling
            if (response != null) {
              ApiErrorHandler.handle(response);
            } else {
              ToastUtil.showError(message);
            }
        }

      }

      // Pre-select house if provided
      if (widget.houseId != null) {
        _selectedHouse = widget.houseId;
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    }
  }

  Future<void> _loadBirdTypes() async {
    try {
      setState(() {
        _isLoadingBirdTypes = true;
      });

      // Assuming repository has a method to fetch bird types
      final result = await _repository.getBirdTypes();

      switch (result) {
        case Success(data: final types):
          setState(() {
            _birdTypes = types;
            _isLoadingBirdTypes = false;
          });

        case Failure(:final response, :final message):
        // Handle with full response for detailed error handling
          if (response != null) {
            ApiErrorHandler.handle(response);
          } else {
            ToastUtil.showError(message);
          }
      }


    } catch (e) {
      ApiErrorHandler.handle(e);
      setState(() {
        _isLoadingBirdTypes = false;
      });
    }
  }

  void _initializeForm() {
    // Set default values for a new batch
    _birdsAliveController.text = '0';
    _currentWeightController.text = '0.0';
    _expectedWeightController.text = '0.0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title:  Text('Add New Batch - ${widget.farm.farmName}'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createBatch,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
                : const Text(
              'Create',
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
              // Batch Photo Upload
              PhotoUpload(
                file: _batchPhotoFile,
                onFileSelected: (File? file) {
                  setState(() {
                    _batchPhotoFile = file;
                  });
                },
                title: 'Batch Photo (Optional)',
                description: 'Upload a photo of your batch',
                primaryColor: Colors.green,
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
              DropdownButtonFormField<String>(
                initialValue: _selectedHouse,
                decoration: InputDecoration(
                  hintText: 'Select house',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _houses.map((House house) {
                  return DropdownMenuItem<String>(
                    value: house.id,
                    child: Text('${house.houseName} (${house.capacity} capacity)'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHouse = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a house';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bird Type Selection
              Text(
                'Bird Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingBirdTypes
                  ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Loading bird types...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
                  : DropdownButtonFormField<String>(
                initialValue: _selectedBirdTypeId,
                decoration: InputDecoration(
                  hintText: 'Select bird type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _birdTypes.map((BirdType type) {
                  return DropdownMenuItem<String>(
                    value: type.id,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBirdTypeId = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a bird type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Batch Type Selection
              Text(
                'Batch Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedBatchType,
                decoration: InputDecoration(
                  hintText: 'Select batch type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _batchTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBatchType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a batch type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Hatch Date
              Text(
                'Hatch Date',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              CustomDateTextField(
                label: 'Date of Birth *Required',
                hintText: 'Enter your date of birth',
                icon: Icons.calendar_today,
                required: true,
                minYear: DateTime.now().year-1,
                returnFormat: DateReturnFormat.dateTime,
                maxYear: DateTime.now().year, controller: _hatchController,
                onChanged: (value){
                  if (value != null) {
                    _hatchDate = value;
                  }
                },

              ),
              const SizedBox(height: 20),

              // Initial Count
              Text(
                'Initial Count',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _initialQuantityController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter initial count';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Initial count must be greater than 0';
                  }
                  return null;
                },
                labelText: 'initial count at hatching',
                hintText: 'e.g., 1000',
              ),
              const SizedBox(height: 20),

              // Birds Alive
              Text(
                'Current Count',
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
                  final alive = int.parse(value);
                  final initial = int.tryParse(_initialQuantityController.text) ?? 0;
                  if (alive > initial) {
                    return 'Birds alive cannot exceed initial count';
                  }
                  return null;
                },
                labelText: 'Current count at the moment',
                hintText: 'e.g., 1000',
              ),
              const SizedBox(height: 20),

              // Current Weight
              Text(
                'Average weight (kg)',
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
                labelText: 'Current average weight ',
                hintText: 'e.g., 0.0',
              ),
              const SizedBox(height: 20),

              // Expected Weight
              Text(
                'Expected Average Weight (kg)',
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
                  final expected = double.parse(value);
                  final current = double.tryParse(_currentWeightController.text) ?? 0.0;
                  if (expected < current) {
                    return 'Expected weight should be greater than current weight';
                  }
                  return null;
                },
                labelText: 'Expected average weight at removal/sale',
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

              // Notes
              Text(
                'Notes (Optional)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _notesController,
                maxLines: 3,
                labelText: 'Notes',
                hintText: 'Enter any additional notes about this batch',
              ),
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
                        'Batch Creation',
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


  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hatchDate == null) {
      ToastUtil.showError('Please select hatch date');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare batch data according to API requirements
      final batchData = {
        'house_id': _selectedHouse,
        'batch_name': _nameController.text.trim(),
        'bird_type_id': _selectedBirdTypeId,
        'batch_type': _selectedBatchType,
        'initial_count': int.parse(_initialQuantityController.text.trim()),
        'hatch_date': DateUtil.toISO8601(_hatchDate!), // Date only
        'birds_alive': int.parse(_birdsAliveController.text.trim()),
        'current_weight': double.parse(_currentWeightController.text.trim()),
        'expected_weight': double.parse(_expectedWeightController.text.trim()),
        'feeding_time': _selectedFeedingTime,
        'feeding_schedule': _feedingTimes[_selectedFeedingTime!]?.join(','),
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };


      final result = await _repository.createBatch(
        widget.farm.id,
        batchData,
        photoFile: _batchPhotoFile,
      );

      switch (result) {
        case Success():
          ToastUtil.showSuccess('Batch created successfully!');
          if (context.mounted) {
           context.pushReplacement('/batches', extra: widget.farm);
          }

        case Failure(:final response, :final message):
        // Handle with full response for detailed error handling
          if (response != null) {
            ApiErrorHandler.handle(response);
          } else {
            ToastUtil.showError(message);
          }
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialQuantityController.dispose();
    _birdsAliveController.dispose();
    _currentWeightController.dispose();
    _expectedWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}