import 'package:agriflock/core/widgets/location_picker_step.dart';
import 'package:agriflock/features/auth/shared/auth_text_field.dart';
import 'package:flutter/material.dart';

class FarmerDetailsStep extends StatefulWidget {
  final TextEditingController experienceController;
  final FocusNode experienceFocus;

  const FarmerDetailsStep({
    super.key,
    required this.experienceController,
    required this.experienceFocus,
  });

  @override
  State<FarmerDetailsStep> createState() => _FarmerDetailsStepState();
}

class _FarmerDetailsStepState extends State<FarmerDetailsStep> {


  // Location data (for both farmer and vet)
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;
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
            controller: widget.experienceController,
            focusNode: widget.experienceFocus,
            maxLength: 2,
            value: '',
          ),
          LocationPickerStep(
            selectedAddress: _selectedAddress,
            latitude: _latitude,
            longitude: _longitude,
            title: 'My Location',
            text: 'Select your current location',
            onLocationSelected: (String address, double lat, double lng) {
              setState(() {
                _selectedAddress = address;
                _latitude = lat;
                _longitude = lng;
              });
            },
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 0),
        ],
      ),
    );
  }
}
