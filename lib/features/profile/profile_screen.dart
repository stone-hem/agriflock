import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SecureStorage _secureStorage = SecureStorage();

  // User data variables
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String? _userAvatar;
  String _userRole = 'Loading...';
  String? _userPhone;
  bool _isPremium = false;
  bool _isLoading = true;
  double _profileCompletion = 65.0; // Default value, can be calculated from user data

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

          // Check if user is premium (you can adjust this logic based on your criteria)
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
    // Calculate completion percentage based on available user data
    int completedFields = 0;
    int totalFields = 5; // Adjust based on your required fields

    if (userData['name'] != null && userData['name'].toString().isNotEmpty) completedFields++;
    if (userData['email'] != null && userData['email'].toString().isNotEmpty) completedFields++;
    if (userData['phone_number'] != null && userData['phone_number'].toString().isNotEmpty) completedFields++;
    if (userData['avatar'] != null && userData['avatar'].toString().isNotEmpty) completedFields++;
    if (userData['agreed_to_terms'] == true) completedFields++;

    return (completedFields / totalFields) * 100;
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : CircleAvatar(
                      radius: 46,
                      backgroundImage: _userAvatar != null
                          ? NetworkImage(_userAvatar!)
                          : const NetworkImage('https://i.pravatar.cc/300'),
                    ),
                  ),
                  const SizedBox(height: 5),
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