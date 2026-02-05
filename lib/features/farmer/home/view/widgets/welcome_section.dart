import 'package:agriflock360/core/widgets/expense/expense_button.dart';
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
          const SizedBox(height: 2),
          Text(
            '$greeting, Welcome back',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            summaryMsg,
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          ExpenseActionButton(
            onPressed: () {
              context.push('/record-expenditure');
            },
            buttonColor: Colors.red,
          )
        ],
      ),
    );
  }
}