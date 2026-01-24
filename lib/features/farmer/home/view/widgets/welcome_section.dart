import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeSection extends StatelessWidget {
  final String greeting;
  final String summaryMsg;
  final int? daysSinceLogin; // Add this

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.lightGreen.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (daysSinceLogin != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Text(
                'Day $daysSinceLogin',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          Text(
            greeting,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Welcome back to your farm',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summaryMsg,
            style: TextStyle(color: Colors.green.shade600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => context.push('/record-expenditure'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade800,
            ),
            icon: Icon(Icons.arrow_forward, color: Colors.red.shade800),
            label: Text('Record an expense'),
          ),
        ],
      ),
    );
  }
}
