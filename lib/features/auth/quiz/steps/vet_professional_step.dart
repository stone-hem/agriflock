import 'package:agriflock/features/auth/quiz/shared/education_level_selector.dart';
import 'package:agriflock/features/auth/shared/auth_text_field.dart';
import 'package:flutter/material.dart';

class VetProfessionalStep extends StatelessWidget {
  final TextEditingController fieldOfStudyController;
  final TextEditingController experienceController;
  final TextEditingController profileController;
  final TextEditingController licenseNumberController;
  final FocusNode fieldOfStudyFocus;
  final FocusNode experienceFocus;
  final FocusNode profileFocus;
  final FocusNode licenseNumberFocus;
  final String? selectedEducationLevel;
  final Function(String) onEducationLevelSelected;

  const VetProfessionalStep({
    super.key,
    required this.fieldOfStudyController,
    required this.experienceController,
    required this.profileController,
    required this.licenseNumberController,
    required this.fieldOfStudyFocus,
    required this.experienceFocus,
    required this.profileFocus,
    required this.selectedEducationLevel,
    required this.onEducationLevelSelected,
    required this.licenseNumberFocus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Qualifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your professional background',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),

          // Education Level Radio Buttons
          EducationLevelSelector(
            selectedEducationLevel: selectedEducationLevel,
            onEducationLevelSelected: onEducationLevelSelected,
          ),
          const SizedBox(height: 24),

          // License Number of Study
          AuthTextField(
            controller: licenseNumberController,
            topLabel: 'License Number(Optional)',
            labelText: 'License Number(applies for vet doctors)',
            hintText: 'Enter Your License Number',
            icon: Icons.local_police,
            focusNode: licenseNumberFocus,
            nextFocusNode: fieldOfStudyFocus,
            maxLength: 100,
            value: '',
          ),
          const SizedBox(height: 20),

          // Field of Study
          AuthTextField(
            controller: fieldOfStudyController,
            topLabel: 'Field of Study*',
            labelText: 'e.g. Poultry Health and Management',
            hintText: 'e.g. Poultry Health and Management',
            icon: Icons.school,
            focusNode: fieldOfStudyFocus,
            nextFocusNode: experienceFocus,
            maxLength: 100,
            value: '',
          ),
          const SizedBox(height: 20),

          // Years of Experience
          AuthTextField(
            controller: experienceController,
            topLabel: 'Years of Experience*',
            labelText: 'Enter your years of veterinary experience(Max 50)',
            hintText: 'Enter your years of veterinary experience',
            icon: Icons.work,
            focusNode: experienceFocus,
            nextFocusNode: profileFocus,
            keyboardType: TextInputType.number,
            value: '',
            maxLength: 2,
          ),
          const SizedBox(height: 20),

          // Professional Profile
          AuthTextField(
            controller: profileController,
            topLabel: 'Professional Summary*',
            labelText: 'My Professional Summary',
            hintText: 'Brief description of your expertise and qualifications',
            icon: Icons.description,
            focusNode: profileFocus,
            maxLines: 3,
            maxLength: 100,
            value: '',
          ),

          const SizedBox(height: 30),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 150 : 0),
        ],
      ),
    );
  }
}
