import 'dart:io';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:agriflock360/core/widgets/reusable_decimal_input.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddBatchScreen extends StatefulWidget {
  final FarmModel farm;
  final House house;

  const AddBatchScreen({super.key, required this.farm, required this.house});

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
  final _chickCostController = TextEditingController();
  final _chickAgeController = TextEditingController();
  final _hatchSourceController = TextEditingController();
  final _repository = BatchHouseRepository();

  String? _selectedBirdTypeId;
  String? _selectedBatchType;
  String? _selectedFeedingTimeCategory;
  File? _batchPhotoFile;
  bool _isLoading = false;
  bool _isLoadingBirdTypes = false;
  bool _hasChickCost = false;
  bool _isOwnHatch = true;

  List<BirdType> _birdTypes = [];
  final List<String> _batchTypes = [
    'Meat Production',
    'Egg Production',
    'Breeding',
    'Dual Purpose',
  ];
  String _currency='';

  final Map<String, List<String>> _feedingTimeOptions = {
    'Day': ['06:00AM', '09:00AM', '12:00 Noon', '3:00PM', '6:00PM'],
    'Night': ['9:00PM', '12:00 Midnight', '3:00AM', '06:00AM'],
    'Both': [
      '06:00AM',
      '09:00AM',
      '12:00 Noon',
      '3:00PM',
      '6:00PM',
      '9:00PM',
      '12:00 Midnight',
      '3:00AM',
    ],
  };

  // Track selected feeding times within each category
  final Map<String, List<String>> _selectedFeedingTimes = {
    'Day': [],
    'Night': [],
    'Both': [],
  };

  int _availableCapacity = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _initializeForm();
    _loadBirdTypes();
    _calculateAvailableCapacity();
  }

  Future<void> _loadCurrency() async {
    var currency = await secureStorage.getCurrency();
    setState(() {
      _currency = currency;
    });
  }

  void _calculateAvailableCapacity() {
    setState(() {
      _availableCapacity = widget.house.capacity - widget.house.currentBirds;
    });
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
    // Initialize chick cost as 0
    _chickCostController.text = '0';
    _chickAgeController.text = '0';

    // Set initial hatch date to today for both modes
    _hatchController.text = DateUtil.toReadableDate(DateTime.now());
  }

  void _switchHatchSource(bool isOwnHatch) {
    setState(() {
      final wasOwnHatch = _isOwnHatch;
      _isOwnHatch = isOwnHatch;

      // Clear relevant fields when switching
      if (wasOwnHatch != isOwnHatch) {
        if (isOwnHatch) {
          // Switching to own hatch
          _chickAgeController.text = '0';
          _hatchSourceController.clear();
          _hatchController.text = DateUtil.toReadableDate(DateTime.now());
        } else {
          // Switching to purchased chicks
          _hatchController.clear();
          _hatchController.text = DateUtil.toReadableDate(DateTime.now());
          _calculateAndUpdateHatchDate();
        }
      }
    });
  }

  void _calculateAndUpdateHatchDate() {
    if (!_isOwnHatch) {
      final age = int.tryParse(_chickAgeController.text) ?? 0;
      if (age >= 0) {
        setState(() {
          _hatchController.text = DateUtil.toReadableDate(DateTime.now().subtract(Duration(days: age)));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Batch - ${widget.farm.farmName}'),
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
                            '${widget.house.capacity} birds',
                            Icons.people,
                            Colors.green,
                          ),
                          _buildCapacityInfo(
                            'Current Birds',
                            '${widget.house.currentBirds} birds',
                            Icons.pets,
                            Colors.orange,
                          ),
                          _buildCapacityInfo(
                            'Available',
                            '$_availableCapacity birds',
                            Icons.event_available,
                            _availableCapacity > 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      if (_availableCapacity <= 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This house is at full capacity! Consider selecting a different house.',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              ReusableInput(
                topLabel: 'Batch Name',
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
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
                topLabel: 'Bird Type',
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
              ReusableDropdown<String>(
                value: _selectedBatchType,
                hintText: 'Select batch type',
                topLabel: 'Batch Type',
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

              // Hatch Source Selection
              Text(
                'Hatch Source',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Own Hatch'),
                      selected: _isOwnHatch,
                      onSelected: (selected) {
                        _switchHatchSource(selected);
                      },
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: _isOwnHatch
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Purchased Chicks'),
                      selected: !_isOwnHatch,
                      onSelected: (selected) {
                        _switchHatchSource(!selected);
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: !_isOwnHatch
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hatch Date - Only shown for own hatch
              if (_isOwnHatch) ...[
                CustomDateTextField(
                  label: 'Date of Hatching',
                  icon: Icons.calendar_today,
                  required: true,
                  initialDate: DateTime.now(),
                  minYear: DateTime.now().year - 1,
                  returnFormat: DateReturnFormat.isoString,
                  maxYear: DateTime.now().year,
                  controller: _hatchController,
                ),
                const SizedBox(height: 20),
              ],

              // Chick Age - Only shown for purchased chicks
              if (!_isOwnHatch) ...[
                ReusableInput(
                  topLabel: 'Chick Age (Days)',
                  controller: _chickAgeController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Calculate and update hatch date in real-time
                    _calculateAndUpdateHatchDate();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter chick age in days';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    final age = int.parse(value);
                    if (age < 0) {
                      return 'Age cannot be negative';
                    }
                    if (age > 365) {
                      return 'Age cannot be more than 1 year';
                    }
                    return null;
                  },
                  labelText: 'Age of chicks when purchased (days)',
                  hintText: 'e.g., 1, 7, 14',
                ),
                const SizedBox(height: 20),

                // Hatch Source (Optional) - Only for purchased chicks
                ReusableInput(
                  topLabel: 'Hatchery/Source (Optional)',
                  controller: _hatchSourceController,
                  labelText: 'Where did you purchase the chicks?',
                  hintText: 'e.g., XYZ Hatchery, Local Market, Farm Name',
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Show calculated hatch date for both modes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isOwnHatch ? 'Selected Hatch Date' : 'Calculated Hatch Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hatchController.text.isNotEmpty?_hatchController.text:'Not provided',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      if (!_isOwnHatch) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Based on chicks being ${_chickAgeController.text} days old',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Chick Cost
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
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
                            'Chick Cost',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Switch(
                            value: _hasChickCost,
                            onChanged: (value) {
                              setState(() {
                                _hasChickCost = value;
                                if (!value) {
                                  _chickCostController.text = '0';
                                }
                              });
                            },
                            activeThumbColor: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_hasChickCost) ...[
                        Text(
                          _isOwnHatch
                              ? 'If there were any costs incurred for hatching (optional)'
                              : 'Cost of purchased chicks (optional)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ReusableInput(
                          controller: _chickCostController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          validator: (value) {
                            if (_hasChickCost &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter chick cost or set to 0';
                            }
                            if (value != null && value.isNotEmpty) {
                              final cost = double.tryParse(value);
                              if (cost == null) {
                                return 'Please enter a valid amount';
                              }
                              if (cost < 0) {
                                return 'Cost cannot be negative';
                              }
                            }
                            return null;
                          },
                          labelText: 'Cost per chick ($_currency)',
                          hintText: _isOwnHatch
                              ? 'e.g., 0 (no cost)'
                              : 'e.g., 50, 75, 100',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _chickCostController.text.isNotEmpty &&
                              _initialQuantityController.text.isNotEmpty
                              ? 'Total cost: $_currency ${_calculateTotalChickCost().toStringAsFixed(2)}'
                              : 'Total cost: $_currency 0.00',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Chick cost field is set to 0. Enable if there are costs.',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Initial Count with capacity validation
              ReusableInput(
                topLabel: 'Initial bird count',
                controller: _initialQuantityController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Update total cost when initial count changes
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter initial count';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final count = int.parse(value);
                  if (count <= 0) {
                    return 'Initial count must be greater than 0';
                  }
                  if (count > _availableCapacity) {
                    return 'Initial count ($count) exceeds available capacity ($_availableCapacity)';
                  }
                  return null;
                },
                labelText: 'Initial count from hatchery Or other sources',
                hintText: 'e.g., $_availableCapacity',
              ),
              const SizedBox(height: 20),

              // Birds Alive
              ReusableInput(
                controller: _birdsAliveController,
                keyboardType: TextInputType.number,
                topLabel: 'Current bird count',
                onChanged: (value) {
                  // Update validation state
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of birds alive';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final alive = int.parse(value);
                  final initial =
                      int.tryParse(_initialQuantityController.text) ?? 0;
                  if (alive > initial) {
                    return 'Birds alive cannot exceed initial count';
                  }
                  return null;
                },
                labelText: 'Current count at the moment',
                hintText: 'e.g., $_availableCapacity',
              ),
              const SizedBox(height: 20),

              // Feeding Time Selection
              ReusableDropdown<String>(
                topLabel: 'Feeding Time',
                value: _selectedFeedingTimeCategory,
                hintText: 'Select feeding time category',
                items: _feedingTimeOptions.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFeedingTimeCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select feeding time category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Specific Feeding Times Selection within Category
              if (_selectedFeedingTimeCategory != null) ...[
                Text(
                  'Select Specific Feeding Times:',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),

                // Display all options for the selected category
                Column(
                  children: _feedingTimeOptions[_selectedFeedingTimeCategory]!.map((
                      time,
                      ) {
                    bool isSelected =
                    _selectedFeedingTimes[_selectedFeedingTimeCategory]!
                        .contains(time);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedFeedingTimes[_selectedFeedingTimeCategory]!
                                  .remove(time);
                            } else {
                              _selectedFeedingTimes[_selectedFeedingTimeCategory]!
                                  .add(time);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.green.shade800
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Show selected times summary
                if (_selectedFeedingTimes[_selectedFeedingTimeCategory]!
                    .isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Feeding Times:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children:
                          _selectedFeedingTimes[_selectedFeedingTimeCategory]!
                              .map(
                                (time) => Chip(
                              label: Text(
                                time,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Current Weight
              ReusableDecimalInput(
                topLabel: 'Average weight (kg)  Per bird(Optional)',
                controller: _currentWeightController,
                labelText: 'Current average weight',
                hintText: 'e.g., 0.0',
                suffixText: 'Max 10',
              ),
              const SizedBox(height: 20),

              // Expected Weight
              ReusableDecimalInput(
                topLabel: 'Expected weight (kg)  Per bird(Optional)',
                controller: _expectedWeightController,
                validator: (value) {
                  // Allow empty/null value since it's not required
                  if (value == null || value.isEmpty) {
                    return null; // No error, field is optional
                  }

                  final expected = double.tryParse(value);
                  if (expected == null) {
                    return 'Please enter a valid number or leave empty';
                  }

                  final current = double.tryParse(_currentWeightController.text) ?? 0.0;
                  if (expected < current) {
                    return 'Expected weight should be greater than current weight';
                  }

                  return null;
                },
                labelText: 'Expected average weight at removal/sale',
                hintText: 'e.g., 2.5',
                suffixText: 'Max 10',
              ),
              const SizedBox(height: 20),



              // Notes
              ReusableInput(
                topLabel: 'Notes (Optional)',
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
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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

  Widget _buildCapacityInfo(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  double _calculateTotalChickCost() {
    try {
      final costPerChick = double.tryParse(_chickCostController.text) ?? 0;
      final initialCount = int.tryParse(_initialQuantityController.text) ?? 0;
      return costPerChick * initialCount;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Handle hatch date validation based on source
    if (_isOwnHatch) {
      if (_hatchController.text.isEmpty) {
        ToastUtil.showError('Please select hatch date');
        return;
      }
    } else {
      // For purchased chicks, validate chick age
      if (_chickAgeController.text.isEmpty) {
        ToastUtil.showError('Please enter chick age');
        return;
      }
      final age = int.tryParse(_chickAgeController.text) ?? 0;
      if (age < 0) {
        ToastUtil.showError('Chick age cannot be negative');
        return;
      }
      if (age > 365) {
        ToastUtil.showError('Chick age cannot be more than 1 year');
        return;
      }

      // Calculate hatch date for purchased chicks
      _hatchController.text = DateTime.now().subtract(Duration(days: age)).toIso8601String();
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
      final selectedFeedingTimes =
      _selectedFeedingTimes[_selectedFeedingTimeCategory]!;

      final batchData = {
        'house_id': widget.house.id,
        'batch_name': _nameController.text.trim(),
        'bird_type_id': _selectedBirdTypeId,
        'batch_type': _selectedBatchType,
        'initial_count': int.parse(_initialQuantityController.text.trim()),
        'current_count': int.parse(_birdsAliveController.text.trim()),
        'hatch_date': DateTime.parse(_hatchController.text).toUtc().toIso8601String(), // Date only
        'birds_alive': int.parse(_birdsAliveController.text.trim()),
        'current_weight': _currentWeightController.text.isNotEmpty?double.parse(_currentWeightController.text.trim()):null,
        'expected_weight': _expectedWeightController.text.isNotEmpty?double.parse(_expectedWeightController.text.trim()):null,
        'purchase_cost': double.parse(_chickCostController.text.trim()),
        'age_at_purchase': int.parse(_chickAgeController.text.trim()),
        'hatchery_source': !_isOwnHatch && _hatchSourceController.text.isNotEmpty
            ? _hatchSourceController.text.trim()
            : null, // Optional hatch source
        'feeding_time': _selectedFeedingTimeCategory,
        'feeding_schedule': selectedFeedingTimes.join(
          ',',
        ), // Send comma-separated times
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      if( double.parse(_chickCostController.text.trim())==0){
        batchData.remove('purchase_cost');
      }

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
    _hatchController.dispose();
    _initialQuantityController.dispose();
    _birdsAliveController.dispose();
    _currentWeightController.dispose();
    _expectedWeightController.dispose();
    _notesController.dispose();
    _chickCostController.dispose();
    _chickAgeController.dispose();
    _hatchSourceController.dispose();
    super.dispose();
  }
}