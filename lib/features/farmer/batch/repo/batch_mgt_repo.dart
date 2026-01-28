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
}