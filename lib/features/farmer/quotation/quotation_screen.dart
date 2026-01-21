import 'dart:ui';
import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/features/farmer/quotation/poultry_house_quotation.dart';
import 'package:agriflock360/features/farmer/quotation/production_estimate.dart';
import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
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
  final SecureStorage _secureStorage = SecureStorage();

  // Profile completion check variables
  bool _isCheckingProfile = true;
  bool _showProfileModal = false;
  double _profileCompletion = 0.0;
  User? _currentUser;

  // Profile completion threshold (you can adjust this)
  static const double PROFILE_COMPLETION_THRESHOLD = 100.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Check profile completion immediately
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    try {
      // Get user data from secure storage
      final userData = await _secureStorage.getUserData();

      if (userData != null && mounted) {
        final completion = _calculateProfileCompletion(userData);

        setState(() {
          _currentUser = userData;
          _profileCompletion = completion;
          _isCheckingProfile = false;
        });

        // If profile is not complete, show modal immediately
        if (completion < PROFILE_COMPLETION_THRESHOLD) {
          // Show modal immediately after build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showProfileCompletionModal();
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isCheckingProfile = false;
          });

          // If no user data, show modal immediately
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showProfileCompletionModal();
            }
          });
        }
      }
    } catch (e) {
      print('Error checking profile completion: $e');
      if (mounted) {
        setState(() {
          _isCheckingProfile = false;
        });
      }
    }
  }

  double _calculateProfileCompletion(User user) {
    int completedFields = 0;
    int totalFields = 5;

    if (user.name.isNotEmpty && user.name != 'Not Provided') completedFields++;
    if (user.email.isNotEmpty) completedFields++;
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) completedFields++;
    if (user.avatar != null && user.avatar!.isNotEmpty) completedFields++;
    if (user.agreedToTerms == true) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  void _showProfileCompletionModal() {
    setState(() {
      _showProfileModal = true;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent, // Remove default barrier
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: _buildProfileModalContent(),
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _showProfileModal = false;
        });
      }
    });
  }

  Widget _buildProfileModalContent() {
    final completionPercentage = _profileCompletion.toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.shade200, width: 2),
            ),
            child: Icon(
              Icons.person_outline,
              size: 40,
              color: Colors.orange.shade700,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 12),

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

          const SizedBox(height: 24),

          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '$completionPercentage%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: completionPercentage >= 100 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress bar
                LinearProgressIndicator(
                  value: _profileCompletion / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completionPercentage >= 100 ? Colors.green : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 10,
                ),

                const SizedBox(height: 8),

                // Status message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    completionPercentage >= 100
                        ? 'Your profile is complete!'
                        : '$completionPercentage% complete - ${100 - completionPercentage}% remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Missing fields info (optional)
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
                    size: 20,
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

          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushReplacement(AppRoutes.dashboard, extra: 'farmer_home');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Maybe Later'),
                ),
              ),

              const SizedBox(width: 16),

              // Complete Profile button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/complete-profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
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
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () => context.push('/notifications'),
          ),
        ],
        bottom: TabBar(
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
            Tab(
              text: 'House Quotation',
            ),
            Tab(
              text: 'Production Estimate',
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Main content
          TabBarView(
            controller: _tabController,
            children: const [
              // House Quotation Tab
              PoultryHouseQuotationScreen(),

              // Production Estimate Tab
              ProductionEstimateScreen(),
            ],
          ),

          // Blur overlay when modal is shown
          if (_showProfileModal || _isCheckingProfile)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: _isCheckingProfile
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Verifying profile...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}