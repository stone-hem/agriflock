import 'dart:io';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditBatchScreen extends StatefulWidget {
  final FarmModel farm;
  final BatchModel batch;
  final House house; // Changed to required house

  const EditBatchScreen({
    super.key,
    required this.farm,
    required this.batch,
    required this.house, // Required house parameter
  });

  @override
  State<EditBatchScreen> createState() => _EditBatchScreenState();
}

class _EditBatchScreenState extends State<EditBatchScreen> {
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
  String? _selectedFeedingTimeCategory;
  DateTime? _hatchDate;
  File? _batchPhotoFile;
  bool _isLoading = false;
  bool _isLoadingBirdTypes = false;

  List<BirdType> _birdTypes = [];
  final List<String> _batchTypes = [
    'Meat Production',
    'Egg Production',
    'Breeding',
    'Dual Purpose',
    'LAYERS'
  ];

  final Map<String, List<String>> _feedingTimeOptions = {
    'Day': ['06:00AM', '09:00AM', '12:00 Noon', '3:00PM', '6:00PM'],
    'Night': ['9:00PM', '12:00 Midnight', '3:00AM', '06:00AM'],
    'Both': ['06:00AM', '09:00AM', '12:00 Noon', '3:00PM', '6:00PM', '9:00PM', '12:00 Midnight', '3:00AM'],
  };

  // Track selected feeding times within each category
  final Map<String, List<String>> _selectedFeedingTimes = {
    'Day': [],
    'Night': [],
    'Both': [],
  };

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadBirdTypes();
  }

  Future<void> _loadBirdTypes() async {
    try {
      setState(() {
        _isLoadingBirdTypes = true;
      });

      final result = await _repository.getBirdTypes();

      switch (result) {
        case Success(data: final types):
          setState(() {
            _birdTypes = types;
            _isLoadingBirdTypes = false;
          });

        case Failure(:final response, :final message):
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
    // Initialize with existing batch data
    final batch = widget.batch;

    _nameController.text = batch.batchName;
    _selectedBirdTypeId = batch.birdTypeId;
    _selectedBatchType = batch.type;
    _hatchDate = batch.startDate;

    // Set hatch controller value
    if (_hatchDate != null) {
      _hatchController.text = DateUtil.toMMDDYYYY(_hatchDate!);
    }

    _initialQuantityController.text = batch.initialQuantity.toString();
    _birdsAliveController.text = batch.birdsAlive.toString();
    _currentWeightController.text = batch.currentWeight.toString();
    _expectedWeightController.text = batch.expectedWeight.toString();
    _selectedFeedingTimeCategory = batch.feedingTime;
    _notesController.text = batch.description ?? '';

    // Parse existing feeding schedule if available
    if (batch.feedingSchedule.isNotEmpty) {
      final times = batch.feedingSchedule;
      _selectedFeedingTimes[_selectedFeedingTimeCategory ?? 'Day'] = times;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate capacity excluding current batch
    final totalCapacity = widget.house.capacity ?? 0;
    final currentBirds = (widget.house.currentBirds ?? 0) - widget.batch.birdsAlive;
    final availableCapacity = totalCapacity - currentBirds + widget.batch.birdsAlive;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Batch - ${widget.farm.farmName}'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateBatch,
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
              // House Information (Display only)
              Card(
                elevation: 0,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'House ${widget.house.houseName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${widget.house.batches.length} batch(es)',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCapacityInfo(
                            'Total Capacity',
                            '$totalCapacity birds',
                            Icons.people,
                            Colors.green,
                          ),
                          _buildCapacityInfo(
                            'Current Birds',
                            '$currentBirds birds',
                            Icons.pets,
                            Colors.orange,
                          ),
                          _buildCapacityInfo(
                            'Available*',
                            '$availableCapacity birds',
                            Icons.event_available,
                            availableCapacity > 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '*Includes current batch count adjustment',
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
              const SizedBox(height: 20),

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
                  : ReusableDropdown<String>(
                value: _selectedBirdTypeId,
                hintText: 'Select bird type',
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
              // Text(
              //   'Batch Type',
              //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey.shade800,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // ReusableDropdown<String>(
              //   value: _selectedBatchType,
              //   hintText: 'Select batch type',
              //   items: _batchTypes.map((String type) {
              //     return DropdownMenuItem<String>(
              //       value: type,
              //       child: Text(type),
              //     );
              //   }).toList(),
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedBatchType = newValue;
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please select a batch type';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 20),

              // // Hatch Date
              // CustomDateTextField(
              //   label: 'Date of Hatching',
              //   hintText: 'Select hatch date',
              //   icon: Icons.calendar_today,
              //   required: true,
              //   minYear: DateTime.now().year - 2,
              //   returnFormat: DateReturnFormat.dateTime,
              //   maxYear: DateTime.now().year,
              //   controller: _hatchController,
              //   initialDate: _hatchDate,
              //   onChanged: (value) {
              //     if (value != null) {
              //       setState(() {
              //         _hatchDate = value;
              //       });
              //     }
              //   },
              // ),
              // const SizedBox(height: 20),

              // Initial Count
              // Text(
              //   'Initial Count',
              //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey.shade800,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // ReusableInput(
              //   controller: _initialQuantityController,
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter initial count';
              //     }
              //     if (int.tryParse(value) == null) {
              //       return 'Please enter a valid number';
              //     }
              //     final count = int.parse(value);
              //     if (count <= 0) {
              //       return 'Initial count must be greater than 0';
              //     }
              //     if (count > availableCapacity) {
              //       return 'Initial count ($count) exceeds available capacity ($availableCapacity)';
              //     }
              //     return null;
              //   },
              //   labelText: 'Initial count from hatchery',
              //   hintText: 'e.g., 1000',
              // ),
              // const SizedBox(height: 20),

              // Current Count (Birds Alive)
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
                    return 'Please enter current count';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                labelText: 'Current count at the moment',
                hintText: 'e.g., 980',
              ),
              const SizedBox(height: 20),
              //
              // // Current Average Weight
              // Text(
              //   'Average weight (kg)',
              //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey.shade800,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // ReusableInput(
              //   controller: _currentWeightController,
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter current average weight';
              //     }
              //     if (double.tryParse(value) == null) {
              //       return 'Please enter a valid weight';
              //     }
              //     return null;
              //   },
              //   labelText: 'Current average weight',
              //   hintText: 'e.g., 1.5',
              // ),
              // const SizedBox(height: 20),
              //
              // // Expected Average Weight
              // Text(
              //   'Expected Average Weight (kg)',
              //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey.shade800,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // ReusableInput(
              //   controller: _expectedWeightController,
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter expected average weight';
              //     }
              //     if (double.tryParse(value) == null) {
              //       return 'Please enter a valid weight';
              //     }
              //     final expected = double.parse(value);
              //     final current = double.tryParse(_currentWeightController.text) ?? 0.0;
              //     if (expected < current) {
              //       return 'Expected weight should be greater than current weight';
              //     }
              //     return null;
              //   },
              //   labelText: 'Expected average weight at removal/sale',
              //   hintText: 'e.g., 2.5',
              // ),
              // const SizedBox(height: 20),
              //
              // // Feeding Time Selection
              // Text(
              //   'Feeding Time',
              //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey.shade800,
              //   ),
              // ),
              // const SizedBox(height: 8),
              //
              // // Feeding Time Category Selection
              // ReusableDropdown<String>(
              //   value: _selectedFeedingTimeCategory,
              //   hintText: 'Select feeding time category',
              //   items: _feedingTimeOptions.keys.map((String category) {
              //     return DropdownMenuItem<String>(
              //       value: category,
              //       child: Text(category),
              //     );
              //   }).toList(),
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedFeedingTimeCategory = newValue;
              //       // Clear previous selections when category changes
              //       if (newValue != null && newValue != _selectedFeedingTimeCategory) {
              //         _selectedFeedingTimes[_selectedFeedingTimeCategory ?? 'Day']?.clear();
              //       }
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please select feeding time category';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 16),

              // Specific Feeding Times Selection within Category
              // if (_selectedFeedingTimeCategory != null) ...[
              //   Text(
              //     'Select Specific Feeding Times:',
              //     style: Theme.of(context).textTheme.titleMedium!.copyWith(
              //       fontWeight: FontWeight.bold,
              //       color: Colors.grey.shade800,
              //     ),
              //   ),
              //   const SizedBox(height: 8),
              //
              //   // Display all options for the selected category
              //   Column(
              //     children: _feedingTimeOptions[_selectedFeedingTimeCategory]!
              //         .map((time) {
              //       bool isSelected = _selectedFeedingTimes[_selectedFeedingTimeCategory]!.contains(time);
              //
              //       return Padding(
              //         padding: const EdgeInsets.only(bottom: 8),
              //         child: GestureDetector(
              //           onTap: () {
              //             setState(() {
              //               if (isSelected) {
              //                 _selectedFeedingTimes[_selectedFeedingTimeCategory]!.remove(time);
              //               } else {
              //                 _selectedFeedingTimes[_selectedFeedingTimeCategory]!.add(time);
              //               }
              //             });
              //           },
              //           child: Container(
              //             padding: const EdgeInsets.all(12),
              //             decoration: BoxDecoration(
              //               color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
              //               borderRadius: BorderRadius.circular(12),
              //               border: Border.all(
              //                 color: isSelected ? Colors.green : Colors.grey.shade300,
              //                 width: isSelected ? 2 : 1,
              //               ),
              //             ),
              //             child: Row(
              //               children: [
              //                 Icon(
              //                   isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              //                   color: isSelected ? Colors.green : Colors.grey,
              //                 ),
              //                 const SizedBox(width: 12),
              //                 Expanded(
              //                   child: Text(
              //                     time,
              //                     style: TextStyle(
              //                       fontWeight: FontWeight.w500,
              //                       color: isSelected ? Colors.green.shade800 : Colors.grey.shade800,
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //   ),
              //
              //   // Show selected times summary
              //   if (_selectedFeedingTimes[_selectedFeedingTimeCategory]!.isNotEmpty) ...[
              //     const SizedBox(height: 16),
              //     Container(
              //       padding: const EdgeInsets.all(16),
              //       decoration: BoxDecoration(
              //         color: Colors.green.shade50,
              //         borderRadius: BorderRadius.circular(12),
              //         border: Border.all(color: Colors.green.shade100),
              //       ),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             'Selected Feeding Times:',
              //             style: const TextStyle(
              //               fontWeight: FontWeight.bold,
              //               color: Colors.green,
              //             ),
              //           ),
              //           const SizedBox(height: 8),
              //           Wrap(
              //             spacing: 8,
              //             runSpacing: 4,
              //             children: _selectedFeedingTimes[_selectedFeedingTimeCategory]!
              //                 .map((time) => Chip(
              //               label: Text(
              //                 time,
              //                 style: const TextStyle(color: Colors.white),
              //               ),
              //               backgroundColor: Colors.green,
              //             ))
              //                 .toList(),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              //   const SizedBox(height: 16),
              // ],

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
                        'Batch Management',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'After updating your batch, you can:\n'
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

  Widget _buildCapacityInfo(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _updateBatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hatchDate == null) {
      ToastUtil.showError('Please select hatch date');
      return;
    }

    // Validate feeding times selection
    if (_selectedFeedingTimeCategory == null ||
        _selectedFeedingTimes[_selectedFeedingTimeCategory]!.isEmpty) {
      ToastUtil.showError('Please select at least one feeding time');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare batch data according to API requirements
      final selectedFeedingTimes = _selectedFeedingTimes[_selectedFeedingTimeCategory]!;

      final batchData = {
        'house_id': widget.house.id,
        'batch_name': _nameController.text.trim(),
        'bird_type_id': _selectedBirdTypeId,
        // 'batch_type': _selectedBatchType,
        // 'initial_count': int.parse(_initialQuantityController.text.trim()),
        'current_count': int.parse(_birdsAliveController.text.trim()),
        // 'hatch_date': DateUtil.toISO8601(_hatchDate!),
        // 'birds_alive': int.parse(_birdsAliveController.text.trim()),
        // 'current_weight': double.parse(_currentWeightController.text.trim()),
        // 'expected_weight': double.parse(_expectedWeightController.text.trim()),
        // 'feeding_time': _selectedFeedingTimeCategory,
        // 'feeding_schedule': selectedFeedingTimes.join(','),
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      final result = await _repository.updateBatch(
        widget.batch.id,
        batchData,
        photoFile: _batchPhotoFile,
      );

      switch (result) {
        case Success():
          ToastUtil.showSuccess('Batch updated successfully!');
          if (context.mounted) {
            context.pushReplacement('/batches/details', extra: {
              'batch': widget.batch,
              'farm': widget.farm,
            });
          }

        case Failure(:final response, :final message):
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