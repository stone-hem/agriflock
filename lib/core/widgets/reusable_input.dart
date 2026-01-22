import 'package:flutter/material.dart';

class ReusableInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? topLabel;
  final String hintText;
  final IconData? icon; // Already nullable
  final bool showIconOutline;
  final bool obscureText;
  final String? suffixText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final String? prefixText;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  const ReusableInput({
    super.key,
    this.controller,
    this.labelText,
    required this.hintText,
    this.icon, // Changed from required to optional
    this.showIconOutline = false,
    this.obscureText = false,
    this.suffixText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.topLabel, this.prefixText,
    this.initialValue, this.focusNode,
  });

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
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            suffixText: suffixText,
            prefixText: prefixText,
            // Conditionally show prefixIcon only when icon is not null
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
                : null, // Set to null when icon is null
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
              // Adjust left padding when there's no icon
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      ],
    );
  }
}
