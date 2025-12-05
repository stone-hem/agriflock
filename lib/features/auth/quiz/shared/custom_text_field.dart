import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final String value;
  final Function(String)? onChanged;
  final TextEditingController controller;


  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon, color: Colors.green),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              counterText: maxLength != null ? '${value.length}/$maxLength' : null,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
