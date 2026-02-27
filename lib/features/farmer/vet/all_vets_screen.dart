import 'package:agriflock360/core/widgets/search_input.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/result.dart';

class AllVetsScreen extends StatefulWidget {
  const AllVetsScreen({super.key});

  @override
  State<AllVetsScreen> createState() => _AllVetsScreenState();
}

class _AllVetsScreenState extends State<AllVetsScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  List<VetFarmer> _allVets = [];
  List<VetFarmer> _filteredVets = [];

  String? _selectedOfficerType;
  String? _selectedRegion;
  String? _selectedStatus;
  int _currentPage = 1;
  final int _limit = 10;
  int _totalVets = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterVets);
    _loadVets();
  }

  Future<void> _loadVets() async {
    setState(() { _isLoading = true; _hasError = false; _errorMessage = null; });
    try {
      final result = await _vetRepository.getVetFarmers(
        officerType: _selectedOfficerType,
        region: _selectedRegion,
        status: _selectedStatus,
        isVerified: true,
        page: _currentPage,
        limit: _limit,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      switch (result) {
        case Success<VetFarmerListResponse>(data: final data):
          setState(() {
            _allVets = data.data;
            _filteredVets = data.data;
            _totalVets = data.total;
            _isLoading = false;
          });
        case Failure(message: final error):
          setState(() { _hasError = true; _errorMessage = error; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _hasError = true; _errorMessage = e.toString(); _isLoading = false; });
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
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      switch (result) {
        case Success<VetFarmerListResponse>(data: final data):
          setState(() {
            _allVets = data.data;
            _filteredVets = data.data;
            _totalVets = data.total;
            _hasError = false;
          });
        case Failure(message: final error):
          setState(() { _hasError = true; _errorMessage = error; });
      }
    } catch (e) {
      setState(() { _hasError = true; _errorMessage = e.toString(); });
    }
  }

  void _filterVets() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredVets = q.isEmpty
          ? _allVets
          : _allVets.where((v) =>
      v.name.toLowerCase().contains(q) ||
          v.educationLevel.toLowerCase().contains(q) ||
          (v.region?.toLowerCase().contains(q) ?? false) ||
          (v.specializations?.areas.toString().toLowerCase().contains(q) ?? false)).toList();
    });
  }

  void _viewDetails(String id) => context.push('/vet-details', extra: id);
  void _bookVet(VetFarmer vet) => context.push('/vet-order-details', extra: vet);

  // ── Star row ──
  Widget _stars(double r) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) {
      if (i < r.floor()) return Icon(Icons.star, color: Colors.amber.shade700, size: 13);
      if (r - i >= 0.5 && i < r.ceil()) return Icon(Icons.star_half, color: Colors.amber.shade700, size: 13);
      return Icon(Icons.star_border, color: Colors.amber.shade400, size: 13);
    }),
  );

  // ── Pill chip ──
  Widget _chip(String label, Color fg, Color bg, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: fg),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
    ]),
  );

  // ── Info row ──
  Widget _info(IconData icon, String label, String value, Color iconColor, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis, maxLines: maxLines)),
        ]),
      );

  Widget _infoCustom({required IconData icon, required Color iconColor, required String label, required Widget child}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
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
          // ── Photo banner ──
          Stack(
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: vet.faceSelfieUrl != null
                    ? Image.network(vet.faceSelfieUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _photoFallback())
                    : _photoFallback(),
              ),
              Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                  ),
                ),
              ),
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: vet.isAvailable ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(vet.isAvailable ? 'Available' : 'Busy',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              Positioned(
                top: 10, right: 10,
                child: Row(children: [
                  if (vet.isVerified)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.verified, color: Colors.white, size: 11),
                        SizedBox(width: 3),
                        Text('Verified', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                ]),
              ),
              Positioned(
                bottom: 8, left: 12, right: 12,
                child: Text(vet.name,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(1, 1))]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // ── Details ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 6, runSpacing: 4, children: [
                  _chip(vet.officerType, Colors.green.shade700, Colors.green.shade50, Icons.badge),
                  _chip(vet.tier.isNotEmpty ? vet.tier : 'Standard', Colors.purple.shade700, Colors.purple.shade50, Icons.workspace_premium),
                ]),
                const SizedBox(height: 10),
                _info(Icons.school, 'Qualification', vet.educationLevel, Colors.blue.shade600),
                Row(children: [
                  Expanded(child: _info(Icons.cake, 'Age', '${vet.age} yrs', Colors.teal.shade600)),
                  Expanded(child: _info(
                    vet.gender.toLowerCase() == 'female' ? Icons.female : Icons.male,
                    'Gender', vet.gender, Colors.pink.shade400,
                  )),
                ]),
                Row(children: [
                  Expanded(child: _info(Icons.work_history, 'Experience', '${vet.yearsOfExperience} yrs', Colors.orange.shade700)),
                  Expanded(child: _info(Icons.task_alt, 'Jobs Done', '${vet.totalJobsCompleted}', Colors.green.shade700)),
                ]),
                _infoCustom(
                  icon: Icons.star, iconColor: Colors.amber.shade700, label: 'Rating',
                  child: Row(children: [
                    _stars(rating),
                    const SizedBox(width: 5),
                    Text('${rating.toStringAsFixed(1)} · ${vet.totalAppraisals} reviews',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  ]),
                ),
                _info(Icons.location_on, 'Location',
                    vet.region != null ? '${vet.region}${address.isNotEmpty ? ', $address' : ''}' : address,
                    Colors.red.shade400, maxLines: 2),
                if (coverage.isNotEmpty)
                  _info(Icons.map, 'Coverage Areas', coverage, Colors.cyan.shade700),

                if (vet.coverageAreas != null && vet.coverageAreas!.subCounties.isNotEmpty)
                  _info(Icons.location_city, 'Sub-counties',
                      vet.coverageAreas!.subCounties.take(3).join(', '), Colors.blueGrey.shade600),
                if (vet.profileBio.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(vet.profileBio,
                    maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Action buttons ──
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewDetails(vet.id),
                      icon: Icon(Icons.info_outline, size: 16, color: Colors.green.shade700),
                      label: Text('View Details', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: BorderSide(color: Colors.green.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _bookVet(vet),
                      icon: const Icon(Icons.calendar_today, size: 15),
                      label: const Text('Book Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    child: Center(child: Icon(Icons.person, size: 64, color: Colors.green.shade300)),
  );

  @override
  Widget build(BuildContext context) {
    // Responsive: 2-column on tablets
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('All Veterinary Officers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          if (_totalVets > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text('$_totalVets total',
                      style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVets,
        child: Column(
          children: [
            // Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SearchInput(
                controller: _searchController,
                hintText: 'Search by name, education, specialization...',
                prefixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
              ),
            ),

            // Body
            Expanded(
              child: _isLoading && _allVets.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _hasError && _allVets.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      const Text('Failed to load veterinarians',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_errorMessage ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadVets,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
                  : _filteredVets.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No veterinarians found',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Text(
                      _searchController.text.isEmpty
                          ? 'No veterinarians available at the moment'
                          : 'Try adjusting your search terms',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : isTablet
              // ── Tablet 2-column grid ──
                  ? GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.52,
                ),
                itemCount: _filteredVets.length,
                itemBuilder: (_, i) => _buildVetCard(_filteredVets[i]),
              )
              // ── Phone single column ──
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _filteredVets.length,
                itemBuilder: (_, i) => _buildVetCard(_filteredVets[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}