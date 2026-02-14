import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class FarmRepository {
  // Get all farms with statistics
  Future<Result<FarmsResponse>> getAllFarmsWithStats() async {
    try {
      final response = await apiClient.get('/farms');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info(
        'Farms API Response: ${jsonDecode(response.body).toString()}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse farms list
        List<dynamic> farmsJson = [];
        if (jsonResponse['farms'] != null) {
          farmsJson = jsonResponse['farms'] as List;
        } else if (jsonResponse['data'] != null) {
          farmsJson = jsonResponse['data'] as List;
        } else if (jsonResponse is List) {
          farmsJson = jsonResponse;
        }

        // Parse farms with proper location handling
        final farms = farmsJson.map((json) {
          // Handle location field - it might be a JSON string
          if (json['location'] != null && json['location'] is String) {
            try {
              final locationData = jsonDecode(json['location']);
              json['location_data'] = locationData;
            } catch (e) {
              LogUtil.error('Error parsing location: $e');
            }
          }
          return FarmModel.fromJson(json);
        }).toList();

        // Parse statistics
        final stats = FarmStatistics(
          totalFarms: jsonResponse['totalFarms'] ?? farms.length,
          totalBirds: _parseTotalBirds(jsonResponse['totalBirds']),
          totalActiveBatches: jsonResponse['activeBatches'] ?? 0,
          totalBatches: jsonResponse['totalBatches'] ?? 0,
          archivedBatches: jsonResponse['archivedBatches'] ?? 0,
        );

        return Success(FarmsResponse(farms: farms, statistics: stats));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch farms',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getAllFarmsWithStats: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getAllFarmsWithStats: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch farms',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Helper method to parse totalBirds which can be int or object
  int _parseTotalBirds(dynamic totalBirds) {
    if (totalBirds == null) return 0;
    if (totalBirds is int) return totalBirds;
    if (totalBirds is Map && totalBirds['total_birds'] != null) {
      return totalBirds['total_birds'] is int
          ? totalBirds['total_birds']
          : int.tryParse(totalBirds['total_birds'].toString()) ?? 0;
    }
    return 0;
  }

  // Get single farm by ID
  Future<Result<FarmModel>> getFarmById(String farmId) async {
    try {
      final response = await apiClient.get('/farms/$farmId');
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle different response structures
        Map<String, dynamic> farmJson;
        if (jsonResponse['data'] != null) {
          farmJson = jsonResponse['data'];
        } else if (jsonResponse['farm'] != null) {
          farmJson = jsonResponse['farm'];
        } else {
          farmJson = jsonResponse;
        }

        // Handle location field
        if (farmJson['location'] != null && farmJson['location'] is String) {
          try {
            final locationData = jsonDecode(farmJson['location']);
            farmJson['location_data'] = locationData;
          } catch (e) {
            LogUtil.error('Error parsing location: $e');
          }
        }

        return Success(FarmModel.fromJson(farmJson));
      } else {
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to fetch farm',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in getFarmById: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in getFarmById: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch farm',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Create new farm (with optional photo)
  Future<Result> createFarm(
      Map<String, dynamic> farmData, {
        File? photoFile,
      }) async {
    try {
      if (photoFile != null) {
        // Use multipart request for file upload
        final fields = <String, String>{};

        // Convert all farmData to string fields
        farmData.forEach((key, value) {
          if (value != null) {
            if (value is Map || value is List) {
              fields[key] = jsonEncode(value);
            } else {
              fields[key] = value.toString();
            }
          }
        });

        // Create multipart file
        final multipartFile = await http.MultipartFile.fromPath(
          'farm_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/farms',
          fields: fields,
          files: [multipartFile],
        );

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {


          return Success(null);
        } else {
          LogUtil.error('Failed to create farm: $jsonResponse');
          return Failure(
            message: jsonResponse['message'] ?? 'Failed to create farm',
            response: response,
            statusCode: response.statusCode,
            cond: jsonResponse['cond'],
          );
        }
      } else {
        // Regular JSON request without photo
        farmData.removeWhere((key, value) => value == null);

        final response = await apiClient.post('/farms', body: farmData);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {

          return Success(null);
        } else {
          LogUtil.error('Failed to create farm: $jsonResponse');
          return Failure(
            message: jsonResponse['message'] ?? 'Failed to create farm',
            response: response,
            statusCode: response.statusCode,
            cond: jsonResponse['cond'],
          );
        }
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in createFarm: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in createFarm: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create farm',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Update existing farm (with optional photo)
  Future<Result<bool>> updateFarm(
      String farmId,
      Map<String, dynamic> farmData, {
        File? photoFile,
      }) async {
    try {
      if (photoFile != null) {
        // Use multipart request for file upload
        final fields = <String, String>{};

        // Convert all farmData to string fields
        farmData.forEach((key, value) {
          if (value != null) {
            if (value is Map || value is List) {
              fields[key] = jsonEncode(value);
            } else {
              fields[key] = value.toString();
            }
          }
        });


        // Create multipart file
        final multipartFile = await http.MultipartFile.fromPath(
          'farm_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/farms/$farmId',
          fields: fields,
          files: [multipartFile],
          method: 'PATCH'
        );

        print(streamedResponse);

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return const Success(true);
        } else {
          LogUtil.error(' Something to fix ${response.body}');
          final message = jsonResponse['message'] is Map
              ? jsonResponse['message']['message']
              : jsonResponse['message'];
          return Failure(
            message: message ?? 'Failed to update farm',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        // Regular JSON request without photo
        farmData.removeWhere((key, value) => value == null);

        final response = await apiClient.patch('/farms/$farmId', body: farmData);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return const Success(true);
        } else {
          final message = jsonResponse['message'] is Map
              ? jsonResponse['message']['message']
              : jsonResponse['message'];
          return Failure(
            message: message ?? 'Failed to update farm',
            response: response,
            statusCode: response.statusCode,
          );
        }
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in updateFarm: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in updateFarm: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to update farm',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Delete farm
  Future<Result<void>> deleteFarm(String farmId) async {
    try {
      final response = await apiClient.delete('/farms/$farmId');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete farm',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteFarm: $e');
      return const Failure(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      LogUtil.error('Error in deleteFarm: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to delete farm',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

}

// Response model that combines farms and statistics
class FarmsResponse {
  final List<FarmModel> farms;
  final FarmStatistics statistics;

  const FarmsResponse({required this.farms, required this.statistics});
}

// Statistics model
class FarmStatistics {
  final int totalFarms;
  final int totalBirds;
  final int totalActiveBatches;
  final int totalBatches;
  final int archivedBatches;

  const FarmStatistics({
    required this.totalFarms,
    required this.totalBirds,
    required this.totalActiveBatches,
    this.totalBatches = 0,
    this.archivedBatches = 0,
  });
}