import 'package:flutter/material.dart';

class ExpenseActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final String description;
  final IconData icon;
  final Color? buttonColor;
  final Color? textColor;
  final Color? descriptionColor;
  final double? buttonHeight;
  final double? buttonWidth;
  final EdgeInsetsGeometry? buttonPadding;
  final double? iconSize;
  final double? buttonTextSize;
  final double? descriptionTextSize;
  final MainAxisAlignment alignment;
  final bool showIcon;
  final double spacing;


  const ExpenseActionButton({
    super.key,
    required this.onPressed,
    this.buttonText = 'Quick expense',
    this.description = 'Record your expenses to see production cost.',
    this.icon = Icons.arrow_forward,
    this.buttonColor,
    this.textColor = Colors.white,
    this.descriptionColor,
    this.buttonHeight = 36,
    this.buttonWidth,
    this.buttonPadding,
    this.iconSize = 16,
    this.buttonTextSize = 13,
    this.descriptionTextSize = 12,
    this.alignment = MainAxisAlignment.start,
    this.showIcon = true,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primaryColor = buttonColor ?? colorScheme.error;
    final Color descColor = descriptionColor ?? Theme.of(context).hintColor;

    return Column(
      crossAxisAlignment: alignment == MainAxisAlignment.center
          ? CrossAxisAlignment.center
          : alignment == MainAxisAlignment.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: textColor,
            padding: buttonPadding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size(0, buttonHeight!),
            fixedSize: buttonWidth != null ? Size(buttonWidth!, buttonHeight!) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: showIcon
              ? Icon(
            icon,
            size: iconSize,
          )
              : const SizedBox.shrink(),
          label: Text(
            buttonText,
            style: TextStyle(
              fontSize: buttonTextSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: spacing),
        SizedBox(
          width: buttonWidth,
          child: Text(
            description,
            style: TextStyle(
              fontSize: descriptionTextSize,
              color: descColor,
              height: 1.3,
            ),
            textAlign: alignment == MainAxisAlignment.center
                ? TextAlign.center
                : alignment == MainAxisAlignment.end
                ? TextAlign.right
                : TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}


