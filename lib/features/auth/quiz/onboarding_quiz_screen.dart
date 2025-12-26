import 'dart:convert';
import 'package:agriflock360/core/utils/shared_prefs.dart';
import 'package:agriflock360/features/auth/quiz/shared/custom_text_field.dart';
import 'package:agriflock360/features/auth/quiz/shared/education_level_selector.dart';
import 'package:agriflock360/core/widgets/file_upload.dart';
import 'package:agriflock360/features/auth/quiz/shared/gender_selector.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:agriflock360/features/auth/quiz/shared/user_type_selection.dart';
import 'package:agriflock360/core/widgets/location_picker_step.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../../main.dart';



class OnboardingQuestionsScreen extends StatefulWidget {
  final String token;
  const OnboardingQuestionsScreen({super.key,required this.token});

  @override
  State<OnboardingQuestionsScreen> createState() => _OnboardingQuestionsScreenState();
}

class _OnboardingQuestionsScreenState extends State<OnboardingQuestionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

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
    '',
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

  int get _totalPages => 4;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
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

  Future<void> _submitFarmerOnboarding() async {
    setState(() => _isSubmitting = true);

    try {
      final response = await apiClient.post(
        '/auth/farmer-register',
        body: {
          'location': {
            'address': _selectedAddress,
            'latitude': _latitude,
            'longitude': _longitude,
          },
          'years_of_experience': int.tryParse(_farmerAgeController.text) ?? 0,
          'current_number_of_chickens': int.tryParse(_chickenNumberController.text) ?? 0,
        },
          headers: {'Authorization': 'Bearer ${widget.token}'}
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true || data['status'] == 'success') {
          await SharedPrefs.setBool('hasCompletedOnboarding', true);
          ToastUtil.showSuccess("Farm profile created successfully!");

          if (mounted) {
            _goToNextPage(); // Go to congratulations page
          }
        } else {
          final errorMessage = data['message'] ?? 'Failed to create farm profile';
          ToastUtil.showError(errorMessage);
        }
      } else {
        ApiErrorHandler.handle(response);
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitVetOnboarding() async {
    setState(() => _isSubmitting = true);

    try {
      // Prepare fields
      final fields = <String, String>{
        'location': jsonEncode({
          'address': _selectedAddress,
          'latitude': _latitude,
          'longitude': _longitude,
        }),
        'age': _vetAgeController.text,
        'gender': _selectedGender ?? '',
        'years_of_experience': _vetExperienceController.text,
        'professional_summary': _vetProfileController.text,
        'education_level': _selectedEducationLevel ?? '',
      };

      // Prepare files
      final files = <http.MultipartFile>[];

      // Add ID photo
      if (_idPhotoFile != null) {
        files.add(await http.MultipartFile.fromPath(
          'id_photo',
          _idPhotoFile!.path,
        ));
      }

      // Add selfie
      if (_selfieFile != null) {
        files.add(await http.MultipartFile.fromPath(
          'selfie',
          _selfieFile!.path,
        ));
      }

      // Add certificates (main qualification certificates)
      for (var i = 0; i < _uploadedCertificates.length; i++) {
        final file = _uploadedCertificates[i];
        if (file.path != null) {
          files.add(await http.MultipartFile.fromPath(
            'certificates[]', // Using array notation for multiple files
            file.path!,
          ));
        }
      }

      // Add additional documents
      for (var i = 0; i < _uploadedFiles.length; i++) {
        final file = _uploadedFiles[i];
        if (file.path != null) {
          files.add(await http.MultipartFile.fromPath(
            'additional_documents[]', // Using array notation for multiple files
            file.path!,
          ));
        }
      }

      // Submit multipart request
      final streamedResponse = await apiClient.postMultipart(
        '/auth/extension-officer',
        fields: fields,
        files: files,
          headers: {'Authorization': 'Bearer ${widget.token}'}
      );

      // Convert StreamedResponse to Response to read body
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true || data['status'] == 'success') {
          await SharedPrefs.setBool('hasCompletedOnboarding', true);
          ToastUtil.showSuccess("Veterinary profile submitted successfully!");

          if (mounted) {
            _goToNextPage(); // Go to congratulations page
          }
        } else {
          final errorMessage = data['message'] ?? 'Failed to submit veterinary profile';
          ToastUtil.showError(errorMessage);
        }
      } else {
        ApiErrorHandler.handle(response);
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _completeOnboarding() async {
    // Validate based on user type
    if (_selectedUserType == 'farmer') {
      if (_selectedAddress == null || _latitude == null || _longitude == null) {
        ToastUtil.showError("Please select a location");
        return;
      }
      if (_chickenNumberController.text.isEmpty) {
        ToastUtil.showError("Please enter the number of chickens");
        return;
      }
      if (_farmerAgeController.text.isEmpty) {
        ToastUtil.showError("Please enter your years of experience");
        return;
      }

      await _submitFarmerOnboarding();
    } else if (_selectedUserType == 'vet') {
      // Validate vet fields
      if (_selectedAddress == null || _latitude == null || _longitude == null) {
        ToastUtil.showError("Please select a location");
        return;
      }
      if (_vetAgeController.text.isEmpty) {
        ToastUtil.showError("Please enter your age");
        return;
      }
      if (_selectedGender == null) {
        ToastUtil.showError("Please select your gender");
        return;
      }
      if (_vetExperienceController.text.isEmpty) {
        ToastUtil.showError("Please enter your years of experience");
        return;
      }
      if (_selectedEducationLevel == null) {
        ToastUtil.showError("Please select your education level");
        return;
      }
      if (_idPhotoFile == null) {
        ToastUtil.showError("Please upload your ID photo");
        return;
      }
      if (_selfieFile == null) {
        ToastUtil.showError("Please upload your selfie");
        return;
      }
      if (_uploadedCertificates.isEmpty) {
        ToastUtil.showError("Please upload at least one qualification certificate");
        return;
      }

      await _submitVetOnboarding();
    }
  }

  void _finalizeOnboarding() {
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
          onPressed: _isSubmitting ? null : () {
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

                // Page 3: Location Picker
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

          // Qualification Certificates Upload
          FileUpload(
            uploadedFiles: _uploadedCertificates,
            onFilesSelected: _onCertificateFilesSelected,
            onFileRemoved: _onCertificateFileRemoved,
            title: 'Upload Qualifications (PDF/DOC/Images) *Required',
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
            label: 'Age *Required',
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
            label: 'Years of Experience *Required',
            hintText: 'Enter your years of veterinary experience',
            icon: Icons.work,
            keyboardType: TextInputType.number,
            value: '',
          ),
          const SizedBox(height: 30),

          // ID Photo Upload
          PhotoUpload(
            file: _idPhotoFile,
            onFileSelected: (File? file) {
              setState(() {
                _idPhotoFile = file;
              });
            },
            title: 'ID Photo *Required',
            description: 'Upload a clear photo of your government-issued ID',
            primaryColor: primaryGreen,
          ),
          const SizedBox(height: 20),

          // Face Selfie Upload
          PhotoUpload(
            file: _selfieFile,
            onFileSelected: (File? file) {
              setState(() {
                _selfieFile = file;
              });
            },
            title: 'Face Selfie *Required',
            description: 'Upload a recent clear photo of yourself',
            primaryColor: primaryGreen,
          ),
          const SizedBox(height: 20),

          // Additional File Upload Section
          FileUpload(
            uploadedFiles: _uploadedFiles,
            onFilesSelected: _onFilesSelected,
            onFileRemoved: _onFileRemoved,
            title: 'Upload Additional Certifications (Optional)',
            description: 'Upload additional professional certificates if any',
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
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
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
                  const Text(
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
                    _buildSummaryItem('Qualification Certificates', '${_uploadedCertificates.length} files'),
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
          if (_currentPage > 0 && _currentPage < _totalPages - 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _goToPreviousPage,
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
          if (_currentPage > 0 && _currentPage < _totalPages - 1) const SizedBox(width: 12),
          Expanded(
            flex: _currentPage > 0 && _currentPage < _totalPages - 1 ? 1 : 2,
            child: ElevatedButton(
              onPressed: (_canProceedToNext() && !_isSubmitting)
                  ? () {
                if (_currentPage < _totalPages - 2) {
                  _goToNextPage();
                } else if (_currentPage == _totalPages - 2) {
                  // Last data page - submit to API
                  _completeOnboarding();
                } else if (_currentPage == _totalPages - 1) {
                  // Congratulations page - finalize
                  _finalizeOnboarding();
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
              child: _isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                _currentPage == _totalPages - 2
                    ? 'Submit'
                    : _currentPage == _totalPages - 1
                    ? 'Get Started'
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