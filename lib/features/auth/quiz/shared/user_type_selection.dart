import 'package:agriflock360/lib/features/auth/quiz/shared/role_card.dart';
import 'package:flutter/material.dart';

class UserTypeSelection extends StatelessWidget {
  final String? selectedUserType;
  final Function(String) onUserTypeSelected;

  const UserTypeSelection({
    super.key,
    required this.selectedUserType,
    required this.onUserTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How will you be using our platform?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your role to customize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),
          RoleCard(
            icon: Icons.agriculture,
            title: 'Farmer',
            subtitle: 'Manage your poultry farm and track your flock',
            isSelected: selectedUserType == 'farmer',
            onTap: () => onUserTypeSelected('farmer'),
          ),
          const SizedBox(height: 20),
          RoleCard(
            icon: Icons.medical_services,
            title: 'Veterinarian(Extension officer)',
            subtitle: 'Provide professional services and consultations',
            isSelected: selectedUserType == 'vet',
            onTap: () => onUserTypeSelected('vet'),
          ),
        ],
      ),
    );
  }
}