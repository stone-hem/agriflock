import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/features/farmer/profile/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/auth/quiz/shared/gender_selector.dart';
import '../../../main.dart';

class CompleteProfileScreen extends StatefulWidget {
  final ProfileData? profileData;
  const CompleteProfileScreen({super.key, this.profileData});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final SecureStorage _secureStorage = SecureStorage();

  User? _user; // Make it nullable

  // Color scheme - matching onboarding
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Farmer Profile Data - Only Personal Information fields
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _preferredAgrovetController = TextEditingController();

  // Feed Company Dropdown
  String? _selectedFeedCompany;
  final TextEditingController _otherFeedCompanyController = TextEditingController();
  bool _showOtherFeedCompany = false;

  // Hatchery Dropdown (using same list)
  String? _selectedHatcheryCompany;
  final TextEditingController _otherHatcheryController = TextEditingController();
  bool _showOtherHatchery = false;

  // Preferred Aggregator - Multi-select checkboxes
  final Map<String, bool> _aggregatorSelections = {
    'Hotel/Restaurant': false,
    'Supermarkets': false,
    'Institutions': false,
    'Individuals(Agents)': false,
    'Others': false,
  };
  final TextEditingController _otherAggregatorController = TextEditingController();
  bool _showOtherAggregator = false;

  // Dropdown options
  static const List<String> _feedCompanyOptions = [
    'Kenchic',
    'Suguna',
    'Isinya',
    'Kenbrid',
    'Uzima Chicken',
    'Kukuchic',
    'Others',
  ];

  // Loading state
  bool _isLoading = false;
  bool _isLoadingUser = true; // Start as true

  // Focus nodes for text fields
  final FocusNode _idNumberFocus = FocusNode();
  final FocusNode _preferredAgrovetFocus = FocusNode();
  final FocusNode _otherFeedCompanyFocus = FocusNode();
  final FocusNode _otherHatcheryFocus = FocusNode();
  final FocusNode _otherAggregatorFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Add listeners to update UI when fields change
    _idNumberController.addListener(_updateValidationState);
    _dobController.addListener(_updateValidationState);
    _preferredAgrovetController.addListener(_updateValidationState);
    _otherFeedCompanyController.addListener(_updateValidationState);
    _otherHatcheryController.addListener(_updateValidationState);
    _otherAggregatorController.addListener(_updateValidationState);

    // Initialize existing profile data
    if (widget.profileData != null) {
      _idNumberController.text = widget.profileData!.nationalId ?? '';
      _dobController.text = widget.profileData!.dateOfBirth ?? '';
      _selectedGender = widget.profileData!.gender ?? '';
      _preferredAgrovetController.text = widget.profileData!.preferredAgrovetName ?? '';

      // Parse existing feed company
      final existingFeedCompany = widget.profileData!.preferredFeedCompany ?? '';
      if (_feedCompanyOptions.contains(existingFeedCompany)) {
        _selectedFeedCompany = existingFeedCompany;
        _showOtherFeedCompany = false;
      } else if (existingFeedCompany.isNotEmpty) {
        _selectedFeedCompany = 'Others';
        _showOtherFeedCompany = true;
        _otherFeedCompanyController.text = existingFeedCompany;
      }

      // Parse existing hatchery company (using same list)
      final existingHatchery = widget.profileData!.preferredChicksCompany ?? '';
      if (_feedCompanyOptions.contains(existingHatchery)) {
        _selectedHatcheryCompany = existingHatchery;
        _showOtherHatchery = false;
      } else if (existingHatchery.isNotEmpty) {
        _selectedHatcheryCompany = 'Others';
        _showOtherHatchery = true;
        _otherHatcheryController.text = existingHatchery;
      }

      // Parse existing aggregator
      final existingAggregator = widget.profileData!.preferredOfftakerAgent ?? '';
      if (existingAggregator.isNotEmpty) {
        final selections = existingAggregator.split(',').map((e) => e.trim()).toList();
        setState(() {
          for (var selection in selections) {
            if (_aggregatorSelections.containsKey(selection)) {
              _aggregatorSelections[selection] = true;
              if (selection == 'Others') {
                _showOtherAggregator = true;
              }
            } else {
              // If it's not in the predefined list, treat as custom "Others"
              _aggregatorSelections['Others'] = true;
              _showOtherAggregator = true;
              _otherAggregatorController.text = selection;
            }
          }
        });
      }
    }
  }

  void _updateValidationState() {
    // Trigger a rebuild to update button state
    setState(() {});
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _dobController.dispose();
    _idNumberFocus.dispose();
    _preferredAgrovetFocus.dispose();
    _otherFeedCompanyFocus.dispose();
    _otherHatcheryFocus.dispose();
    _otherAggregatorFocus.dispose();
    _preferredAgrovetController.dispose();
    _otherFeedCompanyController.dispose();
    _otherHatcheryController.dispose();
    _otherAggregatorController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    // Check required fields
    if (_idNumberController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty ||
        _selectedGender == null ||
        _preferredAgrovetController.text.trim().isEmpty ||
        _selectedFeedCompany == null ||
        _selectedHatcheryCompany == null) {
      return false;
    }

    // Check if "Others" is selected and text is entered for feed company
    if (_selectedFeedCompany == 'Others' && _otherFeedCompanyController.text.trim().isEmpty) {
      return false;
    }

    // Check if "Others" is selected and text is entered for hatchery
    if (_selectedHatcheryCompany == 'Others' && _otherHatcheryController.text.trim().isEmpty) {
      return false;
    }

    // Check if at least one aggregator is selected
    bool hasAggregatorSelected = _aggregatorSelections.values.any((selected) => selected);
    if (!hasAggregatorSelected) {
      return false;
    }

    // Check if "Others" is selected and text is entered
    if (_aggregatorSelections['Others'] == true && _otherAggregatorController.text.trim().isEmpty) {
      return false;
    }

    return true;
  }

  String _getFeedCompanyValue() {
    if (_selectedFeedCompany == 'Others') {
      return _otherFeedCompanyController.text.trim();
    }
    return _selectedFeedCompany ?? '';
  }

  String _getHatcheryValue() {
    if (_selectedHatcheryCompany == 'Others') {
      return _otherHatcheryController.text.trim();
    }
    return _selectedHatcheryCompany ?? '';
  }

  String _getAggregatorValue() {
    List<String> selected = [];
    _aggregatorSelections.forEach((key, value) {
      if (value && key != 'Others') {
        selected.add(key);
      }
    });

    if (_aggregatorSelections['Others'] == true && _otherAggregatorController.text.trim().isNotEmpty) {
      selected.add(_otherAggregatorController.text.trim());
    }

    return selected.join(', ');
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare profile data
      final profileData = {
        'national_id': _idNumberController.text.trim(),
        'date_of_birth': DateTime.parse(_dobController.text).toUtc().toIso8601String(),
        'gender': _selectedGender,
        'preferred_agrovet_name': _preferredAgrovetController.text.trim(),
        'preferred_feed_company': _getFeedCompanyValue(),
        'preferred_chicks_company': _getHatcheryValue(),
        'preferred_offtaker_agent': _getAggregatorValue(),
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
        final updatedUser = _user?.copyWith(
          nationalId: _idNumberController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          gender: _selectedGender,
          preferredAgrovetName: _preferredAgrovetController.text.trim(),
          preferredFeedCompany: _getFeedCompanyValue(),
        );


        // Save updated user to secure storage
        await _secureStorage.saveUser(updatedUser!);

        ToastUtil.showSuccess(
          'Profile completed successfully!',
        );

        if (context.mounted) {
          context.pop(true);
        }
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

  Widget _buildAggregatorCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred aggregator (market) *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              ..._aggregatorSelections.entries.map((entry) {
                return Column(
                  children: [
                    CheckboxListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      activeColor: primaryGreen,
                      onChanged: (bool? value) {
                        setState(() {
                          _aggregatorSelections[entry.key] = value ?? false;
                          if (entry.key == 'Others') {
                            _showOtherAggregator = value ?? false;
                            if (!_showOtherAggregator) {
                              _otherAggregatorController.clear();
                            }
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    if (entry.key == 'Others' && entry.value)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 12, 12),
                        child: TextField(
                          controller: _otherAggregatorController,
                          focusNode: _otherAggregatorFocus,
                          decoration: InputDecoration(
                            hintText: 'Please specify other aggregator',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: primaryGreen, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    if (entry.key != _aggregatorSelections.entries.last.key)
                      const Divider(height: 0, indent: 40),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
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
          title: const Text(
            'Complete Profile',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide your personal details to complete your profile',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),

              // Personal Information Section
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 16),

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

              // Preferred Agrovet
              ReusableInput(
                controller: _preferredAgrovetController,
                focusNode: _preferredAgrovetFocus,
                topLabel: 'Preferred Nearest Agrovet *',
                labelText: 'Preferred Nearest Agrovet *',
                hintText: 'Enter your preferred nearest agrovet',
                icon: Icons.store,
              ),
              const SizedBox(height: 20),

              // Preferred Feed Company - Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferred Feed Company *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ReusableDropdown<String>(
                    value: _selectedFeedCompany,
                    hintText: 'Select feed company',
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFeedCompany = newValue;
                        _showOtherFeedCompany = newValue == 'Others';
                        if (!_showOtherFeedCompany) {
                          _otherFeedCompanyController.clear();
                        }
                      });
                    },
                    items: _feedCompanyOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  if (_showOtherFeedCompany) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherFeedCompanyController,
                      focusNode: _otherFeedCompanyFocus,
                      decoration: InputDecoration(
                        hintText: 'Please specify feed company',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryGreen, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Preferred Hatchery Company - Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableDropdown<String>(
                    value: _selectedHatcheryCompany,
                    hintText: 'Select hatchery company',
                    topLabel: 'Preferred Hatchery Company *',
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedHatcheryCompany = newValue;
                        _showOtherHatchery = newValue == 'Others';
                        if (!_showOtherHatchery) {
                          _otherHatcheryController.clear();
                        }
                      });
                    },
                    items: _feedCompanyOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  if (_showOtherHatchery) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherHatcheryController,
                      focusNode: _otherHatcheryFocus,
                      decoration: InputDecoration(
                        hintText: 'Please specify hatchery company',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryGreen, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Preferred Aggregator - Multi-select Checkboxes
              _buildAggregatorCheckboxes(),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isFormValid()) ? null : _completeProfile,
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
                      : const Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}