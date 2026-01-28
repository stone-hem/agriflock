import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class CategoriesRepository {
  /// Get all inventory categories
  Future<Result<List<InventoryCategory>>> getCategories() async {
    try {
      final response = await apiClient.get('/category-items/all');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Categories API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Direct array response - parse as List<InventoryCategory>
        final categories = (jsonResponse as List)
            .map((item) => InventoryCategory.fromJson(item as Map<String, dynamic>))
            .toList();

        return Success(categories);
      } else {
        // Handle error response
        final errorMessage = jsonResponse is Map<String, dynamic>
            ? (jsonResponse['message'] ?? 'Failed to fetch categories')
            : 'Failed to fetch categories';

        return Failure(
          message: errorMessage,
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getCategories: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('Format error in getCategories: $e');
      return Failure(
        message: 'Invalid response format from server',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getCategories: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch categories',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}