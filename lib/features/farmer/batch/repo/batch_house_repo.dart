// lib/features/farmer/batch/repositories/batch_house_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class BatchHouseRepository {
  // ==================== BATCH METHODS ====================

  // Get all batches for a farm
  Future<List<BatchModel>> getAllBatches(String farmId) async {
    try {
      final response = await apiClient.get('/farms/$farmId/batches');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Batches API Response: $jsonResponse');

      List<dynamic> batchesJson = [];
      if (jsonResponse['batches'] != null) {
        batchesJson = jsonResponse['batches'] as List;
      } else if (jsonResponse['data'] != null) {
        batchesJson = jsonResponse['data'] as List;
      } else if (jsonResponse is List) {
        batchesJson = jsonResponse;
      }

      return batchesJson.map((json) => BatchModel.fromJson(json)).toList();
    } catch (e) {
      LogUtil.error('Error in getAllBatches: $e');
      rethrow;
    }
  }

  // Get single batch by ID
  Future<BatchModel> getBatchById(String farmId, String batchId) async {
    try {
      final response = await apiClient.get('/farms/$farmId/batches/$batchId');
      final jsonResponse = jsonDecode(response.body);

      Map<String, dynamic> batchJson;
      if (jsonResponse['data'] != null) {
        batchJson = jsonResponse['data'];
      } else if (jsonResponse['batch'] != null) {
        batchJson = jsonResponse['batch'];
      } else {
        batchJson = jsonResponse;
      }

      return BatchModel.fromJson(batchJson);
    } catch (e) {
      LogUtil.error('Error in getBatchById: $e');
      rethrow;
    }
  }

  // Create new batch (with optional photo)
  Future<BatchModel> createBatch(
      String farmId,
      Map<String, dynamic> batchData, {
        File? photoFile,
      }) async {
    try {
      if (photoFile != null) {
        // Use multipart request for file upload
        final fields = <String, String>{};

        // Convert all batchData to string fields
        batchData.forEach((key, value) {
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
          'batch_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/batchs',
          fields: fields,
          files: [multipartFile],
        );

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> batchJson;
          if (jsonResponse['data'] != null) {
            batchJson = jsonResponse['data'];
          } else if (jsonResponse['batch'] != null) {
            batchJson = jsonResponse['batch'];
          } else {
            batchJson = jsonResponse;
          }

          return BatchModel.fromJson(batchJson);
        } else {
          LogUtil.error('Failed to create batch: $jsonResponse');
          throw Exception(jsonResponse['message'] ?? 'Failed to create batch');
        }
      } else {
        // Regular JSON request without photo
        batchData.removeWhere((key, value) => value == null);

        final response = await apiClient.post(
          '/batchs',
          body: batchData,
        );

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          LogUtil.success(jsonResponse);
          return BatchModel.fromJson(jsonResponse);
        } else {
          LogUtil.error('Failed to create batch: $jsonResponse');
          throw Exception(jsonResponse['message'] ?? 'Failed to create batch');
        }
      }
    } catch (e) {
      LogUtil.error('Error in createBatch: $e');
      rethrow;
    }
  }

  // Update existing batch (with optional photo)
  Future<BatchModel> updateBatch(
      String farmId,
      String batchId,
      Map<String, dynamic> batchData, {
        File? photoFile,
      }) async {
    try {
      if (photoFile != null) {
        // Use multipart request for file upload
        final fields = <String, String>{};

        // Convert all batchData to string fields
        batchData.forEach((key, value) {
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
          'batch_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/batchs/$batchId',
          fields: fields,
          files: [multipartFile],
        );

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> batchJson;
          if (jsonResponse['data'] != null) {
            batchJson = jsonResponse['data'];
          } else if (jsonResponse['batch'] != null) {
            batchJson = jsonResponse['batch'];
          } else {
            batchJson = jsonResponse;
          }

          return BatchModel.fromJson(batchJson);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update batch');
        }
      } else {
        // Regular JSON request without photo
        batchData.removeWhere((key, value) => value == null);

        final response = await apiClient.put(
          '/batchs/$batchId',
          body: batchData,
        );

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> batchJson;
          if (jsonResponse['data'] != null) {
            batchJson = jsonResponse['data'];
          } else if (jsonResponse['batch'] != null) {
            batchJson = jsonResponse['batch'];
          } else {
            batchJson = jsonResponse;
          }

          return BatchModel.fromJson(batchJson);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update batch');
        }
      }
    } catch (e) {
      LogUtil.error('Error in updateBatch: $e');
      rethrow;
    }
  }

  // Delete batch
  Future<void> deleteBatch(String farmId, String batchId) async {
    try {
      final response = await apiClient.delete('/farms/$farmId/batches/$batchId');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to delete batch');
      }
    } catch (e) {
      LogUtil.error('Error in deleteBatch: $e');
      rethrow;
    }
  }

  // ==================== HOUSE METHODS ====================

  // Get all houses for a farm
  Future<List<House>> getAllHouses(String farmId) async {
    try {
      final response = await apiClient.get('/batchs/$farmId/batch-screen');
      final jsonResponse = jsonDecode(response.body);
      LogUtil.info('Houses API Response: $jsonResponse');

      List<dynamic> housesJson = [];
      if (jsonResponse['houses'] != null) {
        housesJson = jsonResponse['houses'] as List;
      } else if (jsonResponse['data'] != null) {
        housesJson = jsonResponse['data'] as List;
      } else if (jsonResponse is List) {
        housesJson = jsonResponse;
      }

      return housesJson.map((json) => House.fromJson(json)).toList();
    } catch (e) {
      LogUtil.error('Error in getAllHouses: $e');
      rethrow;
    }
  }

  // Get single house by ID
  Future<House> getHouseById(String farmId, String houseId) async {
    try {
      final response = await apiClient.get('/farms/$farmId/houses/$houseId');
      final jsonResponse = jsonDecode(response.body);

      Map<String, dynamic> houseJson;
      if (jsonResponse['data'] != null) {
        houseJson = jsonResponse['data'];
      } else if (jsonResponse['house'] != null) {
        houseJson = jsonResponse['house'];
      } else {
        houseJson = jsonResponse;
      }

      return House.fromJson(houseJson);
    } catch (e) {
      LogUtil.error('Error in getHouseById: $e');
      rethrow;
    }
  }

  // Create new house (with optional photo)
  Future<House> createHouse(
      String farmId,
      Map<String, dynamic> houseData, {
        File? photoFile,
      }) async {
    try {
      if (photoFile != null) {
        // Use multipart request for file upload
        final fields = <String, String>{};

        // Convert all houseData to string fields
        houseData.forEach((key, value) {
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
          'house_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/farms/$farmId/houses',
          fields: fields,
          files: [multipartFile],
        );

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> houseJson;
          if (jsonResponse['data'] != null) {
            houseJson = jsonResponse['data'];
          } else if (jsonResponse['house'] != null) {
            houseJson = jsonResponse['house'];
          } else {
            houseJson = jsonResponse;
          }

          return House.fromJson(houseJson);
        } else {
          LogUtil.error('Failed to create house: $jsonResponse');
          throw Exception(jsonResponse['message'] ?? 'Failed to create house');
        }
      } else {
        // Regular JSON request without photo
        houseData.removeWhere((key, value) => value == null);

        final response = await apiClient.post(
          '/farms/$farmId/houses',
          body: houseData,
        );

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> houseJson;
          if (jsonResponse['data'] != null) {
            houseJson = jsonResponse['data'];
          } else if (jsonResponse['house'] != null) {
            houseJson = jsonResponse['house'];
          } else {
            houseJson = jsonResponse;
          }

          return House.fromJson(houseJson);
        } else {
          LogUtil.error('Failed to create house: $jsonResponse');
          throw Exception(jsonResponse['message'] ?? 'Failed to create house');
        }
      }
    } catch (e) {
      LogUtil.error('Error in createHouse: $e');
      rethrow;
    }
  }

  // Update existing house (with optional photo)
  Future<House> updateHouse(
      String farmId,
      String houseId,
      Map<String, dynamic> houseData, {
        File? photoFile,
      }) async {
    try {
      if (photoFile != null) {
        // Use multipart request for file upload
        final fields = <String, String>{};

        // Convert all houseData to string fields
        houseData.forEach((key, value) {
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
          'house_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/farms/$farmId/houses/$houseId',
          fields: fields,
          files: [multipartFile],
        );

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> houseJson;
          if (jsonResponse['data'] != null) {
            houseJson = jsonResponse['data'];
          } else if (jsonResponse['house'] != null) {
            houseJson = jsonResponse['house'];
          } else {
            houseJson = jsonResponse;
          }

          return House.fromJson(houseJson);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update house');
        }
      } else {
        // Regular JSON request without photo
        houseData.removeWhere((key, value) => value == null);

        final response = await apiClient.put(
          '/farms/$farmId/houses/$houseId',
          body: houseData,
        );

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> houseJson;
          if (jsonResponse['data'] != null) {
            houseJson = jsonResponse['data'];
          } else if (jsonResponse['house'] != null) {
            houseJson = jsonResponse['house'];
          } else {
            houseJson = jsonResponse;
          }

          return House.fromJson(houseJson);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update house');
        }
      }
    } catch (e) {
      LogUtil.error('Error in updateHouse: $e');
      rethrow;
    }
  }

  // Delete house
  Future<void> deleteHouse(String farmId, String houseId) async {
    try {
      final response = await apiClient.delete('/farms/$farmId/houses/$houseId');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to delete house');
      }
    } catch (e) {
      LogUtil.error('Error in deleteHouse: $e');
      rethrow;
    }
  }

  Future<List<BirdType>> getBirdTypes() async {
    try {
      final response = await apiClient.get('/batchs/bird-types');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        LogUtil.info('Bird Types API Response: $jsonResponse');

        // Directly cast the response to List<dynamic> since it's already a list
        final List<dynamic> data = jsonResponse;

        // Use List<dynamic>.map to create BirdType objects
        return data.map((item) => BirdType.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load bird types: ${response.statusCode}');
      }
    } catch (e) {
      LogUtil.error('Error loading bird types: $e');
      rethrow;
    }
  }
}