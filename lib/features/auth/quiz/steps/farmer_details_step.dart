import 'package:agriflock/features/auth/shared/auth_text_field.dart';
import 'package:flutter/material.dart';

class FarmerDetailsStep extends StatelessWidget {
  final TextEditingController experienceController;
  final FocusNode experienceFocus;

  const FarmerDetailsStep({
    super.key,
    required this.experienceController,
    required this.experienceFocus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
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
