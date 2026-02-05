import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/location_picker_step.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/features/auth/shared/auth_text_field.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/profile/models/profile_model.dart';
import 'package:agriflock360/features/farmer/profile/repo/profile_repository.dart';
import 'package:agriflock360/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../batch/model/bird_type.dart';

class UpdateProfileScreen extends StatefulWidget {

  const UpdateProfileScreen({
    super.key,
  });

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();

  final SecureStorage _secureStorage = SecureStorage();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetching = true;

  final _birdRepository = BatchHouseRepository();
  bool _isLoadingBirdTypes = false;
  List<BirdType> _birdTypes = [];

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _yearsOfExperienceController = TextEditingController();
  final TextEditingController _chickenHouseCapacityController = TextEditingController();
  final TextEditingController _currentChickensController = TextEditingController();
  final TextEditingController _preferredAgrovetController = TextEditingController();
  final TextEditingController _preferredFeedCompanyController = TextEditingController();

  // Location data
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  // Poultry type selection
  String? _selectedPoultryType;

  @override
  void initState() {
    super.initState();
    _loadBirdTypes();
    _loadProfileData();
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


  Future<void> _loadProfileData() async {
    try {
      final result = await _repository.getProfile();
      switch(result) {
        case Success<ProfileData>(data:final profileData):
          setState(() {
            _populateFormWithData(profileData);
            _isFetching = false;
          });
        case Failure<ProfileData>(message:final error):
          ToastUtil.showError('Failed to load profile: $error');
          _isFetching = false;
      }

    } catch (e) {
      LogUtil.error('Error loading profile: $e');
      ToastUtil.showError('Error loading profile');
      _isFetching = false;
    }
  }

  void _populateFormWithData(ProfileData profileData) {
    _fullNameController.text = profileData.fullName;
    _phoneNumberController.text = profileData.phoneNumber;
    _yearsOfExperienceController.text = profileData.yearsOfExperience.toString();
    _chickenHouseCapacityController.text = profileData.chickenHouseCapacity.toString();
    _currentChickensController.text = profileData.currentNumberOfChickens.toString();
    _preferredAgrovetController.text = profileData.preferredAgrovetName!=null ? profileData.preferredAgrovetName! : '';
    _preferredFeedCompanyController.text = profileData.preferredFeedCompany!=null ? profileData.preferredFeedCompany! : '';

    _selectedPoultryType = profileData.poultryType;
    _selectedAddress = profileData.location.address;
    _latitude = profileData.location.latitude;
    _longitude = profileData.location.longitude;
    _selectedPoultryType=profileData.poultryTypeId;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAddress == null || _latitude == null || _longitude == null) {
      ToastUtil.showError('Please select a location');
      return;
    }

    if (_selectedPoultryType == null) {
      ToastUtil.showError('Please select poultry type');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First, get current user data from secure storage
      final currentUser = await _secureStorage.getUserData();
      if (currentUser == null) {
        ToastUtil.showError('User session expired. Please login again.');
        setState(() { _isLoading = false; });
        apiClient.logout();
        return;
      }

      final request = UpdateProfileRequest(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        location: Location(
          address: _selectedAddress!,
          latitude: _latitude!,
          longitude: _longitude!,
        ),
        yearsOfExperience: int.tryParse(_yearsOfExperienceController.text) ?? 0,
        poultryTypeId: _selectedPoultryType!,
        chickenHouseCapacity: int.tryParse(_chickenHouseCapacityController.text) ?? 0,
        currentNumberOfChickens: int.tryParse(_currentChickensController.text) ?? 0,
        preferredAgrovetName: _preferredAgrovetController.text.trim(),
        preferredFeedCompany: _preferredFeedCompanyController.text.trim(),
      );

      final result = await _repository.updateProfile(request);

      setState(() {
        _isLoading = false;
      });

      switch(result) {
        case Success(data:final profileData):
        // Update user in secure storage with new profile data
          await _updateSecureStorageUser(currentUser, profileData);

          ToastUtil.showSuccess('Profile updated successfully');
          context.pop(); // Go back to previous screen

        case Failure(message:final msg):
          ToastUtil.showError('Failed to update profile: $msg');
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ToastUtil.showError('Error updating profile: ${e.toString()}');
    }
  }

  Future<void> _updateSecureStorageUser(User currentUser, ProfileData profileData) async {
    try {
      // Create updated user with profile data
      final updatedUser = User(
        // Preserve existing user data
        id: currentUser.id,
        email: currentUser.email,
        name: profileData.fullName,
        phoneNumber: profileData.phoneNumber,
        is2faEnabled: currentUser.is2faEnabled,
        emailVerificationExpiresAt: currentUser.emailVerificationExpiresAt,
        refreshTokenExpiresAt: currentUser.refreshTokenExpiresAt,
        passwordResetExpiresAt: currentUser.passwordResetExpiresAt,
        status: currentUser.status,
        avatar: currentUser.avatar,
        googleId: currentUser.googleId,
        appleId: currentUser.appleId,
        oauthProvider: currentUser.oauthProvider,
        roleId: currentUser.roleId,
        role: currentUser.role,
        isActive: currentUser.isActive,
        lockedUntil: currentUser.lockedUntil,
        createdAt: currentUser.createdAt,
        updatedAt: currentUser.updatedAt, // Update timestamp
        deletedAt: currentUser.deletedAt,
        agreedToTerms: currentUser.agreedToTerms,
        agreedToTermsAt: currentUser.agreedToTermsAt,
        firstLogin: currentUser.firstLogin,
        lastLogin: currentUser.lastLogin,

        // Add profile-specific fields (if your User model has these)
        nationalId: currentUser.nationalId, // Keep existing or update if available
        dateOfBirth: currentUser.dateOfBirth,
        gender: currentUser.gender,
        poultryType: profileData.poultryType,
        chickenHouseCapacity: profileData.chickenHouseCapacity,
        yearsOfExperience: profileData.yearsOfExperience,
        currentNumberOfChickens: profileData.currentNumberOfChickens,
        preferredAgrovetName: profileData.preferredAgrovetName,
        preferredFeedCompany: profileData.preferredFeedCompany,
      );

      // Save updated user to secure storage
      await _secureStorage.saveUser(updatedUser);

      LogUtil.info('User data updated in secure storage');

    } catch (e) {
      LogUtil.error('Error updating secure storage: $e');
      // Don't throw error here - profile was updated successfully on server
      // Just log the storage error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Update Profile'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateProfile,
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              AuthTextField(
                controller: _fullNameController,
                labelText: 'Full Name *',
                hintText: 'Enter your full name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AuthTextField(
                controller: _phoneNumberController,
                labelText: 'Phone Number *',
                hintText: 'Enter your phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Farm Information Section
              const Text(
                'Farm Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              AuthTextField(
                controller: _yearsOfExperienceController,
                labelText: 'Years of Experience *',
                hintText: 'Enter years of experience',
                icon: Icons.work,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter years of experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Poultry Type Selection
              const Text(
                'Poultry Type *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

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
              const SizedBox(height: 16),

              AuthTextField(
                controller: _chickenHouseCapacityController,
                labelText: 'Chicken House Capacity *',
                hintText: 'Enter maximum capacity',
                icon: Icons.house,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chicken house capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AuthTextField(
                controller: _currentChickensController,
                labelText: 'Current Number of Chickens *',
                hintText: 'Enter current chicken count',
                icon: Icons.agriculture,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current number of chickens';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Location Section
              const Text(
                'Farm Location *',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                _selectedAddress ?? 'No location selected',
                style: TextStyle(
                  color: _selectedAddress != null
                      ? Colors.black87
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

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
                  Navigator.of(context).pop();
                },
                primaryColor: Colors.green,
              ),
              const SizedBox(height: 24),

              // Preferences Section
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              AuthTextField(
                controller: _preferredAgrovetController,
                labelText: 'Preferred Agrovet',
                hintText: 'Enter preferred agrovet name',
                icon: Icons.local_pharmacy,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                controller: _preferredFeedCompanyController,
                labelText: 'Preferred Feed Company',
                hintText: 'Enter preferred feed company',
                icon: Icons.shopping_basket,
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _yearsOfExperienceController.dispose();
    _chickenHouseCapacityController.dispose();
    _currentChickensController.dispose();
    _preferredAgrovetController.dispose();
    _preferredFeedCompanyController.dispose();
    super.dispose();
  }
}