import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/payg/models/subscription_plans_model.dart';
import 'package:http/http.dart' as http;

import '../../../../main.dart';

class SubscriptionRepository {
  /// Fetch active subscription plans from the API
  Future<Result<List<ActivePlan>>> getActivePlans() async {
    try {
      final response = await apiClient.get('/app-subscription-plans/active');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Active Plans API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<ActivePlan> plans = (jsonResponse as List)
            .map((item) => ActivePlan.fromJson(item as Map<String, dynamic>))
            .toList();
        return Success(plans);
      } else {
        return Failure(
          message: jsonResponse is Map
              ? (jsonResponse['message'] ?? 'Failed to fetch plans')
              : 'Failed to fetch plans',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getActivePlans: $e');
      return const Failure(
        message: 'No internet connection. Pull down to retry.',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getActivePlans: $e');
      return Failure(message: e.toString());
    }
  }

  /// Subscribe to a plan (e.g. start free trial)
  Future<Result<void>> subscribeToPlan(String planId) async {
    try {
      final response = await apiClient.post(
        '/app-subscriptions',
        body: {'planId': planId},
        headers: {'Content-Type': 'application/json'},
      );
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Subscribe to Plan API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        return Failure(
          message: jsonResponse is Map
              ? (jsonResponse['message'] ?? 'Failed to subscribe to plan')
              : 'Failed to subscribe to plan',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in subscribeToPlan: $e');
      return const Failure(
        message: 'No internet connection. Please try again.',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in subscribeToPlan: $e');
      return Failure(message: e.toString());
    }
  }

  /// Get AI-recommended subscription plan based on farm usage
  Future<Result<PlanRecommendationResponse>> getRecommendedPlan() async {
    try {
      final response = await apiClient.get('/app-subscriptions/recommend');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Recommended Plan API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(
          PlanRecommendationResponse.fromJson(
            jsonResponse as Map<String, dynamic>,
          ),
        );
      } else {
        return Failure(
          message: jsonResponse is Map
              ? (jsonResponse['message'] ?? 'Failed to fetch recommendation')
              : 'Failed to fetch recommendation',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getRecommendedPlan: $e');
      return const Failure(
        message: 'No internet connection. Pull down to retry.',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getRecommendedPlan: $e');
      return Failure(message: e.toString());
    }
  }

  /// Get user's subscription history
  Future<Result<SubscriptionPlansResponse>> getSubscriptionHistory({
    int page = 1,
    int limit = 10,
    String? status,
    String? planType,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (planType != null && planType.isNotEmpty) {
        queryParams['plan_type'] = planType;
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

      // Assuming the endpoint is /subscription/history or similar
      // Adjust the endpoint according to your actual API
      final endpoint = '/app-subscriptions${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await apiClient.get(endpoint);

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Subscription History API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(SubscriptionPlansResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch subscription history',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getSubscriptionHistory: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getSubscriptionHistory: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch subscription history',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}