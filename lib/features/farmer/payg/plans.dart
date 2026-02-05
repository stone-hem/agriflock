import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class PlansPreviewScreen extends StatefulWidget {
  const PlansPreviewScreen({super.key});

  @override
  State<PlansPreviewScreen> createState() => _PlansPreviewScreenState();
}

class _PlansPreviewScreenState extends State<PlansPreviewScreen> {
  String _selectedRegion = 'kenya'; // Default to Kenya
  int _selectedPlanIndex = 1; // Default to Silver plan
  String _currency = '';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

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

  // Plan features by tier - Updated to match new pricing model
  final Map<String, List<String>> _planFeatures = {
    'silver': [
      'Up to 400 birds per batch',
      'Basic feeding schedule',
      'Vaccination reminders',
      'Community support',
      'Basic analytics',
      'Free Quotations Module (first 3 months)',
      '30-day Full Farm Experience',
    ],
    'gold': [
      '400-700 birds per batch',
      'Advanced feeding algorithms',
      'Automated vaccination schedules',
      'Priority support',
      'Advanced analytics & reports',
      'Market price insights',
      'Free Quotations Module (first 3 months)',
      '30-day Full Farm Experience',
      'Pay-per-use extension/vet access',
    ],
    'platinum': [
      'Unlimited birds & batches',
      'AI-powered feeding optimization',
      'Custom vaccination programs',
      '24/7 premium support',
      'Predictive analytics',
      'Real-time market alerts',
      'Free Quotations Module (first 3 months)',
      '30-day Full Farm Experience',
      'Pay-per-use extension/vet access',
      'Export documentation support',
    ],
  };

  // Updated pricing model based on currency
  Map<String, dynamic> _getPlanPrice(String planType) {
    // Check if currency is KES (Kenya)
    if (_currency == 'KES') {
      return {
        'silver': {'price': 150, 'period': 'per month', 'chicks': 'Up to 400 chicks'},
        'gold': {'price': 350, 'period': 'per month', 'chicks': '400-700 chicks'},
        'platinum': {'price': 550, 'period': 'per month', 'chicks': '700+ chicks'},
      }[planType]!;
    } else {
      // USD pricing for US and other regions
      return {
        'silver': {'price': 5, 'period': 'per month', 'chicks': 'Up to 400 chicks'},
        'gold': {'price': 7.5, 'period': 'per month', 'chicks': '400-700 chicks'},
        'platinum': {'price': 10, 'period': 'per month', 'chicks': '700+ chicks'},
      }[planType]!;
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

  Future<void> _loadCurrency() async {
    // Simulating storage fetch - replace with your actual storage implementation
    // var currency = await secureStorage.getCurrency();
    // For now, we'll use a default
    setState(() {
      _currency = 'KES'; // Default to KES for Kenya
      _selectedRegion = 'kenya'; // Set region based on currency
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKenyaPricing = _currency == 'KES';
    final plans = ['silver', 'gold', 'platinum'];

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
                              'Special Offer',
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
                          '• 30-day Full Farm Experience for all plans\n• Quotation Module free for first 3 months\n• All plans include access to extension & veterinary marketplace (pay-per-use)',
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
                          'Current Pricing:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Chip(
                          label: Text(
                            isKenyaPricing ? 'Kenya (KES)' : 'International (USD)',
                            style: TextStyle(
                              color: isKenyaPricing ? Colors.green : Colors.blue,
                            ),
                          ),
                          backgroundColor: isKenyaPricing ? Colors.green[50] : Colors.blue[50],
                        ),
                      ],
                    ),
                  ),

                  // Plans List (Vertical)
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: plans.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final planType = plans[index];
                      final priceInfo = _getPlanPrice(planType);
                      final isSelected = _selectedPlanIndex == index;

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
                              color: isSelected ? Colors.green : Colors.grey[200]!,
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
                                  color: _getPlanColor(planType).withOpacity(0.1),
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
                                          _getPlanIcon(planType),
                                          color: _getPlanColor(planType),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _getPlanName(planType),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _getPlanColor(planType),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (planType == 'silver')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'MOST POPULAR',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[800],
                                            letterSpacing: 0.5,
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
                                          '${priceInfo['price']}${isKenyaPricing ? '' : ''}',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          priceInfo['period'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Chicks range
                                    Text(
                                      priceInfo['chicks'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Features preview (3 items)
                                    Column(
                                      children: _planFeatures[planType]!
                                          .take(3)
                                          .map((feature) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: _getPlanColor(planType),
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

                                    // See all features button
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          _showAllFeatures(planType);
                                        },
                                        child: Text(
                                          'View all features',
                                          style: TextStyle(
                                            color: _getPlanColor(planType),
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
                        Text(
                          'Selected Plan: ${_getPlanName(plans[_selectedPlanIndex])}',
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
                              _handlePlanSelection(plans[_selectedPlanIndex]);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getPlanColor(plans[_selectedPlanIndex]),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Get ${_getPlanName(plans[_selectedPlanIndex])} Plan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              _startFreeTrial(plans[_selectedPlanIndex]);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _getPlanColor(plans[_selectedPlanIndex]),
                              side: BorderSide(color: _getPlanColor(plans[_selectedPlanIndex])),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Start 30-Day Free Trial',
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

  // Helper methods for plan styling
  Color _getPlanColor(String planType) {
    switch (planType) {
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

  IconData _getPlanIcon(String planType) {
    switch (planType) {
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

  String _getPlanName(String planType) {
    switch (planType) {
      case 'silver':
        return 'Silver Plan';
      case 'gold':
        return 'Gold Plan';
      case 'platinum':
        return 'Platinum Plan';
      default:
        return 'Plan';
    }
  }

  void _handlePlanSelection(String planType) async {
    // For all plans, navigate to dashboard with appropriate route
    final priceInfo = _getPlanPrice(planType);

    context.go('/dashboard/plan', extra: {
      'plan': planType,
      'amount': priceInfo['price'],
      'currency': _currency,
      'region': _selectedRegion,
    });
  }

  void _startFreeTrial(String planType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start 30-Day Free Trial'),
        content: Text(
          'You\'ll get full access to all ${_getPlanName(planType)} features for 30 days. This includes the Full Farm Experience and free Quotation Module for 3 months.',
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
              context.go('/dashboard/trial', extra: {
                'plan': planType,
                'days': 30,
              });
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
                    _getPlanName(planType) + ' Features',
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

              const SizedBox(height: 16),

              // Plan description
              Text(
                'Perfect for farms with ${_getPlanPrice(planType)['chicks'].toLowerCase()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
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
                          color: _getPlanColor(planType),
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
                    backgroundColor: _getPlanColor(planType),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Get ${_getPlanName(planType)}',
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
    final isKenyaPricing = _currency == 'KES';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan Selection Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choosing the right plan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• Silver: For farms with up to 400 birds (${isKenyaPricing ? '150 KES' : '\$5'}/month)'),
            const SizedBox(height: 4),
            Text('• Gold: For farms with 400-700 birds (${isKenyaPricing ? '350 KES' : '\$7.5'}/month)'),
            const SizedBox(height: 4),
            Text('• Platinum: For commercial farms with 700+ birds (${isKenyaPricing ? '550 KES' : '\$10'}/month)'),
            const SizedBox(height: 16),
            const Text(
              'All plans include:\n• 30-day Full Farm Experience\n• Free Quotation Module for 3 months\n• Access to extension & veterinary marketplace (pay-per-use)',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Text(
              'Pricing is automatically set based on your region (${isKenyaPricing ? 'Kenya' : 'International'}).',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
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

}