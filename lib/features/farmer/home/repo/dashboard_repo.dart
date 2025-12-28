// lib/features/dashboard/repositories/dashboard_repository.dart

import 'dart:convert';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/features/farmer/home/model/dashboard_model.dart';
import 'package:agriflock360/main.dart';

class DashboardRepository {
  /// Get dashboard summary statistics
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await apiClient.get('/dashboard/summary');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Dashboard Summary API Response: $jsonResponse');

      return DashboardSummary.fromJson(jsonResponse);
    } catch (e) {
      LogUtil.error('Error in getDashboardSummary: $e');
      rethrow;
    }
  }

  /// Get recent dashboard activities
  Future<List<DashboardActivity>> getRecentActivities({int limit = 10}) async {
    try {
      final response = await apiClient.get('/dashboard/recent_activity?limit=$limit');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Recent Activities API Response: $jsonResponse');

      if (jsonResponse is List) {
        return jsonResponse
            .map((activity) => DashboardActivity.fromJson(activity))
            .toList();
      }

      return [];
    } catch (e) {
      LogUtil.error('Error in getRecentActivities: $e');
      rethrow;
    }
  }

  /// Refresh both summary and activities together
  Future<Map<String, dynamic>> refreshDashboard({int activityLimit = 10}) async {
    try {
      final summaryFuture = getDashboardSummary();
      final activitiesFuture = getRecentActivities(limit: activityLimit);

      final results = await Future.wait([summaryFuture, activitiesFuture]);

      return {
        'summary': results[0] as DashboardSummary,
        'activities': results[1] as List<DashboardActivity>,
      };
    } catch (e) {
      LogUtil.error('Error in refreshDashboard: $e');
      rethrow;
    }
  }
}