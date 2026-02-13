// lib/about/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Agriflock 360'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => Navigator.pop(context),
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
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.green,
                    child: const Icon(
                      Icons.image,
                      size: 120,
                      color: Colors.white54,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Agriflock 360',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            Text(
              'Version 1.0.0 (Build 245)',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // App Description
            _AboutSection(
              title: 'About Our App',
              children: [
                Text(
                  'Agriflock 360 is a comprehensive poultry farming management solution designed to help farmers monitor, manage, and optimize their farming operations.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'From batch management to real-time monitoring and PAYG services, we provide everything you need to run a successful modern farm.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Features
            _AboutSection(
              title: 'Key Features',
              children: [
                _FeatureItem(
                  icon: Icons.groups_outlined,
                  title: 'Flock Management',
                  description: 'Track and manage multiple flocks with ease',
                ),
                _FeatureItem(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Real-time Monitoring',
                  description: 'Live data from your farm devices',
                ),
                _FeatureItem(
                  icon: Icons.payment_outlined,
                  title: 'PAYG Services',
                  description: 'Flexible payment for equipment usage',
                ),
                _FeatureItem(
                  icon: Icons.analytics_outlined,
                  title: 'Analytics & Reports',
                  description: 'Detailed insights and performance reports',
                ),
                _FeatureItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Smart Alerts',
                  description: 'Instant notifications for critical events',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Team Section
            _AboutSection(
              title: 'Our Team',
              children: [
                Text(
                  'Built by a passionate team of agricultural experts, software engineers, and data scientists committed to transforming poultry farming in Africa.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    _TeamMember(
                      name: 'Agricultural Experts',
                      role: 'Farming Specialists',
                    ),
                    _TeamMember(
                      name: 'Software Engineers',
                      role: 'Tech Development',
                    ),
                    _TeamMember(
                      name: 'Data Scientists',
                      role: 'Analytics & AI',
                    ),
                    _TeamMember(
                      name: 'Support Team',
                      role: 'Customer Success',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // App Info
            _AboutSection(
              title: 'App Information',
              children: [
                _InfoRow(
                  label: 'Version',
                  value: '1.0.0',
                ),
                _InfoRow(
                  label: 'Build Number',
                  value: '245',
                ),
                _InfoRow(
                  label: 'Last Updated',
                  value: 'December 1, 2024',
                ),
                _InfoRow(
                  label: 'Minimum OS',
                  value: 'Android 8.0 / iOS 12.0',
                ),
                _InfoRow(
                  label: 'App Size',
                  value: '45.2 MB',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Legal Links
            _AboutSection(
              title: 'Legal',
              children: [
                _LegalLink(
                  title: 'Terms of Service',
                  onTap: () {},
                ),
                _LegalLink(
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _LegalLink(
                  title: 'Data Processing Agreement',
                  onTap: () {},
                ),
                _LegalLink(
                  title: 'Open Source Licenses',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Social Links
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Connect With Us',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          icon: Icons.facebook,
                          onTap: () {},
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: Icons.camera_alt_outlined,
                          onTap: () {},
                          color: Colors.pink.shade400,
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: Icons.chat_outlined,
                          onTap: () {},
                          color: Colors.green.shade500,
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: Icons.link_outlined,
                          onTap: () {},
                          color: Colors.blue.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Copyright
            Text(
              '© 2024 Agriflock 360. All rights reserved.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AboutSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  final String role;

  const _TeamMember({
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 30,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            role,
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LegalLink({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _SocialButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}