import 'dart:async';
import 'dart:io';
import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/date_util.dart';
import 'package:agriflock/core/utils/format_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:agriflock/core/widgets/custom_date_text_field.dart';
import 'package:agriflock/core/widgets/photo_upload.dart';
import 'package:agriflock/core/widgets/reusable_decimal_input.dart';
import 'package:agriflock/core/widgets/reusable_dropdown.dart';
import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/features/farmer/batch/batch_created_screen.dart';
import 'package:agriflock/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock/core/models/bird_type.dart';
import 'package:agriflock/core/repositories/bird_type_repository.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock/core/utils/refresh_bus.dart';
import 'package:agriflock/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock/main.dart';
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
  final _hatchController = TextEditingController();
  final _initialQuantityController = TextEditingController();
  final _birdsAliveController = TextEditingController();
  final _currentWeightController = TextEditingController();
  double? _recommendedWeight;
  bool _isLoadingRec = false;
  Timer? _debounce;
  final _notesController = TextEditingController();
  final _chickCostController = TextEditingController();
  final _chickAgeController = TextEditingController();
  final _hatchSourceController = TextEditingController();
  String? _selectedHatcherySource;

  static const List<String> _hatcheriesList = [
    'Kenchic', 'Suguna', 'Isinya', 'Kenbrid', 'Uzima Chicken', 'Kukuchic', 'Others',
  ];

  final _repository = BatchHouseRepository();
  final _birdTypeRepository = BirdTypeRepository();

  String? _selectedBirdTypeId;
  bool _showLayersSubType = false;
  String? _selectedLayersSubTypeId;
  static const String _layersCategoryId = '__layers_category__';
  String? _selectedFeedingTimeCategory;
  File? _batchPhotoFile;
  bool _isLoading = false;
  bool _isLoadingBirdTypes = false;
  bool _hasChickCost = true;
  bool _isOwnHatch = false;
  bool _ageInWeeks = false;

  List<BirdType> _birdTypes = [];

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
    _chickAgeController.addListener(_scheduleRecommendedWeightFetch);
    _hatchController.addListener(_scheduleRecommendedWeightFetch);
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

      final result = await _birdTypeRepository.getBirdTypes();

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
          _chickAgeController.clear();
          _hatchSourceController.clear();
          _hatchController.text = DateUtil.toReadableDate(DateTime.now());
        } else {
          // Switching to purchased chicks
          _hatchController.clear();
          _hatchController.text = DateUtil.toReadableDate(DateTime.now());
        }
      }
    });
  }

  void _scheduleRecommendedWeightFetch() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 600),
      _fetchRecommendedWeight,
    );
  }

  Future<void> _fetchRecommendedWeight() async {
    final breedId = _selectedBirdTypeId;
    if (breedId == null || breedId.isEmpty) {
      setState(() => _recommendedWeight = null);
      return;
    }

    int? ageDays;
    if (_isOwnHatch) {
      try {
        final hatch = DateTime.parse(_hatchController.text);
        ageDays = DateTime.now().difference(hatch).inDays;
      } catch (_) {}
    } else {
      final raw = int.tryParse(_chickAgeController.text.trim());
      if (raw != null) {
        ageDays = _ageInWeeks ? raw * 7 : raw;
      }
    }

    if (ageDays == null || ageDays < 0) {
      setState(() => _recommendedWeight = null);
      return;
    }

    setState(() => _isLoadingRec = true);
    try {
      final response = await apiClient
          .get('/breeds/$breedId/recommended-weight?age=$ageDays');
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final val = double.tryParse(response.body.trim());
        setState(() {
          _recommendedWeight = val;
          _isLoadingRec = false;
        });
      } else {
        setState(() {
          _recommendedWeight = null;
          _isLoadingRec = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
        _recommendedWeight = null;
        _isLoadingRec = false;
      });
      }
    }
  }

  Widget _buildRecommendedWeightBanner() {
    if (_isLoadingRec) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.blue.shade600),
            ),
            const SizedBox(width: 10),
            Text('Fetching recommended weight…',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
          ],
        ),
      );
    }
    if (_recommendedWeight != null) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Recommended weight at this age: ${_recommendedWeight!.toStringAsFixed(3)} kg/bird',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
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
                            'Available Space',
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
              ),
              const SizedBox(height: 32),
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
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableDropdown<String>(
                    topLabel: 'Bird Type',
                    value: _showLayersSubType
                        ? _layersCategoryId
                        : _selectedBirdTypeId,
                    hintText: 'Select bird type',
                    items: [
                      // Non-layers types shown directly
                      ..._birdTypes
                          .where((t) => !t.isLayersCategory)
                          .map((BirdType type) => DropdownMenuItem<String>(
                                value: type.id,
                                child: Text(type.name),
                              )),
                      // Single "Layers" entry for all layers/growers
                      const DropdownMenuItem<String>(
                        value: _layersCategoryId,
                        child: Text('Layers'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue == _layersCategoryId) {
                          _showLayersSubType = true;
                          _selectedBirdTypeId = null;
                          _selectedLayersSubTypeId = null;
                        } else {
                          _showLayersSubType = false;
                          _selectedBirdTypeId = newValue;
                          _selectedLayersSubTypeId = null;
                        }
                      });
                      _scheduleRecommendedWeightFetch();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a bird type';
                      }
                      return null;
                    },
                  ),
                  // Layers sub-type selection
                  if (_showLayersSubType) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14, color: Colors.amber.shade700),
                              const SizedBox(width: 6),
                              Text(
                                'Select the type of layers',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._birdTypes
                              .where((t) => t.isLayersCategory)
                              .map((t) => RadioListTile<String>(
                                    value: t.id,
                                    groupValue: _selectedLayersSubTypeId,
                                    title: Text(t.name,
                                        style: const TextStyle(fontSize: 13)),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedLayersSubTypeId = val;
                                        _selectedBirdTypeId = val;
                                      });
                                      _scheduleRecommendedWeightFetch();
                                    },
                                    activeColor: Colors.amber.shade700,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  )),
                          if (_selectedLayersSubTypeId == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Please select a layers type',
                                style: TextStyle(
                                    color: Colors.red.shade600, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchHatchSource(false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: !_isOwnHatch
                                ? Colors.blue.shade600
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: !_isOwnHatch
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 18,
                                color: !_isOwnHatch
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Purchased',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: !_isOwnHatch
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: !_isOwnHatch
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchHatchSource(true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: _isOwnHatch
                                ? Colors.green.shade600
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: _isOwnHatch
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.egg_outlined,
                                size: 18,
                                color: _isOwnHatch
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Own Hatch',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _isOwnHatch
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: _isOwnHatch
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hatch Date - Only shown for own hatch
              if (_isOwnHatch) ...[
                CustomDateTextField(
                  label: 'Date of Hatching',
                  icon: Icons.calendar_today,
                  required: true,
                  minYear: DateTime.now().year - 1,
                  returnFormat: DateReturnFormat.isoString,
                  maxYear: DateTime.now().year,
                  controller: _hatchController,
                ),
                const SizedBox(height: 20),
              ],

              // Chick Age - Only shown for purchased chicks
              if (!_isOwnHatch) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chick Age',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _ageInWeeks = false;
                              _chickAgeController.clear();
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: !_ageInWeeks ? Colors.blue.shade600 : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Days',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: !_ageInWeeks ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _ageInWeeks = true;
                              _chickAgeController.clear();
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: _ageInWeeks ? Colors.blue.shade600 : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Weeks',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _ageInWeeks ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ReusableInput(
                  controller: _chickAgeController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter chick age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    final age = int.parse(value);
                    if (age < 0) {
                      return 'Age cannot be negative';
                    }
                    if (_ageInWeeks && age > 52) {
                      return 'Age cannot be more than 52 weeks';
                    }
                    if (!_ageInWeeks && age > 365) {
                      return 'Age cannot be more than 1 year (365 days)';
                    }
                    return null;
                  },
                  labelText: 'Right age will help track vaccinations and send you alerts.',
                  hintText: _ageInWeeks ? 'e.g., 1, 2, 4' : 'e.g., 1, 7, 14',
                ),
                const SizedBox(height: 20),

                // Hatch Source (Optional) - Only for purchased chicks
                ReusableDropdown<String>(
                  value: _selectedHatcherySource,
                  topLabel: 'Hatchery/Source',
                  hintText: 'Select hatchery or source',
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedHatcherySource = newValue;
                      if (newValue != 'Others') _hatchSourceController.clear();
                    });
                  },
                  items: _hatcheriesList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                ),
                if (_selectedHatcherySource == 'Others') ...[
                  const SizedBox(height: 12),
                  ReusableInput(
                    controller: _hatchSourceController,
                    hintText: 'Please specify hatchery or source',
                  ),
                ],
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
                      Text(
                        'Chick Cost',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isOwnHatch
                            ? 'Cost incurred for hatching (enter 0 if none)'
                            : 'Purchase cost per chick',
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
                          if (value == null || value.isEmpty) {
                            return 'Please enter chick cost (use 0 if none)';
                          }
                          final cost = double.tryParse(value);
                          if (cost == null) {
                            return 'Please enter a valid amount';
                          }
                          if (cost < 0) {
                            return 'Cost cannot be negative';
                          }
                          return null;
                        },
                        labelText: 'Cost per chick ($_currency)',
                        hintText: _isOwnHatch ? 'e.g., 0 (no cost)' : 'e.g., 50, 75, 100',
                        onChanged: (v) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total cost: $_currency ${FormatUtil.formatAmount(_calculateTotalChickCost())}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
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
                    return 'Current bird count cannot exceed initial birds';
                  }
                  return null;
                },
                labelText: 'Current count during placement',
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
                topLabel: 'Actual Avg weight (kg)  Per bird(Optional)',
                controller: _currentWeightController,
                labelText: 'Current average weight',
                hintText: 'e.g., 0.0',
                suffixText: 'Max 10',
              ),
              const SizedBox(height: 12),
              _buildRecommendedWeightBanner(),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _createBatch,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Saving...' : 'Save Batch'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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

    if (_showLayersSubType && _selectedLayersSubTypeId == null) {
      ToastUtil.showError('Please select the type of layers');
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
      if (_ageInWeeks && age > 52) {
        ToastUtil.showError('Age cannot be more than 52 weeks');
        return;
      }
      if (!_ageInWeeks && age > 365) {
        ToastUtil.showError('Chick age cannot be more than 1 year');
        return;
      }

      // Calculate hatch date for purchased chicks (weeks converted to days)
      final ageInDays = _ageInWeeks ? age * 7 : age;
      _hatchController.text = DateTime.now().subtract(Duration(days: ageInDays)).toIso8601String();
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
        'bird_type_id': _selectedBirdTypeId,
        // 'batch_type': '',
        'initial_count': int.parse(_initialQuantityController.text.trim()),
        'current_count': int.parse(_birdsAliveController.text.trim()),
        //dont send this when is purchase
        if(_isOwnHatch)'hatch_date': DateTime.parse(_hatchController.text).toUtc().toIso8601String(), // Date only
        'current_weight': _currentWeightController.text.isNotEmpty?double.parse(_currentWeightController.text.trim()):null,
        'cost_per_bird':double.tryParse(_chickCostController.text.trim()) ?? 0,
        if (!_isOwnHatch)
          'age_at_purchase': _ageInWeeks
              ? (int.tryParse(_chickAgeController.text.trim()) ?? 1) * 7
              : (int.tryParse(_chickAgeController.text.trim()) ?? 1),
        'hatchery_source': !_isOwnHatch && _selectedHatcherySource != null
            ? (_selectedHatcherySource == 'Others'
                ? (_hatchSourceController.text.trim().isNotEmpty ? _hatchSourceController.text.trim() : null)
                : _selectedHatcherySource)
            : null,
        'feeding_time': _selectedFeedingTimeCategory,
        'feeding_schedule': selectedFeedingTimes.join(
          ',',
        ), // Send comma-separated times
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      if ((double.tryParse(_chickCostController.text.trim()) ?? 0) == 0) {
        batchData.remove('purchase_cost');
      }

      final result = await _repository.createBatch(
        widget.farm.id,
        batchData,
        photoFile: _batchPhotoFile,
      );

      switch (result) {
        case Success<BatchModel>(data: final batch):
          RefreshBus.instance.fire(RefreshEvent.batchCreated);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BatchCreatedScreen(batch: batch, farm: widget.farm),
              ),
            );
          }

        case Failure<BatchModel>(:final response, :final message):
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
    _hatchController.dispose();
    _initialQuantityController.dispose();
    _birdsAliveController.dispose();
    _currentWeightController.dispose();
    _notesController.dispose();
    _chickCostController.dispose();
    _chickAgeController.dispose();
    _hatchSourceController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}