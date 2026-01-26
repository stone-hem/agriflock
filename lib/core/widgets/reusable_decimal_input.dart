import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom TextInputFormatter that automatically adds a decimal point
/// after the first digit and limits to 2 decimal places (format: X.XX)
class AutoDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Remove any non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 3 digits maximum (X.XX format)
    if (digitsOnly.length > 3) {
      digitsOnly = digitsOnly.substring(0, 3);
    }

    String formattedText;
    int cursorPosition;

    if (digitsOnly.isEmpty) {
      formattedText = '';
      cursorPosition = 0;
    } else if (digitsOnly.length == 1) {
      // Just one digit, no dot yet for display but we'll handle it
      formattedText = digitsOnly;
      cursorPosition = 1;
    } else {
      // Two or more digits: insert dot after first digit
      formattedText = '${digitsOnly[0]}.${digitsOnly.substring(1)}';
      cursorPosition = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class ReusableDecimalInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? topLabel;
  final String hintText;
  final IconData? icon;
  final bool showIconOutline;
  final String? suffixText;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enabled;
  final String? prefixText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  const ReusableDecimalInput({
    super.key,
    this.controller,
    this.labelText,
    required this.hintText,
    this.icon,
    this.showIconOutline = false,
    this.suffixText,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.topLabel,
    this.prefixText,
    this.focusNode,
  });

  /// Helper method to get the actual decimal value from the controller
  /// Use this to retrieve the formatted decimal value (e.g., "0.99")
  static double? getValue(TextEditingController controller) {
    String text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return null;

    if (text.length == 1) {
      // Single digit: treat as "0.X"
      return double.parse('0.0$text');
    } else if (text.length == 2) {
      // Two digits: treat as "0.XX"
      return double.parse('0.$text');
    } else {
      // Three digits: treat as "X.XX"
      return double.parse('${text[0]}.${text.substring(1)}');
    }
  }

  /// Helper method to set a decimal value to the controller
  /// Use this to programmatically set values
  static void setValue(TextEditingController controller, double value) {
    if (value < 0 || value > 9.99) {
      throw ArgumentError('Value must be between 0 and 9.99');
    }

    // Convert to string with 2 decimal places
    String valueStr = value.toStringAsFixed(2);
    // Remove the decimal point for internal representation
    String digitsOnly = valueStr.replaceAll('.', '');

    // Format it properly
    if (digitsOnly.length == 1 || (digitsOnly.length == 2 && digitsOnly.startsWith('0'))) {
      controller.text = digitsOnly;
    } else if (digitsOnly.length >= 2) {
      controller.text = '${digitsOnly[0]}.${digitsOnly.substring(1)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
            ],
            if (topLabel != null) ...[
              Text(
                topLabel!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            AutoDecimalFormatter(),
          ],
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: 1,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            suffixText: suffixText,
            prefixText: prefixText,
            prefixIcon: icon != null && showIconOutline
                ? Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.green.shade600,
              ),
            )
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: icon != null ? 16 : 10,
              vertical: 16,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      ],
    );
  }
}

