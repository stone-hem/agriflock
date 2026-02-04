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
    this.titleSize = 16.0,
    this.messageSize = 13.0,
    this.titleWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {

    // Use provided colors or fallback to red shades
    final Color bgColor = backgroundColor ?? Colors.red.shade100;
    final Color brdColor = borderColor ?? Colors.red.shade200;
    final Color txtColor = textColor ?? Colors.red;

    return Container(
      padding: padding ?? const EdgeInsets.all(12.0),
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
                const SizedBox(width: 8),
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
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: txtColor,
              fontSize: messageSize,
            ),
          ),
        ],
      ),
    );
  }
}

