import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon; // Optional icon
  final Color? iconColor; // Optional icon color
  final double iconSize; // Icon size
  final bool showIconOnTop; // Whether to show icon above or beside value
  final MainAxisAlignment iconAlignment; // Icon alignment when beside value

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
    this.iconColor,
    this.iconSize = 24,
    this.showIconOnTop = false,
    this.iconAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null && showIconOnTop) ...[
            Icon(
              icon,
              color: iconColor ?? textColor,
              size: iconSize,
            ),
            const SizedBox(height: 8),
          ],

          // Value row with optional icon
          Row(
            mainAxisAlignment: iconAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null && !showIconOnTop) ...[
                Icon(
                  icon,
                  color: iconColor ?? textColor,
                  size: iconSize,
                ),
                const SizedBox(width: 4),
              ],

              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Label
          Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
