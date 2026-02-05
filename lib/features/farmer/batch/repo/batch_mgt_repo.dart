import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_mgt_model.dart';
import 'package:agriflock360/features/farmer/batch/model/product_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class BatchMgtRepository {
  /// Get batch details with recent activities and stats
  Future<Result<BatchMgtResponse>> getBatchDetails(String batchId) async {
    try {
      final response = await apiClient.get('/batches/$batchId/batchScreen');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Batch Management API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(BatchMgtResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch batch details',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getBatchDetails: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getBatchDetails: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch batch details',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Refresh batch data (same as getBatchDetails but semantically clearer for pull-to-refresh)
  Future<Result<BatchMgtResponse>> refreshBatchDetails(String batchId) async {
    return getBatchDetails(batchId);
  }


  /// NEW: Get batches with pagination
  Future<Result<BatchListResponse>> getBatches({
    int page = 1,
    int limit = 20,
    String? farmId,
    String? houseId,
    String? birdTypeId,
    String? currentStatus,
    // String? search,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (farmId != null && farmId.isNotEmpty) queryParams['farm_id'] = farmId;
      if (houseId != null && houseId.isNotEmpty) queryParams['house_id'] = houseId;
      if (birdTypeId != null && birdTypeId.isNotEmpty) queryParams['bird_type_id'] = birdTypeId;
      if (currentStatus != null && currentStatus.isNotEmpty) queryParams['status'] = currentStatus;
      // if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = Uri(queryParameters: queryParams).query;
      final response = await apiClient.get('/batches?$queryString');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Batches API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(BatchListResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch batches',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getBatches: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getBatches: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch batches',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Archive a batch (move to archived)
  Future<Result<void>> archiveBatch(String farmId, String batchId) async {
    try {
      final response = await apiClient.post(
        '/farms/$farmId/batches/$batchId/archive',
        body: {},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to archive batch',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in archiveBatch: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in archiveBatch: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to archive batch',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Restore an archived batch (move back to active)
  Future<Result<void>> restoreBatch(String farmId, String batchId) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/restore',
        body: {},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to restore batch',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in restoreBatch: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in restoreBatch: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to restore batch',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Permanently delete an archived batch
  Future<Result<void>> deleteArchivedBatch(String farmId, String batchId) async {
    try {
      final response = await apiClient.delete('/batches/$batchId');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete archived batch',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteArchivedBatch: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in deleteArchivedBatch: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to delete archived batch',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Record mortality or other count changes for a batch
  /// Endpoint: POST /batchs/{batchId}/count
  /// Payload: { change_type: "mortality", change_amount: int, reason: string }
  Future<Result<void>> recordMortality({
    required String batchId,
    required int changeAmount,
    required String reason,
    String changeType = 'mortality',
  }) async {
    try {
      final requestBody = {
        'change_type': changeType,
        'change_amount': changeAmount,
        'reason': reason,
      };

      LogUtil.info('Recording mortality for batch $batchId: $requestBody');

      final response = await apiClient.post(
        '/batches/$batchId/count',
        body: requestBody,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Record Mortality API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to record mortality',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in recordMortality: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in recordMortality: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to record mortality',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}