import 'dart:convert';
import 'dart:io';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/farmer/batch/model/feeding_model.dart';
import 'package:agriflock/main.dart';
import 'package:http/http.dart' as http;

class FeedingRepository {
  /// Get feeding recommendations for a batch
  Future<Result<FeedingRecommendationsResponse>> getFeedingRecommendations(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/feeding/recommendations',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Feeding Recommendations API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(FeedingRecommendationsResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch feeding recommendations',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getFeedingRecommendations: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getFeedingRecommendations: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch feeding recommendations',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get feeding records for a batch with pagination
  Future<Result<FeedingRecordsResponse>> getFeedingRecords(
      String batchId, {
        int page = 1,
        int limit = 20,
      }) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/feeding/records?page=$page&limit=$limit',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Feeding Records API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(FeedingRecordsResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch feeding records',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getFeedingRecords: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getFeedingRecords: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch feeding records',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get feed dashboard statistics
  Future<Result<FeedDashboard>> getFeedDashboard(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batches/$batchId/feeding/feed-dashboard',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Feed Dashboard API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(FeedDashboard.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch feed dashboard',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getFeedDashboard: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getFeedDashboard: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch feed dashboard',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Refresh feeding recommendations
  Future<Result<FeedingRecommendationsResponse>> refreshFeedingRecommendations(String batchId) async {
    return getFeedingRecommendations(batchId);
  }

  /// Refresh feeding records
  Future<Result<FeedingRecordsResponse>> refreshFeedingRecords(
      String batchId, {
        int page = 1,
        int limit = 20,
      }) async {
    return getFeedingRecords(batchId, page: page, limit: limit);
  }

  /// Refresh feed dashboard
  Future<Result<FeedDashboard>> refreshFeedDashboard(String batchId) async {
    return getFeedDashboard(batchId);
  }
}