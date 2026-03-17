import 'package:agriflock/app_routes.dart';
import 'package:agriflock/core/utils/age_util.dart';
import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:agriflock/core/widgets/location_picker_step.dart';
import 'package:agriflock/core/widgets/reusable_dropdown.dart';
import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock/core/models/bird_type.dart';
import 'package:agriflock/core/repositories/bird_type_repository.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock/features/farmer/farm/repositories/farm_repository.dart';
import 'package:agriflock/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock/features/farmer/vet/models/vet_order_model.dart';
import 'package:agriflock/features/farmer/vet/models/vet_service_type.dart';
import 'package:agriflock/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:agriflock/features/farmer/vet/widgets/order_process.dart';
import 'package:agriflock/features/farmer/vet/widgets/vet_order_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock/core/utils/result.dart';

/// Subscription states
enum _SubscriptionState { loading, noSubscription, expired, hasSubscription }

class VetOrderScreen extends StatefulWidget {
  final VetFarmer vet;

  const VetOrderScreen({super.key, required this.vet});

  @override
  State<VetOrderScreen> createState() => _VetOrderScreenState();
}

class _VetOrderScreenState extends State<VetOrderScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();
  final SecureStorage _secureStorage = SecureStorage();
  final _formKey = GlobalKey<FormState>();

  // ── Subscription ──────────────────────────────────────────────────────────
  _SubscriptionState _subscriptionState = _SubscriptionState.loading;

  bool get _hasNoSubscription =>
      _subscriptionState == _SubscriptionState.noSubscription;



  // ── Farm-based selection (has/expired plan) ────────────────────────────────
  String? _selectedFarm;
  String? _selectedHouse;
  List<String> _selectedBatches = [];

  // ── Location data ──────────────────────────────────────────────────────────
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  // ── Services & priority ────────────────────────────────────────────────────
  List<String> _selectedServices = [];
  String? _selectedPriority;

  // ── Manual / no-plan fields ────────────────────────────────────────────────
  final _birdsCountController = TextEditingController();
  int? _manualBirdsCount;

  // ── Bird types (manual mode) ───────────────────────────────────────────────
  List<BirdType> _birdTypes = [];
  bool _isLoadingBirdTypes = false;
  final Set<String> _selectedBirdTypeIds = {};

  final _birdAgeController = TextEditingController();
  final _birdMortalityController = TextEditingController();
  String _birdAgeUnit = 'days'; // 'days' | 'weeks'

  // ── PER_PERSON services ────────────────────────────────────────────────────
  final _numberOfPeopleController = TextEditingController();
  int? _numberOfPeople;

  // ── Payment ────────────────────────────────────────────────────────────────
  String? _selectedPaymentMode;

  // Displayed label → API value
  static const Map<String, String> _paymentModes = {
    'M-Pesa': 'MOBILE_MONEY',
    'Cash': 'CASH',
    'Card': 'CREDIT_CARD',
    'Bank Transfer': 'BANK_TRANSFER',
  };

  // ── Estimate ───────────────────────────────────────────────────────────────
  bool _isLoadingEstimate = false;

  // ── Service types ──────────────────────────────────────────────────────────
  List<VetServiceType> _serviceTypes = [];
  bool _isLoadingServices = false;
  String? _servicesError;

  // ── Repositories ──────────────────────────────────────────────────────────
  final _farmRepository = FarmRepository();
  final _batchHouseRepository = BatchHouseRepository();
  final _birdTypeRepository = BirdTypeRepository();

  // ── Farm data ─────────────────────────────────────────────────────────────
  FarmsResponse? _farmsResponse;
  List<House> _houses = [];
  List<BatchModel> _availableBatches = [];

  bool _isLoadingFarms = false;
  bool _isLoadingHouses = false;
  bool _hasFarmsError = false;
  String? _farmsErrorMessage;

  final List<String> _priorities = ['NORMAL', 'URGENT', 'EMERGENCY'];

  // ── Stepped UI ─────────────────────────────────────────────────────────────
  final Set<int> _expandedSteps = {1, 2, 3, 4};
  bool _useCustomLocation = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
    _checkSubscriptionAndInit();
  }

  @override
  void dispose() {
    _birdsCountController.dispose();
    _numberOfPeopleController.dispose();
    _birdAgeController.dispose();
    _birdMortalityController.dispose();
    super.dispose();
  }

  // ── Subscription check ─────────────────────────────────────────────────────

  Future<void> _checkSubscriptionAndInit() async {
    final String state = await _secureStorage.getSubscriptionState();

    _SubscriptionState resolved;
    if (state == 'no_subscription_plan') {
      resolved = _SubscriptionState.noSubscription;
    } else if (state == 'expired_subscription_plan') {
      resolved = _SubscriptionState.expired;
    } else {
      resolved = _SubscriptionState.hasSubscription;
    }

    setState(() => _subscriptionState = resolved);

    // Only fetch farm data when the farmer actually has (or had) a plan.
    if (resolved == _SubscriptionState.hasSubscription ||
        resolved == _SubscriptionState.expired) {
      _loadFarms();
    }

    // Bird types are always needed — a subscribed farmer with no farms set up
    // will also fall through to the manual section.
    _loadBirdTypes();
  }

  // ── Data loaders ───────────────────────────────────────────────────────────

  Future<void> _loadFarms() async {
    setState(() {
      _isLoadingFarms = true;
      _hasFarmsError = false;
      _farmsErrorMessage = null;
    });

    try {
      final result = await _farmRepository.getAllFarmsWithStats();
      switch (result) {
        case Success<FarmsResponse>(data: final data):
          setState(() {
            _farmsResponse = data;
            _isLoadingFarms = false;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _farmsErrorMessage = error;
            _isLoadingFarms = false;
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _hasFarmsError = true;
        _farmsErrorMessage = 'Failed to load farms: $e';
        _isLoadingFarms = false;
      });
    }
  }

  Future<void> _loadServiceTypes() async {
    setState(() {
      _isLoadingServices = true;
      _servicesError = null;
    });

    try {
      final result = await _vetRepository.getVetServiceTypes();
      switch (result) {
        case Success<VetServiceTypesResponse>(data: final data):
          setState(() {
            _serviceTypes = data.serviceTypes;
            _isLoadingServices = false;
          });
          break;
        case Failure(message: final error):
          setState(() {
            _isLoadingServices = false;
            _servicesError = error;
          });
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() {
        _isLoadingServices = false;
        _servicesError = 'Failed to load service types: $e';
      });
    }
  }

  Future<void> _loadBirdTypes() async {
    setState(() => _isLoadingBirdTypes = true);
    final result = await _birdTypeRepository.getBirdTypes();
    if (!mounted) return;
    switch (result) {
      case Success<List<BirdType>>(data: final types):
        setState(() {
          _birdTypes = types;
          _isLoadingBirdTypes = false;
        });
        break;
      case Failure(message: final error):
        setState(() => _isLoadingBirdTypes = false);
        ApiErrorHandler.handle(error);
        break;
    }
  }

  Future<void> _loadHousesForSelectedFarm() async {
    if (_selectedFarm == null) return;

    setState(() {
      _isLoadingHouses = true;
      _houses = [];
      _availableBatches = [];
      _selectedHouse = null;
      _selectedBatches.clear();
    });

    try {
      final result = await _batchHouseRepository.getAllHouses(_selectedFarm!);
      switch (result) {
        case Success<List<House>>(data: final houses):
          setState(() {
            _houses = houses;
            _isLoadingHouses = false;
          });
          break;
        case Failure(message: final error):
          setState(() => _isLoadingHouses = false);
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() => _isLoadingHouses = false);
    }
  }

  // ── Selection helpers ──────────────────────────────────────────────────────

  void _onHouseSelected(String? houseId) {
    setState(() {
      _selectedHouse = houseId;
      _selectedBatches.clear();
      if (houseId != null) {
        final h = _houses.firstWhere(
              (h) => h.id == houseId,
          orElse: () => House(id: '', houseName: '', capacity: 0, batches: []),
        );
        _availableBatches = h.batches;
      } else {
        _availableBatches = [];
      }
    });
  }

  void _onBatchSelected(String batchId, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedBatches.contains(batchId)) _selectedBatches.add(batchId);
      } else {
        _selectedBatches.remove(batchId);
      }
    });
  }

  void _onServiceSelected(String serviceId, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedServices.contains(serviceId))
          _selectedServices.add(serviceId);
      } else {
        _selectedServices.remove(serviceId);
      }
    });
  }

  void _toggleBirdType(BirdType type, bool selected) {
    setState(() {
      if (selected) {
        _selectedBirdTypeIds.add(type.id);
      } else {
        _selectedBirdTypeIds.remove(type.id);
      }
    });
  }

  /// Whether the farmer has fully specified farm → house → batch.
  bool get _hasFarmDetails =>
      _selectedFarm != null &&
          _selectedHouse != null &&
          _selectedBatches.isNotEmpty;

  bool get _hasPerPersonService => _selectedServices.any((id) {
    final s = _serviceTypes.firstWhere((s) => s.id == id,
        orElse: () => _serviceTypes.first);
    return s.pricingType == 'PER_PERSON';
  });

  // ── Step completion ─────────────────────────────────────────────────────────

  bool get _step1Complete {
    if (_hasNoSubscription) return (_manualBirdsCount ?? 0) > 0;
    return _hasFarmDetails || (_manualBirdsCount ?? 0) > 0;
  }

  bool get _step2Complete => _selectedServices.isNotEmpty;

  bool get _step3Complete {
    if (_hasNoSubscription || _useCustomLocation || !_hasFarmLocation) {
      return _selectedAddress != null;
    }
    return true; // using farm GPS
  }

  bool get _step4Complete =>
      _selectedPaymentMode != null && _selectedPriority != null;

  bool get _hasFarmLocation {
    if (_selectedFarm == null || _farmsResponse == null) return false;
    try {
      final farm = _farmsResponse!.farms.firstWhere((f) => f.id == _selectedFarm!);
      return farm.gpsCoordinates != null;
    } catch (_) {
      return false;
    }
  }

  String? get _farmDisplayAddress {
    if (!_hasFarmLocation) return null;
    try {
      return _farmsResponse!.farms.firstWhere((f) => f.id == _selectedFarm!).location;
    } catch (_) {
      return null;
    }
  }

  // ── Build request payload ──────────────────────────────────────────────────

  VetEstimateRequest _buildRequest() {
    int birdsCount = 0;
    List<String>? batchIds;
    List<String>? houseIds;
    List<BirdTypeEntry>? birdTypeDetails;
    int? mortality;
    int? ageInDays;
    FarmLocation? location;

    if (_hasFarmDetails) {
      // Farm-based path
      for (final id in _selectedBatches) {
        final b = _availableBatches.firstWhere((b) => b.id == id,
            orElse: () => BatchModel(
              id: '',
              batchNumber: '',
              initialQuantity: 0,
              birdsAlive: 0,
              age: 0,
              type: '',
              birdTypeId: '',
              breed: '',
              startDate: DateTime.now(),
              currentWeight: 1,
              expectedWeight: 0,
              feedingTime: '',
              feedingSchedule: [],
            ));
        birdsCount += b.birdsAlive;
      }
      batchIds = _selectedBatches;
      houseIds = [_selectedHouse!];
    } else {
      // Manual / no-plan path
      birdsCount = _manualBirdsCount ?? 0;

      if (_selectedBirdTypeIds.isNotEmpty) {
        final age = int.tryParse(_birdAgeController.text) ?? 0;
        final ageInDaysValue =
        _birdAgeUnit == 'weeks' ? age * 7 : age;
        final mort =
            double.tryParse(_birdMortalityController.text) ?? 0;

        birdTypeDetails = _selectedBirdTypeIds.map((id) {
          final type = _birdTypes.firstWhere((t) => t.id == id);
          return BirdTypeEntry(
            birdTypeId: id,
            birdTypeName: type.name,
            count: birdsCount,
            ageValue: ageInDaysValue,
            ageUnit: 'days', // normalised
            mortalityRate: mort,
          );
        }).toList();

        // Top-level fields for basic request
        mortality = mort.round();
        ageInDays = ageInDaysValue;
      }
    }

    if (_selectedAddress != null && _latitude != null && _longitude != null) {
      location = FarmLocation(
        address: _selectedAddress!,
        latitude: _latitude!,
        longitude: _longitude!,
      );
    }

    return VetEstimateRequest(
      vetId: widget.vet.id,
      serviceIds: _selectedServices,
      birdsCount: birdsCount,
      priorityLevel: _selectedPriority!,
      preferredDate: DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String()
          .split('T')
          .first,
      preferredTime: '09:00',
      termsAgreed: false,
      paymentMode: _selectedPaymentMode,
      // Farm-based fields (null for manual path)
      houseIds: houseIds,
      batchIds: batchIds,
      // Manual fields (null for farm path)
      birdTypeIds: !_hasFarmDetails && _selectedBirdTypeIds.isNotEmpty
          ? _selectedBirdTypeIds.toList()
          : null,
      mortality: mortality,
      ageInDays: ageInDays,
      participantsCount: _hasPerPersonService ? _numberOfPeople : null,
      farmLocation: location,
    );
  }

  // ── Estimate submission ────────────────────────────────────────────────────

  Future<void> _getEstimate() async {
    // Validation — location required unless a farm with GPS is used
    final bool needsAddress =
        _hasNoSubscription || _useCustomLocation || !_hasFarmLocation;
    if (needsAddress && _selectedAddress == null) {
      _showSnack('Please select service location', Colors.orange);
      return;
    }
    if (_selectedPriority == null || _selectedServices.isEmpty) {
      _showSnack(
          'Please select priority level and at least one service', Colors.orange);
      return;
    }
    if (_selectedPaymentMode == null) {
      _showSnack('Please select a mode of payment', Colors.orange);
      return;
    }
    if (!_hasFarmDetails &&
        (_manualBirdsCount == null || _manualBirdsCount! <= 0)) {
      _showSnack(
          'Please select farm details or enter the number of birds',
          Colors.orange);
      return;
    }
    if (_hasPerPersonService &&
        (_numberOfPeople == null || _numberOfPeople! <= 0)) {
      _showSnack(
          'Please enter the number of people for the training/group session',
          Colors.orange);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoadingEstimate = true);

    final request = _buildRequest();
    final result = await _vetRepository.getVetOrderEstimate(request);

    setState(() => _isLoadingEstimate = false);

    switch (result) {
      case Success<VetEstimateResponse>(data: final estimate):
        _showOrderBottomSheet(estimate, request);
        break;
      case Failure(message: final error):
        if (mounted) _showSnack('Failed to get estimate: $error', Colors.red);
        break;
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showOrderBottomSheet(
      VetEstimateResponse estimate, VetEstimateRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VetOrderBottomSheet(
        estimate: estimate,
        vet: widget.vet,
        vetRepository: _vetRepository,
        onOrderSuccess: () {
          context.pop();
          context.pop();
          context.pop();
        },
        request: request,
      ),
    );
  }

  // ── Shared UI helpers ──────────────────────────────────────────────────────

  Widget _buildLoadingIndicator(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
              child: Text(error,
                  style: TextStyle(color: Colors.red.shade700))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Text(message),
    );
  }



  // ── Manual birds & bird type section ──────────────────────────────────────

  Widget _buildManualBirdsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Flock Information',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tell us about the birds you need the vet to attend to.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        // Birds count
        ReusableInput(
          controller: _birdsCountController,
          labelText: 'Total Number of Birds *',
          hintText: 'e.g. 200',
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              setState(() => _manualBirdsCount = int.tryParse(v ?? '')),
          validator: (value) {
            if (!_hasFarmDetails) {
              if (value == null || value.isEmpty) {
                return 'Please enter the number of birds';
              }
              if ((int.tryParse(value) ?? 0) <= 0) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Bird types
        _buildBirdTypeSection(),
      ],
    );
  }

  Widget _buildBirdTypeSection() {
    if (_isLoadingBirdTypes) {
      return _buildLoadingIndicator('Loading bird types...');
    }
    if (_birdTypes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type of Birds (Select all that apply)',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: _birdTypes.map((type) {
              final isSelected = _selectedBirdTypeIds.contains(type.id);
              return CheckboxListTile(
                title: Text(type.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                value: isSelected,
                onChanged: (v) => _toggleBirdType(type, v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                secondary: Icon(Icons.pets,
                    color: isSelected ? Colors.green : Colors.grey),
              );
            }).toList(),
          ),
        ),

        // Flock detail fields (shown once any bird type is selected)
        if (_selectedBirdTypeIds.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flock Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                ReusableInput(
                  controller: _birdMortalityController,
                  labelText: 'Mortality Count',
                  hintText: 'e.g. 2',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ReusableInput(
                        controller: _birdAgeController,
                        labelText: 'Age',
                        hintText:
                        _birdAgeUnit == 'days' ? 'e.g. 14' : 'e.g. 3',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        ToggleButtons(
                          isSelected: [
                            _birdAgeUnit == 'days',
                            _birdAgeUnit == 'weeks',
                          ],
                          onPressed: (i) => setState(() {
                            _birdAgeUnit = i == 0 ? 'days' : 'weeks';
                          }),
                          borderRadius: BorderRadius.circular(8),
                          selectedColor: Colors.white,
                          fillColor: Colors.green,
                          color: Colors.grey.shade600,
                          constraints: const BoxConstraints(
                              minHeight: 36, minWidth: 56),
                          children: const [
                            Text('Days', style: TextStyle(fontSize: 12)),
                            Text('Weeks', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Farm section (has/expired plan) ───────────────────────────────────────

  Widget _buildFarmSection() {
    // Whether farms have finished loading (regardless of result).
    final bool farmsLoaded = !_isLoadingFarms && !_hasFarmsError;
    final bool hasNoFarms =
        farmsLoaded && (_farmsResponse == null || _farmsResponse!.farms.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Details',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasNoFarms
              ? 'You have no farms set up yet. Provide your flock details below.'
              : 'Select your farm, house, and batches — or just enter the number of birds below.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        // While farms are loading show a spinner.
        if (_isLoadingFarms) _buildLoadingIndicator('Loading farms...'),

        // Farm load error.
        if (_hasFarmsError)
          _buildErrorWidget(_farmsErrorMessage ?? 'Failed to load farms', _loadFarms),

        // Farms loaded and at least one exists — show farm → house → batch picker.
        if (farmsLoaded && !hasNoFarms) ...[
          _buildFarmDropdown(),
          if (_selectedFarm != null) ...[
            _buildFarmDetails(),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => setState(() {
                _selectedFarm = null;
                _selectedHouse = null;
                _selectedBatches.clear();
                _houses = [];
                _availableBatches = [];
              }),
              child: const Text('Clear Farm Selection'),
            ),
            const SizedBox(height: 16),
            _buildHouseDropdown(),
            if (_selectedHouse != null) ...[
              _buildHouseDetails(),
              const SizedBox(height: 16),
              _buildBatchSelection(),
            ],
          ],

          // Manual fallback when the farmer has farms but hasn't selected one yet.
          if (_selectedFarm == null) ...[
            const SizedBox(height: 12),
            _buildInfoBanner(
              icon: Icons.info_outline,
              color: Colors.orange,
              message: 'No farm selected? Provide your flock details below.',
            ),
            const SizedBox(height: 12),
            _buildManualBirdsSection(),
          ],
        ],

        // No farms at all → drop straight to manual input (same as no-plan flow).
        if (hasNoFarms) ...[
          _buildInfoBanner(
            icon: Icons.info_outline,
            color: Colors.orange,
            message:
            'No farms found on your account. Please provide your flock details below.',
          ),
          const SizedBox(height: 12),
          _buildManualBirdsSection(),
        ],
      ],
    );
  }

  Widget _buildFarmDropdown() {
    if (_isLoadingFarms) return _buildLoadingIndicator('Loading farms...');
    if (_hasFarmsError) {
      return _buildErrorWidget(_farmsErrorMessage ?? 'Failed to load farms', _loadFarms);
    }
    if (_farmsResponse == null || _farmsResponse!.farms.isEmpty) {
      return const SizedBox.shrink();
    }

    return ReusableDropdown<String>(
      value: _selectedFarm,
      topLabel: 'Select a farm',
      hintText: 'Choose a farm',
      icon: Icons.agriculture,
      isExpanded: true,
      items: _farmsResponse!.farms.map((farm) {
        return DropdownMenuItem<String>(
          value: farm.id,
          child: Text(farm.farmName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (v) {
        setState(() {
          _selectedFarm = v;
          _selectedHouse = null;
          _selectedBatches.clear();
          _houses = [];
          _availableBatches = [];
        });
        if (v != null) {
          _loadHousesForSelectedFarm();
          // Update location from farm
          final farm = _farmsResponse!.farms.firstWhere((f) => f.id == v);
          if (farm.gpsCoordinates != null) {
            setState(() {
              _selectedAddress = farm.location;
              _latitude = farm.gpsCoordinates!.latitude;
              _longitude = farm.gpsCoordinates!.longitude;
            });
          }
        }
      },
    );
  }

  Widget _buildFarmDetails() {
    if (_selectedFarm == null || _farmsResponse == null) return const SizedBox();
    final farm = _farmsResponse!.farms
        .firstWhere((f) => f.id == _selectedFarm, orElse: () => _farmsResponse!.farms.first);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(farm.farmName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          if (farm.location != null && farm.location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(farm.location!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHouseDropdown() {
    if (_isLoadingHouses) return _buildLoadingIndicator('Loading houses...');
    if (_houses.isEmpty) return _buildEmptyState('No houses available in this farm');

    return ReusableDropdown<String>(
      topLabel: 'Select a house',
      value: _selectedHouse,
      hintText: 'Choose a poultry house',
      labelText: 'House',
      icon: Icons.home_work,
      isExpanded: true,
      items: _houses.map((h) => DropdownMenuItem<String>(
        value: h.id,
        child: Text(h.houseName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14)),
      )).toList(),
      onChanged: _onHouseSelected,
    );
  }

  Widget _buildHouseDetails() {
    if (_selectedHouse == null) return const SizedBox();
    final house = _houses.firstWhere((h) => h.id == _selectedHouse,
        orElse: () => _houses.first);
    final util = house.capacity > 0
        ? (house.currentBirds / house.capacity * 100)
        : 0.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(house.houseName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: [
              _houseDetailText('Capacity', '${house.currentBirds}/${house.capacity} birds'),
              const SizedBox(width: 16),
              _houseDetailText(
                'Utilization',
                '${util.toStringAsFixed(1)}%',
                valueColor: util > 80 ? Colors.red : Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 2),
          _houseDetailText(
              'Batches', '${house.batches.length} batch${house.batches.length == 1 ? '' : 'es'}'),
        ],
      ),
    );
  }

  Widget _houseDetailText(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const Text(': ', style: TextStyle(fontSize: 12)),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: valueColor)),
      ],
    );
  }

  Widget _buildBatchSelection() {
    if (_availableBatches.isEmpty) {
      return _buildEmptyState('No batches available in this house');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Batches',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: _availableBatches.map((batch) {
              final isSelected = _selectedBatches.contains(batch.id);
              return CheckboxListTile(
                title: Text(batch.breed,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Text(batch.batchNumber,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    Text('• ${batch.birdsAlive} birds',
                        style: const TextStyle(fontSize: 11)),
                    Text('• ${AgeUtil.formatAge(batch.age)}',
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
                value: isSelected,
                onChanged: (v) => _onBatchSelected(batch.id, v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                secondary:
                Icon(Icons.pets, color: isSelected ? Colors.green : Colors.grey),
              );
            }).toList(),
          ),
        ),
        if (_selectedBatches.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Batches:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedBatches.map((id) {
                    final b = _availableBatches.firstWhere((b) => b.id == id);
                    return Chip(
                      label: Text(b.batchNumber),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _onBatchSelected(id, false),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total birds: ${_selectedBatches.fold<int>(0, (sum, id) {
                    final b = _availableBatches.firstWhere((b) => b.id == id);
                    return sum + b.birdsAlive;
                  })}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Service selection ──────────────────────────────────────────────────────

  Widget _buildServiceSelection() {
    if (_isLoadingServices) return _buildLoadingIndicator('Loading service types...');
    if (_servicesError != null) {
      return _buildErrorWidget(_servicesError!, _loadServiceTypes);
    }

    final active = _serviceTypes.where((s) => s.active).toList();
    if (active.isEmpty) return _buildEmptyState('No active services available');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Services',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: active.map((service) {
              final isSelected = _selectedServices.contains(service.id);
              final priceText = switch (service.pricingType) {
                'PER_BIRD' =>
                '${service.currency} ${service.perBirdRate?.toStringAsFixed(2) ?? '0.00'}/bird',
                'PER_PERSON' =>
                '${service.currency} ${service.perPersonRate?.toStringAsFixed(2) ?? '0.00'}/person',
                _ =>
                '${service.currency} ${service.basePrice?.toStringAsFixed(2) ?? '0.00'}',
              };
              return CheckboxListTile(
                title: Text(service.serviceName,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.description.isNotEmpty)
                      Text(service.description,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text('Price: $priceText',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green)),
                  ],
                ),
                value: isSelected,
                onChanged: (v) => _onServiceSelected(service.id, v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                secondary: Icon(Icons.medical_services,
                    color: isSelected ? Colors.purple : Colors.grey),
              );
            }).toList(),
          ),
        ),

        // Number of people for PER_PERSON services
        if (_hasPerPersonService) ...[
          const SizedBox(height: 12),
          ReusableInput(
            controller: _numberOfPeopleController,
            labelText: 'Number of People *',
            hintText: 'Enter number of attendees',
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                setState(() => _numberOfPeople = int.tryParse(v ?? '')),
            validator: (value) {
              if (_hasPerPersonService && (value == null || value.isEmpty)) {
                return 'Please enter the number of people';
              }
              if (_hasPerPersonService &&
                  (int.tryParse(value ?? '') ?? 0) <= 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],

        if (_selectedServices.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Services:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedServices.map((id) {
                    final s = _serviceTypes.firstWhere((s) => s.id == id);
                    return Chip(
                      label: Text(s.serviceName),
                      backgroundColor: Colors.purple.shade100,
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _onServiceSelected(id, false),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Payment mode ───────────────────────────────────────────────────────────

  Widget _buildPaymentModeSection() {
    return ReusableDropdown<String>(
      topLabel: 'Mode of Payment',
      value: _selectedPaymentMode,
      hintText: 'Select payment method',
      icon: Icons.payment,
      isExpanded: true,
      items: _paymentModes.entries.map((entry) {
        IconData icon;
        switch (entry.key) {
          case 'M-Pesa':
            icon = Icons.phone_android;
            break;
          case 'Card':
            icon = Icons.credit_card;
            break;
          case 'Bank Transfer':
            icon = Icons.account_balance;
            break;
          default:
            icon = Icons.money;
        }
        return DropdownMenuItem<String>(
          value: entry.value, // API value e.g. 'MOBILE_MONEY'
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 10),
              Text(entry.key), // Display label e.g. 'M-Pesa'
            ],
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedPaymentMode = v),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a payment method';
        }
        return null;
      },
    );
  }

  // ── Small helpers ──────────────────────────────────────────────────────────

  // ── Location section (conditional) ────────────────────────────────────────

  Widget _buildLocationSection() {
    // No-plan users always show picker
    if (_hasNoSubscription) {
      return LocationPickerStep(
        selectedAddress: _selectedAddress,
        latitude: _latitude,
        longitude: _longitude,
        title: 'Service Location',
        text: 'Select where the vet should visit',
        onLocationSelected: (address, lat, lng) {
          setState(() {
            _selectedAddress = address;
            _latitude = lat;
            _longitude = lng;
          });
        },
      );
    }

    // Subscribed + farm has GPS and not using custom
    if (_hasFarmLocation && !_useCustomLocation) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: Colors.green.shade700, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Using farm location',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.green.shade800),
                  ),
                  if (_farmDisplayAddress != null &&
                      _farmDisplayAddress!.isNotEmpty)
                    Text(
                      _farmDisplayAddress!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.green.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _useCustomLocation = true),
              child: const Text('Change'),
            ),
          ],
        ),
      );
    }

    // Subscribed + no farm GPS or user wants custom location
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_useCustomLocation && _hasFarmLocation) ...[
          Row(
            children: [
              const Expanded(
                child: Text('Custom location',
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _useCustomLocation = false;
                    if (_selectedFarm != null && _farmsResponse != null) {
                      try {
                        final farm = _farmsResponse!.farms
                            .firstWhere((f) => f.id == _selectedFarm!);
                        _selectedAddress = farm.location;
                        _latitude = farm.gpsCoordinates?.latitude;
                        _longitude = farm.gpsCoordinates?.longitude;
                      } catch (_) {}
                    }
                  });
                },
                child: const Text('Use farm location'),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        LocationPickerStep(
          selectedAddress: _selectedAddress,
          latitude: _latitude,
          longitude: _longitude,
          title: 'Service Location',
          text: 'Select where the vet should visit',
          onLocationSelected: (address, lat, lng) {
            setState(() {
              _selectedAddress = address;
              _latitude = lat;
              _longitude = lng;
            });
          },
        ),
      ],
    );
  }

  // ── Stepped section wrapper ─────────────────────────────────────────────────

  Widget _buildStepSection({
    required int step,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    String? completedSummary,
    required Widget child,
  }) {
    final isExpanded = _expandedSteps.contains(step);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green.shade300 : Colors.grey.shade200,
          width: isCompleted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedSteps.remove(step);
              } else {
                _expandedSteps.add(step);
              }
            }),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : (isExpanded
                              ? Colors.blue.shade600
                              : Colors.grey.shade300),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text(
                              '$step',
                              style: TextStyle(
                                color: isExpanded
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        if (!isExpanded &&
                            isCompleted &&
                            completedSummary != null)
                          Text(completedSummary,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)
                        else
                          Text(subtitle,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required MaterialColor color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5, color: color.shade800),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Show a full-screen loader while we determine subscription state.
    if (_subscriptionState == _SubscriptionState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Veterinary Service'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Vet info card ──────────────────────────────────────────────
              _buildVetInfoCard(),
              const SizedBox(height: 12),

              // Subscription nudge
              if (_hasNoSubscription)
                GestureDetector(
                  onTap: () => context.push(AppRoutes.subscriptionPlans),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade50, Colors.green.shade50],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.workspace_premium, color: Colors.orange.shade700, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Subscribe to attach your batches directly to vet orders. Tap to view plans.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 13, color: Colors.orange.shade700),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 10,),

              // ── Step 1: Flock Details ──────────────────────────────────────
              _buildStepSection(
                step: 1,
                title: 'Step 1 — Flock Details',
                subtitle: _hasNoSubscription
                    ? 'Enter number of birds and type'
                    : 'Select your farm, house and batches',
                isCompleted: _step1Complete,
                completedSummary: _hasFarmDetails
                    ? '${_selectedBatches.length} batch(es) selected'
                    : (_manualBirdsCount != null
                        ? '$_manualBirdsCount birds'
                        : null),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasNoSubscription)
                      _buildManualBirdsSection()
                    else
                      _buildFarmSection(),
                  ],
                ),
              ),

              // ── Step 2: Services ───────────────────────────────────────────
              _buildStepSection(
                step: 2,
                title: 'Step 2 — Services',
                subtitle: 'Select the veterinary services you need',
                isCompleted: _step2Complete,
                completedSummary: _step2Complete
                    ? '${_selectedServices.length} service(s) selected'
                    : null,
                child: _buildServiceSelection(),
              ),

              // ── Step 3: Location ───────────────────────────────────────────
              _buildStepSection(
                step: 3,
                title: 'Step 3 — Service Location',
                subtitle: 'Where should the vet visit?',
                isCompleted: _step3Complete,
                completedSummary: _step3Complete
                    ? (!_useCustomLocation && _hasFarmLocation
                        ? 'Farm location: ${_farmDisplayAddress ?? ''}'
                        : _selectedAddress ?? '')
                    : null,
                child: _buildLocationSection(),
              ),

              // ── Step 4: Booking Details ────────────────────────────────────
              _buildStepSection(
                step: 4,
                title: 'Step 4 — Booking Details',
                subtitle: 'Choose payment method and priority level',
                isCompleted: _step4Complete,
                completedSummary: _step4Complete
                    ? '${_paymentModes.entries.firstWhere((e) => e.value == _selectedPaymentMode, orElse: () => const MapEntry('', '')).key} · $_selectedPriority'
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentModeSection(),
                    const SizedBox(height: 16),
                    ReusableDropdown<String>(
                      topLabel: 'Priority Level',
                      value: _selectedPriority,
                      hintText: 'Select priority level',
                      icon: Icons.priority_high,
                      isExpanded: true,
                      items: _priorities.map((p) {
                        final color = p == 'EMERGENCY'
                            ? Colors.red
                            : p == 'URGENT'
                                ? Colors.orange
                                : Colors.green;
                        final surcharge = p == 'EMERGENCY'
                            ? '50%'
                            : p == 'URGENT'
                                ? '25%'
                                : '0%';
                        return DropdownMenuItem<String>(
                          value: p,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(p)),
                              Text(
                                '$surcharge surcharge',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedPriority = v),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select priority level';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Get Estimate button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingEstimate ? null : _getEstimate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isLoadingEstimate
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Icon(Icons.arrow_forward,
                          size: 20, color: Colors.white),
                  label: Text(
                    _isLoadingEstimate ? 'Loading...' : 'Get Estimate',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const OrderProcess(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVetInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.pets, color: Colors.green, size: 24),
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
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.vet.educationLevel,
                    style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.grey.shade500, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.vet.location.address!.formattedAddress,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.vet.isVerified)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Verified',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

}