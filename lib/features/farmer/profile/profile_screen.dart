import 'dart:io';
import 'dart:convert';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
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

  // User data variables
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String? _userAvatar;
  String _userRole = 'Loading...';
  String? _userPhone;
  bool _isPremium = false;
  bool _isLoading = true;
  bool _isUploading = false;
  double _profileCompletion = 65.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get user data from secure storage
      final userData = await _secureStorage.getUserData();

      if (userData != null && mounted) {
        setState(() {
          // Extract user information
          _userName = userData['name'] ?? 'Not Provided';
          _userEmail = userData['email'] ?? 'Not Provided';
          _userAvatar = userData['avatar'];
          _userPhone = userData['phone_number'];

          // Extract role information
          final role = userData['role'];
          if (role != null && role is Map<String, dynamic>) {
            _userRole = role['name'] ?? 'Farmer';
          } else {
            _userRole = 'Farmer';
          }

          // Check if user is premium
          _isPremium = userData['status'] == 'active' &&
              (userData['agreed_to_terms'] == true);

          // Calculate profile completion based on available data
          _profileCompletion = _calculateProfileCompletion(userData);

          _isLoading = false;
        });
      } else {
        // If no user data found, use default values
        if (mounted) {
          setState(() {
            _userName = 'Guest Farmer';
            _userEmail = 'guest@example.com';
            _userRole = 'Farmer';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _userName = 'Error Loading';
          _userEmail = 'Error Loading';
          _userRole = 'Farmer';
          _isLoading = false;
        });
      }
    }
  }

  double _calculateProfileCompletion(Map<String, dynamic> userData) {
    int completedFields = 0;
    int totalFields = 5;

    if (userData['name'] != null && userData['name'].toString().isNotEmpty) completedFields++;
    if (userData['email'] != null && userData['email'].toString().isNotEmpty) completedFields++;
    if (userData['phone_number'] != null && userData['phone_number'].toString().isNotEmpty) completedFields++;
    if (userData['avatar'] != null && userData['avatar'].toString().isNotEmpty) completedFields++;
    if (userData['agreed_to_terms'] == true) completedFields++;

    return (completedFields / totalFields) * 100;
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
      // Create multipart file
      final file = await http.MultipartFile.fromPath(
        'file', // Field name as per your API
        imageFile.path,
      );

      // Use the ApiClient's postMultipart method
      final response = await apiClient.postMultipart(
        '/users/profile/avatar',
        files: [file],
      );

      // Get the response
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update avatar in local storage
        final newAvatarUrl = responseData['avatar'] ?? responseData['data']?['avatar'];

        if (newAvatarUrl != null) {
          // Update secure storage
          final userData = await _secureStorage.getUserData();
          if (userData != null) {
            userData['avatar'] = newAvatarUrl;
            await _secureStorage.saveUserData(userData);
          }

          // Update UI
          if (mounted) {
            setState(() {
              _userAvatar = newAvatarUrl;
              _profileCompletion = _calculateProfileCompletion(userData ?? {});
            });
          }

          ToastUtil.showSuccess('Avatar updated successfully!');
        } else {
          ToastUtil.showError('Failed to get avatar URL from response');
        }
      } else {
        // Handle API error
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Failed to upload avatar';
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
      final response = await apiClient.delete('/users/profile/avatar');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local storage
        final userData = await _secureStorage.getUserData();
        if (userData != null) {
          userData['avatar'] = null;
          await _secureStorage.saveUserData(userData);
        }

        // Update UI
        if (mounted) {
          setState(() {
            _userAvatar = null;
            _profileCompletion = _calculateProfileCompletion(userData ?? {});
          });
        }

        ToastUtil.showSuccess('Avatar removed successfully!');
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Failed to remove avatar';
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
      body: SingleChildScrollView(
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
                      _isLoading || _isUploading
                          ? Container(
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
                          : GestureDetector(
                        onTap: _isUploading ? null : _uploadAvatar,
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
                            backgroundImage: _userAvatar != null
                                ? NetworkImage(_userAvatar!)
                                : const NetworkImage('https://i.pravatar.cc/300')
                            as ImageProvider,
                            child: _userAvatar == null
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
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _userEmail,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Display phone number if available
                  if (_userPhone != null && _userPhone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _userPhone!,
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
                      _userRole,
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Display premium badge if applicable
                  if (_isPremium) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Text(
                        'Premium Member',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  // Profile Completion Card
                  const SizedBox(height: 10),
                  _buildProfileCompletionCard(context),
                ],
              ),
            ),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Subscription',
                    subtitle: 'Check my subscription',
                    color: Colors.blue,
                    onTap: () {
                      context.push('/payg');
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Brooder live data',
                    subtitle: 'See live brooder data',
                    color: Colors.brown,
                    onTap: () {
                      context.push('/telemetry');
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences and notifications',
                    color: Colors.purple,
                    onTap: () {
                      context.push('/settings');
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    color: Colors.orange,
                    onTap: () {
                      context.push('/help');
                    },
                  ),
                  _ProfileMenuItem(
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
                                  // Clear secure storage before logging out
                                  await _secureStorage.clearAll();
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Completion',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_profileCompletion.toInt()}% Complete',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _profileCompletion >= 100 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _profileCompletion / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _profileCompletion >= 100 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    Text(
                      '${_profileCompletion.toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress Bar
            LinearProgressIndicator(
              value: _profileCompletion / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                _profileCompletion >= 100 ? Colors.green : Colors.orange,
              ),
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),

            const SizedBox(height: 12),

            // Warning Text and Button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _profileCompletion < 100 ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _profileCompletion < 100 ? Colors.orange.shade100 : Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    _profileCompletion < 100 ? Icons.info_outline : Icons.check_circle_outline,
                    color: _profileCompletion < 100 ? Colors.orange.shade600 : Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _profileCompletion < 100
                          ? 'Complete your profile to unlock all features'
                          : 'Your profile is complete! All features unlocked.',
                      style: TextStyle(
                        color: _profileCompletion < 100 ? Colors.orange.shade800 : Colors.green.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Complete Profile Button
            if (_profileCompletion < 100)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/complete-profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade600),
        ),
        onTap: onTap,
      ),
    );
  }
}