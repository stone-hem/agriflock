import 'package:flutter/material.dart';

class OrderProcess extends StatelessWidget {
  const OrderProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Booking Process',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProcessStep(
              1,
              'Submit Request',
              'Fill out this booking form',
            ),
            _buildProcessStep(
              2,
              'Get Estimate',
              'Review estimated cost',
            ),
            _buildProcessStep(
              3,
              'Vet Review',
              'Vet reviews your request within 24 hours',
            ),
            _buildProcessStep(
              4,
              'Confirmation',
              'Receive booking confirmation',
            ),
            _buildProcessStep(
              5,
              'Service Delivery',
              'Vet visits your farm',
            ),
          ],
        ),
      ),
    );;
  }

  Widget _buildProcessStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
