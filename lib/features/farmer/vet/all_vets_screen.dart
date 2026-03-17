import 'package:agriflock/core/widgets/location_picker_step.dart';
import 'package:agriflock/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock/core/utils/result.dart';

// Predefined specialization options
const _kSpecializations = [
  'Vaccination',
  'Training',
];

class AllVetsScreen extends StatefulWidget {
  const AllVetsScreen({super.key});

  @override
  State<AllVetsScreen> createState() => _AllVetsScreenState();
}

class _AllVetsScreenState extends State<AllVetsScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  List<VetFarmer> _allVets = [];

  String? _selectedOfficerType;
  String? _selectedRegion;
  String? _selectedStatus;
  int _currentPage = 1;
  final int _limit = 10;
  int _totalVets = 0;

  // ── Advanced filters ──────────────────────────────────────────────────────
  double? _filterLatitude;
  double? _filterLongitude;
  String? _filterAddress;
  List<String> _selectedSpecializations = [];
  double? _minRating;
  int? _minJobsDone;
  int? _minExperience;

  bool get _hasActiveFilters =>
      _filterLatitude != null ||
      _selectedSpecializations.isNotEmpty ||
      _minRating != null ||
      _minJobsDone != null ||
      _minExperience != null;

  @override
  void initState() {
    super.initState();
    _loadVets();
  }

  Future<void> _loadVets() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    try {
      final result = await _vetRepository.getVetFarmers(
        officerType: _selectedOfficerType,
        region: _selectedRegion,
        status: _selectedStatus,
        isVerified: true,
        page: _currentPage,
        limit: _limit,
        latitude: _filterLatitude,
        longitude: _filterLongitude,
        specializations:
            _selectedSpecializations.isNotEmpty ? _selectedSpecializations : null,
        minRating: _minRating,
        minJobsDone: _minJobsDone,
        minExperience: _minExperience,
      );
      switch (result) {
        case Success<VetFarmerListResponse>(data: final data):
          setState(() {
            _allVets = data.data;
            _totalVets = data.total;
            _isLoading = false;
          });
        case Failure(message: final error):
          setState(() {
            _hasError = true;
            _errorMessage = error;
            _isLoading = false;
          });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshVets() async {
    _currentPage = 1;
    try {
      final result = await _vetRepository.refreshVetFarmers(
        officerType: _selectedOfficerType,
        region: _selectedRegion,
        status: _selectedStatus,
        isVerified: true,
        page: _currentPage,
        limit: _limit,
        latitude: _filterLatitude,
        longitude: _filterLongitude,
        specializations:
            _selectedSpecializations.isNotEmpty ? _selectedSpecializations : null,
        minRating: _minRating,
        minJobsDone: _minJobsDone,
        minExperience: _minExperience,
      );
      switch (result) {
        case Success<VetFarmerListResponse>(data: final data):
          setState(() {
            _allVets = data.data;
            _totalVets = data.total;
            _hasError = false;
          });
        case Failure(message: final error):
          setState(() {
            _hasError = true;
            _errorMessage = error;
          });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _filterLatitude = null;
      _filterLongitude = null;
      _filterAddress = null;
      _selectedSpecializations = [];
      _minRating = null;
      _minJobsDone = null;
      _minExperience = null;
    });
    _loadVets();
  }

  void _showFilterSheet() {
    // Local mutable state for the sheet
    double? sheetLat = _filterLatitude;
    double? sheetLng = _filterLongitude;
    String? sheetAddress = _filterAddress;
    final sheetSpecs = Set<String>.from(_selectedSpecializations);
    double? sheetRating = _minRating;
    final minJobsCtrl =
        TextEditingController(text: _minJobsDone?.toString() ?? '');
    final minExpCtrl =
        TextEditingController(text: _minExperience?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => StatefulBuilder(
          builder: (context, setSheet) => Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Filter Veterinarians',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setSheet(() {
                          sheetLat = null;
                          sheetLng = null;
                          sheetAddress = null;
                          sheetSpecs.clear();
                          sheetRating = null;
                          minJobsCtrl.clear();
                          minExpCtrl.clear();
                        });
                      },
                      child: const Text('Clear all',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Location ──────────────────────────────────────────
                    LocationPickerStep(
                      selectedAddress: sheetAddress,
                      latitude: sheetLat,
                      longitude: sheetLng,
                      title: '',
                      text: 'Pick a location to search nearby vets',
                      hintText: 'Type your location',
                      showBanner: false,
                      onLocationSelected: (addr, lat, lng) {
                        setSheet(() {
                          sheetAddress = addr;
                          sheetLat = lat;
                          sheetLng = lng;
                        });
                      },
                    ),
                    if (sheetLat != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 14, color: Colors.green.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                sheetAddress ?? '',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => setSheet(() {
                                sheetLat = null;
                                sheetLng = null;
                                sheetAddress = null;
                              }),
                              child: const Text('Clear',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // ── Specialization ────────────────────────────────────
                    _sheetSection(
                      icon: Icons.medical_services,
                      title: 'Specialization',
                      child: Column(
                        children: _kSpecializations.map((spec) {
                          final selected = sheetSpecs.contains(spec);
                          return CheckboxListTile(
                            dense: true,
                            title: Text(spec,
                                style: const TextStyle(fontSize: 13)),
                            value: selected,
                            activeColor: Colors.green,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setSheet(() => v!
                                ? sheetSpecs.add(spec)
                                : sheetSpecs.remove(spec)),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Minimum Rating ────────────────────────────────────
                    _sheetSection(
                      icon: Icons.star,
                      title: 'Rating',
                      child: Column(
                        children: [
                          _ratingOption(
                              label: '4+ stars',
                              value: 4.0,
                              groupValue: sheetRating,
                              onChanged: (v) =>
                                  setSheet(() => sheetRating = v)),
                          _ratingOption(
                              label: '5 stars',
                              value: 5.0,
                              groupValue: sheetRating,
                              onChanged: (v) =>
                                  setSheet(() => sheetRating = v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Jobs Done ─────────────────────────────────────────
                    _sheetSection(
                      icon: Icons.task_alt,
                      title: 'Minimum Jobs Done',
                      child: TextField(
                        controller: minJobsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g. 10',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Experience ────────────────────────────────────────
                    _sheetSection(
                      icon: Icons.work_history,
                      title: 'Minimum Experience (years)',
                      child: TextField(
                        controller: minExpCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g. 3',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              // Apply button
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filterLatitude = sheetLat;
                        _filterLongitude = sheetLng;
                        _filterAddress = sheetAddress;
                        _selectedSpecializations = sheetSpecs.toList();
                        _minRating = sheetRating;
                        _minJobsDone = int.tryParse(minJobsCtrl.text);
                        _minExperience = int.tryParse(minExpCtrl.text);
                      });
                      Navigator.of(ctx).pop();
                      _loadVets();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetSection(
      {required IconData icon,
      required String title,
      required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        child,
        Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }

  Widget _ratingOption({
    required String label,
    required double? value,
    required double? groupValue,
    required ValueChanged<double?> onChanged,
  }) {
    return RadioListTile<double?>(
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      groupValue: groupValue,
      activeColor: Colors.green,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }

  void _viewDetails(String id) => context.push('/vet-details', extra: id);
  void _bookVet(VetFarmer vet) => context.push('/vet-order-details', extra: vet);

  // ── Star row ──
  Widget _stars(double r) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          if (i < r.floor())
            return Icon(Icons.star, color: Colors.amber.shade700, size: 13);
          if (r - i >= 0.5 && i < r.ceil())
            return Icon(Icons.star_half, color: Colors.amber.shade700, size: 13);
          return Icon(Icons.star_border, color: Colors.amber.shade400, size: 13);
        }),
      );

  Widget _chip(String label, Color fg, Color bg, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _info(IconData icon, String label, String value, Color iconColor,
          {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text('$label: ',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          Expanded(
              child: Text(value,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  overflow: TextOverflow.ellipsis,
                  maxLines: maxLines)),
        ]),
      );

  Widget _infoCustom(
          {required IconData icon,
          required Color iconColor,
          required String label,
          required Widget child}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text('$label: ',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          Expanded(child: child),
        ]),
      );

  Widget _buildVetCard(VetFarmer vet) {
    final rating = double.tryParse(vet.averageRating) ?? 0.0;
    final address = vet.location.address?.formattedAddress ?? '';
    final coverage = vet.coverageAreas?.counties.take(3).join(', ') ?? '';
    final specs = vet.specializations?.areas ?? [];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo banner
          Stack(
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: vet.faceSelfieUrl != null
                    ? Image.network(vet.faceSelfieUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _photoFallback())
                    : _photoFallback(),
              ),
              Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65)
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: vet.isAvailable
                        ? Colors.green.withOpacity(0.9)
                        : Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(vet.isAvailable ? 'Available' : 'Busy',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(children: [
                  if (vet.isVerified)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.verified, color: Colors.white, size: 11),
                        SizedBox(width: 3),
                        Text('Verified',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ),
                ]),
              ),
              Positioned(
                bottom: 8,
                left: 12,
                right: 12,
                child: Text(
                  vet.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                            blurRadius: 6,
                            color: Colors.black54,
                            offset: Offset(1, 1))
                      ]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 6, runSpacing: 4, children: [
                  _chip(vet.officerType, Colors.green.shade700,
                      Colors.green.shade50, Icons.badge),
                  _chip(
                      vet.tier.isNotEmpty ? vet.tier : 'Standard',
                      Colors.purple.shade700,
                      Colors.purple.shade50,
                      Icons.workspace_premium),
                  if (specs.isNotEmpty)
                    ...specs.take(2).map((s) => _chip(
                        s, Colors.teal.shade700, Colors.teal.shade50, Icons.medical_services)),
                ]),
                const SizedBox(height: 10),
                _info(Icons.school, 'Qualification', vet.educationLevel,
                    Colors.blue.shade600),
                Row(children: [
                  Expanded(
                      child: _info(Icons.work_history, 'Experience',
                          '${vet.yearsOfExperience} yrs', Colors.orange.shade700)),
                  Expanded(
                      child: _info(Icons.task_alt, 'Jobs Done',
                          '${vet.totalJobsCompleted}', Colors.green.shade700)),
                ]),
                _infoCustom(
                  icon: Icons.star,
                  iconColor: Colors.amber.shade700,
                  label: 'Rating',
                  child: Row(children: [
                    _stars(rating),
                    const SizedBox(width: 5),
                    Text(
                        '${rating.toStringAsFixed(1)} · ${vet.totalAppraisals} reviews',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  ]),
                ),
                _info(
                    Icons.location_on,
                    'Location',
                    vet.region != null
                        ? '${vet.region}${address.isNotEmpty ? ', $address' : ''}'
                        : address,
                    Colors.red.shade400,
                    maxLines: 2),
                if (coverage.isNotEmpty)
                  _info(Icons.map, 'Coverage', coverage, Colors.cyan.shade700),
                if (vet.licenseNumber != null && vet.licenseNumber!.isNotEmpty)
                  _info(Icons.credit_card, 'License No.', vet.licenseNumber!,
                      Colors.blueGrey.shade600),
                if (vet.profileBio.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    vet.profileBio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewDetails(vet.id),
                      icon: Icon(Icons.info_outline,
                          size: 16, color: Colors.green.shade700),
                      label: Text('View Details',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: BorderSide(color: Colors.green.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _bookVet(vet),
                      icon: const Icon(Icons.calendar_today, size: 15),
                      label: const Text('Book Now',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoFallback() => Container(
        color: Colors.green.shade50,
        child: Center(
            child: Icon(Icons.person, size: 64, color: Colors.green.shade300)),
      );

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Veterinary Officers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: Text('Clear filters',
                  style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
            ),
          Stack(
            children: [
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          if (_totalVets > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text('$_totalVets total',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVets,
        child: Column(
          children: [
            // Filter tap area + active filter chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 18, color: Colors.grey.shade600),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _hasActiveFilters ? 'Filters applied' : 'Filter veterinarians...',
                              style: TextStyle(
                                color: _hasActiveFilters ? Colors.green.shade700 : Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (_hasActiveFilters)
                            Icon(Icons.circle, size: 8, color: Colors.green.shade600),
                        ],
                      ),
                    ),
                  ),
                  // Active filter chips
                  if (_hasActiveFilters) ...[
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_filterAddress != null)
                            _filterChip(
                                Icons.location_on,
                                _filterAddress!.length > 20
                                    ? '${_filterAddress!.substring(0, 20)}…'
                                    : _filterAddress!,
                                () => setState(() {
                                      _filterLatitude = null;
                                      _filterLongitude = null;
                                      _filterAddress = null;
                                    })),
                          ..._selectedSpecializations.map((s) => _filterChip(
                              Icons.medical_services,
                              s,
                              () => setState(
                                  () => _selectedSpecializations.remove(s)))),
                          if (_minRating != null)
                            _filterChip(
                                Icons.star,
                                '${_minRating!.toInt()}+ stars',
                                () =>
                                    setState(() => _minRating = null)),
                          if (_minJobsDone != null)
                            _filterChip(
                                Icons.task_alt,
                                '≥$_minJobsDone jobs',
                                () =>
                                    setState(() => _minJobsDone = null)),
                          if (_minExperience != null)
                            _filterChip(
                                Icons.work_history,
                                '≥$_minExperience yrs',
                                () =>
                                    setState(() => _minExperience = null)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Body
            Expanded(
              child: _isLoading && _allVets.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError && _allVets.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 64, color: Colors.red.shade400),
                                const SizedBox(height: 16),
                                const Text('Failed to load veterinarians',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(_errorMessage ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadVets,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _allVets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 72, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                      'No veterinarians found',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _hasActiveFilters
                                        ? 'Try adjusting or clearing your filters'
                                        : 'No veterinarians available at the moment',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_hasActiveFilters) ...[
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: _clearFilters,
                                      child: const Text('Clear all filters'),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : isTablet
                              ? GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.52,
                                  ),
                                  itemCount: _allVets.length,
                                  itemBuilder: (_, i) =>
                                      _buildVetCard(_allVets[i]),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: _allVets.length,
                                  itemBuilder: (_, i) =>
                                      _buildVetCard(_allVets[i]),
                                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(IconData icon, String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Chip(
        avatar: Icon(icon, size: 12, color: Colors.green.shade700),
        label: Text(label,
            style: TextStyle(fontSize: 11, color: Colors.green.shade800)),
        deleteIcon: const Icon(Icons.close, size: 12),
        deleteIconColor: Colors.green.shade700,
        onDeleted: () {
          onRemove();
          _loadVets();
        },
        backgroundColor: Colors.green.shade50,
        side: BorderSide(color: Colors.green.shade200),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
