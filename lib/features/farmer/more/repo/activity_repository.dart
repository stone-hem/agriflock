import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/more/models/activity_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class ActivityRepository {
  /// Get activities with pagination
  Future<Result<ActivityResponse>> getActivities({
    int page = 1,
    int limit = 20,
    String? activityType,
    String? farmId,
    String? batchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Build query parameters
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (activityType != null && activityType.isNotEmpty) {
        params['activity_type'] = activityType;
      }

      if (farmId != null && farmId.isNotEmpty) {
        params['farm_id'] = farmId;
      }

      if (batchId != null && batchId.isNotEmpty) {
        params['batch_id'] = batchId;
      }

      if (startDate != null) {
        params['start_date'] = startDate.toUtc().toIso8601String();
      }

      if (endDate != null) {
        params['end_date'] = endDate.toUtc().toIso8601String();
      }

      // Build query string
      final queryString = Uri(queryParameters: params).query;
      final endpoint = '/activities${queryString.isNotEmpty ? '?$queryString' : ''}';

      LogUtil.info('Fetching activities from: $endpoint');

      final response = await apiClient.get(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Activities API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(ActivityResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch activities',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getActivities: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in getActivities: $e');
      return const Failure(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getActivities: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch activities',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }



  /// Refresh activities (pull to refresh)
  Future<Result<ActivityResponse>> refreshActivities({
    int limit = 20,
    String? activityType,
    String? farmId,
    String? batchId,
  }) async {
    return getActivities(
      page: 1,
      limit: limit,
      activityType: activityType,
      farmId: farmId,
      batchId: batchId,
    );
  }
}