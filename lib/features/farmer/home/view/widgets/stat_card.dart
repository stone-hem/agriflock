import 'package:flutter/material.dart';

class HomeStatCard extends StatelessWidget {
  final String mainValue;
  final String mainLabel;
  final List<StatItem>? additionalStats;
  final Color color;
  final Color textColor;
  final VoidCallback? onButtonPressed;
  final String? buttonText;
  final bool showDivider;

  const HomeStatCard({
    super.key,
    required this.mainValue,
    required this.mainLabel,
    this.additionalStats,
    required this.color,
    required this.textColor,
    this.onButtonPressed,
    this.buttonText,
    this.showDivider = true,
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
          // Main stat - emphasized
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainValue,
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mainLabel,
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Additional stats in compact layout
              if (additionalStats != null && additionalStats!.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _buildCompactStats(),
                ),
              ],
            ],
          ),


          // Button
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

  Widget _buildCompactStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: additionalStats!
          .take(5) // Limit to 4 stats for compact view
          .map((stat) => Text(
        '${stat.value} ${stat.label}',
        style: TextStyle(
          color: textColor.withOpacity(0.9),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ))
          .toList(),
    );
  }

}

// Helper class for additional stats
class StatItem {
  final String value;
  final String label;

  const StatItem({
    required this.value,
    required this.label,
  });
}