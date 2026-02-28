import 'package:agriflock/core/widgets/expense/expense_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ValueConfirmationBanner extends StatelessWidget {
  final VoidCallback? onViewActivity;
  final String? farms;
  final String? houses;
  final String? batches;
  final String? birds;


  const ValueConfirmationBanner({
    super.key,
    this.onViewActivity, this.farms, this.houses, this.batches, this.birds,
  });

  void _showValueDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.verified, color: Colors.green),
              SizedBox(width: 8),
              SizedBox(width:100,child: Text('Farming with Confidence')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AgriFlock 360 is actively supporting your farm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Current support includes:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('📋 Customized feeding plans'),
              _buildFeatureItem('💉 Vaccination schedules & reminders'),
              _buildFeatureItem('💰 Market-ready quotations'),
              _buildFeatureItem('📈 Profit tracking & analytics'),
              _buildFeatureItem('🔔 Real-time notifications'),
              const SizedBox(height: 12),
              const Text(
                'View your farm activity to see detailed insights and performance metrics.',
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
                if (onViewActivity != null) {
                  onViewActivity!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Activity'),
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
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with icon and Learn More button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Confidence message with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      color: Colors.green.shade700,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Farming with confidence',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),

              // Learn More button
              TextButton(
                onPressed: () => _showValueDetailsDialog(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View farm activity',
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

          // Expense button
          ExpenseActionButton(
            onPressed: () {
              context.push('/record-expenditure');
            },
            buttonColor: Colors.red,
            descriptionColor: Colors.grey.shade700,
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