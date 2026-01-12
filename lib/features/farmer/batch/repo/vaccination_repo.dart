import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/scheduled_vaccination.dart';
import 'package:agriflock360/features/farmer/batch/model/vaccination_model.dart';
import 'package:agriflock360/features/farmer/batch/model/recommended_vaccination_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class VaccinationRepository {
  /// Get vaccinations history for a batch
  Future<Result<VaccinationsResponse>> getVaccinations(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/vaccinations',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Vaccinations API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(VaccinationsResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch vaccinations',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVaccinations: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVaccinations: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch vaccinations',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result<VaccinationScheduleResponse>> getScheduledVaccinations(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/vaccinations/lists',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Scheduled Vaccinations API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(VaccinationScheduleResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch scheduled vaccinations',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getScheduledVaccinations: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getScheduledVaccinations: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch scheduled vaccinations',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get vaccination dashboard statistics
  Future<Result<VaccinationDashboard>> getVaccinationDashboard(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/vaccinations/dashboard',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Vaccination Dashboard API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(VaccinationDashboard.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch vaccination dashboard',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVaccinationDashboard: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVaccinationDashboard: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch vaccination dashboard',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get recommended vaccinations for a batch based on age
  Future<Result<RecommendedVaccinationsResponse>> getRecommendedVaccinations(String batchId) async {
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
          message: jsonResponse['message'] ?? 'Failed to fetch recommended vaccinations',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getRecommendedVaccinations: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
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

  /// Create a new vaccination schedule
  Future<Result<Vaccination>> createVaccination(
      String batchId,
      CreateVaccinationRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations',
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Create Vaccination API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(Vaccination.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create vaccination',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in createVaccination: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in createVaccination: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create vaccination',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Update vaccination status
  Future<Result<Vaccination>> updateVaccinationStatus(
      String batchId,
      String vaccinationId,
      UpdateVaccinationStatusRequest request,
      ) async {
    try {
      final response = await apiClient.put(
        '/batches/$batchId/vaccinations/$vaccinationId',
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Update Vaccination Status API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(Vaccination.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to update vaccination status',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in updateVaccinationStatus: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
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

  /// Quick done - Create completed vaccination
  Future<Result<Vaccination>> quickDoneVaccination(
      String batchId,
      QuickDoneVaccinationRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations',
        body: request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Quick Done Vaccination API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(Vaccination.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create vaccination',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in quickDoneVaccination: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in quickDoneVaccination: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create vaccination',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


  Future<Result<Vaccination>> scheduleVaccination(
      String batchId,
      VaccinationScheduleRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations',
        body: request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Quick Done Vaccination API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(Vaccination.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create vaccination',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in quickDoneVaccination: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in quickDoneVaccination: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create vaccination',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Adopt a single recommended vaccination
  Future<Result<Vaccination>> adoptRecommendedVaccination(
      String batchId,
      AdoptVaccinationRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations/adopt',
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Adopt Vaccination API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(Vaccination.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to adopt vaccination',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in adoptRecommendedVaccination: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in adoptRecommendedVaccination: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to adopt vaccination',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Adopt all recommended vaccinations
  Future<Result<List<Vaccination>>> adoptAllRecommendedVaccinations(
      String batchId,
      AdoptAllVaccinationsRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/vaccinations/adopt-all',
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Adopt All Vaccinations API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<Vaccination> vaccinations = [];
        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List;
          vaccinations = data.map((e) => Vaccination.fromJson(e)).toList();
        }
        return Success(vaccinations);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to adopt all vaccinations',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in adoptAllRecommendedVaccinations: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
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
  Future<Result<void>> deleteVaccination(String batchId, String vaccinationId) async {
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
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
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
  Future<Result<VaccinationsResponse>> refreshVaccinations(String batchId) async {
    return getVaccinations(batchId);
  }

  Future<Result<VaccinationDashboard>> refreshVaccinationDashboard(String batchId) async {
    return getVaccinationDashboard(batchId);
  }

  Future<Result<RecommendedVaccinationsResponse>> refreshRecommendedVaccinations(String batchId) async {
    return getRecommendedVaccinations(batchId);
  }
}