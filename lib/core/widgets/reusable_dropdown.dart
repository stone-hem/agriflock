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
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final Widget? customIcon;
  final bool hideUnderline;

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
    this.suffixIcon,
    this.topLabel,
    this.padding,
    this.borderColor,
    this.borderRadius = 12,
    this.textStyle,
    this.customIcon,
    this.hideUnderline = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget dropdownWidget = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.grey.shade300),
        borderRadius: BorderRadius.circular(borderRadius),
        color: backgroundColor,
      ),
      child: hideUnderline
          ? DropdownButtonHideUnderline(
        child: _buildDropdownButton(context),
      )
          : _buildDropdownButton(context),
    );

    // If there's no top label or icon, just return the styled dropdown
    if (topLabel == null && icon == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null) ...[
            Text(
              labelText!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],
          dropdownWidget,
        ],
      );
    }

    // Return the full layout with top row
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        if (topLabel != null || icon != null) const SizedBox(height: 8),
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        dropdownWidget,
      ],
    );
  }

  Widget _buildDropdownButton(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      hint: Text(
        hintText,
        style: const TextStyle(color: Colors.grey),
      ),
      isExpanded: isExpanded,
      icon: customIcon ?? const Icon(Icons.arrow_drop_down, color: Colors.green),
      iconSize: 24,
      style: textStyle ??
          const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(8),
      onChanged: enabled ? onChanged : null,
      items: items,
      dropdownColor: Colors.white,
      elevation: 4,
      disabledHint: Text(
        hintText,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

// Optional: If you still need the form field version with validation
class ReusableDropdownFormField<T> extends StatelessWidget {
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
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final Widget? customIcon;

  const ReusableDropdownFormField({
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
    this.suffixIcon,
    this.topLabel,
    this.padding,
    this.borderColor,
    this.borderRadius = 12,
    this.textStyle,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topLabel != null || icon != null) ...[
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
        ],
        Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: validator != null && validator!(value) != null
                  ? Colors.red.shade400
                  : borderColor ?? Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            color: backgroundColor,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              value: value,
              items: items,
              onChanged: enabled ? onChanged : null,
              validator: validator,
              isExpanded: isExpanded,
              decoration: InputDecoration(
                border: InputBorder.none,
                errorText: null,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              hint: Text(
                hintText,
                style: const TextStyle(color: Colors.grey),
              ),
              icon: customIcon ?? const Icon(Icons.arrow_drop_down, color: Colors.green),
              style: textStyle ??
                  const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
              dropdownColor: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (validator != null && validator!(value) != null) ...[
          const SizedBox(height: 4),
          Text(
            validator!(value)!,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}