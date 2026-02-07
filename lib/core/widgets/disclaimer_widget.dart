import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String message;

  // Icon options - either IconData or image path
  final IconData? icon;
  final String? iconImagePath;

  // Action button
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  // Styling
  final Color? backgroundColor;
  final Color? accentColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final double? titleSize;
  final double? messageSize;
  final FontWeight? titleWeight;
  final bool showIconBackground;
  final AnnouncementStyle style;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.flash_on,
    this.iconImagePath,
    this.actionLabel,
    this.onActionPressed,
    this.backgroundColor,
    this.accentColor,
    this.textColor,
    this.borderRadius = 16.0,
    this.padding,
    this.iconSize = 24.0,
    this.titleSize = 15.0,
    this.messageSize = 13.0,
    this.titleWeight = FontWeight.w600,
    this.showIconBackground = true,
    this.style = AnnouncementStyle.success,
  });

  @override
  Widget build(BuildContext context) {
    // Get style colors
    final styleColors = _getStyleColors();
    final Color bgColor = backgroundColor ?? styleColors.background;
    final Color accColor = accentColor ?? styleColors.accent;
    final Color txtColor = textColor ?? styleColors.text;

    return Container(
      padding: padding ?? const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius!),
        border: Border.all(color: accColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: accColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stylistic Icon Container
          _buildIconContainer(accColor, txtColor),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: txtColor,
                    fontSize: titleSize,
                    fontWeight: titleWeight,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    color: txtColor.withOpacity(0.8),
                    fontSize: messageSize,
                    height: 1.4,
                  ),
                ),
                // Action button (if provided)
                if (actionLabel != null && onActionPressed != null) ...[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton.icon(
                      onPressed: onActionPressed,
                      icon: Icon(Icons.arrow_forward, size: 16, color: accColor),
                      style: TextButton.styleFrom(
                        foregroundColor: accColor,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: Text(
                        actionLabel!,
                        style: TextStyle(
                          fontSize: messageSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          //underline this text
                          decoration: TextDecoration.underline,
                          decorationColor: accColor,
                          decorationThickness: 1.5,
                        ),


                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildIconContainer(Color accentColor, Color textColor) {
    final iconWidget = iconImagePath != null
        ? Image.asset(
      iconImagePath!,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
      color: showIconBackground ? accentColor : textColor,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.error_outline,
          size: iconSize,
          color: showIconBackground ? accentColor : textColor,
        );
      },
    )
        : Icon(
      icon,
      size: iconSize,
      color: showIconBackground ? accentColor : textColor,
    );

    if (showIconBackground) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: iconWidget,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: iconWidget,
    );
  }

  _StyleColors _getStyleColors() {
    switch (style) {
      case AnnouncementStyle.info:
        return _StyleColors(
          background: const Color(0xFFEEF6FF),
          accent: const Color(0xFF1E88E5),
          text: const Color(0xFF0D47A1),
        );
      case AnnouncementStyle.success:
        return _StyleColors(
          background: const Color(0xFFE8F5E9),
          accent: const Color(0xFF43A047),
          text: const Color(0xFF1B5E20),
        );
      case AnnouncementStyle.warning:
        return _StyleColors(
          background: const Color(0xFFFFF3E0),
          accent: const Color(0xFFFB8C00),
          text: const Color(0xFFE65100),
        );
      case AnnouncementStyle.error:
        return _StyleColors(
          background: const Color(0xFFFFEBEE),
          accent: const Color(0xFFE53935),
          text: const Color(0xFFB71C1C),
        );
      case AnnouncementStyle.neutral:
        return _StyleColors(
          background: const Color(0xFFF5F5F5),
          accent: const Color(0xFF616161),
          text: const Color(0xFF212121),
        );
      case AnnouncementStyle.premium:
        return _StyleColors(
          background: const Color(0xFFF3E5F5),
          accent: const Color(0xFF8E24AA),
          text: const Color(0xFF4A148C),
        );
    }
  }
}

class _StyleColors {
  final Color background;
  final Color accent;
  final Color text;

  _StyleColors({
    required this.background,
    required this.accent,
    required this.text,
  });
}

enum AnnouncementStyle {
  info,
  success,
  warning,
  error,
  neutral,
  premium,
}