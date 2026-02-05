import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/vet/models/completed_orders_model.dart';
import 'package:agriflock360/features/farmer/vet/models/my_order_list_item.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_order_model.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_service_type.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class VetFarmerRepository {
  /// Get recommended vet farmers
  Future<Result<List<VetFarmerRecommendation>>> getRecommendedVetFarmers() async {
    try {
      final response = await apiClient.get('/extension-officers/recommendations?limit=3');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Recommended Vet Farmers API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<VetFarmerRecommendation> recommendations = [];

        if (jsonResponse is List) {
          recommendations = jsonResponse
              .map((item) => VetFarmerRecommendation.fromJson(item))
              .toList();
        } else if (jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as List;
          recommendations = data
              .map((item) => VetFarmerRecommendation.fromJson(item))
              .toList();
        }

        return Success(recommendations);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch recommended vet farmers',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getRecommendedVetFarmers: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getRecommendedVetFarmers: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch recommended vet farmers',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get vet farmers with filters and pagination
  Future<Result<VetFarmerListResponse>> getVetFarmers({
    String? officerType,
    String? region,
    String? status,
    bool? isVerified,
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};

      if (officerType != null && officerType.isNotEmpty) {
        queryParams['officer_type'] = officerType;
      }

      if (region != null && region.isNotEmpty) {
        queryParams['region'] = region;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (isVerified != null) {
        queryParams['is_verified'] = isVerified.toString();
      }

      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Build query string
      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/extension-officers${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await apiClient.get(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Vet Farmers API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(VetFarmerListResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch vet farmers',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVetFarmers: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVetFarmers: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch vet farmers',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result<VetFarmer>> getVetFarmerById(String vetId) async {
    try {
      final response = await apiClient.get('/extension-officers/$vetId');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Vet Farmer by ID API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(VetFarmer.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch vet details',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVetFarmerById: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVetFarmerById: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch vet details',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result<VetEstimateResponse>> getVetOrderEstimate(
      VetEstimateRequest request,
      ) async {
    try {
      LogUtil.warning(request.toJson());

      final response = await apiClient.post(
        '/order-vet/estimate',
        body: request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info(jsonResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(VetEstimateResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to get estimate',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVetOrderEstimate: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVetOrderEstimate: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to get estimate',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get all veterinary service types
  Future<Result<VetServiceTypesResponse>> getVetServiceTypes() async {
    try {
      final response = await apiClient.get(
        '/vet-services-types',
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Vet Service Types API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // The response is a list, not a map
        final List<dynamic> dataList = jsonResponse is List ? jsonResponse : [];
        return Success(VetServiceTypesResponse.fromJson(dataList));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch vet service types',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVetServiceTypes: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVetServiceTypes: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch vet service types',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Submit vet order
  Future<Result<VetOrderResponse>> submitVetOrder(
      VetOrderRequest request,
      ) async {
    try {
      LogUtil.warning(request);

      final response = await apiClient.post(
        '/order-vet',
        body: request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Submit Vet Order API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(VetOrderResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to submit order',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in submitVetOrder: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in submitVetOrder: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to submit order',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Refresh recommended vet farmers (same as getRecommendedVetFarmers but semantically clearer for pull-to-refresh)
  Future<Result<List<VetFarmerRecommendation>>> refreshRecommendedVetFarmers() async {
    return getRecommendedVetFarmers();
  }

  /// Refresh vet farmers list
  Future<Result<VetFarmerListResponse>> refreshVetFarmers({
    String? officerType,
    String? region,
    String? status,
    bool? isVerified,
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    return getVetFarmers(
      officerType: officerType,
      region: region,
      status: status,
      isVerified: isVerified,
      page: page,
      limit: limit,
      search: search,
    );
  }


  /// Get farmer's veterinary orders
  Future<Result<List<MyOrderListItem>>> getFarmerVetOrders({
    String? status,
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }

      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      // Build query string
      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/order-vet/farmer/my-orders${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await apiClient.get(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Farmer Vet Orders API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<MyOrderListItem> orders = [];

        if (jsonResponse is List) {
          orders = jsonResponse
              .map((item) => MyOrderListItem.fromJson(item))
              .toList();
        } else if (jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as List;
          orders = data
              .map((item) => MyOrderListItem.fromJson(item))
              .toList();
        }

        return Success(orders);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch vet orders',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getFarmerVetOrders: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getFarmerVetOrders: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch vet orders',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get single vet order by ID
  Future<Result<MyOrderListItem>> getVetOrderById(String orderId) async {
    try {
      final response = await apiClient.get('/order-vet/$orderId');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Vet Order by ID API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(MyOrderListItem.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch order details',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getVetOrderById: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getVetOrderById: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch order details',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Cancel a vet order
  Future<Result<void>> cancelVetOrder(String orderId, String reason) async {
    try {
      final response = await apiClient.patch(
        '/order-vet/$orderId/cancel',
        body: {'cancellation_reason': reason},
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Cancel Vet Order API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to cancel order',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in cancelVetOrder: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in cancelVetOrder: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to cancel order',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


  Future<Result<List<CompletedOrder>>> getCompletedOrders({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};

      // Always filter by COMPLETED status
      queryParams['status'] = 'COMPLETED';

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      // Build query string
      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/order-vet/farmer/completed-orders${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await apiClient.get(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Completed Orders API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle the response as a List directly
        if (jsonResponse is List) {
          final List<CompletedOrder> orders = jsonResponse
              .map((item) => CompletedOrder.fromJson(item))
              .toList();
          return Success(orders);
        } else if (jsonResponse is Map<String, dynamic> && jsonResponse['data'] is List) {
          // Fallback: in case the API changes to return {data: [...]}
          final List<dynamic> dataList = jsonResponse['data'];
          final List<CompletedOrder> orders = dataList
              .map((item) => CompletedOrder.fromJson(item))
              .toList();
          return Success(orders);
        } else {
          return Failure(
            message: 'Invalid response format from server',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch completed orders',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getCompletedOrders: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getCompletedOrders: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch completed orders',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Refresh farmer vet orders (same as getFarmerVetOrders but semantically clearer for pull-to-refresh)
  Future<Result<List<MyOrderListItem>>> refreshFarmerVetOrders({
    String? status,
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    return getFarmerVetOrders(
      status: status,
      page: page,
      limit: limit,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }
}