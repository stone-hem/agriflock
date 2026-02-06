import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/features/farmer/profile/models/profile_model.dart';
import 'package:agriflock360/features/farmer/profile/repo/profile_repository.dart';
import 'package:agriflock360/features/shared/widgets/profile_menu_item.dart';
import 'package:agriflock360/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SecureStorage _secureStorage = SecureStorage();
  final ImagePicker _imagePicker = ImagePicker();
  final ProfileRepository _repository = ProfileRepository();


  // User data variables - Now using User object
  late User _user;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _user = User(
      id: '',
      email: 'Loading...',
      name: 'Loading...',
      phoneNumber: null,
      is2faEnabled: false,
      status: '',
      oauthProvider: '',
      roleId: '',
      role: Role(
        id: '',
        name: 'Loading...',
        description: '',
        isSystemRole: false,
        isActive: true,
        createdAt: '',
        updatedAt: '',
      ),
      isActive: true,
      createdAt: '',
      updatedAt: '',
      agreedToTerms: false,
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get user data from secure storage as User object
      final userData = await _secureStorage.getUserData();

      if (userData != null && mounted) {
        setState(() {
          _user = userData;
          _isLoading = false;
        });
      } else {
        apiClient.logout();
      }
    } catch (e) {
      apiClient.logout();
    }
  }

  Future<void> _uploadAvatar() async {
    // Show image picker options
    final option = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Avatar', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _deleteAvatar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (option == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: option,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        await _uploadAvatarFile(File(pickedFile.path));
      }
    } catch (e) {
      ToastUtil.showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _uploadAvatarFile(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // Changed from 'file' to 'avatar' to match API expectation
        imageFile.path,
        contentType: http.MediaType('image', 'jpeg'), // Adjust based on file type
      );

      // Will Replace with your actual repository/service call
      // Example: final result = await userRepository.uploadAvatar(imageFile);

      // For now, using the ApiClient directly
      final streamedResponse = await apiClient.putMultipartSingleFile(
        '/users/profile/avatar',
        file: multipartFile,
      );

      // Convert StreamedResponse to Response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse the response
        final responseData = jsonDecode(response.body);

        LogUtil.error(responseData);

        // Update local user data with new avatar URL
        final newAvatarUrl = responseData['avatar_url'] ??
            responseData['data']?['avatar_url'] ;

        if (newAvatarUrl != null) {
          // Create updated user object
          final updatedUser = _user.copyWith(avatar: newAvatarUrl);

          // Save to secure storage
          await _secureStorage.saveUser(updatedUser);

          // Update UI
          if (mounted) {
            setState(() {
              _user = updatedUser;
            });
          }

          ToastUtil.showSuccess('Avatar updated successfully!');
        } else {
          // Try to fetch updated user profile
          await _refreshUserProfile();
          ToastUtil.showSuccess('Avatar updated successfully!');
        }
      } else {
        // Handle error
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Failed to upload avatar (Status: ${response.statusCode})';
        ToastUtil.showError(errorMessage);
      }
    } catch (e) {
      ToastUtil.showError('Failed to upload avatar: ${e.toString()}');
      print('Upload error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _refreshUserProfile() async {
    try {
      // Fetch updated user profile
      final result = await _repository.getProfile();
      switch(result) {
        case Success<ProfileData>(data:final profileData):
        // Create updated user object
          final updatedUser = _user.copyWith(avatar: profileData.avatar);

          // Save to secure storage
          await _secureStorage.saveUser(updatedUser);

          // Update UI
          if (mounted) {
            setState(() {
              _user = updatedUser;
            });
          }
        case Failure<ProfileData>(message:final error):
          ToastUtil.showError('Profile refresh failed');
      }

    } catch (e) {
      print('Error refreshing user profile: $e');
    }
  }

  Future<void> _deleteAvatar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Avatar'),
        content: const Text('Are you sure you want to remove your avatar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Use the repository/API service method
      // Example: final result = await userRepository.deleteAvatar();

      // For now, using the ApiClient directly
      final response = await apiClient.delete('/users/profile/avatar');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Create updated user object without avatar
        final updatedUser = _user.copyWith(avatar: null);

        // Update secure storage
        await _secureStorage.saveUser(updatedUser);

        // Update UI
        if (mounted) {
          setState(() {
            _user = updatedUser;
          });
        }

        ToastUtil.showSuccess('Avatar removed successfully!');
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Failed to remove avatar (Status: ${response.statusCode})';
        ToastUtil.showError(errorMessage);
      }
    } catch (e) {
      ToastUtil.showError('Failed to remove avatar: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('Agriflock 360'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      bottomNavigationBar: const ExpenseMarqueeBannerCompact(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 15, 24, 32),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Avatar with edit button
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isLoading || _isUploading)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _uploadAvatar,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white,
                              backgroundImage: _user.avatar != null
                                  ? NetworkImage(_user.avatar!)
                                  : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                              child: _user.avatar == null
                                  ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              )
                                  : null,
                            ),
                          ),
                        ),
                      // Edit icon overlay
                      if (!_isLoading && !_isUploading)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Text(
                    _user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _user.email,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Display phone number if available
                  if (_user.phoneNumber != null && _user.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _user.phoneNumber!,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],

                  // Display role
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Text(
                      _user.role.name,
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Column(
              children: [
                ProfileMenuItem(
                  icon: Icons.payment_outlined,
                  title: 'Subscription',
                  subtitle: 'Check my subscription',
                  color: Colors.blue,
                  onTap: () {
                    context.push('/payg');
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Brooder live data',
                  subtitle: 'See live brooder data',
                  color: Colors.brown,
                  onTap: () {
                    context.push('/telemetry');
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'App preferences and notifications',
                  color: Colors.purple,
                  onTap: () {
                    context.push('/settings');
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  color: Colors.orange,
                  onTap: () {
                    context.push('/help');
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: 'About Agriflock 360',
                  subtitle: 'App version and information',
                  color: Colors.teal,
                  onTap: () {
                    context.push('/about');
                  },
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Log out'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context, true);
                              },
                              child: const Text('Log out'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await apiClient.logout();
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}