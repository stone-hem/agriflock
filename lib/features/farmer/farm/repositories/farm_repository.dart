// lib/features/farmer/farm/repositories/farm_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class FarmRepository {
  // Get all farms with statistics
  Future<FarmsResponse> getAllFarmsWithStats() async {
    try {
      final response = await apiClient.get('/farms');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info(
        'Farms API Response: ${jsonDecode(response.body).toString()}',
      );

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

      return FarmsResponse(farms: farms, statistics: stats);
    } catch (e) {
      LogUtil.error('Error in getAllFarmsWithStats: $e');
      rethrow;
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

  // Get all farms (backward compatibility)
  Future<List<FarmModel>> getAllFarms() async {
    final response = await getAllFarmsWithStats();
    return response.farms;
  }

  // Get single farm by ID
  Future<FarmModel> getFarmById(String farmId) async {
    try {
      final response = await apiClient.get('/farms/$farmId');
      final jsonResponse = jsonDecode(response.body);

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

      return FarmModel.fromJson(farmJson);
    } catch (e) {
      rethrow;
    }
  }

  // Create new farm (with optional photo)
  Future<FarmModel> createFarm(
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
          Map<String, dynamic> farmJson;
          if (jsonResponse['data'] != null) {
            farmJson = jsonResponse['data'];
          } else if (jsonResponse['farm'] != null) {
            farmJson = jsonResponse['farm'];
          } else {
            farmJson = jsonResponse;
          }

          return FarmModel.fromJson(farmJson);
        } else {
          LogUtil.error('Failed to create farm: $jsonResponse');
          throw Exception(jsonResponse['message'] ?? 'Failed to create farm');
        }
      } else {
        // Regular JSON request without photo
        farmData.removeWhere((key, value) => value == null);

        final response = await apiClient.post('/farms', body: farmData);

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> farmJson;
          if (jsonResponse['data'] != null) {
            farmJson = jsonResponse['data'];
          } else if (jsonResponse['farm'] != null) {
            farmJson = jsonResponse['farm'];
          } else {
            farmJson = jsonResponse;
          }

          return FarmModel.fromJson(farmJson);
        } else {
          LogUtil.error('Failed to create farm: $jsonResponse');
          throw Exception(jsonResponse['message'] ?? 'Failed to create farm');
        }
      }
    } catch (e) {
      LogUtil.error(e.toString());
      rethrow;
    }
  }

  // Update existing farm (with optional photo)
  Future<bool> updateFarm(
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

        // Add _method field for Laravel-style PUT via POST
        fields['_method'] = 'PATCH';

        // Create multipart file
        final multipartFile = await http.MultipartFile.fromPath(
          'farm_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/farms/$farmId',
          fields: fields,
          files: [multipartFile],
        );

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update farm');
        }
      } else {
        // Regular JSON request without photo
        farmData.removeWhere((key, value) => value == null);

        final response = await apiClient.patch('/farms/$farmId', body: farmData);

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update farm');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete farm
  Future<void> deleteFarm(String farmId) async {
    try {
      final response = await apiClient.delete('/farms/$farmId');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to delete farm');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get farm statistics (backward compatibility)
  Future<FarmStatistics> getFarmStatistics() async {
    final response = await getAllFarmsWithStats();
    return response.statistics;
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
