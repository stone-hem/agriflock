import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App Logo
            Center(
              child: Image.asset(
                'assets/logos/Logo_0725.png',
                fit: BoxFit.cover,
                width: 100,
                height: 100,
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
            ),
            const SizedBox(height: 8),
            Text(
              'Agriflock 360',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // Account Settings
            _SettingsSection(
              title: 'Account',
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {},
                ),
                // _SettingsTile(
                //   icon: Icons.security_outlined,
                //   title: 'Privacy & Security',
                //   subtitle: 'Manage your account security - enable 2fa',
                //   onTap: () {},
                // ),
                // _SettingsTile(
                //   icon: Icons.payment_outlined,
                //   title: 'Payment Methods',
                //   subtitle: 'Our payment options',
                //   onTap: () {},
                // ),
              ],
            ),
            const SizedBox(height: 24),

            // App Preferences
            // _SettingsSection(
            //   title: 'App Preferences',
            //   children: [
            //     _SettingsSwitchTile(
            //       icon: Icons.notifications_outlined,
            //       title: 'Push Notifications',
            //       subtitle: 'Receive important updates',
            //       value: _notificationsEnabled,
            //       onChanged: (value) {
            //         setState(() {
            //           _notificationsEnabled = value;
            //         });
            //       },
            //     ),
            //     // _SettingsSwitchTile(
            //     //   icon: Icons.fingerprint_outlined,
            //     //   title: 'Biometric Login',
            //     //   subtitle: 'Use fingerprint or face ID',
            //     //   value: _biometricEnabled,
            //     //   onChanged: (value) {
            //     //     setState(() {
            //     //       _biometricEnabled = value;
            //     //     });
            //     //   },
            //     // ),
            //     _SettingsSwitchTile(
            //       icon: Icons.dark_mode_outlined,
            //       title: 'Dark Mode',
            //       subtitle: 'Switch to dark theme',
            //       value: _darkModeEnabled,
            //       onChanged: (value) {
            //         setState(() {
            //           _darkModeEnabled = value;
            //         });
            //       },
            //     ),
            //     // _SettingsDropdownTile(
            //     //   icon: Icons.language_outlined,
            //     //   title: 'Language',
            //     //   subtitle: 'App language',
            //     //   value: _selectedLanguage,
            //     //   items: const ['English', 'Swahili', 'French', 'Spanish'],
            //     //   onChanged: (value) {
            //     //     setState(() {
            //     //       _selectedLanguage = value!;
            //     //     });
            //     //   },
            //     // ),
            //   ],
            // ),
            // const SizedBox(height: 24),

            // Data & Storage
            // _SettingsSection(
            //   title: 'Data & Storage',
            //   children: [
            //     _SettingsTile(
            //       icon: Icons.storage_outlined,
            //       title: 'Data Usage',
            //       subtitle: 'Manage your data consumption',
            //       onTap: () {},
            //     ),
            //     _SettingsTile(
            //       icon: Icons.cloud_download_outlined,
            //       title: 'Download Quality',
            //       subtitle: 'Set media download quality',
            //       onTap: () {},
            //     ),
            //     _SettingsTile(
            //       icon: Icons.backup_outlined,
            //       title: 'Backup & Restore',
            //       subtitle: 'Backup your farm data',
            //       onTap: () {},
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 24),

            // Support
            _SettingsSection(
              title: 'Support',
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => context.push('/help'),
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Agriflock 360',
                  subtitle: 'App version and information',
                  onTap: () => context.push('/about'),
                ),
                // _SettingsTile(
                //   icon: Icons.rate_review_outlined,
                //   title: 'Rate App',
                //   subtitle: 'Share your experience',
                //   onTap: () {},
                // ),
              ],
            ),
            const SizedBox(height: 32),

            // Legal
            _SettingsSection(
              title: 'Legal',
              children: [
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
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
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.green, size: 20),
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.green,
      ),
    );
  }
}

class _SettingsDropdownTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SettingsDropdownTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.orange, size: 20),
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
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}