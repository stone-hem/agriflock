import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class ExpenditureRepository {
  /// Create a new expenditure
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