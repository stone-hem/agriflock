import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/general_batch_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class GeneralBatchRepository {
  // Get all archived batches for a farm with pagination
  // In your GeneralBatchRepository class

  Future<Result<GeneralBatchesResponse>> getBatches(
      String farmId, {
        int page = 1,
        int limit = 20,
        String? status, // Optional: filter by status (active, completed, etc.)
        String? birdTypeId, // Optional: filter by bird type
      }) async {
    try {
      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (birdTypeId != null && birdTypeId.isNotEmpty) 'bird_type_id': birdTypeId,
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final response = await apiClient.get(
        '/batches?$queryString',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Batches API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Return BatchesResponse instead of GeneralBatchModel
        return Success(GeneralBatchesResponse.fromJson(jsonResponse));
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
}