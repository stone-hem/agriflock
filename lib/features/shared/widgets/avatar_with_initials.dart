import 'package:flutter/material.dart';

class AvatarWithInitials extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? child;
  final BoxBorder? border;

  const AvatarWithInitials({
    super.key,
    required this.name,
    this.radius = 46,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.imageUrl,
    this.onTap,
    this.child,
    this.border,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      // Single name - take first 2 letters
      final singleName = parts[0];
      if (singleName.length >= 2) {
        return singleName.substring(0, 2).toUpperCase();
      } else {
        return singleName.toUpperCase();
      }
    } else {
      // Multiple names - take first letter of first and last
      final firstInitial = parts.first.isNotEmpty ? parts.first[0] : '';
      final lastInitial = parts.last.isNotEmpty ? parts.last[0] : '';
      return '$firstInitial$lastInitial'.toUpperCase();
    }
  }

  Color _getColorFromName(String name) {
    // Generate a consistent color based on the name
    final hash = name.hashCode.abs();
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final bgColor = backgroundColor ?? _getColorFromName(name);
    final defaultTextStyle = TextStyle(
      color: textColor ?? Colors.white,
      fontSize: radius * 0.4,
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: imageUrl == null ? bgColor : null,
          image: imageUrl != null
              ? DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          )
              : null,
          border: border,
        ),
        child: imageUrl == null
            ? Center(
          child: Text(
            initials,
            style: textStyle ?? defaultTextStyle,
          ),
        )
            : (child ?? Container()),
      ),
    );
  }
}