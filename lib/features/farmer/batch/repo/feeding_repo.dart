import 'dart:convert';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/features/farmer/batch/model/feeding_model.dart';
import 'package:agriflock360/main.dart';

class FeedingRepository {
  /// Get feeding recommendations for a batch
  Future<FeedingRecommendationsResponse> getFeedingRecommendations(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batchs/$batchId/feeding/recommendations',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Feeding Recommendations API Response: $jsonResponse');

      return FeedingRecommendationsResponse.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getFeedingRecommendations: $e');
      rethrow;
    }
  }

  /// Get feeding records for a batch with pagination
  Future<FeedingRecordsResponse> getFeedingRecords(
      String batchId, {
        int page = 1,
        int limit = 20,
      }) async {
    try {
      final response = await apiClient.get(
        '/batchs/$batchId/feeding/records?page=$page&limit=$limit',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Feeding Records API Response: $jsonResponse');

      return FeedingRecordsResponse.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getFeedingRecords: $e');
      rethrow;
    }
  }

  /// Get feed dashboard statistics
  Future<FeedDashboard> getFeedDashboard(String batchId) async {
    try {
      final response = await apiClient.get(
        '/batchs/$batchId/feeding/{id}/feed-dashboard',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Feed Dashboard API Response: $jsonResponse');

      return FeedDashboard.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getFeedDashboard: $e');
      rethrow;
    }
  }

  /// Create a new feeding record
  Future<FeedingRecord> createFeedingRecord(
      String batchId,
      CreateFeedingRecordRequest request,
      ) async {
    try {
      final response = await apiClient.post(
        '/batchs/$batchId/feeding/records',
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to create feeding record');
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Create Feeding Record API Response: $jsonResponse');

      return FeedingRecord.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in createFeedingRecord: $e');
      rethrow;
    }
  }

  /// Refresh feeding recommendations
  Future<FeedingRecommendationsResponse> refreshFeedingRecommendations(String batchId) async {
    return getFeedingRecommendations(batchId);
  }

  /// Refresh feeding records
  Future<FeedingRecordsResponse> refreshFeedingRecords(
      String batchId, {
        int page = 1,
        int limit = 20,
      }) async {
    return getFeedingRecords(batchId, page: page, limit: limit);
  }

  /// Refresh feed dashboard
  Future<FeedDashboard> refreshFeedDashboard(String batchId) async {
    return getFeedDashboard(batchId);
  }
}