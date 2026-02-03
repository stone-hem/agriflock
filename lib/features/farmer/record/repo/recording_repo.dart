import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/feeding_model.dart';
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


  // {
  // "batch_id": "637aa326-68a1-481c-9702-846667bf627f",
  // "house_id": "99ad43e9-87ab-4b4c-a051-5132c6ab3066",
  // "category_id": "6d06a951-a33f-4f54-93f1-91da37134514",
  // "category_item_id": "a9f04b3e-db0d-40e9-9350-0d09ee3627d2",
  // "quantity": 1,
  // "unit": "doses",
  // "date": "2026-01-22T19:07:52.021Z",
  // "dosage": "string",
  // "administration_method": "string",
  // "reason": "string",
  // "birds_treated": 0,
  // "treatment_duration_days": 1,
  // "withdrawal_period_days": 0,
  // "cost": 0,
  // "supplier": "string",
  // "notes": "string"
  // }
  /// Create  vaccination
  Future<Result> recordMedication(
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


}