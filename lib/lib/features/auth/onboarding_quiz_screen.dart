import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

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

  // Farmer data
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _farmerAgeController = TextEditingController();

  // Vet data
  final TextEditingController _qualificationsController = TextEditingController();
  List<PlatformFile> _uploadedFiles = [];

  // Single green color scheme throughout
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  final List<String> _pageTitles = [
    'Choose Your Role',
    _getSecondPageTitle(''), // Will be updated dynamically
    'Congratulations!'
  ];

  static String _getSecondPageTitle(String? userType) {
    if (userType == 'farmer') {
      return 'Farm Details';
    } else if (userType == 'vet') {
      return 'Professional Information';
    }
    return 'Additional Information';
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
        // Update page titles when page changes
        if (_currentPage == 1) {
          _pageTitles[1] = _getSecondPageTitle(_selectedUserType);
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _farmNameController.dispose();
    _farmerAgeController.dispose();
    _qualificationsController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 2) {
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

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _uploadedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  void _completeOnboarding() {
    if (_selectedUserType == 'farmer') {
      // Farmer flow - go to login
      context.go('/login');
    } else if (_selectedUserType == 'vet') {
      // Vet flow - show verification message and go to login
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
          return _farmNameController.text.isNotEmpty &&
              _farmerAgeController.text.isNotEmpty;
        } else if (_selectedUserType == 'vet') {
          return _qualificationsController.text.isNotEmpty;
        }
        return false;
      case 2:
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
              value: (_currentPage + 1) / 3,
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
                  'Step ${_currentPage + 1} of 3',
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
                _buildUserTypeSelectionPage(),

                // Page 2: Dynamic based on user type
                _buildDetailsPage(),

                // Page 3: Congratulations
                _buildCongratulationsPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildUserTypeSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How will you be using our platform?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your role to customize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),

          // Farmer Option
          _buildRoleCard(
            icon: Icons.agriculture,
            title: 'Farmer',
            subtitle: 'Manage your poultry farm and track your flock',
            isSelected: _selectedUserType == 'farmer',
            onTap: () {
              setState(() {
                _selectedUserType = 'farmer';
              });
            },
          ),
          const SizedBox(height: 20),

          // Vet Doctor Option
          _buildRoleCard(
            icon: Icons.medical_services,
            title: 'Veterinary Doctor',
            subtitle: 'Provide professional services and consultations',
            isSelected: _selectedUserType == 'vet',
            onTap: () {
              setState(() {
                _selectedUserType = 'vet';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? primaryGreen : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreen.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? primaryGreen : Colors.grey.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primaryGreen : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: primaryGreen,
                ),
            ],
          ),
        ),
      ),
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

          // Farm Name
          _buildTextField(
            controller: _farmNameController,
            label: 'Farm Name',
            hintText: 'Enter your farm name',
            icon: Icons.business,
          ),
          const SizedBox(height: 20),

          // Age
          _buildTextField(
            controller: _farmerAgeController,
            label: 'Your Age',
            hintText: 'Enter your age',
            icon: Icons.person,
            keyboardType: TextInputType.number,
          ),
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
            'Please provide your qualifications for verification',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),

          // Qualifications
          _buildTextField(
            controller: _qualificationsController,
            label: 'Qualifications',
            hintText: 'e.g., DVM, MVSc, etc.',
            icon: Icons.school,
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // File Upload Section
          const Text(
            'Upload Certifications (PDF/DOC)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your professional certificates for verification',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),

          // Upload Button
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: InkWell(
              onTap: _pickFiles,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload files',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'PDF, DOC files supported',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Uploaded Files List
          if (_uploadedFiles.isNotEmpty) ...[
            const Text(
              'Uploaded Files:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ..._uploadedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return _buildUploadedFileItem(file, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon, color: primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Update UI to enable/disable buttons
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedFileItem(PlatformFile file, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(
          file.name,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${(file.size / 1024).toStringAsFixed(1)} KB',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeFile(index),
        ),
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
                  _buildSummaryItem('Role', _selectedUserType == 'farmer' ? 'Farmer' : 'Veterinary Doctor'),
                  if (isFarmer) ...[
                    _buildSummaryItem('Farm Name', _farmNameController.text),
                    _buildSummaryItem('Age', _farmerAgeController.text),
                  ] else ...[
                    _buildSummaryItem('Qualifications', _qualificationsController.text),
                    _buildSummaryItem('Documents Uploaded', '${_uploadedFiles.length} files'),
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
            width: 120,
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
              value,
              style: const TextStyle(color: Colors.black54),
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
              onPressed: _canProceedToNext() ? () {
                if (_currentPage < 2) {
                  _goToNextPage();
                } else {
                  _completeOnboarding();
                }
              } : null,
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
                _currentPage == 2
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