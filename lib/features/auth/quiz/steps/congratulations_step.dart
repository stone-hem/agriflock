import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CongratulationsStep extends StatelessWidget {
  final String? selectedUserType;
  final String? selectedAddress;
  final String identifier;

  // Farmer fields
  final String? chickenNumber;
  final String? farmerExperience;

  // Vet fields
  final String? educationLevel;
  final String? professionalSummary;
  final String? dateOfBirth;
  final String? gender;
  final String? vetExperience;
  final File? idPhotoFile;
  final File? selfieFile;
  final List<PlatformFile>? certificates;
  final List<PlatformFile>? additionalDocuments;


  const CongratulationsStep({
    super.key,
    required this.selectedUserType,
    required this.selectedAddress,
    this.chickenNumber,
    this.farmerExperience,
    this.educationLevel,
    this.professionalSummary,
    this.dateOfBirth,
    this.gender,
    this.vetExperience,
    this.idPhotoFile,
    this.selfieFile,
    this.certificates,
    this.additionalDocuments, required this.identifier,
  });

  bool get isFarmer => selectedUserType == 'farmer';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:  Icon(
              Icons.check_circle,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 32),
           Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            isFarmer
                ? 'Your farm account ($identifier)has been created successfully! '
                    'You can now start managing your poultry farm.'
                : 'Your veterinary account ($identifier) registration is complete! '
                    'Your documents have been submitted for admin verification.',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Summary Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Account Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem('Role', isFarmer ? 'Farmer' : 'Veterinary Doctor'),
                  _buildSummaryItem('Location', selectedAddress ?? 'Not provided'),
                  if (isFarmer) ...[
                    _buildSummaryItem('Chicken Number', chickenNumber ?? ''),
                    _buildSummaryItem('Experience', '${farmerExperience ?? ''} years'),
                  ] else ...[
                    _buildSummaryItem('Highest Education', educationLevel ?? 'Not provided'),
                    _buildSummaryItem('Professional Summary', professionalSummary ?? ''),
                    _buildSummaryItem(
                      'Date of Birth',
                      dateOfBirth?.isEmpty ?? true ? 'Not provided' : dateOfBirth!,
                    ),
                    _buildSummaryItem('Gender', gender?.toUpperCase() ?? ''),
                    _buildSummaryItem('Experience', '${vetExperience ?? ''} years'),
                    _buildSummaryItem('ID Photo', idPhotoFile != null ? 'Uploaded' : 'Not uploaded'),
                    _buildSummaryItem('Selfie', selfieFile != null ? 'Uploaded' : 'Not uploaded'),
                    _buildSummaryItem('Qualification Certificates', '${certificates?.length ?? 0} files'),
                    _buildSummaryItem('Additional Documents', '${additionalDocuments?.length ?? 0} files'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
