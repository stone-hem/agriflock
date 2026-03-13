import 'dart:convert';

import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/farmer/vet/models/vet_report_model.dart';
import 'package:agriflock/main.dart';

class VetReportRepository {
  Future<Result<List<VetReport>>> getMyVetReports() async {
    try {
      final response = await apiClient.get('/visit-reports/my');
      final json = jsonDecode(response.body);
      LogUtil.info('Get My Vet Reports API Response: $json');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json['data'] as List<dynamic>? ?? [];
        final reports = data
            .whereType<Map<String, dynamic>>()
            .map(VetReport.fromJson)
            .toList();
        return Success(reports);
      } else {
        return Failure(
          message: json['message'] ?? 'Failed to load vet reports',
          response: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      LogUtil.error('getMyVetReports error: $e');
      return Failure(
        message: 'An unexpected error occurred',
        response: e.toString(),
        statusCode: 0,
      );
    }
  }

  Future<Result<List<VetReport>>> getVetReportsByOrderId(String orderId) async {
    try {
      final response = await apiClient.get('/visit-reports/order/$orderId');
      final json = jsonDecode(response.body);
      LogUtil.info('Get Vet Reports By Order API Response: $json');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> data;
        if (json is List) {
          data = json;
        } else {
          data = json['data'] as List<dynamic>? ?? [];
        }
        final reports = data
            .whereType<Map<String, dynamic>>()
            .map(VetReport.fromJson)
            .toList();
        return Success(reports);
      } else {
        return Failure(
          message: json['message'] ?? 'Failed to load vet report',
          response: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      LogUtil.error('getVetReportsByOrderId error: $e');
      return Failure(
        message: 'An unexpected error occurred',
        response: e.toString(),
        statusCode: 0,
      );
    }
  }
}
