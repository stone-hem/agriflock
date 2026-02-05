// repositories/profile_repository.dart

import 'dart:convert';
import 'dart:io';

import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:http/http.dart' as http;

import '../../../../main.dart';
import '../models/profile_model.dart';


class ProfileRepository {

  /// Update user profile
  Future<Result> updateProfile(
      UpdateProfileRequest request,
      ) async {
    try {
      LogUtil.info('Request data: ${request.toJson()}');

      final response = await apiClient.put(
        '/users/profile',
        headers: {
          'Content-Type': 'application/json',
        },
        body: request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Update Profile API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to update profile',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in updateProfile: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in updateProfile: $e');
      return const Failure(
        message: 'Invalid request or response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in updateProfile: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to update profile',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result<ProfileData>> getProfile() async {
    try {
      LogUtil.info('Fetching profile...');

      final response = await apiClient.get(
        '/users/profile',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Profile API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['data'] != null) {
          final profileData = ProfileData.fromJson(jsonResponse['data']);
          return Success(profileData);
        } else {
          return Failure(
            message: 'Invalid response format: data field is missing',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch profile',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getProfile: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in getProfile: $e');
      return const Failure(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getProfile: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch profile',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Upload user avatar
  Future<Result> uploadAvatar(File imageFile) async {
    try {
      LogUtil.info('Uploading avatar file: ${imageFile.path}');

      // Create MultipartFile from the image
      final fileName = imageFile.path.split('/').last;
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: fileName,
      );

      // Use the new single file upload method
      final streamedResponse = await apiClient.putMultipartSingleFile(
        '/users/profile/avatar',
        file: multipartFile,
      );

      // Convert StreamedResponse to Response
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = jsonDecode(response.body);

      final newAvatarUrl = jsonResponse['data']?['avatar_url'] ;

      LogUtil.info('Upload Avatar API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(newAvatarUrl);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to upload avatar',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in uploadAvatar: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in uploadAvatar: $e');
      return const Failure(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in uploadAvatar: $e');
      return Failure(message: e.toString());
    }
  }

  /// Delete user avatar
  Future<Result> deleteAvatar() async {
    try {
      LogUtil.info('Deleting user avatar');

      final response = await apiClient.delete(
        '/users/profile/avatar',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Delete Avatar API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete avatar',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteAvatar: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in deleteAvatar: $e');
      return const Failure(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in deleteAvatar: $e');
      return Failure(message: e.toString());
    }
  }





}