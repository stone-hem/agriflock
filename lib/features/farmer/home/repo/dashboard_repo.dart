// lib/features/dashboard/repositories/dashboard_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/home/model/batch_home_model.dart';
import 'package:agriflock360/features/farmer/home/model/dashboard_model.dart';
import 'package:agriflock360/features/farmer/home/model/financial_overview_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class DashboardRepository {
  /// Get dashboard summary statistics
  Future<Result<DashboardSummary>> getDashboardSummary() async {
    try {
      final response = await apiClient.get('/dashboard/summary');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Dashboard Summary API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(DashboardSummary.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch dashboard summary',
          response: response,
          statusCode: response.statusCode,
          cond: jsonResponse['cond'],
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getDashboardSummary: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getDashboardSummary: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch dashboard summary',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get recent dashboard activities
  Future<Result<List<DashboardActivity>>> getRecentActivities({int limit = 10}) async {
    try {
      final response = await apiClient.get('/dashboard/recent_activity?limit=$limit');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Recent Activities API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<DashboardActivity> activities = [];

        if (jsonResponse is List) {
          activities = jsonResponse
              .map((activity) => DashboardActivity.fromJson(activity))
              .toList();
        } else if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          final data = jsonResponse['data'] as List;
          activities = data
              .map((activity) => DashboardActivity.fromJson(activity))
              .toList();
        }

        return Success(activities);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch recent activities',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getRecentActivities: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getRecentActivities: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch recent activities',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result<FinancialOverview>> getFinancialOverview() async {
    try {
      final response = await apiClient.get('/financials/overview');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Financial Overview API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(FinancialOverview.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch financial overview',
          response: response,
          statusCode: response.statusCode,
          cond: jsonResponse['cond'],
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getFinancialOverview: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON parsing error in getFinancialOverview: $e');
      return const Failure(
        message: 'Invalid response format from server',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getFinancialOverview: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch financial overview',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Refresh both summary and activities together
  /// Refresh both summary, activities, and financial overview together
  Future<Result<Map<String, dynamic>>> refreshDashboard({int activityLimit = 10}) async {
    try {
      final summaryFuture = getDashboardSummary();
      final activitiesFuture = getRecentActivities(limit: activityLimit);
      final financialFuture = getFinancialOverview(); // ADD THIS

      final results = await Future.wait([
        summaryFuture,
        activitiesFuture,
        financialFuture, // ADD THIS
      ]);

      // Check if all requests were successful
      final summaryResult = results[0] as Result<DashboardSummary>;
      final activitiesResult = results[1] as Result<List<DashboardActivity>>;
      final financialResult = results[2] as Result<FinancialOverview>; // ADD THIS

      if (summaryResult is Success<DashboardSummary> &&
          activitiesResult is Success<List<DashboardActivity>> &&
          financialResult is Success<FinancialOverview>) { // UPDATE THIS
        return Success({
          'summary': summaryResult.data,
          'activities': activitiesResult.data,
          'financial': financialResult.data, // ADD THIS
        });
      } else if (summaryResult is Failure) {
        // Return the first failure (summary failure)
        return Failure(
          message: 'Failed to refresh dashboard summary',
        );
      } else if (activitiesResult is Failure) {
        // Return activities failure
        return Failure(
          message: 'Failed to refresh dashboard activities',
        );
      } else if (financialResult is Failure) { // ADD THIS BLOCK
        // Return financial failure
        return Failure(
          message: 'Failed to refresh financial overview',
        );
      } else {
        // Unexpected state
        return const Failure(
          message: 'Failed to refresh dashboard data',
          statusCode: 0,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in refreshDashboard: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in refreshDashboard: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to refresh dashboard',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get user batches
  Future<Result<List<BatchHomeData>>> getUserBatches() async {
    try {
      final response = await apiClient.get('/farm-reports/my-batches');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('User Batches API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final batchResponse = BatchHomeResponse.fromJson(jsonResponse);
        return Success(batchResponse.data);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch user batches',
          response: response,
          statusCode: response.statusCode,
          cond: jsonResponse['cond'],
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getUserBatches: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON parsing error in getUserBatches: $e');
      return const Failure(
        message: 'Invalid response format from server',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getUserBatches: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch user batches',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


}