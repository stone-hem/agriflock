import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/farm/models/inventory_models.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class InventoryRepository {
  /// Get inventory items with pagination and filtering
  Future<Result<InventoryResponse>> getInventoryItems({
    int page = 1,
    int limit = 20,
    String? farmId,
    String? categoryId,
    String? searchQuery,
    String? status,
    bool? lowStockOnly,
    DateTime? expiryBefore,
  }) async {
    try {
      // Build query parameters
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (farmId != null && farmId.isNotEmpty) {
        params['farm_id'] = farmId;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        params['category_id'] = categoryId;
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search'] = searchQuery;
      }

      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }

      if (lowStockOnly == true) {
        params['low_stock_only'] = 'true';
      }

      if (expiryBefore != null) {
        params['expiry_before'] = expiryBefore.toUtc().toIso8601String();
      }

      // Build query string
      final queryString = Uri(queryParameters: params).query;
      final endpoint = '/inventory/items${queryString.isNotEmpty ? '?$queryString' : ''}';

      LogUtil.info('Fetching inventory items from: $endpoint');

      final response = await apiClient.get(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Inventory Items API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(InventoryResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch inventory items',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getInventoryItems: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in getInventoryItems: $e');
      return const Failure(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getInventoryItems: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch inventory items',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get inventory categories
  Future<Result<List<InventoryCategory>>> getInventoryCategories({
    bool activeOnly = true,
  }) async {
    try {
      final endpoint = '/inventory/categories?active_only=$activeOnly';
      LogUtil.info('Fetching categories from: $endpoint');

      final response = await apiClient.get(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Categories API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final categoryResponse = InventoryCategoryResponse.fromJson(jsonResponse);
        return Success(categoryResponse.categories);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch categories',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getInventoryCategories: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in getInventoryCategories: $e');
      return const Failure(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getInventoryCategories: $e');

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

  /// Create a new inventory item
  Future<Result<InventoryItem>> createInventoryItem(
      CreateInventoryItemRequest request,
      ) async {
    try {
      final endpoint = '/inventory/items';
      LogUtil.info('Creating inventory item at: $endpoint');
      LogUtil.info('Request data: ${request.toJson()}');

      final response = await apiClient.post(
        endpoint,
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Create Item API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['data'] != null) {
          final item = InventoryItem.fromJson(jsonResponse['data']);
          return Success(item);
        } else {
          return Failure(
            message: 'Invalid response format',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create inventory item',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in createInventoryItem: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in createInventoryItem: $e');
      return const Failure(
        message: 'Invalid request or response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in createInventoryItem: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create inventory item',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Adjust stock for an inventory item
  Future<Result<InventoryItem>> adjustStock(
      String itemId,
      AdjustStockRequest request,
      ) async {
    try {
      final endpoint = '/inventory/items/$itemId/adjust';
      LogUtil.info('Adjusting stock at: $endpoint');
      LogUtil.info('Request data: ${request.toJson()}');

      final response = await apiClient.post(
        endpoint,
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Adjust Stock API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['data'] != null) {
          final item = InventoryItem.fromJson(jsonResponse['data']);
          return Success(item);
        } else {
          return Failure(
            message: 'Invalid response format',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to adjust stock',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in adjustStock: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in adjustStock: $e');
      return const Failure(
        message: 'Invalid request or response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in adjustStock: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to adjust stock',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get inventory item by ID
  Future<Result<InventoryItem>> getInventoryItem(String itemId) async {
    try {
      final endpoint = '/inventory/items/$itemId';
      LogUtil.info('Fetching inventory item from: $endpoint');

      final response = await apiClient.get(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Item API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['data'] != null) {
          final item = InventoryItem.fromJson(jsonResponse['data']);
          return Success(item);
        } else {
          return Failure(
            message: 'Invalid response format',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch inventory item',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getInventoryItem: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in getInventoryItem: $e');
      return const Failure(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getInventoryItem: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch inventory item',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Update inventory item
  Future<Result<InventoryItem>> updateInventoryItem(
      String itemId,
      Map<String, dynamic> updateData,
      ) async {
    try {
      final endpoint = '/inventory/items/$itemId';
      LogUtil.info('Updating inventory item at: $endpoint');
      LogUtil.info('Update data: $updateData');

      final response = await apiClient.put(
        endpoint,
        body: jsonEncode(updateData),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Update Item API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['data'] != null) {
          final item = InventoryItem.fromJson(jsonResponse['data']);
          return Success(item);
        } else {
          return Failure(
            message: 'Invalid response format',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to update inventory item',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in updateInventoryItem: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in updateInventoryItem: $e');
      return const Failure(
        message: 'Invalid request or response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in updateInventoryItem: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to update inventory item',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Delete inventory item
  Future<Result<bool>> deleteInventoryItem(String itemId) async {
    try {
      final endpoint = '/inventory/items/$itemId';
      LogUtil.info('Deleting inventory item at: $endpoint');

      final response = await apiClient.delete(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Delete Item API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(true);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete inventory item',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteInventoryItem: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in deleteInventoryItem: $e');
      return const Failure(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in deleteInventoryItem: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to delete inventory item',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Refresh inventory items
  Future<Result<InventoryResponse>> refreshInventory({
    int limit = 20,
    String? farmId,
    String? categoryId,
  }) async {
    return getInventoryItems(
      page: 1,
      limit: limit,
      farmId: farmId,
      categoryId: categoryId,
    );
  }
}