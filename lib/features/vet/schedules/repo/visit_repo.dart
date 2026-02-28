import 'dart:convert';
import 'dart:io';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/vet/schedules/models/visit_model.dart';
import 'package:agriflock/features/vet/schedules/models/visit_stats.dart';
import 'package:agriflock/main.dart';
import 'package:http/http.dart' as http;

class VisitsRepository {
  /// Get vet visits by status with pagination response
  Future<Result<List<Visit>>> getVetVisitsByStatus({
    required String status,
  }) async {
    try {
      final endpoint = '/vet/visits/status/$status';

      LogUtil.info('Fetching visits with endpoint: $endpoint');
      final response = await apiClient.get(endpoint);
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Vet Visits by Status API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<Visit> visits = [];

        // API returns a List directly
        if (jsonResponse is List) {
          visits = jsonResponse.map((item) => Visit.fromJson(item)).toList();
        } else {
          LogUtil.error('Unexpected response format: $jsonResponse');
          return Failure(
            message: 'Unexpected response format from server',
            statusCode: response.statusCode,
          );
        }

        return Success(visits);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch vet visits',
          response: response,
          statusCode: response.statusCode,
          cond: jsonResponse is Map ? jsonResponse['cond'] as String? : null,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVetVisitsByStatus: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVetVisitsByStatus: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch vet visits',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Accept a visit
  Future<Result> acceptVisit({
    required String visitId,
  }) async {
    try {
      final response = await apiClient.post(
        '/vet/visits/$visitId/accept',
        body: {},
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Accept Visit API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to accept visit',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in acceptVisit: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in acceptVisit: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to accept visit',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Reject a visit
  Future<Result> rejectVisit({
    required String visitId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiClient.post(
        '/vet/visits/$visitId/reject',
        body: body,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Reject Visit API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to reject visit',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in rejectVisit: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in rejectVisit: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to reject visit',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Complete a visit
  Future<Result> completeVisit({
    required String visitId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiClient.post(
        '/vet/visits/$visitId/complete',
        body: body,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Complete Visit API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to complete visit',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in completeVisit: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in completeVisit: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to complete visit',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Cancel a visit
  Future<Result> cancelVisit({
    required String visitId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiClient.post(
        '/vet/visits/$visitId/cancel',
        body: body,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Cancel Visit API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to cancel visit',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in cancelVisit: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in cancelVisit: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to cancel visit',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Start a visit
  Future<Result> startVisit({
    required String visitId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiClient.post(
        '/vet/visits/$visitId/start',
        body: body,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Start Visit API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to start visit',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in startVisit: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in startVisit: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to start visit',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


  /// Get visit statistics (counts by status)
  Future<Result<VisitStats>> getVisitStats() async {
    try {
      const endpoint = '/vet/dashboard/visit-stats';

      LogUtil.info('Fetching visit stats with endpoint: $endpoint');
      final response = await apiClient.get(endpoint);
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Visit Stats API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse is Map<String, dynamic>) {
          final stats = VisitStats.fromJson(jsonResponse);
          return Success(stats);
        } else {
          LogUtil.error('Unexpected response format: $jsonResponse');
          return Failure(
            message: 'Unexpected response format from server',
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch visit statistics',
          response: response,
          statusCode: response.statusCode,
          cond: jsonResponse is Map ? jsonResponse['cond'] as String? : null,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVisitStats: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVisitStats: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch visit statistics',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}