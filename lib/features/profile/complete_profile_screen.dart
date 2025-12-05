import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/lib/features/auth/quiz/shared/custom_text_field.dart';
import 'package:agriflock360/lib/features/auth/quiz/shared/gender_selector.dart';
import 'package:agriflock360/lib/features/auth/quiz/shared/photo_upload.dart';
import 'package:agriflock360/lib/features/auth/quiz/shared/file_upload.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _poultryTypeController = TextEditingController();
  final TextEditingController _houseCapacityController = TextEditingController();
  final TextEditingController _currentChickensController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();

  // Photos
  File? _idPhoto;

  // Additional documents
  final List<PlatformFile> _uploadedFiles = [];

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
    ProfileStep(
      title: 'Verification',
      subtitle: 'Upload photos for verification',
      icon: Icons.verified_user_outlined,
      color: primaryGreen,
      stepNumber: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate getting GPS coordinates (you would integrate with GPS service)
    _gpsController.text = 'Fetching location...';
    _fetchGPSLocation();
  }

  void _fetchGPSLocation() {
    // Simulate GPS fetch - replace with actual GPS service
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _gpsController.text = '-1.286389, 36.817223'; // Example Nairobi coordinates
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _poultryTypeController.dispose();
    _houseCapacityController.dispose();
    _currentChickensController.dispose();
    _gpsController.dispose();
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
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
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
        return true;
    // return _fullNameController.text.isNotEmpty &&
    //     _idNumberController.text.isNotEmpty &&
    //     _phoneController.text.isNotEmpty &&
    //     _dobController.text.isNotEmpty &&
    //     _selectedGender != null &&
    //     _experienceController.text.isNotEmpty &&
    //     _poultryTypeController.text.isNotEmpty;

      case 1: // Farm Operations
        return true;
    // return _houseCapacityController.text.isNotEmpty &&
    //     _currentChickensController.text.isNotEmpty;

      case 2: // Verification
        return true;
    // return _idPhoto != null;

      default:
        return false;
    }
  }

  void _completeProfile() {
    // TODO: Save profile data to backend
    final profileData = {
      'fullName': _fullNameController.text,
      'idNumber': _idNumberController.text,
      'phone': _phoneController.text,
      'dob': _dobController.text,
      'gender': _selectedGender,
      'poultryType': _poultryTypeController.text,
      'houseCapacity': _houseCapacityController.text,
      'currentChickens': _currentChickensController.text,
      'gpsCoordinates': _gpsController.text,
    };

    print('Profile data to save: $profileData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    context.go('/dashboard'); // Navigate to dashboard after completion
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
      case 2:
        return _buildVerificationPage();
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

          // Full Name
          CustomTextField(
            controller: _fullNameController,
            label: 'Full Name *',
            hintText: 'Enter your full name',
            icon: Icons.person,
            value: '',
          ),
          const SizedBox(height: 20),

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

          // Phone Number
          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number *',
            hintText: 'Enter your phone number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
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
                            : _dobController.text,
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
          const SizedBox(height: 20),


          // Poultry Type
          CustomTextField(
            controller: _poultryTypeController,
            label: 'Primary Poultry Type *',
            hintText: 'e.g., Broilers, Layers, Indigenous, etc.',
            icon: Icons.eco,
            value: '',
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

          // Chicken House Capacity
          CustomTextField(
            controller: _houseCapacityController,
            label: 'Chicken House Capacity *',
            hintText: 'Maximum number of chickens your house can hold',
            icon: Icons.home_work,
            keyboardType: TextInputType.number,
            value: '',
          ),
          const SizedBox(height: 20),

          // Current Number of Chickens
          CustomTextField(
            controller: _currentChickensController,
            label: 'Current Number of Chickens *',
            hintText: 'Current number of chickens in your farm',
            icon: Icons.numbers,
            keyboardType: TextInputType.number,
            value: '',
          ),
          const SizedBox(height: 20),

          // GPS Coordinates (auto-filled)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Farm GPS Coordinates',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: primaryGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _gpsController.text,
                        style: TextStyle(
                          color: _gpsController.text == 'Fetching location...'
                              ? Colors.grey.shade500
                              : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: primaryGreen),
                      onPressed: _fetchGPSLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Location will be automatically detected. Tap refresh to update.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Photos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload photos for profile verification',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),

          // ID Photo
          PhotoUpload(
            file: _idPhoto,
            onFileSelected: (File? file) {
              setState(() {
                _idPhoto = file;
              });
            },
            title: 'ID Photo *',
            description: 'Upload a clear photo of your government-issued ID',
            primaryColor: primaryGreen,
          ),
          const SizedBox(height: 20),

          // Additional documents (optional)
          FileUpload(
            uploadedFiles: _uploadedFiles,
            onFilesSelected: _onFilesSelected,
            onFileRemoved: _onFileRemoved,
            title: 'Additional Documents (Optional)',
            description: 'Upload any additional farming certificates or documents',
            primaryColor: primaryGreen,
          ),
        ],
      ),
    );
  }

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
                onPressed: _previousPage,
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
              onPressed: _isCurrentStepValid()
                  ? () {
                if (_currentPage < _profileSteps.length - 1) {
                  _nextPage();
                } else {
                  _completeProfile();
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(
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