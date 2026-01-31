import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/profile/models/profile_model.dart';
import 'package:agriflock360/features/farmer/profile/repo/profile_repository.dart';
import 'package:agriflock360/features/farmer/quotation/poultry_house_quotation.dart';
import 'package:agriflock360/features/farmer/quotation/production_estimate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color(0xFF2E7D32);
  ProfileData? _profileData;


  // Create instance of ProfileRepository
  final ProfileRepository _profileRepository = ProfileRepository();

  // Profile completion check variables
  bool _isCheckingProfile = true;
  double _profileCompletion = 0.0;
  String? _errorMessage;

  // Profile completion threshold
  static const double PROFILE_COMPLETION_THRESHOLD = 100.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAndCheckProfileCompletion();
  }

  Future<void> _fetchAndCheckProfileCompletion() async {
    try {
      if (mounted) {
        setState(() {
          _isCheckingProfile = true;
          _errorMessage = null;
        });
      }

      // Fetch profile from API
      final result = await _profileRepository.getProfile();

      if (mounted) {
        switch(result) {
          case Success<ProfileData>():
            _profileData = result.data;
            final completion = _calculateProfileCompletion(_profileData!);

            setState(() {
              _profileCompletion = completion;
              _isCheckingProfile = false;
            });
          case Failure<ProfileData>():
            setState(() {
              _profileCompletion = 0.0;
              _isCheckingProfile = false;
              _errorMessage = result.message;
            });
        }

      }
    } catch (e) {
      print('Error fetching profile completion: $e');
      if (mounted) {
        setState(() {
          _profileCompletion = 0.0;
          _isCheckingProfile = false;
          _errorMessage = 'An error occurred. Please try again.';
        });
      }
    }
  }

  double _calculateProfileCompletion(ProfileData profile) {
    int completedFields = 0;
    int totalFields = 5;

    // Check national ID
    if (profile.nationalId != null && profile.nationalId!.isNotEmpty) {
      completedFields++;
    }

    // Check date of birth
    if (profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty) {
      completedFields++;
    }

    // Check gender
    if (profile.gender != null && profile.gender!.isNotEmpty) {
      completedFields++;
    }

    // Check poultry type
    if (profile.poultryTypeId==null) {
      completedFields++;
    }

    // Check chicken house capacity
    if (profile.chickenHouseCapacity != null) {
      completedFields++;
    }


    return (completedFields / totalFields) * 100;
  }

  Widget _buildProfileCompletionScreen() {
    final completionPercentage = _profileCompletion.toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Error message if any
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    onPressed: _fetchAndCheckProfileCompletion,
                  ),
                ],
              ),
            ),

          // Header with icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.shade200, width: 3),
            ),
            child: Icon(
              Icons.person_outline,
              size: 50,
              color: Colors.orange.shade700,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'To access quotation features, please complete your profile information first.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completion',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '$completionPercentage%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: completionPercentage >= 100
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _profileCompletion / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completionPercentage >= 100 ? Colors.green : Colors.orange,
                    ),
                    minHeight: 12,
                  ),
                ),

                const SizedBox(height: 12),

                // Status message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    completionPercentage >= 100
                        ? 'Your profile is complete!'
                        : '$completionPercentage% complete - ${100 - completionPercentage}% remaining',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Missing fields info
          if (completionPercentage < 100)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Complete all profile fields to unlock quotation features',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 40),

          // Buttons
          Column(
            children: [
              // Complete Profile button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to complete profile screen
                    // This will push and wait for result if profile is updated
                    context.push('/complete-profile',extra: _profileData).then((value) {
                      // Refresh profile data after returning from complete profile screen
                      if (value == true) {
                        _fetchAndCheckProfileCompletion();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Refresh button for error state
              if (_errorMessage != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _fetchAndCheckProfileCompletion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Retry Loading Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.pushReplacement(AppRoutes.dashboard,
                        extra: 'farmer_home');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('Agriflock 360'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: Colors.grey.shade700),
            onPressed: () => context.push('/notifications'),
          ),
        ],
        bottom: _profileCompletion >= PROFILE_COMPLETION_THRESHOLD
            ? TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'House Quotation'),
            Tab(text: 'Production Estimate'),
          ],
        )
            : null,
      ),
      body: _isCheckingProfile
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Fetching profile data...',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : _profileCompletion >= PROFILE_COMPLETION_THRESHOLD
          ? TabBarView(
        controller: _tabController,
        children: const [
          PoultryHouseQuotationScreen(),
          ProductionEstimateScreen(),
        ],
      )
          : _buildProfileCompletionScreen(),
    );
  }
}