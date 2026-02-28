import 'dart:convert';
import 'dart:io';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/farmer/batch/model/vaccination_list_model.dart';
import 'package:agriflock/features/farmer/batch/model/vaccination_model.dart';
import 'package:agriflock/features/farmer/batch/model/recommended_vaccination_model.dart';
import 'package:agriflock/main.dart';
import 'package:http/http.dart' as http;

class VaccinationRepository {
  /// Get vaccinations history for a batch
  Future<Result<VaccinationListResponse>> getVaccinationList({
    required String batchId,
  }) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/vaccinations/lists',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Vaccination List API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(VaccinationListResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch vaccination list',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVaccinationList: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in getVaccinationList: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch vaccination list',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


  /// Get recommended vaccinations for a batch based on age
  Future<Result<RecommendedVaccinationsResponse>> getRecommendedVaccinations(
    String batchId,
  ) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/vaccinations/recommendations',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Recommended Vaccinations API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(RecommendedVaccinationsResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message:
              jsonResponse['message'] ??
              'Failed to fetch recommended vaccinations',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getRecommendedVaccinations: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in getRecommendedVaccinations: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch recommended vaccinations',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Update vaccination status
  Future<Result> updateVaccinationStatus(
    String batchId,
    String vaccinationId,
    UpdateVaccinationStatusRequest request,
  ) async {
    try {
      LogUtil.info(request.toJson());
      final response = await apiClient.patch(
        '/batches/$batchId/vaccinations/$vaccinationId/status',
        body: request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Update Vaccination Status API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message:
              jsonResponse['message'] ?? 'Failed to update vaccination status',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in updateVaccinationStatus: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in updateVaccinationStatus: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to update vaccination status',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }




  /// Adopt  recommended vaccinations
  Future<Result> adoptRecommendedVaccinations(
    String batchId, Map<String,dynamic> request,
  ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations/adopt',
        body: request,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Adopt All Vaccinations API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message:
              jsonResponse['message'] ?? 'Failed to adopt all vaccinations',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in adoptAllRecommendedVaccinations: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in adoptAllRecommendedVaccinations: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to adopt all vaccinations',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Delete vaccination
  Future<Result<void>> deleteVaccination(
    String batchId,
    String vaccinationId,
  ) async {
    try {
      final response = await apiClient.delete(
        '/batches/$batchId/vaccinations/$vaccinationId',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        LogUtil.info('Delete Vaccination: Success');
        return const Success(null);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete vaccination',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteVaccination: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in deleteVaccination: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to delete vaccination',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Refresh methods
  Future<Future<Result<VaccinationListResponse>>> refreshVaccinations(
    String batchId,
  ) async {
    return getVaccinationList(batchId: batchId);
  }

  Future<Result<RecommendedVaccinationsResponse>>
  refreshRecommendedVaccinations(String batchId) async {
    return getRecommendedVaccinations(batchId);
  }
}
