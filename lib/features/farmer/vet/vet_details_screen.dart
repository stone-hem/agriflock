import 'package:agriflock/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock/core/utils/result.dart';

class VetDetailsScreen extends StatefulWidget {
  final String vetId;
  const VetDetailsScreen({super.key, required this.vetId});

  @override
  State<VetDetailsScreen> createState() => _VetDetailsScreenState();
}

class _VetDetailsScreenState extends State<VetDetailsScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();
  VetFarmer? _vet;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  static const Color _orange = Color(0xFFE65100);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _mid = Color(0xFF6B6B6B);
  static const Color _border = Color(0xFFEEEEEE);

  @override
  void initState() {
    super.initState();
    _loadVetDetails();
  }

  Future<void> _loadVetDetails() async {
    setState(() { _isLoading = true; _hasError = false; _errorMessage = null; });
    try {
      final result = await _vetRepository.getVetFarmerById(widget.vetId);
      switch (result) {
        case Success<VetFarmer>(data: final data):
          setState(() { _vet = data; _isLoading = false; });
        case Failure(message: final error):
          setState(() { _hasError = true; _errorMessage = error; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _hasError = true; _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  String _mask(String? v) {
    if (v == null || v.isEmpty) return 'Not provided';
    if (v.contains('@')) {
      final p = v.split('@');
      return '${p[0].length > 2 ? p[0].substring(0, 2) : ''}***@${p[1]}';
    }
    if (RegExp(r'^\+?[\d\s-]+$').hasMatch(v)) {
      return v.length > 4 ? '${v.substring(0, v.length - 4)}****' : '****';
    }
    return v;
  }

  // ── Compact inline row: icon + label + value ──
  Widget _row(IconData icon, String label, String value, Color iconColor) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 7),
            Text('$label: ',
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: _mid)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12.5, color: _dark, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2),
            ),
          ],
        ),
      );

  // ── Section header ──
  Widget _sectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Row(
      children: [
        Container(
          width: 3.5,
          height: 16,
          decoration: BoxDecoration(
              color: _orange, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 15, color: _orange),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _dark,
                letterSpacing: 0.2)),
      ],
    ),
  );

  // ── Pill chip ──
  Widget _chip(String label, Color fg, Color bg) => Container(
    margin: const EdgeInsets.only(right: 5, bottom: 5),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3))),
    child: Text(label,
        style: TextStyle(
            fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
  );

  // ── Mini stat badge ──
  Widget _stat(String val, String lbl, IconData icon) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: _green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: _green),
      ),
      const SizedBox(height: 4),
      Text(val,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: _dark)),
      Text(lbl,
          style: const TextStyle(
              fontSize: 10.5, color: _mid, fontWeight: FontWeight.w500)),
    ],
  );

  // ── Star row ──
  Widget _stars(double r) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) {
      if (i < r.floor())
        return const Icon(Icons.star, color: Color(0xFFFFB300), size: 14);
      if (r - i >= 0.5 && i < r.ceil())
        return const Icon(Icons.star_half,
            color: Color(0xFFFFB300), size: 14);
      return const Icon(Icons.star_border,
          color: Color(0xFFFFB300), size: 14);
    }),
  );

  Widget _buildBookButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _vet!.isAvailable ? () => _orderVet(context) : null,
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(
        _vet!.isAvailable ? 'Book Appointment' : 'Currently Unavailable',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _vet!.isAvailable ? _orange : Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        elevation: 2,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _green)),
      );
    }
    if (_hasError || _vet == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => context.pop(),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
                const SizedBox(height: 16),
                const Text('Failed to load vet details',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold, color: _dark)),
                const SizedBox(height: 8),
                Text(_errorMessage ?? 'Please try again',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: _mid)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadVetDetails,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final vet = _vet!;
    final rating = double.tryParse(vet.averageRating) ?? 0.0;
    final address = vet.location.address?.formattedAddress ?? '';
    final specs = vet.specializations?.areas ?? [];
    final certs = vet.specializations?.certifications ?? [];
    final counties = vet.coverageAreas?.counties ?? [];
    final subCounties = vet.coverageAreas?.subCounties ?? [];
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero ──
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.30,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 17, color: _dark),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  vet.faceSelfieUrl != null
                      ? Image.network(vet.faceSelfieUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _heroBg())
                      : _heroBg(),
                  // Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                  // Name + badges overlay
                  Positioned(
                    bottom: 14, left: 16, right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(vet.name,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(blurRadius: 6, color: Colors.black45, offset: Offset(1, 1))
                                      ])),
                            ),
                            if (vet.isVerified) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                    color: _green, shape: BoxShape.circle),
                                child: const Icon(Icons.verified,
                                    size: 14, color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: vet.isAvailable
                                      ? Colors.green.withOpacity(0.85)
                                      : Colors.red.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                    width: 5, height: 5,
                                    decoration: const BoxDecoration(
                                        color: Colors.white, shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Text(vet.isAvailable ? 'Available' : 'Unavailable',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                            const SizedBox(width: 6),
                            Text(vet.educationLevel,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats strip ──
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('${vet.yearsOfExperience}yr', 'Experience', Icons.work_history),
                        _divider(),
                        _stat(rating.toStringAsFixed(1), 'Rating', Icons.star_rounded),
                        _divider(),
                        _stat('${vet.totalAppraisals}', 'Reviews', Icons.people_outline),
                        _divider(),
                        _stat('${vet.totalJobsCompleted}', 'Jobs', Icons.task_alt),
                      ],
                    ),
                  ),

                  // ── Rating stars detail ──
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(children: [
                      _stars(rating),
                      const SizedBox(width: 6),
                      Text(
                        '${rating.toStringAsFixed(1)} out of 5 · ${vet.totalRatingsCount} total ratings',
                        style: const TextStyle(fontSize: 11.5, color: _mid),
                      ),
                    ]),
                  ),

                  // ── Book button ──
                  const SizedBox(height: 14),
                  _buildBookButton(),

                  // ── About ──
                  if (vet.profileBio.isNotEmpty) ...[
                    _sectionHeader('About', Icons.person_outline),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: Text(vet.profileBio,
                          style: const TextStyle(
                              fontSize: 12.5, color: _dark, height: 1.55)),
                    ),
                  ],

                  // ── Professional Details ──
                  _sectionHeader('Professional Details', Icons.badge_outlined),
                  _detailsBlock([
                    _row(Icons.badge, 'Officer Type',
                        _cap(vet.officerType), Colors.green.shade600),
                    _row(Icons.school, 'Qualification',
                        vet.educationLevel, Colors.blue.shade600),
                    _row(Icons.workspace_premium, 'Tier',
                        vet.tier.isNotEmpty ? _cap(vet.tier) : 'Standard',
                        Colors.purple.shade600),
                    _row(Icons.cake_outlined, 'Age',
                        '${vet.age} years', Colors.teal.shade600),
                    _row(
                        vet.gender.toLowerCase() == 'female'
                            ? Icons.female
                            : Icons.male,
                        'Gender',
                        _cap(vet.gender),
                        Colors.pink.shade400),
                    _row(Icons.work_history, 'Experience',
                        '${vet.yearsOfExperience} years', Colors.orange.shade700),
                    _row(Icons.task_alt, 'Jobs Completed',
                        '${vet.totalJobsCompleted}', Colors.green.shade700),
                    if (vet.licenseNumber != null && vet.licenseNumber!.isNotEmpty)
                      _row(Icons.credit_card, 'License No.',
                          vet.licenseNumber!, Colors.blueGrey.shade600),
                    if (vet.licenseExpiryDate != null && vet.licenseExpiryDate!.isNotEmpty)
                      _row(Icons.event, 'License Expiry',
                          vet.licenseExpiryDate!, Colors.red.shade400),
                  ]),

                  // ── Specializations ──
                  if (specs.isNotEmpty || certs.isNotEmpty) ...[
                    _sectionHeader('Specializations', Icons.medical_services_outlined),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (specs.isNotEmpty) ...[
                            Text('Areas',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade500)),
                            const SizedBox(height: 6),
                            Wrap(
                              children: specs
                                  .map((s) => _chip(s, Colors.green.shade700,
                                  Colors.green.shade50))
                                  .toList(),
                            ),
                          ],
                          if (certs.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('Certifications',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade500)),
                            const SizedBox(height: 6),
                            Wrap(
                              children: certs
                                  .map((c) =>
                                  _chip(c, Colors.blue.shade700, Colors.blue.shade50))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // ── Coverage Areas ──
                  if (counties.isNotEmpty || subCounties.isNotEmpty) ...[
                    _sectionHeader('Coverage Areas', Icons.map_outlined),
                    _detailsBlock([
                      if (counties.isNotEmpty)
                        _row(Icons.map, 'Counties',
                            counties.join(', '), Colors.cyan.shade700),
                      if (subCounties.isNotEmpty)
                        _row(Icons.location_city, 'Sub-Counties',
                            subCounties.join(', '), Colors.blueGrey.shade600),
                    ]),
                  ],

                  // ── Services Offered ──
                  _sectionHeader('Services Offered', Icons.miscellaneous_services_outlined),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border)),
                    child: Wrap(
                      children: [
                        'Advisory Call (Remote)',
                        'Disease Investigation',
                        'Farm Visit & Assessment',
                        'Training / Group Session',
                        'Vaccination',
                      ]
                          .map((s) =>
                          _chip(s, Colors.orange.shade700, Colors.orange.shade50))
                          .toList(),
                    ),
                  ),

                  // ── Contact Information ──
                  _sectionHeader('Contact', Icons.contact_phone_outlined),
                  _detailsBlock([
                    _row(Icons.location_on, 'Address',
                        address.isNotEmpty ? address : 'Not specified',
                        Colors.red.shade400),
                    if (vet.region != null && vet.region!.isNotEmpty)
                      _row(Icons.public, 'Region', vet.region!, Colors.teal.shade600),
                    _row(Icons.email_outlined, 'Email',
                        _mask(vet.user?.email), Colors.blue.shade600),
                    _row(Icons.phone_outlined, 'Phone',
                        _mask(vet.user?.phoneNumber), Colors.green.shade600),
                    if (vet.contactInfo != null) ...[
                      if (vet.contactInfo!.whatsapp.isNotEmpty)
                        _row(Icons.chat_outlined, 'WhatsApp',
                            _mask(vet.contactInfo!.whatsapp), Colors.green.shade700),
                      if (vet.contactInfo!.alternativePhone.isNotEmpty)
                        _row(Icons.phone_android, 'Alt. Phone',
                            _mask(vet.contactInfo!.alternativePhone),
                            Colors.indigo.shade500),
                    ],
                  ]),

                  // ── Certificates badge ──
                  if (vet.certificateUrls.isNotEmpty ||
                      vet.additionalCertificateUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_user,
                              color: Colors.green.shade700, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            '${vet.certificateUrls.length + vet.additionalCertificateUrls.length} certificate(s) on file',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Bottom Book Button ──
                  const SizedBox(height: 20),
                  _buildBookButton(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _heroBg() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.green.shade100, Colors.green.shade50],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: const Center(child: Icon(Icons.pets, size: 72, color: _green)),
  );

  Widget _divider() => Container(
      height: 30, width: 1, color: Colors.grey.shade200);

  // Wraps a list of rows in a single white rounded container
  Widget _detailsBlock(List<Widget> rows) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
  );

  String _cap(String s) => s.isEmpty
      ? s
      : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');

  void _orderVet(BuildContext context) {
    if (_vet != null) context.push('/vet-order-details', extra: _vet!);
  }
}