import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_mgt_model.dart';
import 'package:agriflock360/features/farmer/batch/model/product_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class ProductRepo {

  /// Create a new product record (eggs, meat, or other)
  Future<Result> createProduct(CreateProductRequest request) async {
    try {
      final response = await apiClient.post(
        '/products',
        body: request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Create Product API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create product',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in createProduct: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in createProduct: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create product',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get all products with optional batch filter
  Future<Result<List<Product>>> getProducts({String? batchId}) async {
    try {
      final queryParam = batchId != null ? '?batch_id=$batchId' : '';
      final response = await apiClient.get('/products$queryParam');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Products API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<Product> products = [];
        if (jsonResponse is List) {
          products = jsonResponse.map((product) => Product.fromJson(product)).toList();
        } else if (jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as List;
          products = data.map((product) => Product.fromJson(product)).toList();
        }

        return Success(products);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch products',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getProducts: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getProducts: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch products',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get product dashboard statistics
  Future<Result<ProductDashboard>> getProductDashboard({int days = 1000000}) async {
    try {
      final response = await apiClient.get('/products/dashboard?days=$days');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Product Dashboard API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(ProductDashboard.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch product dashboard',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getProductDashboard: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getProductDashboard: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch product dashboard',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}