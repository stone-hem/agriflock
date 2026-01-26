import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/vet/home/models/dashboard_stats_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class VetDashboardRepository {
  /// Get vet dashboard statistics
  Future<Result<VetDashboardStats>> getDashboardStats() async {
    try {
      const endpoint = '/vet/dashboard/stats';

      LogUtil.info('Fetching dashboard stats with endpoint: $endpoint');
      final response = await apiClient.get(endpoint);
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Dashboard Stats API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse is Map<String, dynamic>) {
          final stats = VetDashboardStats.fromJson(jsonResponse);
          return Success(stats);
        } else {
          LogUtil.error('Unexpected response format: $jsonResponse');
          return Failure(
            message: 'Unexpected response format from server',
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch dashboard statistics',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getDashboardStats: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getDashboardStats: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch dashboard statistics',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}