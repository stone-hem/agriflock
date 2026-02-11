import 'package:flutter/material.dart';

class Day27DecisionModal extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback? onDismiss;

  const Day27DecisionModal({
    super.key,
    required this.onContinue,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '27 Days Completed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '4 days left',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),


            const SizedBox(height: 20),

            // Progress indicator
            LinearProgressIndicator(
              value: 27/30,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 28),

            // Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights,
                size: 40,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            const Text(
              'You\'ve been farming smarter for 27 days',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,

              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            const Text(
              'Based on your activity, AgriFlock 360 is preparing a plan recommendation tailored to your farm size and usage.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,

              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Dismiss Button
            TextButton(
              onPressed: onDismiss ?? () => Navigator.pop(context),
              child: const Text(
                'Not now',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}