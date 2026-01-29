import 'package:agriflock360/features/auth/shared/auth_text_field.dart';
import 'package:flutter/material.dart';

class FarmerDetailsStep extends StatelessWidget {
  final TextEditingController chickenNumberController;
  final TextEditingController experienceController;
  final FocusNode chickenNumberFocus;
  final FocusNode experienceFocus;

  const FarmerDetailsStep({
    super.key,
    required this.chickenNumberController,
    required this.experienceController,
    required this.chickenNumberFocus,
    required this.experienceFocus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your farm',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This information helps us personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),
          AuthTextField(
            labelText: 'Current number of chickens',
            hintText: 'Enter the number of chickens you rear',
            icon: Icons.numbers,
            keyboardType: TextInputType.number,
            controller: chickenNumberController,
            focusNode: chickenNumberFocus,
            nextFocusNode: experienceFocus,
            value: '',
          ),
          const SizedBox(height: 20),
          AuthTextField(
            labelText: 'Years of experience',
            hintText: 'Enter your years of experience in poultry farming',
            icon: Icons.work,
            keyboardType: TextInputType.number,
            controller: experienceController,
            focusNode: experienceFocus,
            maxLength: 2,
            value: '',
          ),
          const SizedBox(height: 30),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 0),
        ],
      ),
    );
  }
}
