// Update lib/features/farmer/expense/repo/expenditure_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/main.dart';
import 'package:http/http.dart' as http;
import 'package:agriflock/features/farmer/expense/model/expenditure_model.dart';

class ExpenditureRepository {
  /// Get all expenditures with optional filters
  Future<Result<ExpenditureResponse>> getExpenditures({
    String? farmId,
    String? houseId,
    String? batchId,
    String? categoryId,
    String? startDate,
    String? endDate,
    String? searchQuery,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (farmId != null) queryParams['farm_id'] = farmId;
      if (houseId != null) queryParams['house_id'] = houseId;
      if (batchId != null) queryParams['batch_id'] = batchId;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (searchQuery != null) queryParams['search'] = searchQuery;

      LogUtil.info('Get Expenditures API Query Parameters: $queryParams');


      final response = await apiClient.get(
        '/expenditures',
        queryParameters: queryParams,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get Expenditures API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(ExpenditureResponse.fromJson(jsonResponse));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch expenditures',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getExpenditures: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getExpenditures: $e');
      return Failure(message: e.toString());
    }
  }

  /// Delete an expenditure
  Future<Result<bool>> deleteExpenditure(String expenditureId) async {
    try {
      final response = await apiClient.delete('/expenditures/$expenditureId');

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Delete Expenditure API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(jsonResponse['success'] ?? true);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete expenditure',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteExpenditure: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in deleteExpenditure: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to delete expenditure',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Create a new expenditure (existing method, keeping it here for completeness)
  Future<Result<Map<String, dynamic>>> createExpenditure(
      Map<String, dynamic> expenditureData,
      ) async {
    try {
      final response = await apiClient.post(
        '/expenditures',
        body: expenditureData,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Create Expenditure API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(jsonResponse);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create expenditure',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in createExpenditure: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in createExpenditure: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create expenditure',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}