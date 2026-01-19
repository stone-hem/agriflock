import 'package:flutter/material.dart';

class HomeStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onButtonPressed;
  final String? buttonText;


  const HomeStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    this.onButtonPressed, this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (onButtonPressed != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onButtonPressed,
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.arrow_forward,
                size: 16,
                color: textColor,
              ),
              label: Text(
                buttonText!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}