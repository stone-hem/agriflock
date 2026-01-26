import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/auth/quiz/shared/gender_selector.dart';
import '../../../main.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  // Loading state
  bool _isLoading = false;

  // Focus nodes for text fields
  final FocusNode _idNumberFocus = FocusNode();
  final FocusNode _houseCapacityFocus = FocusNode();
  final FocusNode _otherPoultryTypeFocus = FocusNode();

  // Poultry type options
  final List<String> _poultryTypes = [
    'Broilers',
    'Layers',
    'Improved Kienyeji',
    'Other'
  ];

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

    // Add listeners to update UI when fields change
    _idNumberController.addListener(_updateValidationState);
    _dobController.addListener(_updateValidationState);
    _houseCapacityController.addListener(_updateValidationState);
    _otherPoultryTypeController.addListener(_updateValidationState);
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
            _selectedGender != null;

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

  Future<void> _completeProfile() async {
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
        'date_of_birth': _dobController.text.trim(),
        'gender': _selectedGender,
        'poultry_type': (_selectedPoultryType == 'Other'
            ? _otherPoultryTypeController.text.trim()
            : _selectedPoultryType)?.toLowerCase() ?? '',
        'chicken_house_capacity': int.tryParse(_houseCapacityController.text.trim()) ?? 0,
      };

      // Make API call
      final response = await apiClient.put(
        '/users/profile', // Your API endpoint
        body: profileData,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ToastUtil.showSuccess(
          'Profile completed successfully! Please Log in again to use the app.',
        );

        // Navigate to quotation
        context.pushReplacement(AppRoutes.dashboard, extra: 'farmer_quotation');
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
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque, // Important for proper tap handling
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () {
              _dismissKeyboard();
              context.pushReplacement(AppRoutes.dashboard, extra: 'farmer_home');
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
                  _dismissKeyboard(); // Dismiss keyboard when changing pages
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
              returnFormat: DateReturnFormat.dateTime,
              initialDate:  DateTime.now().subtract(const Duration(days: 365 * 10)),
              minYear: DateTime.now().year - 100,
              maxYear: DateTime.now().year - 10,
              controller: _dobController,
              onChanged: (value) {
                if (value != null) {
                    // _hatchDate = value;
                    _dobController.text = DateUtil.toReadableDate(value);
                }
              },
            ),

            const SizedBox(height: 20),

            // Gender
            GenderSelector(
              selectedGender: _selectedGender,
              onGenderSelected: (String gender) {
                _dismissKeyboard(); // Dismiss keyboard when selecting gender
                setState(() {
                  _selectedGender = gender.toLowerCase();
                });
              },
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

            // Primary Poultry Type (Dropdown)
            GestureDetector(
              onTap: () {
                _dismissKeyboard(); // Dismiss keyboard before opening dropdown
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Primary Poultry Type *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPoultryType,
                        hint: const Text('Select poultry type'),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: primaryGreen),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        onChanged: (String? newValue) {
                          _dismissKeyboard(); // Dismiss keyboard when selecting from dropdown
                          setState(() {
                            _selectedPoultryType = newValue;
                            if (newValue != 'Other') {
                              _otherPoultryTypeController.clear();
                            }
                          });
                        },
                        items: _poultryTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_selectedPoultryType == 'Other')
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ReusableInput(
                        controller: _otherPoultryTypeController,
                        focusNode: _otherPoultryTypeFocus,
                        labelText: 'Specify other poultry type *',
                        hintText: 'Enter your specific poultry type',
                        icon: Icons.edit,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Chicken House Capacity
            ReusableInput(
              controller: _houseCapacityController,
              focusNode: _houseCapacityFocus,
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

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                  _dismissKeyboard(); // Dismiss keyboard before navigation/submission
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
      ),
    );
  }

}

// Data Model
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