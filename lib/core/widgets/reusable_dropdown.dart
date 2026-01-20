import 'package:flutter/material.dart';

class ReusableDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? labelText;
  final String hintText;
  final IconData? icon;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enabled;
  final bool isExpanded;
  final Widget? suffixIcon;
  final String? topLabel;


  const ReusableDropdown({
    super.key,
    required this.value,
    required this.items,
    this.labelText,
    required this.hintText,
    this.icon,
    this.validator,
    this.onChanged,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
    this.isExpanded = true,
    this.suffixIcon, this.topLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          isExpanded: isExpanded,
          isDense: true, // Helps with vertical spacing
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            // Fixed prefixIcon with explicit constraints
            prefixIcon: icon != null
                ? Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor ?? Colors.green.shade600,
                ),
              ),
            )
                : null,
            prefixIconConstraints: icon != null
                ? const BoxConstraints(
              minWidth: 60,
              minHeight: 40,
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
              borderSide: BorderSide(
                color: Colors.green.shade600,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade600,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: icon != null ? 12 : 16,
              vertical: 16,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      ],
    );
  }
}
