import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@agriflock.com',
      queryParameters: {
        'subject': 'Agriflock 360 Support Request',
        'body': 'Hello Agriflock Team,\n\nI need assistance with:',
      },
    );

    // if (await canLaunchUrl(emailLaunchUri)) {
    //   await launchUrl(emailLaunchUri);
    // }
  }

  void _launchPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: '+254711123456',
    );

    // if (await canLaunchUrl(phoneLaunchUri)) {
    //   await launchUrl(phoneLaunchUri);
    // }
  }

  void _launchWhatsApp() async {
    final Uri whatsappLaunchUri = Uri(
      scheme: 'https',
      path: 'wa.me/254711123456',
      queryParameters: {
        'text': 'Hello Agriflock 360 Support, I need help with:',
      },
    );

    // if (await canLaunchUrl(whatsappLaunchUri)) {
    //   await launchUrl(whatsappLaunchUri);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
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
              'We\'re here to help!',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            Text(
              'Get assistance with any issues',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // Contact Methods
            _ContactMethodCard(
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: 'Speak directly with our support team',
              actionText: '+254 711 123 456',
              color: Colors.green,
              onTap: _launchPhone,
            ),
            const SizedBox(height: 16),
            _ContactMethodCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'Send us an email',
              actionText: 's@agriflock.com',
              color: Colors.blue,
              onTap: _launchEmail,
            ),
            const SizedBox(height: 16),
            _ContactMethodCard(
              icon: Icons.chat_outlined,
              title: 'WhatsApp',
              subtitle: 'Quick chat support',
              actionText: 'Chat on WhatsApp',
              color: Colors.green,
              onTap: _launchWhatsApp,
            ),
            const SizedBox(height: 32),

            // FAQ Section
            _HelpSection(
              title: 'Frequently Asked Questions',
              children: [
                _FAQItem(
                  question: 'How do I add a new batch?',
                  answer: 'Go to the Home screen and tap "Add Flock" in the Quick Actions section. Fill in the required details about your birds.',
                ),
                _FAQItem(
                  question: 'How does PAYG service work?',
                  answer: 'PAYG (Pay As You Go) allows you to pay for device usage monthly. Make payments before the due date to keep your device active.',
                ),
                _FAQItem(
                  question: 'Can I use multiple farms?',
                  answer: 'Yes, you can manage multiple farms from one account. Go to Settings to add new farm locations.',
                ),
                _FAQItem(
                  question: 'How do I reset my password?',
                  answer: 'On the login screen, tap "Forgot Password" and follow the instructions sent to your email.',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Support Resources
            // _HelpSection(
            //   title: 'Support Resources',
            //   children: [
            //     _ResourceTile(
            //       icon: Icons.library_books_outlined,
            //       title: 'User Guide',
            //       subtitle: 'Complete app usage instructions',
            //       onTap: () {},
            //     ),
            //     _ResourceTile(
            //       icon: Icons.video_library_outlined,
            //       title: 'Video Tutorials',
            //       subtitle: 'Step-by-step video guides',
            //       onTap: () {},
            //     ),
            //     _ResourceTile(
            //       icon: Icons.forum_outlined,
            //       title: 'Community Forum',
            //       subtitle: 'Connect with other farmers',
            //       onTap: () {},
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 32),

            // Emergency Support
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade50, Colors.deepOrange.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 40,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Emergency Support',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For critical issues affecting your farm operations, call our 24/7 emergency line',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _launchPhone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Call Emergency Line'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final Color color;
  final VoidCallback onTap;

  const _ContactMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 16),
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
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                actionText,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _HelpSection({
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
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.grey.shade600,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.answer,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.purple, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
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