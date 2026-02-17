import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/result.dart';

class BrowseVetsScreen extends StatefulWidget {
  const BrowseVetsScreen({super.key});

  @override
  State<BrowseVetsScreen> createState() => _BrowseVetsScreenState();
}

class _BrowseVetsScreenState extends State<BrowseVetsScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();

  bool _isLoadingRecommended = false;
  bool _hasRecommendedError = false;
  String? _recommendedErrorMessage;
  List<VetFarmerRecommendation> _recommendedVets = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendedVets();
  }

  Future<void> _loadRecommendedVets() async {
    setState(() {
      _isLoadingRecommended = true;
      _hasRecommendedError = false;
      _recommendedErrorMessage = null;
    });
    try {
      final result = await _vetRepository.getRecommendedVetFarmers();
      switch (result) {
        case Success<List<VetFarmerRecommendation>>(data: final data):
          setState(() {
            _recommendedVets = data;
            _isLoadingRecommended = false;
          });
        case Failure(message: final error):
          setState(() {
            _hasRecommendedError = true;
            _recommendedErrorMessage = error;
            _isLoadingRecommended = false;
          });
      }
    } catch (e) {
      setState(() {
        _hasRecommendedError = true;
        _recommendedErrorMessage = e.toString();
        _isLoadingRecommended = false;
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      final result = await _vetRepository.refreshRecommendedVetFarmers();
      switch (result) {
        case Success<List<VetFarmerRecommendation>>(data: final data):
          setState(() { _recommendedVets = data; _hasRecommendedError = false; });
        case Failure(message: final error):
          setState(() { _hasRecommendedError = true; _recommendedErrorMessage = error; });
      }
    } catch (e) {
      setState(() { _hasRecommendedError = true; _recommendedErrorMessage = e.toString(); });
    }
  }

  void _navigateToAllVets() => context.push('/all-vets');
  void _bookVet(String id) => context.push('/vet-order-details', extra: id);

  // ── Responsive helpers ──
  double _cardWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return 430;
    if (w >= 600) return 370;
    return w * 0.84;
  }

  double _listHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return 660;
    if (w >= 600) return 620;
    return 580;
  }

  // ── Star widget ──
  Widget _stars(double r) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) {
      if (i < r.floor()) return Icon(Icons.star, color: Colors.amber.shade700, size: 14);
      if (r - i >= 0.5 && i < r.ceil()) return Icon(Icons.star_half, color: Colors.amber.shade700, size: 14);
      return Icon(Icons.star_border, color: Colors.amber.shade400, size: 14);
    }),
  );

  // ── Pill chip ──
  Widget _chip(String label, Color fg, Color bg, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: fg),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
      ],
    ),
  );

  // ── Info row ──
  Widget _info(IconData icon, String label, String value, Color iconColor, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            Expanded(
              child: Text(value,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                overflow: TextOverflow.ellipsis,
                maxLines: maxLines,
              ),
            ),
          ],
        ),
      );

  Widget _infoCustom({required IconData icon, required Color iconColor, required String label, required Widget child}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            Expanded(child: child),
          ],
        ),
      );

  // ── Recommended vet card ──
  Widget _buildCard(BuildContext context, VetFarmerRecommendation vet) {
    final rating = double.tryParse(vet.averageRating) ?? 0.0;
    final address = vet.location.address?.formattedAddress ?? 'Location N/A';
    final coverage = vet.coverageAreas?.counties.take(3).join(', ') ?? '';
    final specs = vet.specializations?.areas ?? [];

    return Container(
      width: _cardWidth(context),
      margin: const EdgeInsets.only(right: 14),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.orange.shade200, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo banner ──
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: vet.faceSelfieUrl != null
                      ? Image.network(vet.faceSelfieUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _photoFallback())
                      : _photoFallback(),
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
                // Availability badge
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
                // Verified + Recommended badges
                Positioned(
                  top: 10, right: 10,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    if (vet.isVerified)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.verified, color: Colors.white, size: 11),
                          SizedBox(width: 3),
                          Text('Verified', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.shade600, borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.star, color: Colors.white, size: 11),
                        SizedBox(width: 3),
                        Text('Recommended', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ]),
                ),
                // Name
                Positioned(
                  bottom: 8, left: 12, right: 90,
                  child: Text(vet.name,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(1, 1))]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // ── Details ──
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
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
                    _info(Icons.group, 'Total Ratings', '${vet.totalRatingsCount}', Colors.blue.shade500),
                    _info(Icons.location_on, 'Location', address, Colors.red.shade400, maxLines: 2),
                    if (coverage.isNotEmpty)
                      _info(Icons.map, 'Coverage Areas', coverage, Colors.cyan.shade700),
                    if (specs.isNotEmpty)
                      _infoCustom(
                        icon: Icons.medical_services, iconColor: Colors.indigo.shade500, label: 'Specializations',
                        child: Wrap(
                          spacing: 4, runSpacing: 4,
                          children: specs.take(3).map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.indigo.shade200),
                            ),
                            child: Text(s, style: TextStyle(fontSize: 10, color: Colors.indigo.shade700, fontWeight: FontWeight.w500)),
                          )).toList(),
                        ),
                      ),
                    if (vet.licenseNumber != null && vet.licenseNumber!.isNotEmpty)
                      _info(Icons.credit_card, 'License No.', vet.licenseNumber!, Colors.blueGrey.shade600),
                    if (vet.profileBio.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(vet.profileBio,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Book Now ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _bookVet(vet.id),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoFallback() => Container(
    color: Colors.green.shade50,
    child: Center(child: Icon(Icons.person, size: 70, color: Colors.green.shade300)),
  );

  Widget _buildQuickActions() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.flash_on, size: 17, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/my-vet-orders'),
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text('My Orders'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/my-completed-orders'),
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Completed'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ]),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(children: [
          Image.asset('assets/logos/Logo_0725.png', fit: BoxFit.cover, width: 40, height: 40,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.green,
                child: const Icon(Icons.image, size: 40, color: Colors.white54),
              )),
          const SizedBox(width: 8),
          const Text('Agriflock 360'),
        ]),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: const ExpenseMarqueeBannerCompact(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(),
              const SizedBox(height: 20),

              if (_isLoadingRecommended)
                const Center(
                  child: Padding(padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: Colors.green)),
                ),

              if (_hasRecommendedError && !_isLoadingRecommended)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    const Text('Failed to load recommendations',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_recommendedErrorMessage ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadRecommendedVets,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ]),
                ),

              if (!_isLoadingRecommended) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Recommended Vets',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('Top-rated veterinarians near you',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ]),
                    if (_recommendedVets.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('${_recommendedVets.length} nearby',
                            style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_recommendedVets.isEmpty && !_hasRecommendedError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(children: [
                      Icon(Icons.person_search, size: 72, color: Colors.grey.shade300),
                      const SizedBox(height: 14),
                      Text('No Recommended Vets',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Text('No veterinarians found near you yet.\nBrowse all vets below.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500), textAlign: TextAlign.center),
                    ]),
                  )
                else
                  SizedBox(
                    height: _listHeight(context),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedVets.length,
                      itemBuilder: (ctx, i) => _buildCard(ctx, _recommendedVets[i]),
                    ),
                  ),

                const SizedBox(height: 24),

                // View All Vets
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToAllVets,
                    icon: Icon(Icons.people_alt, color: Colors.green.shade700, size: 20),
                    label: Text('View All Veterinary Officers',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.green.shade400, width: 1.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.green.withOpacity(0.04),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}