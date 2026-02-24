import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../../../main.dart';

class OnboardingRepository {
  Future<Map<String, dynamic>> submitFarmerOnboarding({
    required String token,
    required String address,
    required double latitude,
    required double longitude,
    required int yearsOfExperience
  }) async {
    try {
      final body = <String, dynamic>{
        'location': {
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        },
        'years_of_experience': yearsOfExperience,
      };

      final response = await apiClient.post(
        '/auth/farmer-register',
        body: body,
        headers: {'Authorization': 'Bearer $token'},
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Farm profile created successfully'
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create farm profile',
          'statusCode': response.statusCode,
          'response': response,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'error': e,
      };
    }
  }

  Future<Map<String, dynamic>> submitVetOnboarding({
    required String token,
    required String address,
    required double latitude,
    required double longitude,
    required String dateOfBirth,
    required String gender,
    required String yearsOfExperience,
    required String professionalSummary,
    required String educationLevel,
    required String idPhotoPath,
    required String selfiePath,
    required List<PlatformFile> certificates,
    List<PlatformFile>? additionalDocuments,
    required String nationalId,
    required String fieldOfStudy,
  }) async {
    try {
      // Prepare fields
      final fields = <String, String>{
        'location': jsonEncode({
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        }),
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'years_of_experience': yearsOfExperience,
        'profile_bio': professionalSummary,
        'education_level': educationLevel,
        'officer_type': 'vet',
        'national_id': nationalId,
        'field_of_study': fieldOfStudy,
      };

      // Prepare files
      final files = <http.MultipartFile>[];

      // Add ID photo
      files.add(await http.MultipartFile.fromPath(
        'id_photo',
        idPhotoPath,
      ));

      // Add selfie
      files.add(await http.MultipartFile.fromPath(
        'face_selfie',
        selfiePath,
      ));

      // Add certificates
      for (var file in certificates) {
        if (file.path != null) {
          files.add(await http.MultipartFile.fromPath(
            'certificates',
            file.path!,
          ));
        }
      }

// Add additional documents if any
      if (additionalDocuments != null) {
        for (var file in additionalDocuments) {
          if (file.path != null) {
            files.add(await http.MultipartFile.fromPath(
              'additional_certificates',
              file.path!,
            ));
          }
        }
      }


      // Submit multipart request
      final streamedResponse = await apiClient.postMultipart(
        '/extension-officers',
        fields: fields,
        files: files,
        headers: {'Authorization': 'Bearer $token'},
      );

      // Convert StreamedResponse to Response to read body
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Veterinary profile submitted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit veterinary profile',
          'statusCode': response.statusCode,
          'response': response,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'error': e,
      };
    }
  }
}