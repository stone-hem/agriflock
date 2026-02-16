import 'dart:io';
import 'package:agriflock360/core/widgets/file_upload.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class VetDocumentsStep extends StatelessWidget {
  final List<PlatformFile> uploadedCertificates;
  final List<PlatformFile> uploadedFiles;
  final File? idPhotoFile;
  final File? selfieFile;
  final Function(List<PlatformFile>) onCertificatesSelected;
  final Function(int) onCertificateRemoved;
  final Function(List<PlatformFile>) onFilesSelected;
  final Function(int) onFileRemoved;
  final Function(File?) onIdPhotoSelected;
  final Function(File?) onSelfieSelected;

  static const Color primaryGreen = Colors.green;

  const VetDocumentsStep({
    super.key,
    required this.uploadedCertificates,
    required this.uploadedFiles,
    required this.idPhotoFile,
    required this.selfieFile,
    required this.onCertificatesSelected,
    required this.onCertificateRemoved,
    required this.onFilesSelected,
    required this.onFileRemoved,
    required this.onIdPhotoSelected,
    required this.onSelfieSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload required documents for verification',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),

          // Qualification Certificates Upload
          FileUpload(
            uploadedFiles: uploadedCertificates,
            onFilesSelected: onCertificatesSelected,
            onFileRemoved: onCertificateRemoved,
            title: 'Qualification Certificates *Required',
            description: 'Upload your professional certificate(s) (PDF/DOC/Images)',
          ),
          const SizedBox(height: 30),

          // ID Photo Upload
          PhotoUpload(
            file: idPhotoFile,
            onFileSelected: onIdPhotoSelected,
            title: 'ID Photo *Required',
            description: 'Upload a clear photo of your government-issued ID',
          ),
          const SizedBox(height: 24),

          // Face Selfie Upload
          PhotoUpload(
            file: selfieFile,
            onFileSelected: onSelfieSelected,
            title: 'Face Selfie *Required',
            description: 'Take a recent clear photo of yourself',
            showSelfieFirst: true,
            cameraOnly: true,
          ),
          const SizedBox(height: 30),

          // Additional File Upload Section
          FileUpload(
            uploadedFiles: uploadedFiles,
            onFilesSelected: onFilesSelected,
            onFileRemoved: onFileRemoved,
            title: 'Additional Certifications (Optional)',
            description: 'Upload additional professional certificates if any',
          ),

          const SizedBox(height: 30),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 150 : 0),
        ],
      ),
    );
  }
}
