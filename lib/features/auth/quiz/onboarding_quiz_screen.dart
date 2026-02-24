import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/shared_prefs.dart';
import 'package:agriflock360/features/auth/quiz/repo/onboarding_repository.dart';
import 'package:agriflock360/features/auth/quiz/shared/user_type_selection.dart';
import 'package:agriflock360/features/auth/quiz/steps/farmer_details_step.dart';
import 'package:agriflock360/features/auth/quiz/steps/farmer_bird_type_step.dart';
import 'package:agriflock360/features/auth/quiz/steps/vet_personal_info_step.dart';
import 'package:agriflock360/features/auth/quiz/steps/vet_professional_step.dart';
import 'package:agriflock360/features/auth/quiz/steps/vet_documents_step.dart';
import 'package:agriflock360/features/auth/quiz/steps/congratulations_step.dart';
import 'package:agriflock360/core/widgets/location_picker_step.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/auth/quiz/utils/terms_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class OnboardingQuestionsScreen extends StatefulWidget {
  final String token;
  const OnboardingQuestionsScreen({super.key, required this.token});

  @override
  State<OnboardingQuestionsScreen> createState() => _OnboardingQuestionsScreenState();
}

class _OnboardingQuestionsScreenState extends State<OnboardingQuestionsScreen> {
  final PageController _pageController = PageController();
  final OnboardingRepository _repository = OnboardingRepository();
  final ScrollController _scrollController = ScrollController();
  final currentYear = DateTime.now().year;

  int _currentPage = 0;
  bool _isSubmitting = false;

  // User type selection
  String? _selectedUserType;
  bool _termsAccepted = false;

  // Location data (for both farmer and vet)
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  // Farmer data
  final TextEditingController _farmerExperienceController = TextEditingController();
  final FocusNode _farmerExperienceFocus = FocusNode();
  // Vet data
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _vetExperienceController = TextEditingController();
  final TextEditingController _vetProfileController = TextEditingController();
  final TextEditingController _vetNationalIdController = TextEditingController();
  final TextEditingController _vetFieldOfStudyController = TextEditingController();
  final FocusNode _vetFieldOfStudyFocus = FocusNode();
  final FocusNode _vetNationalIdFocus = FocusNode();
  final FocusNode _vetExperienceFocus = FocusNode();
  final FocusNode _vetProfileFocus = FocusNode();

  // For vet gender and education level
  String? _selectedGender;
  String? _selectedEducationLevel;

  // For uploaded files
  final List<PlatformFile> _uploadedFiles = [];
  final List<PlatformFile> _uploadedCertificates = [];

  // For ID photo and selfie
  File? _idPhotoFile;
  File? _selfieFile;

  // Colors
  static const Color primaryGreen = Colors.green;

  // Step configurations
  // Farmer steps: Role -> Farm Details -> Location -> Congratulations (4 steps)
  // Vet steps: Role -> Personal Info -> Professional -> Documents -> Location -> Congratulations (6 steps)

  int get _totalPages {
    if (_selectedUserType == 'vet') return 7;
    return 5; // farmer or not selected
  }

  List<String> get _pageTitles {
    if (_selectedUserType == 'vet') {
      return [
        'Choose Your Role',
        'Terms & Conditions',
        'Personal Information',
        'Professional Details',
        'Document Verification',
        'Select Location',
        'Congratulations!',
      ];
    }
    return [
      'Choose Your Role',
      'Farm Details',
      'Poultry Details',
      'Select Location',
      'Congratulations!',
    ];
  }

  // Get the index for location page based on user type
  int get _locationPageIndex => _selectedUserType == 'vet' ? 5 : 3;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
    _setupFocusListeners();
  }

  void _onPageChanged() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  void _setupFocusListeners() {


    _farmerExperienceFocus.addListener(() {
      if (_farmerExperienceFocus.hasFocus) {
        _scrollToPosition(100);
      }
    });

    _vetExperienceFocus.addListener(() {
      if (_vetExperienceFocus.hasFocus) {
        _scrollToPosition(200);
      }
    });

    _vetProfileFocus.addListener(() {
      if (_vetProfileFocus.hasFocus) {
        _scrollToPosition(300);
      }
    });
  }

  void _scrollToPosition(double position) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _scrollController.dispose();
    _farmerExperienceController.dispose();
    _farmerExperienceFocus.dispose();
    _dobController.dispose();
    _vetExperienceController.dispose();
    _vetProfileController.dispose();
    _vetExperienceFocus.dispose();
    _vetProfileFocus.dispose();
    _vetNationalIdController.dispose();
    _vetNationalIdFocus.dispose();
    _vetFieldOfStudyController.dispose();
    _vetFieldOfStudyFocus.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      FocusScope.of(context).unfocus();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      FocusScope.of(context).unfocus();
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
      final result = await _repository.submitFarmerOnboarding(
        token: widget.token,
        address: _selectedAddress!,
        latitude: _latitude!,
        longitude: _longitude!,
        yearsOfExperience: int.tryParse(_farmerExperienceController.text) ?? 0,
      );

      if (result['success'] == true) {
        await SharedPrefs.setBool('hasCompletedOnboarding', true);
        ToastUtil.showSuccess(result['message']);

        if (mounted) {
          _goToNextPage();
        }
      } else {
        _handleApiError(result);
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
      LogUtil.warning(DateTime.parse(_dobController.text).toUtc().toIso8601String());
      final result = await _repository.submitVetOnboarding(
        token: widget.token,
        address: _selectedAddress!,
        latitude: _latitude!,
        longitude: _longitude!,
        dateOfBirth: DateTime.parse(_dobController.text).toUtc().toIso8601String(),
        gender: _selectedGender!,
        yearsOfExperience: _vetExperienceController.text,
        professionalSummary: _vetProfileController.text,
        educationLevel: _selectedEducationLevel!,
        idPhotoPath: _idPhotoFile!.path,
        selfiePath: _selfieFile!.path,
        certificates: _uploadedCertificates,
        additionalDocuments: _uploadedFiles.isNotEmpty ? _uploadedFiles : null,
        nationalId: _vetNationalIdController.text,
        fieldOfStudy: _vetFieldOfStudyController.text,
      );

      if (result['success'] == true) {
        await SharedPrefs.setBool('hasCompletedOnboarding', true);
        ToastUtil.showSuccess(result['message']);

        if (mounted) {
          _goToNextPage();
        }
      } else {
        _handleApiError(result);
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleApiError(Map<String, dynamic> result) {
    if (result.containsKey('response')) {
      ApiErrorHandler.handle(result['response']);
    } else if (result.containsKey('error')) {
      ApiErrorHandler.handle(result['error']);
    } else {
      ToastUtil.showError(result['message']);
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedUserType == 'farmer') {
      if (!_validateFarmerFields()) return;
      await _submitFarmerOnboarding();
    } else if (_selectedUserType == 'vet') {
      if (!_validateVetFields()) return;
      await _submitVetOnboarding();
    }
  }

  bool _validateFarmerFields() {
    if (_selectedAddress == null || _latitude == null || _longitude == null) {
      ToastUtil.showError("Please select a location");
      return false;
    }
    if (_farmerExperienceController.text.isEmpty) {
      ToastUtil.showError("Please enter your years of experience");
      return false;
    }
    return true;
  }

  bool _validateVetFields() {
    if (_selectedAddress == null || _latitude == null || _longitude == null) {
      ToastUtil.showError("Please select a location");
      return false;
    }
    if (_dobController.text.isEmpty) {
      ToastUtil.showError("Please select your date of birth");
      return false;
    }
    if (_selectedGender == null) {
      ToastUtil.showError("Please select your gender");
      return false;
    }
    if (_vetExperienceController.text.isEmpty) {
      ToastUtil.showError("Please enter your years of experience");
      return false;
    }
    if (_selectedEducationLevel == null) {
      ToastUtil.showError("Please select your education level");
      return false;
    }
    if (_idPhotoFile == null) {
      ToastUtil.showError("Please upload your ID photo");
      return false;
    }
    if (_selfieFile == null) {
      ToastUtil.showError("Please upload your selfie");
      return false;
    }
    if (_uploadedCertificates.isEmpty) {
      ToastUtil.showError("Please upload at least one qualification certificate");
      return false;
    }
    return true;
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
          icon: const Icon(Icons.verified_user, color: primaryGreen),
          title: const Text('Verification Required'),
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
    if (_selectedUserType == null && _currentPage == 0) {
      return false;
    }

    if (_selectedUserType == 'farmer') {
      return _canProceedFarmer();
    } else if (_selectedUserType == 'vet') {
      return _canProceedVet();
    }

    return _currentPage == 0 && _selectedUserType != null;
  }

  bool _canProceedFarmer() {
    switch (_currentPage) {
      case 0:
        return _selectedUserType != null;
      case 1:
        return true; // Farm details - allow continue, validate on submit
      case 2:
        return _selectedAddress != null && _latitude != null && _longitude != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  bool _canProceedVet() {
    switch (_currentPage) {
      case 0: // Role selection
        return _selectedUserType != null;
      case 1: // Terms & Conditions
        return _termsAccepted;
      case 2: // Personal Info
        return _dobController.text.isNotEmpty &&
            _selectedGender != null &&
            _vetNationalIdController.text.isNotEmpty;
      case 3: // Professional
        return _selectedEducationLevel != null &&
            _vetFieldOfStudyController.text.isNotEmpty &&
            _vetExperienceController.text.isNotEmpty &&
            _vetProfileController.text.isNotEmpty;
      case 4: // Documents
        return _uploadedCertificates.isNotEmpty &&
            _idPhotoFile != null &&
            _selfieFile != null;
      case 5: // Location
        return _selectedAddress != null && _latitude != null && _longitude != null;
      case 6: // Congratulations
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildProgressSection(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _buildPages(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(keyboardVisible),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text(
        _currentPage < _pageTitles.length ? _pageTitles[_currentPage] : '',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      automaticallyImplyLeading: false,
      centerTitle: false,
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          onPressed: () => context.go(AppRoutes.login),
          child: const Text(
            "Cancel Onboarding",
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
          ),
          const SizedBox(height: 12),
          Row(
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
                _currentPage < _pageTitles.length ? _pageTitles[_currentPage] : '',
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages() {
    if (_selectedUserType == 'vet') {
      return [
        _buildRoleSelectionPage(),
        _buildVetTermsPage(),
        _buildVetPersonalInfoPage(),
        _buildVetProfessionalPage(),
        _buildVetDocumentsPage(),
        _buildLocationPage(),
        _buildCongratulationsPage(),
      ];
    }

    // Farmer or no selection yet
    return [
      _buildRoleSelectionPage(),
      _buildFarmerDetailsPage(),
      _buildLocationPage(),
      _buildCongratulationsPage(),
    ];
  }

  Widget _buildRoleSelectionPage() {
    return UserTypeSelection(
      selectedUserType: _selectedUserType,
      onUserTypeSelected: (String userType) async {
        setState(() {
          _selectedUserType = userType;
          _termsAccepted = false;
        });
      },
    );
  }

  Widget _buildFarmerDetailsPage() {
    return FarmerDetailsStep(
      experienceController: _farmerExperienceController,
      experienceFocus: _farmerExperienceFocus,
    );
  }


  Widget _buildVetTermsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gavel, color: primaryGreen, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Terms & Code of Conduct',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 1
          _TermsSection(
            sectionNumber: '1',
            title: 'Role Definition',
            child: const _TermsBodyText(
              'Extension officers using AgriFlock 360 are independent professionals who offer poultry advisory, vaccination, and technical services to farmers through the AgriFlock 360 platform. AgriFlock 360 is a technology marketplace and does not employ extension officers.',
            ),
          ),

          // Section 2
          _TermsSection(
            sectionNumber: '2',
            title: 'Eligibility & Onboarding Requirements',
            child: Column(
              children: const [
                _TermsItem(icon: Icons.check_circle_outline, text: 'Must be an active poultry extension officer (government, NGO, private, or cooperative).'),
                _TermsItem(icon: Icons.check_circle_outline, text: 'Must own a smartphone capable of running the AgriFlock 360 app.'),
                _TermsItem(icon: Icons.check_circle_outline, text: 'Must provide accurate personal and professional information.'),
                _TermsItem(icon: Icons.check_circle_outline, text: 'Must complete basic onboarding and module activation.'),
              ],
            ),
          ),

          // Section 3
          _TermsSection(
            sectionNumber: '3',
            title: 'Professional Conduct',
            child: Column(
              children: const [
                _TermsItem(icon: Icons.verified_user, text: 'Act ethically and professionally at all times.'),
                _TermsItem(icon: Icons.science, text: 'Provide accurate, science-based advice.'),
                _TermsItem(icon: Icons.badge, text: 'Do not misrepresent qualifications.'),
                _TermsItem(icon: Icons.privacy_tip, text: 'Respect farmers\' property, birds, and privacy.'),
              ],
            ),
          ),

          // Section 4
          _TermsSection(
            sectionNumber: '4',
            title: 'Service Delivery Standards',
            child: Column(
              children: const [
                _TermsItem(icon: Icons.fact_check, text: 'Confirm flock details before service.'),
                _TermsItem(icon: Icons.vaccines, text: 'Use approved vaccines and methods.'),
                _TermsItem(icon: Icons.app_registration, text: 'Record all services accurately in the app.'),
                _TermsItem(icon: Icons.health_and_safety, text: 'Follow poultry welfare and biosecurity standards.'),
              ],
            ),
          ),

          // Section 5
          _TermsSection(
            sectionNumber: '5',
            title: 'Payments & Earnings',
            child: Column(
              children: const [
                _TermsItem(icon: Icons.price_change, text: 'Extension officers set or agree on service price within platform guidelines.'),
                _TermsItem(icon: Icons.account_balance_wallet, text: 'Officers earn 80% per completed job.'),
                _TermsItem(icon: Icons.percent, text: 'AgriFlock 360 earns 20% as platform commission.'),
                _TermsItem(icon: Icons.mobile_friendly, text: 'Payments must be mobile money (logged in-app).'),
              ],
            ),
          ),

          // Section 6
          _TermsSection(
            sectionNumber: '6',
            title: 'Ratings & Accountability',
            child: Column(
              children: const [
                _TermsItem(icon: Icons.star_rate, text: 'Farmers rate services after completion.'),
                _TermsItem(icon: Icons.trending_down, text: 'Consistently low ratings may result in reduced visibility, suspension, or removal.'),
                _TermsItem(icon: Icons.report_problem, text: 'False reporting or malpractice leads to immediate suspension.'),
              ],
            ),
          ),

          // Section 7
          _TermsSection(
            sectionNumber: '7',
            title: 'Non-Exclusivity',
            child: const _TermsBodyText(
              'Extension officers are free to work outside AgriFlock 360. However, all services conducted via the platform must be logged for transparency and accountability.',
            ),
          ),

          // Section 8
          _TermsSection(
            sectionNumber: '8',
            title: 'Liability Disclaimer',
            child: const _TermsBodyText(
              'AgriFlock 360 is not responsible for the quality of physical services delivered. Extension officers are solely responsible for services provided, subject to platform monitoring.',
            ),
          ),

          // Section 9
          _TermsSection(
            sectionNumber: '9',
            title: 'Termination',
            child: const _TermsBodyText(
              'AgriFlock 360 reserves the right to suspend or terminate access for violations of these terms or unethical conduct.',
            ),
          ),

          // Section 10
          _TermsSection(
            sectionNumber: '10',
            title: 'Agreement',
            child: const _TermsBodyText(
              'By activating the Extension Module, the officer agrees to abide by these Terms & Code of Conduct.',
            ),
          ),

          const SizedBox(height: 20),

          // Checkbox Agreement
          GestureDetector(
            onTap: () {
              setState(() {
                _termsAccepted = !_termsAccepted;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  activeColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'I have read and agree to the Terms & Code of Conduct for Extension Officers on AgriFlock 360.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (!_termsAccepted)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'You must accept the terms to proceed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVetPersonalInfoPage() {
    return VetPersonalInfoStep(
      dobController: _dobController,
      nationalIdController: _vetNationalIdController,
      nationalIdFocus: _vetNationalIdFocus,
      selectedGender: _selectedGender,
      onGenderSelected: (String gender) {
        setState(() {
          _selectedGender = gender.toLowerCase();
        });
      },
      currentYear: currentYear,
    );
  }

  Widget _buildVetProfessionalPage() {
    return VetProfessionalStep(
      fieldOfStudyController: _vetFieldOfStudyController,
      experienceController: _vetExperienceController,
      profileController: _vetProfileController,
      fieldOfStudyFocus: _vetFieldOfStudyFocus,
      experienceFocus: _vetExperienceFocus,
      profileFocus: _vetProfileFocus,
      selectedEducationLevel: _selectedEducationLevel,
      onEducationLevelSelected: (String level) {
        setState(() {
          _selectedEducationLevel = level;
        });
      },
    );
  }

  Widget _buildVetDocumentsPage() {
    return VetDocumentsStep(
      uploadedCertificates: _uploadedCertificates,
      uploadedFiles: _uploadedFiles,
      idPhotoFile: _idPhotoFile,
      selfieFile: _selfieFile,
      onCertificatesSelected: _onCertificateFilesSelected,
      onCertificateRemoved: _onCertificateFileRemoved,
      onFilesSelected: _onFilesSelected,
      onFileRemoved: _onFileRemoved,
      onIdPhotoSelected: (File? file) {
        setState(() {
          _idPhotoFile = file;
        });
      },
      onSelfieSelected: (File? file) {
        setState(() {
          _selfieFile = file;
        });
      },
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      child: LocationPickerStep(
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
      ),
    );
  }

  Widget _buildCongratulationsPage() {
    return CongratulationsStep(
      selectedUserType: _selectedUserType,
      selectedAddress: _selectedAddress,
      farmerExperience: _farmerExperienceController.text,
      educationLevel: _selectedEducationLevel,
      professionalSummary: _vetProfileController.text,
      dateOfBirth: _dobController.text,
      gender: _selectedGender,
      vetExperience: _vetExperienceController.text,
      idPhotoFile: _idPhotoFile,
      selfieFile: _selfieFile,
      certificates: _uploadedCertificates,
      additionalDocuments: _uploadedFiles,
    );
  }

  Widget _buildBottomNavigation(bool keyboardVisible) {
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == _totalPages - 1;
    final isLocationPage = _currentPage == _locationPageIndex;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: keyboardVisible ? 20 : MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstPage && !isLastPage)
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
          if (!isFirstPage && !isLastPage) const SizedBox(width: 12),
          Expanded(
            flex: (!isFirstPage && !isLastPage) ? 1 : 2,
            child: ElevatedButton(
              onPressed: (_canProceedToNext() && !_isSubmitting)
                  ? () {
                      if (isLastPage) {
                        _finalizeOnboarding();
                      } else if (isLocationPage) {
                        _completeOnboarding();
                      } else {
                        _goToNextPage();
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
                      isLocationPage
                          ? 'Submit'
                          : isLastPage
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

class _TermsSection extends StatelessWidget {
  final String sectionNumber;
  final String title;
  final Widget child;

  const _TermsSection({
    required this.sectionNumber,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sectionNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TermsBodyText extends StatelessWidget {
  final String text;
  const _TermsBodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black54,
        height: 1.5,
      ),
    );
  }
}

class _TermsItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TermsItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.green.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}