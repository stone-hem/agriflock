import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class PlansPreviewScreen extends StatefulWidget {
  const PlansPreviewScreen({super.key});

  @override
  State<PlansPreviewScreen> createState() => _PlansPreviewScreenState();
}

class _PlansPreviewScreenState extends State<PlansPreviewScreen> {
  // Determine user's region (you would get this from device locale or API)
  String _selectedRegion = 'kenya'; // Default to Kenya
  int _selectedPlanIndex = 1; // Default to Starter plan
  final PageController _pageController = PageController();

  // Region options
  final List<Map<String, dynamic>> regions = [
    {
      'code': 'kenya',
      'name': 'Kenya (KES)',
      'currency': 'KES',
      'symbol': 'KSh',
    },
    {
      'code': 'us',
      'name': 'United States (USD)',
      'currency': 'USD',
      'symbol': '\$',
    },
    {
      'code': 'other',
      'name': 'Other Regions (USD)',
      'currency': 'USD',
      'symbol': '\$',
    },
  ];

  // Plan features by tier
  final Map<String, List<String>> _planFeatures = {
    'free': [
      'Up to 50 birds per batch',
      'Basic feeding schedule',
      '3 free quotations per month',
      'Vaccination reminders',
      'Community support',
      'Basic analytics',
    ],
    'starter': [
      'Up to 500 birds per batch',
      'Advanced feeding algorithms',
      'Unlimited quotations',
      'Automated vaccination schedules',
      'Priority support',
      'Advanced analytics & reports',
      'Market price insights',
      '1 veterinary consultation/month',
    ],
    'growth': [
      'Unlimited birds & batches',
      'AI-powered feeding optimization',
      'Bulk quotation generation',
      'Custom vaccination programs',
      '24/7 premium support',
      'Predictive analytics',
      'Real-time market alerts',
      '4 veterinary consultations/month',
      'Extension officer access',
      'Export documentation support',
    ],
  };

  // Get price based on region
  Map<String, dynamic> _getPlanPrice(String planType) {
    switch (_selectedRegion) {
      case 'kenya':
        return {
          'free': {'price': 0, 'period': 'Always free'},
          'starter': {'price': 150, 'period': 'per month'},
          'growth': {'price': 300, 'period': 'per month'},
        }[planType]!;
      case 'us':
        return {
          'free': {'price': 0, 'period': 'Always free'},
          'starter': {'price': 3, 'period': 'per month'},
          'growth': {'price': 5, 'period': 'per month'},
        }[planType]!;
      case 'other':
        return {
          'free': {'price': 0, 'period': 'Always free'},
          'starter': {'price': 3, 'period': 'per month'},
          'growth': {'price': 5, 'period': 'per month'},
        }[planType]!;
      default:
        return {'price': 0, 'period': 'per month'};
    }
  }

  // Get currency symbol
  String get _currencySymbol {
    return regions.firstWhere((r) => r['code'] == _selectedRegion)['symbol'];
  }

  // Get region name
  String get _regionName {
    return regions.firstWhere((r) => r['code'] == _selectedRegion)['name'];
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
              'Choose Your Plan',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () {
                  _showHelpDialog(context);
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 10),

                  // Plans carousel
                  SizedBox(
                    height: 560,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedPlanIndex = index;
                        });
                      },
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final plans = ['free', 'starter', 'growth'];
                        final plan = plans[index];
                        return _buildPlanCard(plan, index);
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Page indicators
                  _buildPageIndicators(),

                  const SizedBox(height: 32),

                  // Selected plan details
                  _buildPlanDetails(),

                  const SizedBox(height: 40),

                  // CTA Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPlanCard(String planType, int index) {
    final priceInfo = _getPlanPrice(planType);
    final bool isSelected = _selectedPlanIndex == index;

    Color cardColor;
    Color textColor;
    String planName;
    IconData icon;

    switch (planType) {
      case 'free':
        cardColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        planName = 'Free Access';
        icon = Icons.person_outline;
        break;
      case 'starter':
        cardColor = Colors.green[50]!;
        textColor = Colors.green[900]!;
        planName = 'Starter Plan';
        icon = Icons.rocket_launch_outlined;
        break;
      case 'growth':
        cardColor = Colors.deepPurple[50]!;
        textColor = Colors.deepPurple[900]!;
        planName = 'Growth Plan';
        icon = Icons.trending_up;
        break;
      default:
        cardColor = Colors.white;
        textColor = Colors.black;
        planName = 'Plan';
        icon = Icons.agriculture;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: isSelected ? 0 : 16,
        vertical: isSelected ? 0 : 24,
      ),
      transform: isSelected
          ? Matrix4.identity()
          : Matrix4.identity()..scale(0.92),
      child: Card(
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: textColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            planName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (planType == 'free')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                    ],
                  ),


                ],
              ),

              if (planType == 'starter' || planType == 'growth')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${(_selectedRegion == 'kenya' && planType == 'starter') ? 'Most Popular' : 'Recommended'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _currencySymbol,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '${priceInfo['price']}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              Text(
                priceInfo['period'],
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 32),

              // Key feature highlight
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPlanHighlightIcon(planType),
                      color: textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getPlanHighlight(planType),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Features list (limited preview)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _planFeatures[planType]!
                    .take(3)
                    .map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: textColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),

              const Spacer(),

              // See all features button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    _showAllFeatures(planType);
                  },
                  icon: Icon(Icons.list_alt, color: textColor),
                  label: Text(
                    'See all features',
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPlanHighlight(String planType) {
    switch (planType) {
      case 'free':
        return 'Perfect for small farms just starting out';
      case 'starter':
        return 'Ideal for growing farms with up to 500 birds';
      case 'growth':
        return 'For commercial farms and agribusinesses';
      default:
        return '';
    }
  }

  IconData _getPlanHighlightIcon(String planType) {
    switch (planType) {
      case 'free':
        return Icons.emoji_objects_outlined;
      case 'starter':
        return Icons.stacked_line_chart;
      case 'growth':
        return Icons.business_outlined;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _selectedPlanIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _selectedPlanIndex == index
                ? Colors.green
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPlanDetails() {
    final plans = ['free', 'starter', 'growth'];
    final selectedPlan = plans[_selectedPlanIndex];
    final priceInfo = _getPlanPrice(selectedPlan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Comparison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.price_change, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly Cost',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currencySymbol}${priceInfo['price']} ${priceInfo['period']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              Row(
                children: [
                  const Icon(Icons.public, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Region',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _regionName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              Row(
                children: [
                  const Icon(Icons.featured_play_list, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Total Features',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_planFeatures[selectedPlan]!.length} features',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final plans = ['free', 'starter', 'growth'];
    final selectedPlan = plans[_selectedPlanIndex];

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _handlePlanSelection(selectedPlan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedPlan == 'free' ? Colors.grey[800] : Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              selectedPlan == 'free'
                  ? 'Continue with Free Plan'
                  : 'Get ${selectedPlan == 'starter' ? 'Starter' : 'Growth'} Plan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (selectedPlan != 'free')
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Start free trial
                _startFreeTrial(selectedPlan);
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
                'Try 7 Days Free',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () {
            // Contact sales
            _contactSales();
          },
          child: const Text(
            'Need a custom plan for large operations? Contact Sales',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _handlePlanSelection(String planType) async {
    if (planType == 'free') {
      // Continue with free plan
      context.go('/dashboard/free');
      return;
    }

    // For paid plans, navigate to payment
    final priceInfo = _getPlanPrice(planType);
    final currency = regions.firstWhere((r) => r['code'] == _selectedRegion)['currency'];

    // Show loading or navigate to payment
    context.go('/payment', extra: {
      'plan': planType,
      'amount': priceInfo['price'],
      'currency': currency,
      'region': _selectedRegion,
    });
  }

  void _startFreeTrial(String planType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start 7-Day Free Trial'),
        content: Text(
          'You\'ll get full access to all ${planType == 'starter' ? 'Starter' : 'Growth'} Plan features for 7 days. After the trial, you\'ll be charged ${_currencySymbol}${_getPlanPrice(planType)['price']} per month unless you cancel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start trial logic
              context.go('/dashboard/trial', extra: {'plan': planType});
            },
            child: const Text('Start Free Trial'),
          ),
        ],
      ),
    );
  }

  void _showAllFeatures(String planType) {
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
                    planType == 'free' ? 'Free Plan Features' :
                    planType == 'starter' ? 'Starter Plan Features' : 'Growth Plan Features',
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

              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: _planFeatures[planType]!
                      .map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
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
                    _handlePlanSelection(planType);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    planType == 'free'
                        ? 'Continue with Free'
                        : 'Get ${planType == 'starter' ? 'Starter' : 'Growth'} Plan',
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan Selection Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choosing the right plan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Free: For farms with up to 50 birds'),
            SizedBox(height: 4),
            Text('• Starter: For farms with 50-500 birds'),
            SizedBox(height: 4),
            Text('• Growth: For commercial farms (500+ birds)'),
            SizedBox(height: 16),
            Text(
              'Regional pricing is automatically applied based on your location.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _contactSales() {
    // Implement contact sales functionality
    // This could open email, phone, or chat
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}