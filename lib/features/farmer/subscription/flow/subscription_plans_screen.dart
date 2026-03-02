import 'package:agriflock/app_routes.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:agriflock/features/farmer/subscription/models/subscription_plan_model.dart';
import 'package:agriflock/features/farmer/subscription/repo/subscription_repo.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final SubscriptionRepository _repo = SubscriptionRepository();

  List<ActivePlan> _plans = [];
  bool _isLoadingPlans = true;
  bool _isSubscribing = false;
  int? _expandedIndex;
  int? _navigatingIndex;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    final result = await _repo.getActivePlans();
    result.when(
      success: (plans) {
        setState(() {
          _plans = plans;
          _isLoadingPlans = false;
        });
      },
      failure: (_, __, ___) {
        setState(() => _isLoadingPlans = false);
      },
    );
  }

  Color _planColor(String planType) {
    switch (planType.toUpperCase()) {
      case 'FREE_TRIAL':
        return Theme.of(context).primaryColor;
      case 'SILVER':
        return const Color(0xFF5C7CFA);
      case 'GOLD':
        return const Color(0xFFF59F00);
      case 'PLATINUM':
        return const Color(0xFF7C3AED);
      default:
        return Colors.grey;
    }
  }

  IconData _planIcon(String planType) {
    switch (planType.toUpperCase()) {
      case 'FREE_TRIAL':
        return Icons.card_giftcard_rounded;
      case 'SILVER':
        return Icons.agriculture_rounded;
      case 'GOLD':
        return Icons.trending_up_rounded;
      case 'PLATINUM':
        return Icons.diamond_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Future<void> _handleSelect(int index) async {
    if (_isSubscribing) return;
    final plan = _plans[index];
    setState(() {
      _navigatingIndex = index;
      _isSubscribing = true;
    });

    if (plan.isFreeTrial) {
      final result = await _repo.subscribeToPlan(plan.id);
      await secureStorage.saveSubscriptionState('has_subscription_plan');
      if (!mounted) return;

      result.when(
        success: (_) {
          context.go('/onboarding/setup');
        },
        failure: (message, _, __) {
          setState(() {
            _isSubscribing = false;
            _navigatingIndex = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
      );
    } else {
      setState(() {
        _isSubscribing = false;
        _navigatingIndex = null;
      });
      context.push(AppRoutes.subscriptionPayment, extra: {
        'planId': plan.id,
        'planName': plan.name,
        'planType': plan.planType,
        'amount': plan.priceAmount,
        'currency': plan.currency,
        'billingCycleDays': plan.billingCycleDays,
        'isOnboarding': true,
      });
    }
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
                        'Choose a subscription plan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: Colors.grey[500]),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Pick your plan &\nget started today',
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
                'All plans include a free trial. Tap a plan to continue.',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),

              const SizedBox(height: 16),

              // ── Plans List ────────────────────────────────────
              Expanded(
                child: _isLoadingPlans
                    ? const Center(child: CircularProgressIndicator())
                    : _plans.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  itemCount: _plans.length,
                  itemBuilder: (context, index) =>
                      _buildPlanCard(index),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'You can upgrade or change your plan anytime.',
                  style:
                  TextStyle(fontSize: 11.5, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Could not load plans. Please try again.',
        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final color = _planColor(plan.planType);
    final isTrial = plan.isFreeTrial;
    final isExpanded = _expandedIndex == index;
    final isNavigating = _navigatingIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _TapPlanCard(
        color: color,
        icon: _planIcon(plan.planType),
        name: plan.name,
        isTrial: isTrial,
        trialDays: plan.trialPeriodDays,
        currency: plan.currency,
        priceAmount: plan.priceAmount,
        isExpanded: isExpanded,
        isNavigating: isNavigating,
        plan: plan,
        onTap: () => _handleSelect(index),
        onExpandToggle: () {
          setState(() {
            _expandedIndex = isExpanded ? null : index;
          });
        },
      ),
    );
  }
}

class _TapPlanCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String name;
  final bool isTrial;
  final int? trialDays;
  final String currency;
  final double priceAmount;
  final bool isExpanded;
  final bool isNavigating;
  final ActivePlan plan;
  final VoidCallback onTap;
  final VoidCallback onExpandToggle;

  const _TapPlanCard({
    required this.color,
    required this.icon,
    required this.name,
    required this.isTrial,
    required this.trialDays,
    required this.currency,
    required this.priceAmount,
    required this.isExpanded,
    required this.isNavigating,
    required this.plan,
    required this.onTap,
    required this.onExpandToggle,
  });

  @override
  State<_TapPlanCard> createState() => _TapPlanCardState();
}

class _TapPlanCardState extends State<_TapPlanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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

  String get _priceLabel {
    if (widget.isTrial) return 'Free for ${widget.trialDays ?? 60} days';
    final amount = widget.priceAmount;
    final formatted =
    amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(2);
    return '${widget.currency} $formatted / month';
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Main row ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon box
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child:
                      Icon(widget.icon, color: widget.color, size: 24),
                    ),
                    const SizedBox(width: 8),
                    // Title + price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[850],
                                ),
                              ),
                              if (widget.isTrial) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'FREE',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _priceLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isTrial
                                  ? Colors.green[600]
                                  : Colors.grey[500],
                              fontWeight: widget.isTrial
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right actions: expand + loading/arrow
                    GestureDetector(
                      onTap: widget.onExpandToggle,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          widget.isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey[400],
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    widget.isNavigating
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: widget.color,
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.grey[350]),
                  ],
                ),
              ),

              // ── Tap CTA bar ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.07),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(17),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 14, color: widget.color),
                    const SizedBox(width: 6),
                    Text(
                      widget.isTrial
                          ? 'Tap to start free trial'
                          : 'Tap to subscribe',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.color,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Expandable details ───────────────────────────
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedDetails(),
                crossFadeState: widget.isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedDetails() {
    final plan = widget.plan;
    final color = widget.color;
    final modules = plan.includedModules.toSet().toList();
    final features = plan.readableFeatures;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey.shade100),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              plan.description,
              style: TextStyle(
                  fontSize: 12.5, color: Colors.grey[600], height: 1.35),
            ),
            const SizedBox(height: 10),
          ],
          if (modules.isNotEmpty) ...[
            Text(
              'INCLUDED MODULES',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: modules.map((m) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    m[0] + m.substring(1).toLowerCase(),
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
          if (features.isNotEmpty) ...[
            Text(
              'FEATURES',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: color, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.3),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (plan.isFreeTrial) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 15, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Full access during your trial. No payment required.',
                      style:
                      TextStyle(fontSize: 11.5, color: Colors.green[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}