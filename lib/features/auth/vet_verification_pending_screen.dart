import 'dart:async';
import 'package:agriflock360/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetVerificationPendingScreen extends StatefulWidget {
  const VetVerificationPendingScreen({super.key});

  @override
  State<VetVerificationPendingScreen> createState() =>
      _VetVerificationPendingScreenState();
}

class _VetVerificationPendingScreenState
    extends State<VetVerificationPendingScreen> {
  static const List<Map<String, IconData>> _messages = [
    {
      'icon': Icons.monetization_on_outlined,
    },
    {
      'icon': Icons.people_outline,
    },
    {
      'icon': Icons.dashboard_outlined,
    },
    {
      'icon': Icons.visibility_outlined,
    },
    {
      'icon': Icons.notifications_active_outlined,
    },
    {
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'icon': Icons.star_outline,
    },
    {
      'icon': Icons.groups_outlined,
    },
  ];

  static const List<Map<String, String>> _messageTexts = [
    {
      'title': 'Earn on Your Schedule',
      'body':
          'Once verified, you can set your own availability and consultation fees. Work when it suits you and earn on your terms.',
    },
    {
      'title': 'Connect with Farmers',
      'body':
          'AgriFlock360 connects you with thousands of poultry farmers who need your veterinary expertise in their area.',
    },
    {
      'title': 'Manage Your Practice',
      'body':
          'Access a full dashboard to manage appointments, track payments, and view your earnings analytics in real-time.',
    },
    {
      'title': 'Grow Your Reach',
      'body':
          'Verified vets get priority listing and increased visibility to farmers in their region. More visibility means more clients.',
    },
    {
      'title': 'Consultation Requests',
      'body':
          'Receive consultation requests directly from poultry farmers in your area. Accept or decline at your convenience.',
    },
    {
      'title': 'Track Your Earnings',
      'body':
          'View detailed payment history, pending payments, and earnings reports all in one place. Stay on top of your finances.',
    },
    {
      'title': 'Build Your Reputation',
      'body':
          'Farmers can rate and review your services, helping you build a strong professional reputation on the platform.',
    },
    {
      'title': 'Professional Network',
      'body':
          'Join a community of verified veterinary professionals dedicated to improving poultry health outcomes across the region.',
    },
  ];

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _messageTexts.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Verification icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 60,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verification in Progress',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your account is being reviewed by our team.\nThis process typically takes up to 24 hours.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll notify you once your verification is complete.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Divider with text
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'What to expect',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              // Messages carousel
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemCount: _messageTexts.length,
                        itemBuilder: (context, index) {
                          final msg = _messageTexts[index];
                          final iconData =
                              _messages[index].values.first;
                          return _buildMessageCard(
                            msg['title']!,
                            msg['body']!,
                            iconData,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _messageTexts.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.green
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Back to Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(String title, String body, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade100),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.green.shade600,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
