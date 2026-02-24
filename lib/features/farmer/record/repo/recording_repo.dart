import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class RecordingRepo {


  /// Create a new feeding record
  Future<Result> createFeedingRecord(
      Map<String, dynamic> request,
      ) async {
    try {
      LogUtil.warning(request);
      final response = await apiClient.post(
        '/recording/feeding',
        body: request,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Create Feeding Record API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create feeding record',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in createFeedingRecord: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in createFeedingRecord: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create feeding record',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


  /// Create  vaccination
  Future<Result> recordVaccination(
      Map<String, dynamic> request,
      ) async {
    try {

      final response = await apiClient.post(
        '/recording/vaccination',
        body: request,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Quick Done Vaccination API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create vaccination',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in quickDoneVaccination: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in quickDoneVaccination: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create vaccination',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


  /// Create medication record
  /// Payload: batch_id, house_id, category_id, category_item_id, quantity, unit,
  /// date, dosage, administration_method, reason, birds_treated,
  /// treatment_duration_days, withdrawal_period_days, cost, supplier, notes
  Future<Result> recordMedication(
      Map<String, dynamic> request,
      ) async {
    try {
      final response = await apiClient.post(
        '/recording/medicine',
        body: request,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Medication Record API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to create medication record',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in recordMedication: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in recordMedication: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create medication record',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  /// Create medication record
  /// Payload: batch_id, house_id, category_id, category_item_id, quantity, unit,
  /// date, dosage, administration_method, reason, birds_treated,
  /// treatment_duration_days, withdrawal_period_days, cost, supplier, notes
  Future<Result> recordWeight(
      Map<String, dynamic> request,
      String batchId,
      ) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/weight-samples/weight',
        body: request,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Weight Record API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(null);
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to  record weight',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in recordWeight: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in recordWeight: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to record weight',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


}