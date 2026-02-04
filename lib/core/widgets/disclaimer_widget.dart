import 'package:flutter/material.dart';

class DisclaimerWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment? crossAxisAlignment;
  final double? iconSize;
  final double? titleSize;
  final double? messageSize;
  final FontWeight? titleWeight;

  const DisclaimerWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.warning_amber,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.borderRadius = 12.0,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.iconSize = 24.0,
    this.titleSize = 18.0,
    this.messageSize = 14.0,
    this.titleWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Use provided colors or fallback to red shades
    final Color bgColor = backgroundColor ?? colorScheme.errorContainer;
    final Color brdColor = borderColor ?? colorScheme.error.withOpacity(0.3);
    final Color txtColor = textColor ?? colorScheme.onErrorContainer;

    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius!),
        border: Border.all(color: brdColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment!,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: txtColor,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: txtColor,
                    fontSize: titleSize,
                    fontWeight: titleWeight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: icon != null ? 36 : 0),
            child: Text(
              message,
              style: TextStyle(
                color: txtColor,
                fontSize: messageSize,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Usage examples:
class ExampleUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Default red disclaimer
        const DisclaimerWidget(
          title: 'Disclaimer',
          message: 'Record all activities for accurate reports. '
              'This information will be used for analytics and compliance purposes.',
        ),

        const SizedBox(height: 16),

        // Blue info variant
        DisclaimerWidget(
          title: 'Information',
          message: 'Your data is encrypted and stored securely. '
              'You can export your records anytime.',
          icon: Icons.info_outline,
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          textColor: Colors.blue.shade900,
        ),

        const SizedBox(height: 16),

        // Green success variant
        DisclaimerWidget(
          title: 'Success',
          message: 'All changes have been saved successfully.',
          icon: Icons.check_circle_outline,
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          textColor: Colors.green.shade900,
        ),

        const SizedBox(height: 16),

        // Custom styled variant
        DisclaimerWidget(
          title: 'Important Note',
          message: 'This action cannot be undone. '
              'Please review before proceeding.',
          icon: Icons.error_outline,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange,
          borderRadius: 16.0,
          padding: const EdgeInsets.all(20),
        ),

        const SizedBox(height: 16),

        // Without icon
        DisclaimerWidget(
          title: 'Reminder',
          message: 'Please submit your report by Friday.',
          icon: null,
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
        ),
      ],
    );
  }
}