// lib/features/farmer/batch/repo/vaccination_repository.dart

import 'dart:convert';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/features/farmer/batch/model/vaccination_model.dart';
import 'package:agriflock360/features/farmer/batch/model/recommended_vaccination_model.dart'; // Add this
import 'package:agriflock360/main.dart';

class VaccinationRepository {
  /// Get all vaccinations for a batch
  Future<VaccinationsResponse> getVaccinations(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/vaccinations',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Vaccinations API Response: $jsonResponse');

      return VaccinationsResponse.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getVaccinations: $e');
      rethrow;
    }
  }

  /// Get vaccination dashboard statistics
  Future<VaccinationDashboard> getVaccinationDashboard(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/vaccinations/vaccinations/dashboard',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Vaccination Dashboard API Response: $jsonResponse');

      return VaccinationDashboard.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getVaccinationDashboard: $e');
      rethrow;
    }
  }

  /// Get recommended vaccinations for a batch based on age
  Future<RecommendedVaccinationsResponse> getRecommendedVaccinations(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/vaccinations/recommendations',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch recommendations');
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Recommended Vaccinations API Response: $jsonResponse');

      return RecommendedVaccinationsResponse.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getRecommendedVaccinations: $e');
      rethrow;
    }
  }

  /// Create a new vaccination schedule
  Future<Vaccination> createVaccination(
      String batchId,
      CreateVaccinationRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations',
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to create vaccination');
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Create Vaccination API Response: $jsonResponse');

      return Vaccination.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in createVaccination: $e');
      rethrow;
    }
  }

  /// Update vaccination status
  Future<Vaccination> updateVaccinationStatus(
      String batchId,
      String vaccinationId,
      UpdateVaccinationStatusRequest request,
      ) async {
    try {
      final response = await apiClient.put(
        '/batches/$batchId/vaccinations/$vaccinationId',
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(
          jsonResponse['message'] ?? 'Failed to update vaccination status',
        );
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Update Vaccination Status API Response: $jsonResponse');

      return Vaccination.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in updateVaccinationStatus: $e');
      rethrow;
    }
  }

  /// Quick done - Create completed vaccination
  Future<Vaccination> quickDoneVaccination(
      String batchId,
      QuickDoneVaccinationRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations',
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(
          jsonResponse['message'] ?? 'Failed to record vaccination',
        );
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Quick Done Vaccination API Response: $jsonResponse');

      return Vaccination.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in quickDoneVaccination: $e');
      rethrow;
    }
  }

  /// Adopt a single recommended vaccination
  Future<Vaccination> adoptRecommendedVaccination(
      String batchId,
      AdoptVaccinationRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations/adopt',
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to adopt vaccination');
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Adopt Vaccination API Response: $jsonResponse');

      return Vaccination.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in adoptRecommendedVaccination: $e');
      rethrow;
    }
  }

  /// Adopt all recommended vaccinations
  Future<List<Vaccination>> adoptAllRecommendedVaccinations(
      String batchId,
      AdoptAllVaccinationsRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations/adopt-all',
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to adopt all vaccinations');
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Adopt All Vaccinations API Response: $jsonResponse');

      final List<dynamic> data = jsonResponse['data'] as List;
      return data.map((e) => Vaccination.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      LogUtil.error('Error in adoptAllRecommendedVaccinations: $e');
      rethrow;
    }
  }

  /// Delete vaccination
  Future<void> deleteVaccination(String batchId, String vaccinationId) async {
    try {
      final response = await apiClient.delete(
        '/batches/$batchId/vaccinations/$vaccinationId',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(
          jsonResponse['message'] ?? 'Failed to delete vaccination',
        );
      }

      LogUtil.info('Delete Vaccination: Success');
    } catch (e) {
      LogUtil.error('Error in deleteVaccination: $e');
      rethrow;
    }
  }

  /// Refresh methods
  Future<VaccinationsResponse> refreshVaccinations(String batchId) async {
    return getVaccinations(batchId);
  }

  Future<VaccinationDashboard> refreshVaccinationDashboard(String batchId) async {
    return getVaccinationDashboard(batchId);
  }

  Future<RecommendedVaccinationsResponse> refreshRecommendedVaccinations(String batchId) async {
    return getRecommendedVaccinations(batchId);
  }
}