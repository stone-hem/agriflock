import 'package:agriflock360/core/widgets/expense/expense_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeSection extends StatelessWidget {
  final String greeting;
  final int? daysSinceLogin;
  final String? userName;
  final String? farms;
  final String? houses;
  final String? batches;
  final String? birds;


  const WelcomeSection({
    super.key,
    required this.greeting,
    this.daysSinceLogin,
    this.userName, this.farms, this.houses, this.batches, this.birds,
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
        crossAxisAlignment: .start,
        children: [

          Row(
            crossAxisAlignment: .center,
            children: [
              Text(
                userName != null && userName!.isNotEmpty
                    ? '$greeting, $userName'
                    : greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 2),
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
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                '$farms Farm(s)',
                style: TextStyle(
                  color: Colors.green.shade600,
                  fontSize: 13,
                ),
              ),
              Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54, // Color of the dot
                ),
              ),
              Text(
                '$houses House(s)',
                style: TextStyle(
                  color: Colors.green.shade600,
                  fontSize: 13,
                ),
              ),
              Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54, // Color of the dot
                ),
              ),
              Text(
                '$batches Batch(es)',
                style: TextStyle(
                  color: Colors.green.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          TextButton.icon(
            onPressed: () {
              context.push('/record-expenditure');
            },
            icon: Icon(Icons.arrow_forward),
            label: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Quick expense',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.red
                    ),
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: 'Add your expenses and selling price to see your profit.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}