import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeSection extends StatelessWidget {
  final String greeting;
  final String summaryMsg;
  final int? daysSinceLogin;

  const WelcomeSection({
    super.key,
    required this.greeting,
    required this.summaryMsg,
    this.daysSinceLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.lightGreen.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (daysSinceLogin != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Text(
                'Day $daysSinceLogin',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          Text(
            greeting,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Welcome back to your farm',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summaryMsg,
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/record-expenditure'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Quick expense', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}