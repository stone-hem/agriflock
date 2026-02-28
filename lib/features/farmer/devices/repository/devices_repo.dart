import 'dart:convert';
import 'dart:io';

import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/farmer/devices/models/device_model.dart';
import 'package:agriflock/main.dart';
import 'package:http/http.dart' as http;

class DevicesRepository {
  /// Get all devices assigned to the current farmer
  Future<Result<List<DeviceItem>>> getMyDevices() async {
    try {
      final response = await apiClient.get('/devices/me');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Get My Devices API Response: $jsonResponse');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final deviceListResponse = DeviceListResponse.fromJson(
          jsonResponse as Map<String, dynamic>,
        );
        return Success(deviceListResponse.devices);
      } else {
        final errorMessage = jsonResponse is Map<String, dynamic>
            ? (jsonResponse['message'] ?? 'Failed to fetch devices')
            : 'Failed to fetch devices';

        return Failure(
          message: errorMessage,
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getMyDevices: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      LogUtil.error('Format error in getMyDevices: $e');
      return const Failure(
        message: 'Invalid response format from server',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getMyDevices: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch devices',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}