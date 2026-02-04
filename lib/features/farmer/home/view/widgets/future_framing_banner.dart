import 'package:agriflock360/core/widgets/expense/expense_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FutureFramingBanner extends StatelessWidget {
  final VoidCallback? onSeePlans;

  const FutureFramingBanner({
    super.key,
    this.onSeePlans,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF57C00), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.timer, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    '9 Days Remaining',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Day 21',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            children:[
              const Text(
              'Your Full Farm Experience ends in 9 days',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
              TextButton.icon(
                onPressed: onSeePlans ?? () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.yellow,
                  textStyle: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  )
                ),

                icon: Icon(Icons.crisis_alert_outlined, size: 16,fontWeight: FontWeight.bold,),
                label: const Text(
                  'See what happens after trial',
                ),
              ),]
          ),
          const Text(
            'Continue receiving feeding guidance, vaccination reminders, and quotations by choosing the right plan for your farm.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          ExpenseActionButton(
            onPressed: () {
              context.push('/record-expenditure');
            },
            buttonColor: Colors.red,
              descriptionColor:Colors.white

          )

        ],
      ),
    );
  }
}