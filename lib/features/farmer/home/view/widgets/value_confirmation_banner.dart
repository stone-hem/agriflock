import 'package:agriflock360/core/widgets/expense/expense_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ValueConfirmationBanner extends StatelessWidget {
  final VoidCallback? onViewActivity;

  const ValueConfirmationBanner({
    super.key,
    this.onViewActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green, Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'You\'re farming with confidence',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onViewActivity ?? () {},
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
              'View farm activity',
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'AgriFlock 360 is actively supporting your farm with feeding plans, vaccination schedules, and market-ready quotations.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 10),
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