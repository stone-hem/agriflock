import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? padding;
  final Color? fillColor;
  final Color? borderColor;

  const SearchInput({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.textInputAction,
    this.padding,
    this.fillColor,
    this.borderColor, this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
        ),
        prefixIcon: prefixIcon ?? const Icon(
          Icons.search,
          size: 20,
          color: Colors.grey,
        ),
        suffixIcon: suffixIcon ?? (controller?.text.isNotEmpty == true
            ? IconButton(
          icon: const Icon(
            Icons.clear,
            size: 18,
            color: Colors.grey,
          ),
          onPressed: () {
            controller?.clear();
            onChanged?.call('');
            onClear?.call();
          },
        )
            : null),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
        isDense: true,
      ),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }
}