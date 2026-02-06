import 'dart:convert';
import 'dart:io';

import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/location_picker_step.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/main.dart';
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

  // ── Farm form ──────────────────────────────────────────
  final _farmFormKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _farmDescriptionController = TextEditingController();
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;
  File? _farmPhotoFile;

  // ── Batch form ─────────────────────────────────────────
  final _batchFormKey = GlobalKey<FormState>();
  final _batchNameController = TextEditingController();
  final _hatchController = TextEditingController();
  final _initialQuantityController = TextEditingController();
  final _birdsAliveController = TextEditingController();

  String? _selectedBirdTypeId;
  String? _selectedBatchType;
  String? _selectedFeedingTimeCategory;
  File? _batchPhotoFile;

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
  bool _isCreatingBatch = false;
  String? _createdFarmId;

  @override
  void initState() {
    super.initState();
    _hatchController.text = DateUtil.toReadableDate(DateTime.now());
    _loadBirdTypes();
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

  // ── Farm creation ──────────────────────────────────────
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
        // Extract the farm ID from response
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
          _isCreatingFarm = false;
        });

        ToastUtil.showSuccess('Farm "${_farmNameController.text}" created!');

        // Move to batch step
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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

  // ── House + Batch creation ─────────────────────────────
  Future<void> _createHouseAndBatch() async {
    if (!_batchFormKey.currentState!.validate()) return;

    if (_selectedFeedingTimeCategory == null ||
        _selectedFeedingTimes[_selectedFeedingTimeCategory]!.isEmpty) {
      ToastUtil.showError('Please select at least one feeding time');
      return;
    }

    if (_createdFarmId == null) {
      ToastUtil.showError('Farm not found. Please go back and create a farm.');
      return;
    }

    setState(() => _isCreatingBatch = true);

    try {
      // Step A: Create a default house for this farm
      final initialCount = int.tryParse(_initialQuantityController.text.trim()) ?? 100;
      final houseCapacity = (initialCount * 1.5).ceil(); // 50% buffer

      final houseData = {
        'house_name': 'House 1',
        'capacity': houseCapacity,
        'description': 'Default house created during onboarding',
      };

      final houseResponse = await apiClient.post(
        '/farms/$_createdFarmId/houses',
        body: houseData,
      );

      final houseJson = jsonDecode(houseResponse.body);
      LogUtil.info('House create response: $houseJson');

      if (houseResponse.statusCode < 200 || houseResponse.statusCode >= 300) {
        ApiErrorHandler.handle(houseResponse);
        setState(() => _isCreatingBatch = false);
        return;
      }

      final houseId = houseJson['id']
          ?? houseJson['data']?['id']
          ?? houseJson['house']?['id'];

      if (houseId == null) {
        ToastUtil.showError('House created but could not retrieve ID');
        setState(() => _isCreatingBatch = false);
        return;
      }

      // Step B: Create the batch
      final selectedFeedingTimes =
          _selectedFeedingTimes[_selectedFeedingTimeCategory]!;

      final batchData = <String, dynamic>{
        'house_id': houseId.toString(),
        'batch_name': _batchNameController.text.trim(),
        'bird_type_id': _selectedBirdTypeId,
        'batch_type': _selectedBatchType,
        'initial_count': initialCount,
        'current_count': int.tryParse(_birdsAliveController.text.trim()) ?? initialCount,
        'hatch_date': DateTime.parse(_hatchController.text).toUtc().toIso8601String(),
        'birds_alive': int.tryParse(_birdsAliveController.text.trim()) ?? initialCount,
        'feeding_time': _selectedFeedingTimeCategory,
        'feeding_schedule': selectedFeedingTimes.join(','),
      };

      batchData.removeWhere((key, value) => value == null);

      http.Response batchResponse;

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
        batchResponse = await http.Response.fromStream(streamedResponse);
      } else {
        batchResponse = await apiClient.post('/batches', body: batchData);
      }

      final batchJson = jsonDecode(batchResponse.body);
      LogUtil.info('Batch create response: $batchJson');

      if (batchResponse.statusCode >= 200 && batchResponse.statusCode < 300) {
        ToastUtil.showSuccess('Batch created! You\'re all set.');

        if (mounted) {
          // Navigate to dashboard with farms tab selected
          context.go('/dashboard', extra: 'farmer_farms');
        }
      } else {
        ApiErrorHandler.handle(batchResponse);
      }
    } catch (e) {
      LogUtil.error('Error creating house/batch: $e');
      if (e is http.Response) {
        ApiErrorHandler.handle(e);
      } else {
        ToastUtil.showError('Failed to create batch: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBatch = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = _isCreatingFarm || _isCreatingBatch;

    return PopScope(
      canPop: !isSubmitting,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            _currentPage == 0 ? 'Create Your Farm' : 'Add Your First Batch',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: isSubmitting
                ? null
                : () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go('/day1/welcome-msg-page');
                    }
                  },
          ),
          actions: [
            if (isSubmitting)
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
            // Progress bar
            LinearProgressIndicator(
              value: (_currentPage + 1) / 2,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  _buildStepChip(0, 'Farm'),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  _buildStepChip(1, 'Batch'),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildFarmStep(),
                  _buildBatchStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepChip(int step, String label) {
    final isActive = _currentPage >= step;
    final isCurrent = _currentPage == step;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            const Icon(Icons.check_circle, size: 16, color: Colors.green)
          else
            Text(
              '${step + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.white : Colors.grey.shade600,
              ),
            ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCurrent ? Colors.white : isActive ? Colors.green : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Farm ───────────────────────────────────────
  Widget _buildFarmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _farmFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.agriculture_rounded, color: Colors.green.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 1: Create your farm',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Give your farm a name and optionally set its location.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PhotoUpload(
              file: _farmPhotoFile,
              onFileSelected: (File? file) {
                setState(() => _farmPhotoFile = file);
              },
              title: 'Farm Photo (Optional)',
              description: 'Upload a photo of your farm',
              primaryColor: Colors.green,
            ),
            const SizedBox(height: 24),

            ReusableInput(
              topLabel: 'Farm Name',
              controller: _farmNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter farm name';
                }
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingFarm ? null : _createFarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isCreatingFarm
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Farm & Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _isCreatingFarm ? null : () => context.go('/dashboard'),
                child: Text(
                  'Skip setup for now',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Batch ──────────────────────────────────────
  Widget _buildBatchStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _batchFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.egg_rounded, color: Colors.blue.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 2: Add your first batch',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'A default house will be created automatically. Fill in your batch details.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PhotoUpload(
              file: _batchPhotoFile,
              onFileSelected: (File? file) {
                setState(() => _batchPhotoFile = file);
              },
              title: 'Batch Photo (Optional)',
              description: 'Upload a photo of your batch',
              primaryColor: Colors.green,
            ),
            const SizedBox(height: 24),

            ReusableInput(
              topLabel: 'Batch Name',
              controller: _batchNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter batch name';
                }
                return null;
              },
              labelText: 'Name',
              hintText: 'e.g., Spring Broiler Batch 2026',
            ),
            const SizedBox(height: 20),

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
                      setState(() => _selectedBirdTypeId = newValue);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a bird type';
                      }
                      return null;
                    },
                  ),
            const SizedBox(height: 20),

            // Batch Type
            ReusableDropdown<String>(
              topLabel: 'Batch Type',
              value: _selectedBatchType,
              hintText: 'Select batch type',
              items: _batchTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() => _selectedBatchType = newValue);
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
            CustomDateTextField(
              label: 'Date of Hatching',
              icon: Icons.calendar_today,
              required: true,
              initialDate: DateTime.now(),
              minYear: DateTime.now().year - 1,
              maxYear: DateTime.now().year,
              returnFormat: DateReturnFormat.isoString,
              controller: _hatchController,
            ),
            const SizedBox(height: 20),

            // Initial Count
            ReusableInput(
              topLabel: 'Initial Bird Count',
              controller: _initialQuantityController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Auto-fill birds alive if empty
                if (_birdsAliveController.text.isEmpty) {
                  _birdsAliveController.text = value;
                }
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
                return null;
              },
              labelText: 'Initial count from hatchery or other sources',
              hintText: 'e.g., 100, 500, 1000',
            ),
            const SizedBox(height: 20),

            // Current Birds Alive
            ReusableInput(
              topLabel: 'Current Bird Count',
              controller: _birdsAliveController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter current count';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                final alive = int.parse(value);
                final initial = int.tryParse(_initialQuantityController.text) ?? 0;
                if (alive > initial) {
                  return 'Current count cannot exceed initial count';
                }
                return null;
              },
              labelText: 'Current count at the moment',
              hintText: 'e.g., 100',
            ),
            const SizedBox(height: 20),

            // Feeding Time Category
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
                setState(() => _selectedFeedingTimeCategory = newValue);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select feeding time category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Specific feeding times
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
                children: _feedingTimeOptions[_selectedFeedingTimeCategory]!
                    .map((time) {
                  final isSelected =
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
                            color: isSelected ? Colors.green : Colors.grey.shade300,
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
              if (_selectedFeedingTimes[_selectedFeedingTimeCategory]!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Feeding Times:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _selectedFeedingTimes[_selectedFeedingTimeCategory]!
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
              ],
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingBatch ? null : _createHouseAndBatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isCreatingBatch
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Batch & Go to Dashboard',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _isCreatingBatch
                    ? null
                    : () => context.go('/dashboard', extra: 'farmer_farms'),
                child: Text(
                  'Skip for now',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _farmNameController.dispose();
    _farmDescriptionController.dispose();
    _batchNameController.dispose();
    _hatchController.dispose();
    _initialQuantityController.dispose();
    _birdsAliveController.dispose();
    super.dispose();
  }
}
