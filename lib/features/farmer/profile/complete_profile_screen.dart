import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/auth/quiz/shared/custom_text_field.dart';
import 'package:agriflock360/core/widgets/file_upload.dart';
import 'package:agriflock360/features/auth/quiz/shared/gender_selector.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

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

  // Photos
  File? _idPhoto;

  // Additional documents
  final List<PlatformFile> _uploadedFiles = [];

  // Loading state
  bool _isLoading = false;

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
    // ProfileStep(
    //   title: 'Verification',
    //   subtitle: 'Upload photos for verification',
    //   icon: Icons.verified_user_outlined,
    //   color: primaryGreen,
    //   stepNumber: 3,
    // ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _idNumberController.dispose();
    _dobController.dispose();
    _houseCapacityController.dispose();
    _otherPoultryTypeController.dispose();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _dobController.text = picked.toIso8601String(); // Use ISO format for API
      });
    }
  }

  void _onFilesSelected(List<PlatformFile> files) {
    setState(() {
      _uploadedFiles.addAll(files);
    });
  }

  void _onFileRemoved(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  bool _isCurrentStepValid() {
    switch (_currentPage) {
      case 0: // Personal Information
        return
          _idNumberController.text.isNotEmpty &&
              _dobController.text.isNotEmpty &&
              _selectedGender != null;

      case 1: // Farm Operations
        return _selectedPoultryType != null &&
            _houseCapacityController.text.isNotEmpty &&
            (_selectedPoultryType != 'Other' ||
                _otherPoultryTypeController.text.isNotEmpty);

    // case 2: // Verification
    //   return true;
    //   // return _idPhoto != null;

      default:
        return false;
    }
  }

  Future<void> _completeProfile() async {
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
          // Add auth token if needed:
          // 'Authorization': 'Bearer $yourToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ToastUtil.showSuccess(
         'Profile completed successfully! Please Log in again to use the app.',
        );

        // Navigate to login
        await apiClient.logout();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => context.pop(),
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
    );
  }

  Widget _buildStepPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return _buildPersonalInfoPage();
      case 1:
        return _buildFarmOperationsPage();
    // case 2:
    //   return _buildVerificationPage();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
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
          CustomTextField(
            controller: _idNumberController,
            label: 'ID Number *',
            hintText: 'Enter your national ID number',
            icon: Icons.badge,
            keyboardType: TextInputType.number,
            value: '',
          ),
          const SizedBox(height: 20),

          // Date of Birth
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date of Birth *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryGreen),
                      const SizedBox(width: 12),
                      Text(
                        _dobController.text.isEmpty
                            ? 'Select your date of birth'
                            : _formatDateForDisplay(_dobController.text),
                        style: TextStyle(
                          color: _dobController.text.isEmpty
                              ? Colors.grey.shade500
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gender
          GenderSelector(
            selectedGender: _selectedGender,
            onGenderSelected: (String gender) {
              setState(() {
                _selectedGender = gender.toLowerCase();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFarmOperationsPage() {
    return SingleChildScrollView(
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
          Column(
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
                    icon: Icon(Icons.arrow_drop_down, color: primaryGreen),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
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
                  child: CustomTextField(
                    controller: _otherPoultryTypeController,
                    label: 'Specify other poultry type *',
                    hintText: 'Enter your specific poultry type',
                    icon: Icons.edit,
                    value: '',
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Chicken House Capacity
          CustomTextField(
            controller: _houseCapacityController,
            label: 'Chicken House Capacity *',
            hintText: 'Maximum number of chickens your house can hold',
            icon: Icons.home_work,
            keyboardType: TextInputType.number,
            value: '',
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget _buildVerificationPage() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Verification Photos',
  //           style: TextStyle(
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         const Text(
  //           'Upload photos for profile verification',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Colors.black54,
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //
  //         // ID Photo
  //         PhotoUpload(
  //           file: _idPhoto,
  //           onFileSelected: (File? file) {
  //             setState(() {
  //               _idPhoto = file;
  //             });
  //           },
  //           title: 'ID Photo *',
  //           description: 'Upload a clear photo of your government-issued ID',
  //           primaryColor: primaryGreen,
  //         ),
  //         const SizedBox(height: 20),
  //
  //         // Additional documents (optional)
  //         FileUpload(
  //           uploadedFiles: _uploadedFiles,
  //           onFilesSelected: _onFilesSelected,
  //           onFileRemoved: _onFileRemoved,
  //           title: 'Additional Documents (Optional)',
  //           description: 'Upload any additional farming certificates or documents',
  //           primaryColor: primaryGreen,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomNavigation() {
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
              onPressed: _isLoading || !_isCurrentStepValid()
                  ? null
                  : () {
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

  String _formatDateForDisplay(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoDate;
    }
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