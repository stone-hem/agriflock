import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/payg/models/subscription_plans_model.dart';
import 'package:agriflock360/features/farmer/payg/repo/subscription_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlanTransitionScreen extends StatefulWidget {
  const PlanTransitionScreen({super.key});

  @override
  State<PlanTransitionScreen> createState() => _PlanTransitionScreenState();
}

class _PlanTransitionScreenState extends State<PlanTransitionScreen> {
  final SubscriptionRepository _repo = SubscriptionRepository();

  PlanRecommendationResponse? _recommendation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repo.getRecommendedPlan();

    if (!mounted) return;
    switch (result) {
      case Success<PlanRecommendationResponse>(data: final data):
        setState(() {
          _recommendation = data;
          _isLoading = false;
        });
      case Failure<PlanRecommendationResponse>(message: final msg):
        setState(() {
          _error = msg;
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : _error != null
                ? _buildErrorState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              _error ?? 'Failed to load recommendation',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRecommendation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pushReplacement(AppRoutes.home),
              child: const Text(
                'Go to Home',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final rec = _recommendation!;
    final plan = rec.recommendedPlan;
    final features = plan.readableFeatures;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => context.pushReplacement(AppRoutes.home),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Plan Ready',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Title
          const Text(
            'Your Recommended Plan is Ready',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 20),

          // Reasoning from API
          Text(
            rec.reasoning,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 40),

          // Recommended Plan Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Features
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 20),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${plan.currency} ${plan.priceAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '/ ${plan.billingCycleDays} days',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Accept Recommended Plan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/payg/payment', extra: {
                  'planId': plan.id,
                  'planName': plan.name,
                  'planType': plan.planType,
                  'amount': plan.priceAmount,
                  'currency': plan.currency,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Accept Recommended Plan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // View Other Plans
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/plans'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Other Plans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Continue with Free Access
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.pushReplacement(AppRoutes.home),
              child: const Text(
                'Continue with Free Access',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'Free access includes basic features with limited usage.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
