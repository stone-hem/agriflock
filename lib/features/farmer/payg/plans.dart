import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/payg/repo/subscription_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/features/farmer/payg/models/subscription_plans_model.dart';

class PlansPreviewScreen extends StatefulWidget {
  const PlansPreviewScreen({super.key});

  @override
  State<PlansPreviewScreen> createState() => _PlansPreviewScreenState();
}

class _PlansPreviewScreenState extends State<PlansPreviewScreen> {
  final SubscriptionRepository _repository = SubscriptionRepository();

  // State for API data
  List<SubscriptionPlanItem> _subscriptionHistory = [];
  List<SubscriptionPlanItem> _availablePlans = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedPlanIndex = 0;

  // Default pricing based on available plans from API
  String _currency = 'KES'; // Default
  String _selectedRegion = 'kenya';

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _repository.getSubscriptionHistory();

      switch(result) {
        case Success<SubscriptionPlansResponse>(data: final response):
          setState(() {
            _subscriptionHistory = response.data;

            // Extract available plans from history (you might want to filter unique plans)
            _availablePlans = response.data;

            // Set currency based on first available plan
            if (_availablePlans.isNotEmpty) {
              _currency = _availablePlans.first.plan.currency;
              _selectedRegion = _currency == 'KES' ? 'kenya' : 'us';
            }

            // Find active subscription and select it by default
            final activeIndex = _availablePlans.indexWhere(
                    (plan) => plan.status == 'ACTIVE'
            );

            if (activeIndex != -1) {
              _selectedPlanIndex = activeIndex;
            }

            _isLoading = false;
          });

        case Failure<SubscriptionPlansResponse>():
          setState(() {
            _errorMessage = result.message;
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
      }
    } catch (e) {
      LogUtil.error('Error loading subscription data: $e');
      setState(() {
        _errorMessage = 'Failed to load subscription data';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load subscription data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get currency symbol based on API data
  String get _currencySymbol {
    return _currency == 'KES' ? 'KSh' : '\$';
  }

  // Get plan color based on plan type from API
  Color _getPlanColor(String planType) {
    switch (planType.toLowerCase()) {
      case 'silver':
        return Colors.blue;
      case 'gold':
        return Colors.amber[700]!;
      case 'platinum':
        return Colors.deepPurple;
      default:
        return Colors.green;
    }
  }

  // Get plan icon based on plan type from API
  IconData _getPlanIcon(String planType) {
    switch (planType.toLowerCase()) {
      case 'silver':
        return Icons.agriculture;
      case 'gold':
        return Icons.trending_up;
      case 'platinum':
        return Icons.diamond_outlined;
      default:
        return Icons.agriculture;
    }
  }

  // Get features for a plan based on included modules from API
  List<String> _getPlanFeatures(SubscriptionPlan plan) {
    final features = <String>[];

    // Add included modules as features
    for (final module in plan.includedModules) {
      switch (module) {
        case 'VACCINATIONS':
          features.add('Vaccination management');
          break;
        case 'FEEDING':
          features.add('Feeding schedule & tracking');
          break;
        case 'MARKETPLACE':
          features.add('Extension/veterinary marketplace access');
          break;
        case 'QUOTATIONS':
          features.add('Quotation module');
          break;
      }
    }

    // Add plan-specific features from features object
    if (plan.features.maxChicks != null) {
      features.add('Up to ${plan.features.maxChicks} birds');
    } else if (plan.features.minChicks != null) {
      features.add('From ${plan.features.minChicks} birds');
    }

    features.add('${plan.features.supportLevel} support');
    features.add('${plan.features.trialPeriodDays}-day trial period');
    features.add('Marketplace: ${plan.features.marketplaceAccess}');

    return features;
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading subscription plans...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSubscriptionData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.subscriptions_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Subscription Plans Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscription plans will appear here when available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSubscriptionData,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanItem subscription, int index) {
    final isSelected = _selectedPlanIndex == index;
    final plan = subscription.plan;
    final isActive = subscription.status == 'ACTIVE';
    final features = _getPlanFeatures(plan);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _getPlanColor(plan.planType)
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isSelected ? 0.15 : 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getPlanColor(plan.planType).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getPlanIcon(plan.planType),
                        color: _getPlanColor(plan.planType),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getPlanColor(plan.planType),
                            ),
                          ),
                          Text(
                            plan.planType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPlanColor(plan.planType),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Price section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _currencySymbol,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        plan.priceAmount.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'per month',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Status and remaining days
                  if (subscription.daysRemaining > 0)
                    Text(
                      '${subscription.daysRemaining} days remaining',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (subscription.status == 'EXPIRED')
                    Text(
                      'Expired on ${subscription.endDate.split('T')[0]}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Features preview (3 items)
                  Column(
                    children: features
                        .take(3)
                        .map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _getPlanColor(plan.planType),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                        .toList(),
                  ),

                  // See all features button if there are more than 3
                  if (features.length > 3)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _showAllFeatures(plan, features);
                        },
                        child: Text(
                          'View all features',
                          style: TextStyle(
                            color: _getPlanColor(plan.planType),
                            fontSize: 13,
                          ),
                        ),
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

  void _showAllFeatures(SubscriptionPlan plan, List<String> features) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                plan.planType.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  color: _getPlanColor(plan.planType),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _currencySymbol,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    plan.priceAmount.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'per month',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Plan Features:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: features
                      .map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _getPlanColor(plan.planType),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handlePlanSelection(plan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPlanColor(plan.planType),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Select ${plan.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePlanSelection(SubscriptionPlan plan) {
    // Handle plan selection - navigate to payment or subscription upgrade
    final selectedSubscription = _availablePlans[_selectedPlanIndex];

    if (selectedSubscription.status == 'ACTIVE') {
      // Show current active subscription details
      _showActiveSubscriptionDialog(selectedSubscription);
    } else {
      // Show upgrade/switch dialog
      _showPlanChangeDialog(plan);
    }
  }

  void _showActiveSubscriptionDialog(SubscriptionPlanItem subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Active Subscription: ${subscription.plan.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${subscription.status}'),
            Text('Start Date: ${subscription.startDate.split('T')[0]}'),
            Text('End Date: ${subscription.endDate.split('T')[0]}'),
            if (subscription.daysRemaining > 0)
              Text('Days Remaining: ${subscription.daysRemaining}'),
            const SizedBox(height: 16),
            Text(
              'Auto-renew: ${subscription.autoRenew ? 'Enabled' : 'Disabled'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: subscription.autoRenew ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!subscription.autoRenew)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showRenewDialog(subscription);
              },
              child: const Text('Renew Now'),
            ),
        ],
      ),
    );
  }

  void _showPlanChangeDialog(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change to ${plan.name}'),
        content: Text(
          'Switch to ${plan.name} for ${_currencySymbol}${plan.priceAmount} per month?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement plan change logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Processing plan change to ${plan.name}...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm Change'),
          ),
        ],
      ),
    );
  }

  void _showRenewDialog(SubscriptionPlanItem subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renew ${subscription.plan.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Renew for ${_currencySymbol}${subscription.plan.priceAmount}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'The subscription will be renewed for another month.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement renewal logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Renewing ${subscription.plan.name}...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Renew Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Subscription Plans',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: _loadSubscriptionData,
              ),
            ],
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            SliverFillRemaining(
              child: _buildErrorState(),
            )
          else if (_availablePlans.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pricing notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.green[800]),
                                const SizedBox(width: 8),
                                 Text(
                                  'Subscription Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• All plans include access to extension & veterinary marketplace\n• Quotation Module included in all plans\n• Auto-renewal can be managed in subscription settings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[800],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Currency/Region indicator
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              'Current Currency:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Chip(
                              label: Text(
                                _currency,
                                style: const TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                              backgroundColor: Colors.green[50],
                            ),
                          ],
                        ),
                      ),

                      // Plans List
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _availablePlans.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildPlanCard(_availablePlans[index], index);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Selected plan action button
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (_selectedPlanIndex < _availablePlans.length)
                              Column(
                                children: [
                                  Text(
                                    'Selected Plan: ${_availablePlans[_selectedPlanIndex].plan.name}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _handlePlanSelection(_availablePlans[_selectedPlanIndex].plan);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _getPlanColor(_availablePlans[_selectedPlanIndex].plan.planType),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 56),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: Text(
                                        _availablePlans[_selectedPlanIndex].status == 'ACTIVE'
                                            ? 'Manage Active Plan'
                                            : 'Select ${_availablePlans[_selectedPlanIndex].plan.name}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // TODO: Navigate to subscription history screen
                                  context.push('/subscription/history');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(color: Colors.green),
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'View Subscription History',
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

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}