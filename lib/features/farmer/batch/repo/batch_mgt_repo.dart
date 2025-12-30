// lib/features/farmer/batch/repositories/batch_mgt_repository.dart

import 'dart:convert';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_mgt_model.dart';
import 'package:agriflock360/features/farmer/batch/model/product_model.dart';
import 'package:agriflock360/main.dart';

class BatchMgtRepository {
  /// Get batch details with recent activities and stats
  Future<BatchMgtResponse> getBatchDetails(String batchId) async {
    try {
      final response = await apiClient.get(
          '/batches/$batchId/batchScreen'
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Batch Management API Response: $jsonResponse');

      return BatchMgtResponse.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getBatchDetails: $e');
      rethrow;
    }
  }

  /// Refresh batch data (same as getBatchDetails but semantically clearer for pull-to-refresh)
  Future<BatchMgtResponse> refreshBatchDetails(String batchId) async {
    return getBatchDetails(batchId);
  }

  /// Create a new product record (eggs, meat, or other)
  Future<Product> createProduct(CreateProductRequest request) async {
    try {
      final response = await apiClient.post(
        '/products',
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to create product record');
      }

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Create Product API Response: $jsonResponse');

      return Product.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in createProduct: $e');
      rethrow;
    }
  }

  /// Get all products with optional batch filter
  Future<List<Product>> getProducts({String? batchId}) async {
    try {
      final queryParam = batchId != null ? '?batch_id=$batchId' : '';
      final response = await apiClient.get('/products$queryParam');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Products API Response: $jsonResponse');

      if (jsonResponse is List) {
        return jsonResponse.map((product) => Product.fromJson(product)).toList();
      }

      return [];
    } catch (e) {
      LogUtil.error('Error in getProducts: $e');
      rethrow;
    }
  }

  /// Get product dashboard statistics
  Future<ProductDashboard> getProductDashboard({int days = 1000000}) async {
    try {
      final response = await apiClient.get('/products/dashboard?days=$days');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Product Dashboard API Response: $jsonResponse');

      return ProductDashboard.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getProductDashboard: $e');
      rethrow;
    }
  }
}