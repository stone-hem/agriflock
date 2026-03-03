import 'package:agriflock/core/widgets/location_picker_step.dart';
import 'package:agriflock/features/auth/shared/auth_text_field.dart';
import 'package:flutter/material.dart';

class FarmerDetailsStep extends StatelessWidget {
  final TextEditingController experienceController;
  final FocusNode experienceFocus;
  final String? selectedAddress;
  final double? latitude;
  final double? longitude;
  final Function(String address, double lat, double lng) onLocationSelected;

  const FarmerDetailsStep({
    super.key,
    required this.experienceController,
    required this.experienceFocus,
    this.selectedAddress,
    this.latitude,
    this.longitude,
    required this.onLocationSelected,
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
          const SizedBox(height: 16),
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
          LocationPickerStep(
            selectedAddress: selectedAddress,
            latitude: latitude,
            longitude: longitude,
            title: 'My Location',
            text: 'Select your current location',
            onLocationSelected: onLocationSelected,
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 0),
        ],
      ),
    );
  }
}
