import 'dart:io';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddEditBatchScreen extends StatefulWidget {
  final String farmId;
  final String? houseId;
  final BatchModel? batch;
  final List<House>? houses;

  const AddEditBatchScreen({
    super.key,
    required this.farmId,
    this.houseId,
    this.batch,
    this.houses,
  });

  @override
  State<AddEditBatchScreen> createState() => _AddEditBatchScreenState();
}

class _AddEditBatchScreenState extends State<AddEditBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialQuantityController = TextEditingController();
  final _birdsAliveController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _expectedWeightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repository = BatchHouseRepository();

  String? _selectedBreed;
  String? _selectedType;
  String? _selectedFeedingTime;
  String? _selectedHouse;
  DateTime? _hatchDate;
  File? _batchPhotoFile;
  bool _isLoading = false;

  List<House> _houses = [];

  final List<String> _breeds = [
    'Broiler',
    'Layer',
    'Improved Kienyeji'
  ];

  final List<String> _types = [
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
    _initializeForm();
  }

  Future<void> _loadHouses() async {
    try {
      if (widget.houses != null) {
        setState(() {
          _houses = widget.houses!;
        });
      } else {
        final houses = await _repository.getAllHouses(widget.farmId);
        setState(() {
          _houses = houses;
        });
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    }
  }

  void _initializeForm() {
    if (widget.batch != null) {
      // Editing existing batch
      _nameController.text = widget.batch!.batchName;
      _initialQuantityController.text = widget.batch!.initialQuantity.toString();
      _birdsAliveController.text = widget.batch!.birdsAlive.toString();
      _currentWeightController.text = widget.batch!.currentWeight.toString();
      _expectedWeightController.text = widget.batch!.expectedWeight.toString();
      _descriptionController.text = widget.batch!.description ?? '';
      _selectedBreed = widget.batch!.breed;
      _selectedType = widget.batch!.type;
      _selectedFeedingTime = widget.batch!.feedingTime;
      _selectedHouse = widget.batch!.houseId;
      _hatchDate = widget.batch!.startDate;
    } else if (widget.houseId != null) {
      // Pre-select house when adding batch from house card
      _selectedHouse = widget.houseId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.batch != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Batch' : 'Add New Batch'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveBatch,
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
                value: _selectedHouse,
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
                value: _selectedBreed,
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
                value: _selectedType,
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
                        _hatchDate == null
                            ? 'Select start date'
                            : '${_hatchDate!.day}/${_hatchDate!.month}/${_hatchDate!.year}',
                        style: TextStyle(
                          color: _hatchDate == null
                              ? Colors.grey.shade600
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Initial Quantity
              Text(
                'Initial Quantity',
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
                    return 'Please enter initial quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                labelText: 'Initial Quantity',
                hintText: 'e.g., 1000',
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
                hintText: 'e.g., 980',
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
                labelText: 'Weight',
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
                value: _selectedFeedingTime,
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

              // Description
              Text(
                'Description (Optional)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _descriptionController,
                maxLines: 3,
                labelText: 'Description',
                hintText: 'Enter any additional notes',
              ),
              const SizedBox(height: 32),

              // Delete Button (only when editing)
              if (isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Batch'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
      initialDate: _hatchDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _hatchDate) {
      setState(() {
        _hatchDate = picked;
      });
    }
  }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hatchDate == null) {
      ToastUtil.showError('Please select start date');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final batchData = {
        'batch_name': _nameController.text.trim(),
        'house_id': _selectedHouse,
        'breed': _selectedBreed,
        'type': _selectedType,
        'start_date': _hatchDate!.toIso8601String(),
        'initial_quantity': int.parse(_initialQuantityController.text.trim()),
        'birds_alive': int.parse(_birdsAliveController.text.trim()),
        'current_weight': double.parse(_currentWeightController.text.trim()),
        'expected_weight': double.parse(_expectedWeightController.text.trim()),
        'feeding_time': _selectedFeedingTime,
        'feeding_schedule': _feedingTimes[_selectedFeedingTime!],
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      };

      if (widget.batch == null) {
        // Create new batch
        await _repository.createBatch(
          widget.farmId,
          batchData,
          photoFile: _batchPhotoFile,
        );
        ToastUtil.showSuccess('Batch "${_nameController.text}" created successfully!');
      } else {
        // Update existing batch
        await _repository.updateBatch(
          widget.farmId,
          widget.batch!.id!,
          batchData,
          photoFile: _batchPhotoFile,
        );
        ToastUtil.showSuccess('Batch updated successfully!');
      }

      if (context.mounted) {
        context.pop(true); // Return true to indicate success
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text('Are you sure you want to delete "${widget.batch!.batchName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBatch();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBatch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _repository.deleteBatch(widget.farmId, widget.batch!.id!);
      ToastUtil.showSuccess('Batch deleted successfully');
      if (context.mounted) {
        context.pop(true);
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
    _descriptionController.dispose();
    super.dispose();
  }
}