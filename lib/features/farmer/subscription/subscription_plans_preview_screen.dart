import 'package:agriflock/app_routes.dart';
import 'package:agriflock/features/farmer/subscription/models/subscription_plan_model.dart';
import 'package:agriflock/features/farmer/subscription/repo/subscription_repo.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mid-session plan browser — shown when a farmer wants to upgrade
/// their subscription or browse available plans.
class SubscriptionPlansPreviewScreen extends StatefulWidget {
  const SubscriptionPlansPreviewScreen({super.key});

  @override
  State<SubscriptionPlansPreviewScreen> createState() =>
      _SubscriptionPlansPreviewScreenState();
}

class _SubscriptionPlansPreviewScreenState
    extends State<SubscriptionPlansPreviewScreen> {
  final SubscriptionRepository _repo = SubscriptionRepository();

  List<ActivePlan> _plans = [];
  bool _isLoading = true;
  bool _isSubscribing = false;
  String? _errorMessage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repo.getActivePlans();

    result.when(
      success: (plans) {
        setState(() {
          _plans = plans;
          _isLoading = false;
          if (_selectedIndex >= plans.length) _selectedIndex = 0;
        });
      },
      failure: (message, _, __) {
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      },
    );
  }

  Color _planColor(String planType) {
    switch (planType.toUpperCase()) {
      case 'SILVER':
        return const Color(0xFF5C7CFA);
      case 'GOLD':
        return const Color(0xFFF59F00);
      case 'PLATINUM':
        return const Color(0xFF7C3AED);
      default:
        return Colors.green;
    }
  }

  IconData _planIcon(String planType) {
    switch (planType.toUpperCase()) {
      case 'SILVER':
        return Icons.agriculture_rounded;
      case 'GOLD':
        return Icons.trending_up_rounded;
      case 'PLATINUM':
        return Icons.diamond_rounded;
      default:
        return Icons.agriculture_rounded;
    }
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'KES':
        return 'KSh';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _fetchPlans,
                  color: Colors.green,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading plans…',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _fetchPlans,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        ...List.generate(_plans.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildPlanCard(i),
          );
        }),
        const SizedBox(height: 8),
        if (_plans.isNotEmpty) _buildActionSection(),
      ],
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final color = _planColor(plan.planType);
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
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
                color: color.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Row(
                children: [
                  Icon(_planIcon(plan.planType), color: color, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      plan.name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currencySymbol(plan.currency)} ${plan.priceAmount.toStringAsFixed(plan.priceAmount % 1 == 0 ? 0 : 2)}/mo',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.description,
                    style: TextStyle(
                        fontSize: 12.5, color: Colors.grey[600], height: 1.35),
                  ),
                  if (plan.chicksLabel.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.egg_rounded, size: 15, color: color),
                        const SizedBox(width: 5),
                        Text(
                          plan.chicksLabel,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  ...plan.readableFeatures.take(4).map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: color, size: 16),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                f,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey[700],
                                    height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (plan.readableFeatures.length > 4)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showAllFeatures(plan),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('View all features',
                            style:
                                TextStyle(color: color, fontSize: 12.5)),
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

  Widget _buildActionSection() {
    final plan = _plans[_selectedIndex];
    final color = _planColor(plan.planType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Selected: ${plan.name}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubscribing
                  ? null
                  : () => _handlePlanSelection(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                disabledBackgroundColor: color.withValues(alpha: 0.5),
              ),
              child: _isSubscribing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      plan.isFreeTrial
                          ? 'Start Free Trial'
                          : 'Get ${plan.name}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllFeatures(ActivePlan plan) {
    final color = _planColor(plan.planType);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${plan.name} Features',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(plan.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: plan.readableFeatures.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(plan.readableFeatures[i],
                            style: const TextStyle(
                                fontSize: 14, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handlePlanSelection(plan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Get ${plan.name}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlanSelection(ActivePlan plan) async {
    if (plan.isFreeTrial) {
      setState(() => _isSubscribing = true);
      final result = await _repo.subscribeToPlan(plan.id);
      if (!mounted) return;
      result.when(
        success: (_) async {
          await secureStorage.saveSubscriptionState('has_active_plan');
          if (!mounted) return;
          context.go(AppRoutes.home);
        },
        failure: (message, _, __) {
          setState(() => _isSubscribing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message), backgroundColor: Colors.red),
          );
        },
      );
    } else {
      context.push(AppRoutes.subscriptionPayment, extra: {
        'planId': plan.id,
        'planName': plan.name,
        'planType': plan.planType,
        'amount': plan.priceAmount,
        'currency': plan.currency,
        'billingCycleDays': plan.billingCycleDays,
        'isOnboarding': false,
      });
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Plan Selection Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choosing the right plan:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._plans.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                      '• ${p.name}: ${p.chicksLabel} — ${_currencySymbol(p.currency)} ${p.priceAmount.toStringAsFixed(p.priceAmount % 1 == 0 ? 0 : 2)}/mo'),
                )),
            const SizedBox(height: 12),
            const Text(
              'All plans include a free trial, quotation module, and marketplace access.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
