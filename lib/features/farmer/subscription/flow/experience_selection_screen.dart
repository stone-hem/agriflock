import 'package:agriflock/app_routes.dart';
import 'package:agriflock/main.dart';
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
  bool _isNavigating = false;

  Future<void> _handleSelect(int option) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    if (option == 0) {
      if (!mounted) return;
      context.push(AppRoutes.subscriptionPlans);
    } else {
      await secureStorage.saveSubscriptionState('no_subscription_plan');
      if (!mounted) return;
      context.go(AppRoutes.browseVets);
    }

    if (mounted) setState(() => _isNavigating = false);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Compact Header ────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/logos/Logo_0725.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AgriFlock 360',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[850],
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Choose your experience',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'How would you\nlike to use the app?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a plan to get started instantly.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 20),

              // ── Option Cards ──────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    // Full Farm
                    Expanded(
                      child: _TapOptionCard(
                        accentColor: primaryColor,
                        icon: Icons.agriculture_rounded,
                        title: 'Full Farm Experience',
                        subtitle: 'Best for managing multiple flocks',
                        badge: 'Recommended',
                        bullets: const [
                          'Farm & batch management',
                          'Daily records & expenses',
                          'Reports & analytics',
                          'Vet services booking',
                          'Device monitoring',
                        ],
                        isLoading: _isNavigating,
                        onTap: () => _handleSelect(0),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Extension / Devices Only
                    Expanded(
                      child: _TapOptionCard(
                        accentColor: Colors.blue.shade600,
                        icon: Icons.devices_rounded,
                        title: 'Extension Services or Devices Only',
                        subtitle: 'Advisory services & device monitoring',
                        bullets: const [
                          'Vet & extension services',
                          'Device monitoring',
                          'Basic profile',
                        ],
                        isLoading: _isNavigating,
                        onTap: () => _handleSelect(1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'You can change this later.',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TapOptionCard extends StatefulWidget {
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final String? badge;
  final bool isLoading;
  final VoidCallback onTap;

  const _TapOptionCard({
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.isLoading,
    required this.onTap,
    this.badge,
  });

  @override
  State<_TapOptionCard> createState() => _TapOptionCardState();
}

class _TapOptionCardState extends State<_TapOptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon + title + badge + arrow
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(widget.icon,
                          color: widget.accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              if (widget.badge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: widget.accentColor
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.badge!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: widget.accentColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    widget.isLoading
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: widget.accentColor,
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: Colors.grey[400]),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 12),

                // Bullet features
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: widget.bullets.map((b) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: widget.accentColor, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            b,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                // Tap CTA bar
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 15, color: widget.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        'Tap to select & continue',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: widget.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}