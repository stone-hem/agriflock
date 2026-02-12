import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/report/models/batch_report_model.dart';
import 'package:agriflock360/features/farmer/report/models/farm_batch_report_model.dart';
import 'package:agriflock360/features/farmer/report/models/farm_financial_stats_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class ReportRepository {
  /// Get farm and batch reports for a specific farm
  /// {{base_url}}/farm-reports/farm-batches/:farmId?start_date=2026-01-01&end_date=2026-02-02&period=yearly
  Future<Result<FarmBatchReportResponse>> getFarmBatchReports({
    required String farmId,
    required DateTime startDate,
    required DateTime endDate,
    required String period, // 'daily', 'weekly', 'monthly', 'yearly'
  }) async {
    try {
      final queryParams = {
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'period': period,
      };

      LogUtil.info(
          'Fetching farm batch reports for farm: $farmId with params: $queryParams');

      final response = await apiClient.get(
        '/farm-reports/farm-batches/$farmId',
        queryParameters: queryParams,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info(
          'Farm Batch Reports API Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final farmBatchReportResponse =
        FarmBatchReportResponse.fromJson(jsonResponse);
        return Success(farmBatchReportResponse);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch farm reports',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getFarmBatchReports: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getFarmBatchReports: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch farm reports',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get batch report for a specific batch
  /// {{base_url}}/farm-reports/batch/:batchId?start_date=2026-01-01&end_date=2026-02-02&period=weekly
  Future<Result<BatchReportResponse>> getBatchReport({
    required String batchId,
    required DateTime startDate,
    required DateTime endDate,
    required String period, // 'daily', 'weekly', 'monthly', 'yearly'
  }) async {
    try {
      final queryParams = {
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'period': period,
      };

      LogUtil.info(
          'Fetching batch report for batch: $batchId with params: $queryParams');

      final response = await apiClient.get(
        '/farm-reports/batch/$batchId',
        queryParameters: queryParams,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Batch Report API Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final batchReportResponse = BatchReportResponse.fromJson(jsonResponse);
        return Success(batchReportResponse);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch batch report',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getBatchReport: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getBatchReport: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch batch report',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Get farm financial stats
  /// {{base_url}}/financials/stats?farm_id=:farmId&start_date=2026-02-01&end_date=2026-02-11
  Future<Result<FarmFinancialStatsResponse>> getFarmFinancialStats({
    required String farmId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final queryParams = {
        'farm_id': farmId,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
      };

      LogUtil.info(
          'Fetching farm financial stats for farm: $farmId with params: $queryParams');

      final response = await apiClient.get(
        '/financials/stats',
        queryParameters: queryParams,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info(
          'Farm Financial Stats API Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final statsResponse =
            FarmFinancialStatsResponse.fromJson(jsonResponse);
        return Success(statsResponse);
      } else {
        return Failure(
          message:
              jsonResponse['message'] ?? 'Failed to fetch financial stats',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getFarmFinancialStats: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getFarmFinancialStats: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch financial stats',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}