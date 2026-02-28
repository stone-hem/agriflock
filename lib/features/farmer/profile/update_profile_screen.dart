import 'package:agriflock/core/model/user_model.dart';
import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:agriflock/core/widgets/location_picker_step.dart';
import 'package:agriflock/core/widgets/reusable_dropdown.dart';
import 'package:agriflock/features/auth/shared/auth_text_field.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock/features/farmer/profile/models/profile_model.dart';
import 'package:agriflock/features/farmer/profile/repo/profile_repository.dart';
import 'package:agriflock/main.dart';
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

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _yearsOfExperienceController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadProfileData();
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
    _yearsOfExperienceController.text = profileData.yearsOfExperience.toString();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
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

      final request = {
        'full_name': _fullNameController.text.trim(),
        'years_of_experience': int.tryParse(_yearsOfExperienceController.text) ?? 0,
      };

      final result = await _repository.updateProfile(request);

      setState(() {
        _isLoading = false;
      });

      switch(result) {
        case Success():
        // Update user in secure storage with new profile data
          await _updateSecureStorageUser(currentUser);

          ToastUtil.showSuccess('Profile updated successfully');
          if(!mounted) return;
          context.pop(); // Go back to previous screen

        case Failure(message:final msg):
          ToastUtil.showError('Failed to update profile: $msg');
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ToastUtil.showError('Error updating profile: ${e.toString()}');
    }
  }

  Future<void> _updateSecureStorageUser(User currentUser) async {
    try {
      // Create updated user with profile data
      final updatedUser = User(
        // Preserve existing user data
        id: currentUser.id,
        email: currentUser.email,
        name: _fullNameController.text.trim(),
        phoneNumber: currentUser.phoneNumber,
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
        poultryType: currentUser.poultryType,
        chickenHouseCapacity: currentUser.chickenHouseCapacity,
        yearsOfExperience:  int.tryParse(_yearsOfExperienceController.text) ?? 0,
        currentNumberOfChickens: currentUser.currentNumberOfChickens,
        preferredAgrovetName: currentUser.preferredAgrovetName,
        preferredFeedCompany: currentUser.preferredFeedCompany,
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
                'My Username',
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
    _yearsOfExperienceController.dispose();
    super.dispose();
  }
}