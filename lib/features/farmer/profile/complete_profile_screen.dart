import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/profile/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/auth/quiz/shared/gender_selector.dart';
import '../../../main.dart';
import '../batch/model/bird_type.dart';

class CompleteProfileScreen extends StatefulWidget {
  final ProfileData? profileData;
  const CompleteProfileScreen({super.key,  this.profileData});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final SecureStorage _secureStorage = SecureStorage();
  final _birdRepository = BatchHouseRepository();
  bool _isLoadingBirdTypes = false;
  List<BirdType> _birdTypes = [];


  final PageController _pageController = PageController();
  int _currentPage = 0;
  User? _user; // Make it nullable

  // Color scheme - matching onboarding
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Farmer Profile Data
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  String? _selectedPoultryType;
  final TextEditingController _houseCapacityController = TextEditingController();
  final TextEditingController _otherPoultryTypeController = TextEditingController();
  final TextEditingController _preferredAgrovetController = TextEditingController();
  final TextEditingController _preferredFeedCompanyController = TextEditingController();


  // Loading state
  bool _isLoading = false;
  bool _isLoadingUser = true; // Start as true

  // Focus nodes for text fields
  final FocusNode _idNumberFocus = FocusNode();
  final FocusNode _houseCapacityFocus = FocusNode();
  final FocusNode _otherPoultryTypeFocus = FocusNode();
  final FocusNode _preferredAgrovetFocus = FocusNode();
  final FocusNode _preferredFeedCompanyFocus = FocusNode();




  final List<ProfileStep> _profileSteps = [
    ProfileStep(
      title: 'Personal Information',
      subtitle: 'Basic personal details and identification',
      icon: Icons.person_outline,
      color: primaryGreen,
      stepNumber: 1,
    ),
    ProfileStep(
      title: 'Farm Operations',
      subtitle: 'Details about your poultry farming operations',
      icon: Icons.agriculture_outlined,
      color: primaryGreen,
      stepNumber: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadBirdTypes();
    _loadUserData();
    // Add listeners to update UI when fields change
    _idNumberController.addListener(_updateValidationState);
    _dobController.addListener(_updateValidationState);
    _houseCapacityController.addListener(_updateValidationState);
    _otherPoultryTypeController.addListener(_updateValidationState);
    //initialize existing profile data
    if (widget.profileData != null) {
      _idNumberController.text = widget.profileData!.nationalId ?? '';
      _dobController.text = widget.profileData!.dateOfBirth ?? '';
      _selectedGender = widget.profileData!.gender ?? '';
      _houseCapacityController.text =
      widget.profileData!.chickenHouseCapacity != null
          ? widget.profileData!.chickenHouseCapacity.toString()
          : '';
      _preferredAgrovetController.text = widget.profileData!.preferredAgrovetName ?? '';
      _preferredFeedCompanyController.text = widget.profileData!.preferredFeedCompany ?? '';
    }
  }

  Future<void> _loadBirdTypes() async {

    try {
      setState(() {
        _isLoadingBirdTypes = true;
      });

      final result = await _birdRepository.getBirdTypes();

      switch (result) {
        case Success(data: final types):
          setState(() {
            _birdTypes = types;
            _isLoadingBirdTypes = false;
          });

        case Failure(:final response, :final message):
          if (response != null) {
            ApiErrorHandler.handle(response);
          } else {
            ToastUtil.showError(message);
          }
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      setState(() {
        _isLoadingBirdTypes = false;
      });
    }
  }

  void _updateValidationState() {
    // Trigger a rebuild to update button state
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _idNumberController.dispose();
    _dobController.dispose();
    _houseCapacityController.dispose();
    _otherPoultryTypeController.dispose();
    _idNumberFocus.dispose();
    _houseCapacityFocus.dispose();
    _otherPoultryTypeFocus.dispose();
    _preferredAgrovetFocus.dispose();
    _preferredFeedCompanyFocus.dispose();
    _preferredAgrovetController.dispose();
    _preferredFeedCompanyController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _profileSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isCurrentStepValid() {
    switch (_currentPage) {
      case 0: // Personal Information
        return _idNumberController.text.trim().isNotEmpty &&
            _dobController.text.trim().isNotEmpty &&
            _selectedGender != null && _preferredAgrovetController.text.trim().isNotEmpty &&
            _preferredFeedCompanyController.text.trim().isNotEmpty;

      case 1: // Farm Operations
        final hasPoultryType = _selectedPoultryType != null;
        final hasCapacity = _houseCapacityController.text.trim().isNotEmpty;
        final otherTypeValid = _selectedPoultryType != 'Other' ||
            _otherPoultryTypeController.text.trim().isNotEmpty;

        return hasPoultryType && hasCapacity && otherTypeValid;

      default:
        return false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Get user data from secure storage as User object
      final userData = await _secureStorage.getUserData();

      if (userData != null && mounted) {
        setState(() {
          _user = userData;
          _isLoadingUser = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoadingUser = false;
          });
          ToastUtil.showError('No user data found. Please login again.');
          await apiClient.logout();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
        ToastUtil.showError('Error loading user data');
        await apiClient.logout();
      }
    }
  }

  Future<void> _completeProfile() async {
    // Check if user is loaded
    if (_user == null) {
      ToastUtil.showError('User data not loaded. Please try again.');
      return;
    }

    // Dismiss keyboard before submitting
    FocusScope.of(context).unfocus();

    if (!_isCurrentStepValid()) {
      ToastUtil.showError('Please fill all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare profile data
      final profileData = {
        'national_id': _idNumberController.text.trim(),
        'date_of_birth': DateTime.parse(_dobController.text).toUtc().toIso8601String(),
        'gender': _selectedGender,
        'poultry_type_id': _selectedPoultryType,
        'chicken_house_capacity': int.tryParse(_houseCapacityController.text.trim()) ?? 0,
        'preferred_agrovet_name': _preferredAgrovetController.text.trim(),
        'preferred_feed_company': _preferredFeedCompanyController.text.trim(),
      };

      LogUtil.warning('Profile Data: $profileData');


      // Make API call
      final response = await apiClient.put(
        '/users/profile',
        body: profileData,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {

        // Create updated user with profile data
        final updatedUser = User(
          id: _user!.id,
          email: _user!.email,
          name: _user!.name,
          phoneNumber: _user!.phoneNumber,
          is2faEnabled: _user!.is2faEnabled,
          emailVerificationExpiresAt: _user!.emailVerificationExpiresAt,
          refreshTokenExpiresAt: _user!.refreshTokenExpiresAt,
          passwordResetExpiresAt: _user!.passwordResetExpiresAt,
          status: _user!.status,
          avatar: _user!.avatar,
          googleId: _user!.googleId,
          appleId: _user!.appleId,
          oauthProvider: _user!.oauthProvider,
          roleId: _user!.roleId,
          role: _user!.role,
          isActive: _user!.isActive,
          lockedUntil: _user!.lockedUntil,
          createdAt: _user!.createdAt,
          updatedAt: _user!.updatedAt,
          deletedAt: _user!.deletedAt,
          agreedToTerms: _user!.agreedToTerms,
          agreedToTermsAt: _user!.agreedToTermsAt,
          firstLogin: _user!.firstLogin,
          lastLogin: _user!.lastLogin,
          // Add profile-specific fields (make sure your User model has these)
          nationalId: _idNumberController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          gender: _selectedGender,
          poultryType:_selectedPoultryType,
          chickenHouseCapacity: int.tryParse(_houseCapacityController.text.trim()) ?? 0,
          preferredAgrovetName: _preferredAgrovetController.text.trim(),
          preferredFeedCompany: _preferredFeedCompanyController.text.trim(),
        );

        // Save updated user to secure storage
        await _secureStorage.saveUser(updatedUser);

        ToastUtil.showSuccess(
          'Profile completed successfully!',
        );

        // Navigate to quotation
        context.go(AppRoutes.quotation);
      } else {
        ApiErrorHandler.handle(response);
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method to dismiss keyboard
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while loading user
    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: primaryGreen),
              const SizedBox(height: 20),
              Text(
                'Loading your profile...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error if user not loaded
    if (_user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () {
              apiClient.logout();
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                'Unable to load user data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please login again to continue',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  apiClient.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () {
              _dismissKeyboard();
              context.go(AppRoutes.home);
            },
          ),
          title: Text(
            _profileSteps[_currentPage].title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Progress indicator
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _profileSteps.length,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
              ),
            ),
            const SizedBox(height: 8),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentPage + 1} of ${_profileSteps.length}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _profileSteps[_currentPage].title,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _profileSteps.length,
                onPageChanged: (page) {
                  _dismissKeyboard();
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  return _buildStepPage(pageIndex);
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildStepPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return _buildPersonalInfoPage();
      case 1:
        return _buildFarmOperationsPage();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoPage() {
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide your personal details for your profile',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),

            // ID Number
            ReusableInput(
              controller: _idNumberController,
              focusNode: _idNumberFocus,
              topLabel: 'Your National ID *',
              labelText: 'ID Number *',
              hintText: 'Enter your national ID number',
              icon: Icons.badge,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Date of Birth
            CustomDateTextField(
              label: 'Date of Birth *',
              icon: Icons.calendar_today,
              required: true,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
              returnFormat: DateReturnFormat.isoString,
              minYear: DateTime.now().year - 100,
              maxYear: DateTime.now().year - 10,
              controller: _dobController,
            ),

            const SizedBox(height: 20),

            // Gender
            GenderSelector(
              selectedGender: _selectedGender,
              onGenderSelected: (String gender) {
                _dismissKeyboard();
                setState(() {
                  _selectedGender = gender.toLowerCase();
                });
              },
            ),


            const SizedBox(height: 20),
            ReusableInput(
              controller: _preferredAgrovetController,
              focusNode: _preferredAgrovetFocus,
              topLabel: 'Preferred Agrovet *',
              labelText: 'Preferred Agrovet *',
              hintText: 'Enter your preferred agrovet',
              icon: Icons.input,
            ),

            const SizedBox(height: 20),
            ReusableInput(
              controller: _preferredFeedCompanyController,
              focusNode: _preferredFeedCompanyFocus,
              topLabel: 'Preferred Feed Company *',
              labelText: 'Preferred Feed Company *',
              hintText: 'Enter your preferred Feed Company',
              icon: Icons.input,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmOperationsPage() {
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Operations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Details about your current farming operations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),

            // Primary Poultry Type
            _isLoadingBirdTypes
                ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
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
              value: _selectedPoultryType,
              hintText: 'Select bird type',
              items: _birdTypes.map((BirdType type) {
                return DropdownMenuItem<String>(
                  value: type.id,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPoultryType = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a bird type';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Chicken House Capacity
            ReusableInput(
              controller: _houseCapacityController,
              focusNode: _houseCapacityFocus,
              topLabel: 'Chicken House Capacity *',
              labelText: 'Chicken House Capacity *',
              hintText: 'Maximum number of chickens your house can hold',
              icon: Icons.home_work,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isValid = _isCurrentStepValid();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousPage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: const BorderSide(color: primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentPage > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: (_isLoading || !isValid)
                  ? null
                  : () {
                _dismissKeyboard();
                if (_currentPage < _profileSteps.length - 1) {
                  _nextPage();
                } else {
                  _completeProfile();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                _currentPage == _profileSteps.length - 1
                    ? 'Complete Profile'
                    : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int stepNumber;

  ProfileStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.stepNumber,
  });
}