import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/result.dart';

class VetDetailsScreen extends StatefulWidget {
  final String vetId;

  const VetDetailsScreen({super.key, required this.vetId});

  @override
  State<VetDetailsScreen> createState() => _VetDetailsScreenState();
}

class _VetDetailsScreenState extends State<VetDetailsScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();
  final ScrollController _scrollController = ScrollController();
  VetFarmer? _vet;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  double _imageHeight = 0.0;

  static const Color primaryGreen = Colors.green;
  static const Color darkGray = Color(0xFF212121);
  static const Color mediumGray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _loadVetDetails();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _imageHeight = _scrollController.offset;
    });
  }

  Future<void> _loadVetDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final result = await _vetRepository.getVetFarmerById(widget.vetId);

      switch (result) {
        case Success<VetFarmer>(data: final data):

          setState(() {
            _vet = data;
            _isLoading = false;
          });
          break;
        case Failure(message: final error, :final statusCode, :final response):
          setState(() {
            _hasError = true;
            _errorMessage = error;
            _isLoading = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _maskContactInfo(String? value) {
    if (value == null || value.isEmpty) return 'Not provided';

    if (value.contains('@')) {
      final parts = value.split('@');
      if (parts[0].length > 2) {
        return '${parts[0].substring(0, 2)}***@${parts[1]}';
      }
      return '***@${parts[1]}';
    }

    if (RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
      if (value.length > 4) {
        return '${value.substring(0, value.length - 4)}****';
      }
      return '****';
    }

    return value;
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _vet!.isAvailable ? () => _orderVet(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: borderColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 20),
            SizedBox(width: 8),
            Text(
              'Book Appointment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryGreen, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: mediumGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: darkGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withOpacity(0.3), width: 1),
      ),
      child: Text(
        service,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
          ),
          SizedBox(height: 20),
          Text(
            'Loading vet details...',
            style: TextStyle(fontSize: 15, color: mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.error_outline, size: 48, color: mediumGray),
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to load vet details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please try again',
              style: const TextStyle(fontSize: 14, color: mediumGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadVetDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageContainerHeight = screenHeight * 0.33;

    return Scaffold(
      backgroundColor: lightGray,
      body: _isLoading
          ? _buildLoadingState()
          : _hasError || _vet == null
          ? _buildErrorState()
          : Stack(
        children: [
          // Main content with CustomScrollView
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: imageContainerHeight,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: darkGray, size: 18),
                    onPressed: () => context.pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image
                     if(_vet?.faceSelfieUrl != null)Image.network(
                        _vet!.faceSelfieUrl!,
                        fit: BoxFit.cover,
                      )
                      else
                        Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade100,
                              Colors.green.shade50,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 80,
                          color: primaryGreen,
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Content overlay
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _vet!.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (_vet!.isVerified) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _vet!.educationLevel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  color: lightGray,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Book Button at Top
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildBookButton(),
                      ),

                      const SizedBox(height: 16),

                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildStatCard(
                              '${_vet!.yearsOfExperience}',
                              'Years',
                              Icons.work_history_outlined,
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              _vet!.averageRating,
                              'Rating',
                              Icons.star_rounded,
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              '${_vet!.totalAppraisals}',
                              'Reviews',
                              Icons.people_outline,
                            ),
                          ],
                        ),
                      ),

                      // Main Content Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // About Section
                            if (_vet!.profileBio.isNotEmpty) ...[
                              const Text(
                                'About',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: darkGray,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor, width: 1),
                                ),
                                child: Text(
                                  _vet!.profileBio,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: darkGray,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Services
                            const Text(
                              'Services Offered',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkGray,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              children: [
                                _buildServiceChip('Advisory Call (Remote) Transport'),
                                _buildServiceChip('Disease Investigation'),
                                _buildServiceChip('Farm Visit & Assessment'),
                                _buildServiceChip('Training / Group Session'),
                                _buildServiceChip('Vaccination')
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Contact Information
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkGray,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildInfoCard(
                              icon: Icons.location_on,
                              label: 'Location',
                              value: _vet!.location.address!.formattedAddress,
                            ),
                            _buildInfoCard(
                              icon: Icons.email,
                              label: 'Email',
                              value: _maskContactInfo(_vet!.user?.email),
                            ),
                            _buildInfoCard(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: _maskContactInfo(_vet!.user?.phoneNumber),
                            ),

                            // Certificates
                            if (_vet!.certificateUrls.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryGreen.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.verified_user,
                                      color: primaryGreen,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${_vet!.certificateUrls.length} certificate(s) verified',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Bottom Book Button
                            _buildBookButton(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _orderVet(BuildContext context) {
    if (_vet != null) {
      context.push('/vet-order-details', extra: _vet!);
    }
  }
}