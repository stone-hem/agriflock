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
      final response = await apiClient.get('/inventory/categories');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Categories API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = CategoriesResponse.fromJson(jsonResponse);
        return Success(responseData.data);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch categories',
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