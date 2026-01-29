import 'package:agriflock360/features/auth/quiz/shared/education_level_selector.dart';
import 'package:agriflock360/features/auth/shared/auth_text_field.dart';
import 'package:flutter/material.dart';

class VetProfessionalStep extends StatelessWidget {
  final TextEditingController fieldOfStudyController;
  final TextEditingController experienceController;
  final TextEditingController profileController;
  final FocusNode fieldOfStudyFocus;
  final FocusNode experienceFocus;
  final FocusNode profileFocus;
  final String? selectedEducationLevel;
  final Function(String) onEducationLevelSelected;

  const VetProfessionalStep({
    super.key,
    required this.fieldOfStudyController,
    required this.experienceController,
    required this.profileController,
    required this.fieldOfStudyFocus,
    required this.experienceFocus,
    required this.profileFocus,
    required this.selectedEducationLevel,
    required this.onEducationLevelSelected,
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

          // Field of Study
          AuthTextField(
            controller: fieldOfStudyController,
            labelText: 'Field of Study *Required',
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
            labelText: 'Years of Experience *Required',
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
            labelText: 'Professional Summary *Required',
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
