import 'package:agriflock360/features/auth/quiz/shared/custom_text_field.dart';
import 'package:agriflock360/features/auth/quiz/shared/education_level_selector.dart';
import 'package:agriflock360/features/auth/quiz/shared/file_upload.dart';
import 'package:agriflock360/features/auth/quiz/shared/gender_selector.dart';
import 'package:agriflock360/features/auth/quiz/shared/photo_upload.dart';
import 'package:agriflock360/features/auth/quiz/shared/user_type_selection.dart';
import 'package:agriflock360/features/auth/quiz/shared/location_picker_step.dart'; // Import the new component
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class OnboardingQuestionsScreen extends StatefulWidget {
  const OnboardingQuestionsScreen({super.key});

  @override
  State<OnboardingQuestionsScreen> createState() => _OnboardingQuestionsScreenState();
}

class _OnboardingQuestionsScreenState extends State<OnboardingQuestionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User type selection
  String? _selectedUserType;

  // Location data (for both farmer and vet)
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  // Farmer data
  final TextEditingController _chickenNumberController = TextEditingController();
  final TextEditingController _farmerAgeController = TextEditingController();

  // Vet data
  final TextEditingController _vetAgeController = TextEditingController();
  final TextEditingController _vetExperienceController = TextEditingController();
  final TextEditingController _vetProfileController = TextEditingController();

  // For vet gender and education level
  String? _selectedGender;
  String? _selectedEducationLevel;

  // For uploaded files
  final List<PlatformFile> _uploadedFiles = [];
  final List<PlatformFile> _uploadedCertificates = [];

  // For ID photo and selfie
  File? _idPhotoFile;
  File? _selfieFile;

  // Single green color scheme throughout
  static const Color primaryGreen = Colors.green;
  static const Color backgroundColor = Color(0xFFF8F9FA);

  final List<String> _pageTitles = [
    'Choose Your Role',
    '', // Will be updated dynamically
    'Select Location',
    'Congratulations!'
  ];

  String _getDetailsPageTitle(String? userType) {
    if (userType == 'farmer') {
      return 'Farm Details';
    } else if (userType == 'vet') {
      return 'Professional Information';
    }
    return 'Additional Information';
  }

  int get _totalPages => 4; // Now we have 4 pages instead of 3

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
        // Update page titles when page changes
        if (_currentPage == 1) {
          _pageTitles[1] = _getDetailsPageTitle(_selectedUserType);
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chickenNumberController.dispose();
    _farmerAgeController.dispose();
    _vetAgeController.dispose();
    _vetExperienceController.dispose();
    _vetProfileController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onFilesSelected(List<PlatformFile> files) {
    setState(() {
      _uploadedFiles.addAll(files);
    });
  }

  void _onCertificateFilesSelected(List<PlatformFile> files) {
    setState(() {
      _uploadedCertificates.addAll(files);
    });
  }

  void _onFileRemoved(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  void _onCertificateFileRemoved(int index) {
    setState(() {
      _uploadedCertificates.removeAt(index);
    });
  }

  void _completeOnboarding() {
    if (_selectedUserType == 'farmer') {
      context.go('/login');
    } else if (_selectedUserType == 'vet') {
      _showVerificationMessage();
    }
  }

  void _showVerificationMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.verified_user, color: primaryGreen),
              SizedBox(width: 8),
              Text('Verification Required'),
            ],
          ),
          content: const Text(
            'Your details have been sent to the admin for verification. '
                'You will be notified once your account is approved. '
                'You can now login with your credentials.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              child: const Text(
                'Continue to Login',
                style: TextStyle(color: primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _canProceedToNext() {
    switch (_currentPage) {
      case 0:
        return _selectedUserType != null;
      case 1:
        if (_selectedUserType == 'farmer') {
          return true;
        } else if (_selectedUserType == 'vet') {
          return _vetAgeController.text.isNotEmpty;
        }
        return true;
      case 2:
      // Location page - must have location selected
        return _selectedAddress != null &&
            _latitude != null &&
            _longitude != null;
      case 3:
        return true;
      default:
        return false;
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
          onPressed: () {
            if (_currentPage > 0) {
              _goToPreviousPage();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _pageTitles[_currentPage],
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
              value: (_currentPage + 1) / _totalPages,
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
                  'Step ${_currentPage + 1} of $_totalPages',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _pageTitles[_currentPage],
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

          // PageView content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Page 1: User Type Selection
                UserTypeSelection(
                  selectedUserType: _selectedUserType,
                  onUserTypeSelected: (String userType) {
                    setState(() {
                      _selectedUserType = userType;
                    });
                  },
                ),

                // Page 2: Dynamic based on user type
                _buildDetailsPage(),

                // Page 3: Location Picker (NEW)
                LocationPickerStep(
                  selectedAddress: _selectedAddress,
                  latitude: _latitude,
                  longitude: _longitude,
                  onLocationSelected: (String address, double lat, double lng) {
                    setState(() {
                      _selectedAddress = address;
                      _latitude = lat;
                      _longitude = lng;
                    });
                  },
                  primaryColor: primaryGreen,
                ),

                // Page 4: Congratulations
                _buildCongratulationsPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildDetailsPage() {
    if (_selectedUserType == 'farmer') {
      return _buildFarmerDetailsPage();
    } else if (_selectedUserType == 'vet') {
      return _buildVetDetailsPage();
    } else {
      return const Center(
        child: Text('Please select a user type'),
      );
    }
  }

  Widget _buildFarmerDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your farm',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This information helps us personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),

          CustomTextField(
            label: 'Current number of chickens',
            hintText: 'Enter the number of chickens you rear',
            icon: Icons.numbers,
            keyboardType: TextInputType.number,
            controller: _chickenNumberController,
            value: '',
          ),

          const SizedBox(height: 20),
          CustomTextField(
            label: 'Years of experience',
            hintText: 'Enter your years of experience in poultry farming',
            icon: Icons.person,
            keyboardType: TextInputType.number,
            controller: _farmerAgeController,
            value: '',
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildVetDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please provide your details for verification',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),

          // Education Level Radio Buttons
          EducationLevelSelector(
            selectedEducationLevel: _selectedEducationLevel,
            onEducationLevelSelected: (String level) {
              setState(() {
                _selectedEducationLevel = level;
              });
            },
          ),
          const SizedBox(height: 30),
          // Additional File Upload Section using reusable component
          FileUpload(
            uploadedFiles: _uploadedCertificates,
            onFilesSelected: _onCertificateFilesSelected,
            onFileRemoved: _onCertificateFileRemoved,
            title: 'Upload Certifications (PDF/DOC/Images) for you qualification',
            description: 'Upload your professional certificate(s)',
            primaryColor: primaryGreen,
          ),
          const SizedBox(height: 30),

          // Professional Profile
          CustomTextField(
            controller: _vetProfileController,
            label: 'Professional Summary (max 100 characters)',
            hintText: 'Brief description of your expertise and qualifications',
            icon: Icons.description,
            maxLines: 3,
            maxLength: 100,
            value: '',
          ),
          const SizedBox(height: 20),

          // Age
          CustomTextField(
            controller: _vetAgeController,
            label: 'Age',
            hintText: 'Enter your age',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            value: '',
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

          // Years of Experience
          CustomTextField(
            controller: _vetExperienceController,
            label: 'Years of Experience',
            hintText: 'Enter your years of veterinary experience',
            icon: Icons.work,
            keyboardType: TextInputType.number,
            value: '',
          ),
          const SizedBox(height: 30),

          // ID Photo Upload using reusable component
          PhotoUpload(
            file: _idPhotoFile,
            onFileSelected: (File? file) {
              setState(() {
                _idPhotoFile = file;
              });
            },
            title: 'ID Photo',
            description: 'Upload a clear photo of your government-issued ID',
            primaryColor: primaryGreen,
          ),
          const SizedBox(height: 20),

          // Face Selfie Upload using reusable component
          PhotoUpload(
            file: _selfieFile,
            onFileSelected: (File? file) {
              setState(() {
                _selfieFile = file;
              });
            },
            title: 'Face Selfie',
            description: 'Upload a recent clear photo of yourself',
            primaryColor: primaryGreen,
          ),
          const SizedBox(height: 20),

          // Additional File Upload Section using reusable component
          FileUpload(
            uploadedFiles: _uploadedFiles,
            onFilesSelected: _onFilesSelected,
            onFileRemoved: _onFileRemoved,
            title: 'Upload Additional Certifications (PDF/DOC/Images) If Any',
            description: 'Upload your professional certificates and documents if any',
            primaryColor: primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildCongratulationsPage() {
    final isFarmer = _selectedUserType == 'farmer';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 60,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            isFarmer
                ? 'Your farm account has been created successfully! '
                'You can now start managing your poultry farm.'
                : 'Your veterinary account registration is complete! '
                'Your documents have been submitted for admin verification.',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Summary Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem('Role', isFarmer ? 'Farmer' : 'Veterinary Doctor'),
                  _buildSummaryItem('Location', _selectedAddress ?? 'Not provided'),
                  if (_latitude != null && _longitude != null)
                    _buildSummaryItem(
                      'Coordinates',
                      'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
                    ),
                  if (isFarmer) ...[
                    _buildSummaryItem('Chicken Number', _chickenNumberController.text),
                    _buildSummaryItem('Experience', '${_farmerAgeController.text} years'),
                  ] else ...[
                    _buildSummaryItem('Highest Education', _selectedEducationLevel ?? 'Not provided'),
                    _buildSummaryItem('Professional Summary', _vetProfileController.text),
                    _buildSummaryItem('Age', _vetAgeController.text),
                    _buildSummaryItem('Gender', _selectedGender?.toUpperCase() ?? ''),
                    _buildSummaryItem('Experience', '${_vetExperienceController.text} years'),
                    _buildSummaryItem('ID Photo', _idPhotoFile != null ? 'Uploaded' : 'Not uploaded'),
                    _buildSummaryItem('Selfie', _selfieFile != null ? 'Uploaded' : 'Not uploaded'),
                    _buildSummaryItem('Additional Documents', '${_uploadedFiles.length} files'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black54,
              ),
            ),
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
                onPressed: _goToPreviousPage,
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
              onPressed: _canProceedToNext()
                  ? () {
                if (_currentPage < _totalPages - 1) {
                  _goToNextPage();
                } else {
                  _completeOnboarding();
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
                _currentPage == _totalPages - 1 ? 'Get Started' : 'Continue',
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