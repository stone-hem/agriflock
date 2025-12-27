// lib/features/farmer/batch/repositories/archived_batch_repository.dart

import 'dart:convert';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/features/farmer/batch/model/archived_batch_model.dart';
import 'package:agriflock360/main.dart';

class ArchivedBatchRepository {
  // Get all archived batches for a farm with pagination
  Future<ArchivedBatchesResponse> getArchivedBatches(
      String farmId, {
        int page = 1,
        int limit = 20,
      }) async {
    try {
      // final response = await apiClient.get(
      //   '/farms/$farmId/batches/archived?page=$page&limit=$limit',
      // );
      final response = await apiClient.get(
        '/batchs/archived?page=$page&limit=$limit',
      );
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Archived Batches API Response: $jsonResponse');

      return ArchivedBatchesResponse.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getArchivedBatches: $e');
      rethrow;
    }
  }

  // Archive a batch (move to archived)
  Future<void> archiveBatch(String farmId, String batchId) async {
    try {
      final response = await apiClient.post(
        '/farms/$farmId/batches/$batchId/archive',
        body: {},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to archive batch');
      }
    } catch (e) {
      LogUtil.error('Error in archiveBatch: $e');
      rethrow;
    }
  }

  // Restore an archived batch (move back to active)
  Future<void> restoreBatch(String farmId, String batchId) async {
    try {
      final response = await apiClient.post(
        '/batchs/$batchId/restore',
        body: {},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to restore batch');
      }
    } catch (e) {
      LogUtil.error('Error in restoreBatch: $e');
      rethrow;
    }
  }

  // Permanently delete an archived batch
  Future<void> deleteArchivedBatch(String farmId, String batchId) async {
    try {
      final response = await apiClient.delete('/batchs/$batchId');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to delete batch permanently');
      }
    } catch (e) {
      LogUtil.error('Error in deleteArchivedBatch: $e');
      rethrow;
    }
  }


}

