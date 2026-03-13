import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    bool floating = true,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colors = _colors(type);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_icon(type), color: colors.iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: colors.textColor, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: colors.backgroundColor,
          behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
          shape: floating
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              : null,
          duration: duration,
          margin: floating
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
              : null,
        ),
      );
  }

  static IconData _icon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_outlined;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }

  static _SnackBarColors _colors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarColors(
          backgroundColor: const Color(0xFF1A4731),
          textColor: const Color(0xFFB6F5D2),
          iconColor: const Color(0xFF3DD68C),
        );
      case SnackBarType.error:
        return _SnackBarColors(
          backgroundColor: const Color(0xFF4A1919),
          textColor: const Color(0xFFF5B6B6),
          iconColor: const Color(0xFFFF6B6B),
        );
      case SnackBarType.warning:
        return _SnackBarColors(
          backgroundColor: const Color(0xFF4A3A10),
          textColor: const Color(0xFFF5E4B6),
          iconColor: const Color(0xFFF1C04C),
        );
      case SnackBarType.info:
        return _SnackBarColors(
          backgroundColor: const Color(0xFF1A2E4A),
          textColor: const Color(0xFFB6D4F5),
          iconColor: const Color(0xFF5B9BD5),
        );
    }
  }
}

class _SnackBarColors {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  const _SnackBarColors({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
  });
}
