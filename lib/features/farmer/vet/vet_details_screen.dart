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
  VetFarmer? _vet;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // Clean color palette
  static const Color primaryGreen = Colors.green;
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color darkGray = Color(0xFF212121);
  static const Color mediumGray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _loadVetDetails();
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

  Future<void> _refreshData() async {
    await _loadVetDetails();
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = primaryGreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
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
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        service,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
            style: TextStyle(
              fontSize: 15,
              color: mediumGray,
            ),
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
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: mediumGray,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to load vet details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please try again',
              style: const TextStyle(
                fontSize: 14,
                color: mediumGray,
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vet Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: darkGray,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGray),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: borderColor,
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryGreen,
        child: _isLoading
            ? _buildLoadingState()
            : _hasError || _vet == null
            ? _buildErrorState()
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryGreen,
                          width: 3,
                        ),
                        image: _vet!.faceSelfieUrl.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(_vet!.faceSelfieUrl),
                          fit: BoxFit.cover,
                        )
                            : null,
                        color: Colors.white,
                      ),
                      child: _vet!.faceSelfieUrl.isEmpty
                          ? const Icon(
                        Icons.pets,
                        size: 48,
                        color: primaryGreen,
                      )
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      _vet!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Verified Badge
                    if (_vet!.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Education
                    Text(
                      _vet!.educationLevel,
                      style: const TextStyle(
                        fontSize: 15,
                        color: mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildStatCard(
                      '${_vet!.yearsOfExperience}',
                      'Years Exp',
                      Icons.work_outline,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      _vet!.averageRating,
                      'Rating',
                      Icons.star_outline,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      '${_vet!.totalAppraisals}',
                      'Reviews',
                      Icons.rate_review_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // About Section
              if (_vet!.profileBio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _vet!.profileBio,
                          style: const TextStyle(
                            fontSize: 14,
                            color: darkGray,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Contact Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.location_on_outlined,
                            iconColor: primaryGreen,
                            label: 'Location',
                            value: _vet!.location.address,
                          ),
                          Container(
                            height: 1,
                            color: borderColor,
                          ),
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            iconColor: primaryGreen,
                            label: 'Email',
                            value: _maskContactInfo(_vet!.user?.email),
                          ),
                          Container(
                            height: 1,
                            color: borderColor,
                          ),
                          _buildInfoRow(
                            icon: Icons.phone_outlined,
                            iconColor: primaryGreen,
                            label: 'Phone',
                            value: _maskContactInfo(_vet!.user?.phoneNumber),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Services
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Services Offered',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      children: [
                        _buildServiceChip('Consultation'),
                        _buildServiceChip('Treatment'),
                        _buildServiceChip('Vaccination'),
                        _buildServiceChip('Check-up'),
                        _buildServiceChip('Emergency Care'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Certificates
              if (_vet!.certificateUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          color: primaryGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Certificates',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: darkGray,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_vet!.certificateUrls.length} certificate(s) available',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: _vet!.status == 'active'
                          ? () => _orderVet(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: borderColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _orderVet(BuildContext context) {
    if (_vet != null) {
      context.push('/vet-order-details', extra: _vet!);
    }
  }
}