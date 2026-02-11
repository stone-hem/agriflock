import 'package:agriflock360/core/widgets/expense/expense_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FutureFramingBanner extends StatelessWidget {
  final VoidCallback? onSeePlans;
  final String? farms;
  final String? houses;
  final String? batches;
  final String? birds;


  const FutureFramingBanner({
    super.key,
    this.onSeePlans, this.farms, this.houses, this.batches, this.birds,
  });

  void _showLearnMoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.timer, color: Colors.orange),
              SizedBox(width: 8),
              Text('Trial Ending Soon'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Full Farm Experience ends in 9 days (Day 21)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Continue receiving:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('📋 Feeding guidance'),
              _buildFeatureItem('💉 Vaccination reminders'),
              _buildFeatureItem('💰 Quotations and pricing'),
              const SizedBox(height: 12),
              const Text(
                'Choose the right plan for your farm to continue all features.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onSeePlans != null) {
                  onSeePlans!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('See Plans'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with trial info and Learn More button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Trial info
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.orange.shade700,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '9 Days Remaining',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Day 21',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              // Learn More button
              TextButton(
                onPressed: () => _showLearnMoreDialog(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Learn More',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 8),

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

          // Expense button - taking full width
          ExpenseActionButton(
            onPressed: () {
              context.push('/record-expenditure');
            },
            buttonColor: Colors.red,
            descriptionColor: Colors.grey.shade700,
            // Optional: You can make it more compact with these parameters
            buttonHeight: 34,
            buttonTextSize: 12,
            descriptionTextSize: 11,
            spacing: 3,
          ),
        ],
      ),
    );
  }
}