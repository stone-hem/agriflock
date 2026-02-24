import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/features/auth/quiz/shared/gender_selector.dart';
import 'package:agriflock360/features/auth/shared/auth_text_field.dart';
import 'package:flutter/material.dart';

class VetPersonalInfoStep extends StatelessWidget {
  final TextEditingController dobController;
  final TextEditingController nationalIdController;
  final FocusNode nationalIdFocus;
  final String? selectedGender;
  final Function(String) onGenderSelected;
  final int currentYear;

  const VetPersonalInfoStep({
    super.key,
    required this.dobController,
    required this.nationalIdController,
    required this.nationalIdFocus,
    required this.selectedGender,
    required this.onGenderSelected,
    required this.currentYear,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),

          // Date of Birth Picker
          CustomDateTextField(
            controller: dobController,
            label: 'Date of Birth *Required',
            icon: Icons.calendar_today,
            returnFormat: DateReturnFormat.isoString,
            required: true,
            minYear: 1900,
            maxYear: currentYear - 18,
          ),
          const SizedBox(height: 24),

          // Gender
          GenderSelector(
            selectedGender: selectedGender,
            onGenderSelected: onGenderSelected,
          ),
          const SizedBox(height: 24),

          // National ID
          AuthTextField(
            controller: nationalIdController,
            labelText: 'National ID number*',
            hintText: 'Enter your national ID',
            icon: Icons.badge,
            focusNode: nationalIdFocus,
            keyboardType: TextInputType.text,
            value: '',
            maxLength: 50,
          ),

          const SizedBox(height: 30),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 0),
        ],
      ),
    );
  }
}
