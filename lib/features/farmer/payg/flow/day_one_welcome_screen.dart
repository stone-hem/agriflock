import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/payg/models/subscription_plans_model.dart';
import 'package:agriflock360/features/farmer/payg/repo/subscription_repo.dart';
import 'package:agriflock360/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Day1WelcomeScreen extends StatefulWidget {
  const Day1WelcomeScreen({super.key});

  @override
  State<Day1WelcomeScreen> createState() => _Day1WelcomeScreenState();
}

class _Day1WelcomeScreenState extends State<Day1WelcomeScreen> {
  final SubscriptionRepository _repo = SubscriptionRepository();

  List<ActivePlan> _plans = [];
  bool _isLoadingPlans = true;
  bool _isSubscribing = false;
  int? _expandedIndex;
  int? _selectedPlanIndex;

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
          // Default select the free trial plan
          final trialIndex = plans.indexWhere((p) => p.isFreeTrial);
          _selectedPlanIndex = trialIndex >= 0 ? trialIndex : null;
        });
      },
      failure: (_, _, _) {
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

  ActivePlan? get _selectedPlan =>
      _selectedPlanIndex != null ? _plans[_selectedPlanIndex!] : null;

  Future<void> _handleContinue() async {
    final plan = _selectedPlan;
    if (plan == null) {
      ToastUtil.showError('You must select a plan to use Agriflock 360 app');
      return;
    }

    setState(() => _isSubscribing = true);

    if (plan.isFreeTrial) {
      // Free trial: subscribe and go to farm setup
      final result = await _repo.subscribeToPlan(plan.id);
      if (!mounted) return;

      result.when(
        success: (_) {
          context.go('/onboarding/setup');
        },
        failure: (message, _, __) {
          setState(() => _isSubscribing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
      );
    } else {
      // Paid plan: go to payment screen with plan details
      setState(() => _isSubscribing = false);
      context.push('/payg/payment', extra: {
        'planId': plan.id,
        'planName': plan.name,
        'planType': plan.planType,
        'amount': plan.priceAmount,
        'currency': plan.currency,
      });
    }
  }

  String get _buttonText {
    final plan = _selectedPlan;
    if (plan == null) return 'Continue';
    if (plan.isFreeTrial) return 'Start Free Trial & Set Up Farm';
    return 'Subscribe to ${plan.name}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top hero section ─────────────────────────────────
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
                    child:  Image.asset(
                      'assets/logos/Logo_0725.png',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to AgriFlock 360',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a plan to get started.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Plans list section ───────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: _isLoadingPlans
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      )
                    : _plans.isEmpty
                        ? _buildEmptyPlans()
                        : _buildPlansList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlans() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Could not load plans right now.',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildPlansList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            itemCount: _plans.length + 1, // +1 for the header
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4),
                  child: Text(
                    'Choose a Plan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              }
              return _buildPlanTile(index - 1);
            },
          ),
        ),

        // ── Bottom buttons ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            children: [
              _buildContinueButton(),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: Icon(Icons.arrow_forward),
                  onPressed: () async {
                    await secureStorage.saveSubscriptionState('true');
                    if (!mounted) return;
                    context.go(AppRoutes.home);
                  },
                  label: Text('Skip for now ')
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final plan = _selectedPlan;
    final buttonColor = plan != null ? _planColor(plan.planType) : Theme.of(context).primaryColor;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubscribing || _selectedPlanIndex == null
            ? null
            : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
        ),
        child: _isSubscribing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                _buttonText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildPlanTile(int index) {
    final plan = _plans[index];
    final color = _planColor(plan.planType);
    final isExpanded = _expandedIndex == index;
    final isTrial = plan.isFreeTrial;
    final isSelected = _selectedPlanIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          children: [
            // ── Header (always visible) ──────────────────────
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _selectedPlanIndex = index;
                  _expandedIndex = isExpanded ? null : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Radio indicator
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_planIcon(plan.planType), color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[850],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isTrial
                                ? 'Free for ${plan.trialPeriodDays ?? 30} days'
                                : '${plan.currency} ${plan.priceAmount.toStringAsFixed(plan.priceAmount % 1 == 0 ? 0 : 2)}/mo',
                            style: TextStyle(
                              fontSize: 12,
                              color: isTrial ? Colors.green : Colors.grey[600],
                              fontWeight: isTrial ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTrial)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[400],
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),

            // ── Expandable details ───────────────────────────
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedDetails(plan, color),
              crossFadeState:
                  isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(ActivePlan plan, Color color) {
    final modules = plan.includedModules.toSet().toList(); // dedupe
    final features = plan.readableFeatures;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),

          if (plan.description.isNotEmpty) ...[
            Text(
              plan.description,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.35),
            ),
            const SizedBox(height: 10),
          ],

          // Modules chips
          if (modules.isNotEmpty) ...[
            Text(
              'Included modules',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: modules.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    m[0] + m.substring(1).toLowerCase(),
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          // Features list
          if (features.isNotEmpty) ...[
            Text(
              'Features',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: color, size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          f,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // Trial-specific note
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
                  Icon(Icons.info_outline, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Full access to all features during your trial. No payment required.',
                      style: TextStyle(fontSize: 11.5, color: Colors.green[800]),
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
