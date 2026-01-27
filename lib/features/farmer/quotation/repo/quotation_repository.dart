// repositories/housing_quotation_repository.dart

import 'dart:convert';
import 'dart:io';

import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:http/http.dart' as http;

import '../../../../main.dart';
import '../models/housing_quotation_model.dart';

class QuotationRepository {

  /// Generate a housing quotation based on bird capacity
  Future<Result<HousingQuotationData>> housingQuotation({
    required int birdCapacity,
  }) async {
    try {
      final requestBody = {
        'bird_capacity': birdCapacity,
      };

      LogUtil.info('Generate Quotation Request: ${jsonEncode(requestBody)}');

      final response = await apiClient.post(
        '/housing/quotations/generate',
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Generate Quotation API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['data'] != null) {
          final quotationData = HousingQuotationData.fromJson(jsonResponse['data']);
          return Success(quotationData);
        } else {
          return Failure(
            message: 'Invalid response format: data field is missing',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to generate quotation',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in generateQuotation: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('JSON format error in generateQuotation: $e');
      return const Failure(
        message: 'Invalid request or response format',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in generateQuotation: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to generate quotation',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}