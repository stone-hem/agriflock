import 'dart:convert';
import 'dart:io';

import 'package:agriflock/app_routes.dart';
import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/date_util.dart';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:agriflock/core/widgets/custom_date_text_field.dart';
import 'package:agriflock/core/widgets/location_picker_step.dart';
import 'package:agriflock/core/widgets/reusable_dropdown.dart';
import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/core/widgets/reusable_decimal_input.dart';
import 'package:agriflock/core/widgets/photo_upload.dart';
import 'package:agriflock/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class OnboardingSetupScreen extends StatefulWidget {
  const OnboardingSetupScreen({super.key});

  @override
  State<OnboardingSetupScreen> createState() => _OnboardingSetupScreenState();
}

class _OnboardingSetupScreenState extends State<OnboardingSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Step 1: Farm form ──────────────────────────────────
  final _farmFormKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _farmDescriptionController = TextEditingController();
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;
  File? _farmPhotoFile;

  // ── Step 2: House form ─────────────────────────────────
  final _houseFormKey = GlobalKey<FormState>();
  final _houseNameController = TextEditingController();
  final _houseCapacityController = TextEditingController();
  final _houseDescriptionController = TextEditingController();

  // ── Step 3: Batch form ─────────────────────────────────
  final _batchFormKey = GlobalKey<FormState>();
  final _hatchController = TextEditingController();
  final _initialQuantityController = TextEditingController();
  final _birdsAliveController = TextEditingController();

  String? _selectedBirdTypeId;
  String? _selectedBatchType;
  String? _selectedFeedingTimeCategory;
  File? _batchPhotoFile;
  bool _isOwnHatch = false;
  bool _hasChickCost = true;
  String _currency = '';
  final _currentWeightController = TextEditingController();
  final _expectedWeightController = TextEditingController();
  final _notesController = TextEditingController();
  final _chickCostController = TextEditingController();
  final _chickAgeController = TextEditingController();
  final _hatchSourceController = TextEditingController();
  String? _selectedHatcherySource;

  static const List<String> _hatcheriesList = [
    'Kenchic', 'Suguna', 'Isinya', 'Kenbrid', 'Uzima Chicken', 'Kukuchic', 'Others',
  ];

  final List<String> _batchTypes = [
    'Meat Production',
    'Egg Production',
    'Breeding',
    'Dual Purpose',
  ];

  final Map<String, List<String>> _feedingTimeOptions = {
    'Day': ['06:00AM', '09:00AM', '12:00 Noon', '3:00PM', '6:00PM'],
    'Night': ['9:00PM', '12:00 Midnight', '3:00AM', '06:00AM'],
    'Both': [
      '06:00AM', '09:00AM', '12:00 Noon', '3:00PM', '6:00PM',
      '9:00PM', '12:00 Midnight', '3:00AM',
    ],
  };

  final Map<String, List<String>> _selectedFeedingTimes = {
    'Day': [],
    'Night': [],
    'Both': [],
  };

  // ── Data ───────────────────────────────────────────────
  final _batchHouseRepo = BatchHouseRepository();
  List<BirdType> _birdTypes = [];
  bool _isLoadingBirdTypes = false;

  // ── State ──────────────────────────────────────────────
  bool _isCreatingFarm = false;
  bool _isCreatingHouse = false;
  bool _isCreatingBatch = false;
  String? _createdFarmId;
  String? _createdFarmName;
  String? _createdHouseId;
  String? _createdHouseName;
  String? _createdBatchName;

  @override
  void initState() {
    super.initState();
    _houseNameController.text = 'House 1';
    _hatchController.text = DateUtil.toReadableDate(DateTime.now());
    _chickCostController.text = '0';
    _loadBirdTypes();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final currency = await secureStorage.getCurrency();
    if (mounted) setState(() => _currency = currency);
  }

  void _switchHatchSource(bool isOwnHatch) {
    setState(() {
      final wasOwnHatch = _isOwnHatch;
      _isOwnHatch = isOwnHatch;
      if (wasOwnHatch != isOwnHatch) {
        if (isOwnHatch) {
          _hatchSourceController.clear();
          _hatchController.text = DateUtil.toReadableDate(DateTime.now());
        } else {
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
          _hatchController.text = DateUtil.toReadableDate(
            DateTime.now().subtract(Duration(days: age)),
          );
        });
      }
    }
  }

  double _calculateTotalChickCost() {
    try {
      final costPerChick = double.tryParse(_chickCostController.text) ?? 0;
      final initialCount = int.tryParse(_initialQuantityController.text) ?? 0;
      return costPerChick * initialCount;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _loadBirdTypes() async {
    setState(() => _isLoadingBirdTypes = true);
    final result = await _batchHouseRepo.getBirdTypes();
    switch (result) {
      case Success(data: final types):
        setState(() {
          _birdTypes = types;
          _isLoadingBirdTypes = false;
        });
      case Failure(message: final msg):
        setState(() => _isLoadingBirdTypes = false);
        LogUtil.error('Failed to load bird types: $msg');
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ── Step 1: Farm creation ──────────────────────────────
  Future<void> _createFarm() async {
    if (!_farmFormKey.currentState!.validate()) return;

    setState(() => _isCreatingFarm = true);

    try {
      final farmData = <String, dynamic>{
        'farm_name': _farmNameController.text.trim(),
        'total_area': 0.0,
        'farm_type': 'poultry',
      };

      if (_farmDescriptionController.text.trim().isNotEmpty) {
        farmData['description'] = _farmDescriptionController.text.trim();
      }

      if (_selectedAddress != null && _latitude != null && _longitude != null) {
        farmData['location'] = {
          'address': {'formatted_address': _selectedAddress},
          'latitude': _latitude,
          'longitude': _longitude,
        };
      }

      http.Response response;

      if (_farmPhotoFile != null) {
        final fields = <String, String>{};
        farmData.forEach((key, value) {
          if (value != null) {
            fields[key] = value is Map || value is List
                ? jsonEncode(value)
                : value.toString();
          }
        });

        final multipartFile = await http.MultipartFile.fromPath(
          'farm_avatar',
          _farmPhotoFile!.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/farms',
          fields: fields,
          files: [multipartFile],
        );
        response = await http.Response.fromStream(streamedResponse);
      } else {
        farmData.removeWhere((key, value) => value == null);
        response = await apiClient.post('/farms', body: farmData);
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Farm create response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final farmId = jsonResponse['id']
            ?? jsonResponse['data']?['id']
            ?? jsonResponse['farm']?['id'];

        if (farmId == null) {
          ToastUtil.showError('Farm created but could not retrieve ID');
          setState(() => _isCreatingFarm = false);
          return;
        }

        setState(() {
          _createdFarmId = farmId.toString();
          _createdFarmName = _farmNameController.text.trim();
          _isCreatingFarm = false;
        });

        ToastUtil.showSuccess('Farm "$_createdFarmName" created!');
        _goToPage(1);
      } else {
        ApiErrorHandler.handle(response);
        setState(() => _isCreatingFarm = false);
      }
    } catch (e) {
      LogUtil.error('Error creating farm: $e');
      if (e is http.Response) {
        ApiErrorHandler.handle(e);
      } else {
        ToastUtil.showError('Failed to create farm: $e');
      }
      setState(() => _isCreatingFarm = false);
    }
  }

  // ── Step 2: House creation ─────────────────────────────
  Future<void> _createHouse() async {
    if (!_houseFormKey.currentState!.validate()) return;

    if (_createdFarmId == null) {
      ToastUtil.showError('Farm not found. Please go back and create a farm.');
      return;
    }

    setState(() => _isCreatingHouse = true);

    try {
      final houseData = <String, dynamic>{
        'name': _houseNameController.text.trim(),
        'capacity': int.tryParse(_houseCapacityController.text.trim()) ?? 500,
      };

      if (_houseDescriptionController.text.trim().isNotEmpty) {
        houseData['description'] = _houseDescriptionController.text.trim();
      }

      final response = await apiClient.post(
        '/farms/$_createdFarmId/houses',
        body: houseData,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('House create response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final houseId = jsonResponse['id']
            ?? jsonResponse['data']?['id']
            ?? jsonResponse['house']?['id'];

        if (houseId == null) {
          ToastUtil.showError('House created but could not retrieve ID');
          setState(() => _isCreatingHouse = false);
          return;
        }

        setState(() {
          _createdHouseId = houseId.toString();
          _createdHouseName = _houseNameController.text.trim();
          _isCreatingHouse = false;
        });

        ToastUtil.showSuccess('House "$_createdHouseName" created!');
        _goToPage(2);
      } else {
        ApiErrorHandler.handle(response);
        setState(() => _isCreatingHouse = false);
      }
    } catch (e) {
      LogUtil.error('Error creating house: $e');
      if (e is http.Response) {
        ApiErrorHandler.handle(e);
      } else {
        ToastUtil.showError('Failed to create house: $e');
      }
      setState(() => _isCreatingHouse = false);
    }
  }

  // ── Step 3: Batch creation ─────────────────────────────
  Future<void> _createBatch() async {
    if (!_batchFormKey.currentState!.validate()) return;

    // Hatch date / chick age validation
    if (_isOwnHatch) {
      if (_hatchController.text.isEmpty) {
        ToastUtil.showError('Please select a hatch date');
        return;
      }
    } else {
      if (_chickAgeController.text.isEmpty) {
        ToastUtil.showError('Please enter chick age');
        return;
      }
      final age = int.tryParse(_chickAgeController.text) ?? -1;
      if (age < 0) {
        ToastUtil.showError('Chick age cannot be negative');
        return;
      }
      if (age > 365) {
        ToastUtil.showError('Chick age cannot be more than 1 year');
        return;
      }
      _hatchController.text = DateTime.now()
          .subtract(Duration(days: age))
          .toIso8601String();
    }

    if (_selectedFeedingTimeCategory == null ||
        _selectedFeedingTimes[_selectedFeedingTimeCategory]!.isEmpty) {
      ToastUtil.showError('Please select at least one feeding time');
      return;
    }

    if (_createdHouseId == null) {
      ToastUtil.showError('House not found. Please go back and create a house.');
      return;
    }

    setState(() => _isCreatingBatch = true);

    try {
      final selectedFeedingTimes =
          _selectedFeedingTimes[_selectedFeedingTimeCategory]!;

      final batchData = <String, dynamic>{
        'house_id': _createdHouseId,
        'bird_type_id': _selectedBirdTypeId,
        'batch_type': _selectedBatchType,
        'initial_count': int.parse(_initialQuantityController.text.trim()),
        'current_count': int.parse(_birdsAliveController.text.trim()),
        'hatch_date':
            DateTime.parse(_hatchController.text).toUtc().toIso8601String(),
        'birds_alive': int.parse(_birdsAliveController.text.trim()),
        'feeding_time': _selectedFeedingTimeCategory,
        'feeding_schedule': selectedFeedingTimes.join(','),
        'purchase_cost': double.parse(_chickCostController.text.trim()),
        'age_at_purchase': int.parse(_chickAgeController.text.trim()),
        if (!_isOwnHatch && _selectedHatcherySource != null)
          'hatchery_source': _selectedHatcherySource == 'Others'
              ? (_hatchSourceController.text.trim().isNotEmpty ? _hatchSourceController.text.trim() : null)
              : _selectedHatcherySource,
        if (_currentWeightController.text.isNotEmpty)
          'current_weight':
              double.parse(_currentWeightController.text.trim()),
        if (_expectedWeightController.text.isNotEmpty)
          'expected_weight':
              double.parse(_expectedWeightController.text.trim()),
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      if (double.parse(_chickCostController.text.trim()) == 0) {
        batchData.remove('purchase_cost');
      }

      batchData.removeWhere((key, value) => value == null);

      http.Response response;

      if (_batchPhotoFile != null) {
        final fields = <String, String>{};
        batchData.forEach((key, value) {
          if (value != null) {
            fields[key] = value is Map || value is List
                ? jsonEncode(value)
                : value.toString();
          }
        });

        final multipartFile = await http.MultipartFile.fromPath(
          'batch_avatar',
          _batchPhotoFile!.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/batches',
          fields: fields,
          files: [multipartFile],
        );
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await apiClient.post('/batches', body: batchData);
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Batch create response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _createdBatchName = 'New Batch';
          _isCreatingBatch = false;
        });

        ToastUtil.showSuccess('Batch created successfully!');
        _goToPage(3);
      } else {
        ApiErrorHandler.handle(response);
        setState(() => _isCreatingBatch = false);
      }
    } catch (e) {
      LogUtil.error('Error creating batch: $e');
      if (e is http.Response) {
        ApiErrorHandler.handle(e);
      } else {
        ToastUtil.showError('Failed to create batch: $e');
      }
      setState(() => _isCreatingBatch = false);
    }
  }

  bool get _isSubmitting => _isCreatingFarm || _isCreatingHouse || _isCreatingBatch;

  String get _appBarTitle {
    switch (_currentPage) {
      case 0:
        return 'Create Your Farm';
      case 1:
        return 'Add a House';
      case 2:
        return 'Add Your First Batch';
      case 3:
        return 'All Set!';
      default:
        return 'Setup';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: _currentPage == 3
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  _appBarTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (_currentPage > 0) {
                            _goToPage(_currentPage - 1);
                          } else {
                            context.go('/day1/welcome-msg-page');
                          }
                        },
                ),
                actions: [
                  if (_isSubmitting)
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
        body: Column(
          children: [
            // Progress bar + step chips (hide on success page)
            if (_currentPage < 3) ...[
              LinearProgressIndicator(
                value: (_currentPage + 1) / 3,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    _buildStepChip(0, 'Farm'),
                    _buildArrow(),
                    _buildStepChip(1, 'House'),
                    _buildArrow(),
                    _buildStepChip(2, 'Batch'),
                  ],
                ),
              ),
            ],

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildFarmStep(),
                  _buildHouseStep(),
                  _buildBatchStep(),
                  _buildSuccessStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
    );
  }

  Widget _buildStepChip(int step, String label) {
    final isActive = _currentPage >= step;
    final isCurrent = _currentPage == step;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.green
            : isActive
                ? Colors.green.shade50
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive && !isCurrent)
            const Icon(Icons.check_circle, size: 14, color: Colors.green)
          else
            Text(
              '${step + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.white : Colors.grey.shade600,
              ),
            ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCurrent
                  ? Colors.white
                  : isActive
                      ? Colors.green
                      : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 1: FARM
  // ══════════════════════════════════════════════════════════
  Widget _buildFarmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _farmFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              icon: Icons.agriculture_rounded,
              color: Colors.green,
              title: 'What is a Farm?',
              description:
                  'A farm is your main operation — the physical location where you '
                  'raise your poultry. You can have multiple farms, each with its '
                  'own houses and batches.',
            ),
            const SizedBox(height: 24),

            PhotoUpload(
              file: _farmPhotoFile,
              onFileSelected: (File? file) => setState(() => _farmPhotoFile = file),
              title: 'Farm Photo (Optional)',
              description: 'Upload a photo of your farm',
              primaryColor: Colors.green,
                isRequired:false
            ),
            const SizedBox(height: 24),

            ReusableInput(
              topLabel: 'Farm Name',
              controller: _farmNameController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter farm name';
                return null;
              },
              labelText: 'Name',
              hintText: 'e.g., Main Poultry Farm',
            ),
            const SizedBox(height: 20),

            LocationPickerStep(
              selectedAddress: _selectedAddress,
              latitude: _latitude,
              longitude: _longitude,
              title: 'Select Location',
              text: 'Search and Select your farm location',
              onLocationSelected: (String address, double lat, double lng) {
                setState(() {
                  _selectedAddress = address;
                  _latitude = lat;
                  _longitude = lng;
                });
              },
              primaryColor: Colors.green,
            ),
            const SizedBox(height: 20),

            ReusableInput(
              topLabel: 'Description (Optional)',
              controller: _farmDescriptionController,
              maxLines: 3,
              labelText: 'Description',
              hintText: 'Enter a brief description of your farm',
            ),
            const SizedBox(height: 32),

            _buildActionButton(
              label: 'Create Farm & Continue',
              isLoading: _isCreatingFarm,
              onPressed: _createFarm,
            ),
            const SizedBox(height: 8),
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 2: HOUSE
  // ══════════════════════════════════════════════════════════
  Widget _buildHouseStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _houseFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              icon: Icons.house_rounded,
              color: Colors.orange,
              title: 'What is a House?',
              description:
                  'A house (or poultry house / shed) is a structure within your farm '
                  'where birds are kept. Each house has a capacity limit and can hold '
                  'one or more batches of birds.',
            ),
            const SizedBox(height: 16),

            // Show which farm this house belongs to
            if (_createdFarmName != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Adding house to: $_createdFarmName',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            ReusableInput(
              topLabel: 'House Name',
              controller: _houseNameController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter house name';
                return null;
              },
              labelText: 'Name',
              hintText: 'e.g., House 1, Main Shed',
            ),
            const SizedBox(height: 20),

            ReusableInput(
              topLabel: 'Capacity (number of birds)',
              controller: _houseCapacityController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter capacity';
                if (int.tryParse(value) == null) return 'Enter a valid number';
                final cap = int.parse(value);
                if (cap <= 0) return 'Capacity must be greater than 0';
                return null;
              },
              labelText: 'Maximum bird capacity',
              hintText: 'e.g., 500, 1000, 5000',
            ),
            const SizedBox(height: 20),

            ReusableInput(
              topLabel: 'Description (Optional)',
              controller: _houseDescriptionController,
              maxLines: 2,
              labelText: 'Description',
              hintText: 'e.g., Broiler house with automated feeders',
            ),
            const SizedBox(height: 32),

            _buildActionButton(
              label: 'Create House & Continue',
              isLoading: _isCreatingHouse,
              onPressed: _createHouse,
            ),
            const SizedBox(height: 8),
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 3: BATCH
  // ══════════════════════════════════════════════════════════
  Widget _buildBatchStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _batchFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              icon: Icons.egg_rounded,
              color: Colors.blue,
              title: 'What is a Batch?',
              description:
                  'A batch is a group of birds placed in a house at the same time. '
                  'You\'ll track feeding, vaccinations, medication, expenses, and '
                  'growth for each batch separately.',
            ),
            const SizedBox(height: 16),

            // Context: farm + house
            if (_createdFarmName != null && _createdHouseName != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_createdFarmName  >  $_createdHouseName',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Batch Photo
            PhotoUpload(
              file: _batchPhotoFile,
              onFileSelected: (File? file) => setState(() => _batchPhotoFile = file),
              title: 'Batch Photo (Optional)',
              description: 'Upload a photo of your batch',
              primaryColor: Colors.green,
            ),
            const SizedBox(height: 32),

            // Bird Type
            _isLoadingBirdTypes
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Loading bird types...', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ReusableDropdown<String>(
                    topLabel: 'Bird Type',
                    value: _selectedBirdTypeId,
                    hintText: 'Select bird type',
                    items: _birdTypes
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedBirdTypeId = v),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please select a bird type' : null,
                  ),
            const SizedBox(height: 20),

            // Batch Type
            ReusableDropdown<String>(
              topLabel: 'Batch Type',
              value: _selectedBatchType,
              hintText: 'Select batch type',
              items: _batchTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBatchType = v),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please select a batch type' : null,
            ),
            const SizedBox(height: 20),

            // ── Hatch Source ──────────────────────────────────────────
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

            // Hatch Date (own hatch only)
            if (_isOwnHatch) ...[
              CustomDateTextField(
                label: 'Date of Hatching',
                icon: Icons.calendar_today,
                required: true,
                minYear: DateTime.now().year - 1,
                maxYear: DateTime.now().year,
                returnFormat: DateReturnFormat.isoString,
                controller: _hatchController,
              ),
              const SizedBox(height: 20),
            ],

            // Purchased chicks fields
            if (!_isOwnHatch) ...[
              ReusableInput(
                topLabel: 'Chick Age (Days)',
                controller: _chickAgeController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateAndUpdateHatchDate(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter chick age in days';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  final age = int.parse(value);
                  if (age < 0) return 'Age cannot be negative';
                  if (age > 365) return 'Age cannot be more than 1 year';
                  return null;
                },
                labelText: 'Age of chicks when purchased (days)',
                hintText: 'e.g., 1, 7, 14',
              ),
              const SizedBox(height: 20),
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
              // Calculated hatch date display
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
                          'Calculated Hatch Date',
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
                      _hatchController.text.isNotEmpty
                          ? _hatchController.text
                          : 'Not provided',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on chicks being ${_chickAgeController.text} days old',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Chick Cost ────────────────────────────────────────────
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
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                        ),
                        Switch(
                          value: _hasChickCost,
                          onChanged: (value) {
                            setState(() {
                              _hasChickCost = value;
                              if (!value) _chickCostController.text = '0';
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
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ReusableInput(
                        controller: _chickCostController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        validator: (value) {
                          if (_hasChickCost && (value == null || value.isEmpty)) {
                            return 'Please enter chick cost or set to 0';
                          }
                          if (value != null && value.isNotEmpty) {
                            final cost = double.tryParse(value);
                            if (cost == null) return 'Please enter a valid amount';
                            if (cost < 0) return 'Cost cannot be negative';
                          }
                          return null;
                        },
                        labelText: 'Cost per chick${_currency.isNotEmpty ? ' ($_currency)' : ''}',
                        hintText: _isOwnHatch ? 'e.g., 0 (no cost)' : 'e.g., 50, 75, 100',
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
                      Text(
                        _chickCostController.text.isNotEmpty
                            ? 'Remember to add other expenses after batch placement to get the accurate financial report'
                            : '',
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
                            Icon(Icons.info, color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Chick cost field is set to 0. Enable if there are costs.',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
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

            // ── Initial bird count ─────────────────────────────────────
            ReusableInput(
              topLabel: 'Initial bird count',
              controller: _initialQuantityController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter initial count';
                if (int.tryParse(value) == null) return 'Please enter a valid number';
                if (int.parse(value) <= 0) return 'Initial count must be greater than 0';
                return null;
              },
              labelText: 'Initial count from hatchery Or other sources',
              hintText: 'e.g., 100, 500, 1000',
            ),
            const SizedBox(height: 20),

            // ── Current bird count ─────────────────────────────────────
            ReusableInput(
              topLabel: 'Current bird count',
              controller: _birdsAliveController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter number of birds alive';
                if (int.tryParse(value) == null) return 'Please enter a valid number';
                final alive = int.parse(value);
                final initial = int.tryParse(_initialQuantityController.text) ?? 0;
                if (alive > initial) return 'Current bird count cannot exceed initial birds';
                return null;
              },
              labelText: 'Current count during placement',
              hintText: 'e.g., 100',
            ),
            const SizedBox(height: 20),

            // ── Feeding Time ───────────────────────────────────────────
            ReusableDropdown<String>(
              topLabel: 'Feeding Time',
              value: _selectedFeedingTimeCategory,
              hintText: 'Select feeding time category',
              items: _feedingTimeOptions.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedFeedingTimeCategory = v),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please select feeding time category' : null,
            ),
            const SizedBox(height: 16),

            if (_selectedFeedingTimeCategory != null) ...[
              Text(
                'Select Specific Feeding Times:',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 8),
              Column(
                children: _feedingTimeOptions[_selectedFeedingTimeCategory]!.map((time) {
                  final isSelected = _selectedFeedingTimes[_selectedFeedingTimeCategory]!
                      .contains(time);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedFeedingTimes[_selectedFeedingTimeCategory]!.remove(time);
                          } else {
                            _selectedFeedingTimes[_selectedFeedingTimeCategory]!.add(time);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
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
              if (_selectedFeedingTimes[_selectedFeedingTimeCategory]!.isNotEmpty) ...[
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
                      const Text(
                        'Selected Feeding Times:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _selectedFeedingTimes[_selectedFeedingTimeCategory]!
                            .map((t) => Chip(
                                  label: Text(t, style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.green,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],

            // ── Average weight (optional) ──────────────────────────────
            ReusableDecimalInput(
              topLabel: 'Average weight (kg)  Per bird(Optional)',
              controller: _currentWeightController,
              labelText: 'Current average weight',
              hintText: 'e.g., 0.0',
              suffixText: 'Max 10',
            ),
            const SizedBox(height: 20),

            // ── Expected weight (optional) ─────────────────────────────
            ReusableDecimalInput(
              topLabel: 'Expected weight (kg)  Per bird(Optional)',
              controller: _expectedWeightController,
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final expected = double.tryParse(value);
                if (expected == null) return 'Please enter a valid number or leave empty';
                final current =
                    double.tryParse(_currentWeightController.text) ?? 0.0;
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

            // ── Notes (optional) ───────────────────────────────────────
            ReusableInput(
              topLabel: 'Notes (Optional)',
              controller: _notesController,
              maxLines: 3,
              labelText: 'Notes',
              hintText: 'Enter any additional notes about this batch',
            ),
            const SizedBox(height: 32),

            _buildActionButton(
              label: 'Create Batch & Finish',
              isLoading: _isCreatingBatch,
              onPressed: _createBatch,
            ),
            const SizedBox(height: 8),
            _buildSkipButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  SUCCESS PAGE
  // ══════════════════════════════════════════════════════════
  Widget _buildSuccessStep() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Big checkmark
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: const Icon(Icons.check_rounded, size: 50, color: Colors.green),
            ),
            const SizedBox(height: 24),

            const Text(
              'You\'re All Set!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your farm is ready to go. Here\'s what was created:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Summary cards
            _buildSummaryRow(
              Icons.agriculture_rounded,
              Colors.green,
              'Farm',
              _createdFarmName ?? 'Your Farm',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              Icons.house_rounded,
              Colors.orange,
              'House',
              _createdHouseName ?? 'House 1',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              Icons.egg_rounded,
              Colors.blue,
              'Batch',
              _createdBatchName ?? 'Your Batch',
            ),
            const SizedBox(height: 32),

            // What you can do now
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you can now track on your batch:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.restaurant_rounded, 'Feeding schedules & consumption'),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.vaccines_rounded, 'Vaccination records & reminders'),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.medication_rounded, 'Medication & treatment logs'),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.receipt_long_rounded, 'Expenses & input purchases'),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.trending_up_rounded, 'Growth & performance reports'),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.inventory_2_rounded, 'Inventory & store management'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Did you by other expenses'),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/record-expenditure'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Add more expenses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Or '),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Go to the dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: _isSubmitting ? null : () => context.go('/home'),
        child: Text(
          'Skip setup for now',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.check_circle, color: color, size: 22),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade700),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _farmNameController.dispose();
    _farmDescriptionController.dispose();
    _houseNameController.dispose();
    _houseCapacityController.dispose();
    _houseDescriptionController.dispose();
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
