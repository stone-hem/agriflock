import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState
    extends State<ExperienceSelectionScreen> {
  int? _selectedOption; // 0 = Full Farm, 1 = Extension Only
  bool _isContinuing = false;

  Future<void> _handleContinue() async {
    if (_selectedOption == null) return;

    setState(() => _isContinuing = true);

    if (_selectedOption == 0) {
      // Full Farm Experience → go to plan selection (Day1WelcomeScreen)
      if (!mounted) return;
      context.push('/day1/welcome-msg-page');
    } else {
      // Extension Services + Devices Only → save state & go home
      await secureStorage.saveSubscriptionState('no_subscription_plan');
      if (!mounted) return;
      context.go(AppRoutes.browseVets);
    }

    if (mounted) setState(() => _isContinuing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Hero Section ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logos/Logo_0725.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.agriculture,
                                size: 50,
                                color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How would you like to use AgriFlock 360?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the experience that best fits your needs.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Options Section ───────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select your experience',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Option A: Full Farm Experience ────────────
                      _ExperienceOptionCard(
                        index: 0,
                        selectedIndex: _selectedOption,
                        accentColor: Colors.green,
                        icon: Icons.agriculture_rounded,
                        title: 'Full Farm Experience',
                        description:
                            'Unlock complete farm management — batch tracking, daily records, expenses, reports, vet services & device monitoring. Best for farmers managing multiple flocks.',
                        badge: 'Recommended',
                        badgeColor: Colors.green,
                        bullets: const [
                          'Farm & batch management',
                          'Daily records & expenses',
                          'Reports & analytics',
                          'Vet services booking',
                          'Device monitoring',
                        ],
                        onTap: () =>
                            setState(() => _selectedOption = 0),
                      ),

                      const SizedBox(height: 14),

                      // ── Option B: Extension Services + Devices ────
                      _ExperienceOptionCard(
                        index: 1,
                        selectedIndex: _selectedOption,
                        accentColor: Colors.blue,
                        icon: Icons.devices_rounded,
                        title: 'Extension Services or  Devices Only',
                        description:
                            'Access vet & extension services, quotations, and device monitoring without full farm setup. Ideal if you mainly need advisory services.',
                        bullets: const [
                          'Vet & extension services',
                          'Quotations',
                          'Device monitoring',
                        ],
                        onTap: () =>
                            setState(() => _selectedOption = 1),
                      ),

                      const SizedBox(height: 28),

                      // ── Continue Button ───────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedOption == null || _isContinuing
                              ? null
                              : _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize:
                                const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            disabledBackgroundColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.4),
                          ),
                          child: _isContinuing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Continue',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceOptionCard extends StatelessWidget {
  final int index;
  final int? selectedIndex;
  final Color accentColor;
  final IconData icon;
  final String title;
  final String description;
  final List<String> bullets;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ExperienceOptionCard({
    required this.index,
    required this.selectedIndex,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.bullets,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  bool get _isSelected => selectedIndex == index;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSelected ? accentColor : Colors.grey.shade200,
          width: _isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (_isSelected)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Radio
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isSelected
                            ? accentColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: _isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Title + badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[850],
                                ),
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (badgeColor ?? accentColor)
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  badge!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        badgeColor ?? accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey[600],
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade100, height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: bullets.map((b) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: accentColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        b,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
