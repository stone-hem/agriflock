import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class BatchHouseRepository {
  // ==================== BATCH METHODS ====================

  Future<Result<List<BatchModel>>> getAllBatches(String farmId) async {
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

      final batches = batchesJson
          .map((json) => BatchModel.fromJson(json))
          .toList();
      return Success(batches);
    } on SocketException catch (e) {
      LogUtil.error('Network error in getAllBatches: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in getAllBatches: $e');

      // If error is http.Response, return it
      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch batches',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Get single batch by ID
  Future<Result<BatchModel>> getBatchById(String farmId, String batchId) async {
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

      return Success(BatchModel.fromJson(batchJson));
    } on SocketException catch (e) {
      LogUtil.error('Network error in getBatchById: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in getBatchById: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch batch',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result> createBatch(
    String farmId,
    Map<String, dynamic> batchData, {
    File? photoFile,
  }) async {
    try {
      if (photoFile != null) {
        // Use multipart request for file upload
        final fields = <String, String>{};

        batchData.forEach((key, value) {
          if (value != null) {
            if (value is Map || value is List) {
              fields[key] = jsonEncode(value);
            } else {
              fields[key] = value.toString();
            }
          }
        });



        final multipartFile = await http.MultipartFile.fromPath(
          'batch_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/batches',
          fields: fields,
          files: [multipartFile],
        );

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return Success(null);
        } else {
          LogUtil.error('Failed to create batch: $jsonResponse');
          return Failure(
            message: jsonResponse['message'] ?? 'Failed to create batch',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        // Regular JSON request without photo
        batchData.removeWhere((key, value) => value == null);
        LogUtil.info(batchData.toString());

        final response = await apiClient.post('/batches', body: batchData);

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          LogUtil.success(response.body);
          return Success(null);
        } else {
          LogUtil.error('Failed to create batch: ${response.body}');
          return Failure(
            message: jsonResponse['message'] ?? 'Failed to create batch',
            response: response,
            statusCode: response.statusCode,
          );
        }
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in createBatch: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in createBatch: $e');

      // If error is http.Response, return it
      if (e is http.Response) {
        return Failure(
          message: 'Failed to create batch',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result> updateBatch(
    String batchId,
    Map<String, dynamic> batchData, {
    File? photoFile,
  }) async {
    try {
      if (photoFile != null) {
        final fields = <String, String>{};

        batchData.forEach((key, value) {
          if (value != null) {
            if (value is Map || value is List) {
              fields[key] = jsonEncode(value);
            } else {
              fields[key] = value.toString();
            }
          }
        });


        final multipartFile = await http.MultipartFile.fromPath(
          'batch_avatar',
          photoFile.path,
        );

        final streamedResponse = await apiClient.postMultipart(
          '/batches/$batchId',
          fields: fields,
          files: [multipartFile],
          method: 'PATCH'
        );

        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return Success(null);
        } else {
          LogUtil.error(' Something to fix ${response.body}');

          final message = jsonResponse['message'] is Map
              ? jsonResponse['message']['message']
              : jsonResponse['message'];
          return Failure(
            message: message ?? 'Failed to update batch',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        batchData.removeWhere((key, value) => value == null);

        final response = await apiClient.patch(
          '/batches/$batchId',
          body: batchData,
        );

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return Success(null);
        } else {
          LogUtil.error(' Something to fix ${response.body}');

          final message = jsonResponse['message'] is Map
              ? jsonResponse['message']['message']
              : jsonResponse['message'];
          return Failure(
            message: message ?? 'Failed to update batch',
            response: response,
            statusCode: response.statusCode,
          );
        }
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in updateBatch: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in updateBatch: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to update batch',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result<void>> deleteBatch(String farmId, String batchId) async {
    try {
      final response = await apiClient.delete(
        '/farms/$farmId/batches/$batchId',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete batch',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteBatch: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in deleteBatch: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to delete batch',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result<void>> completeBatch(String batchId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        '/batches/$batchId/complete',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete batch',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteBatch: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in deleteBatch: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to delete batch',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }


  // ==================== HOUSE METHODS ====================

  // Get all houses for a farm
  Future<Result<List<House>>> getAllHouses(String farmId) async {
    try {
      final response = await apiClient.get('/batches/$farmId/batch-screen');
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

      final houses = housesJson.map((json) => House.fromJson(json)).toList();
      return Success(houses);
    } on SocketException catch (e) {
      LogUtil.error('Network error in getAllHouses: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in getAllHouses: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch houses',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Get single house by ID
  Future<Result<House>> getHouseById(String farmId, String houseId) async {
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

      return Success(House.fromJson(houseJson));
    } on SocketException catch (e) {
      LogUtil.error('Network error in getHouseById: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in getHouseById: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to fetch house',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Create new house (with optional photo)
  Future<Result> createHouse(
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
          return Success(null);
        } else {
          LogUtil.error('Failed to create house: $jsonResponse');
          return Failure(
            message: jsonResponse['message'] ?? 'Failed to create house',
            response: response,
            statusCode: response.statusCode,
          );
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
          return Success(null);
        } else {
          LogUtil.error('Failed to create house: $jsonResponse');
          return Failure(
            message: jsonResponse['message'] ?? 'Failed to create house',
            response: response,
            statusCode: response.statusCode,
          );
        }
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in createHouse: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in createHouse: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to create house',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Update existing house (with optional photo)
  Future<Result> updateHouse(
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
          return Success(null);
        } else {
          return Failure(
            message: jsonResponse['message'] ?? 'Failed to update house',
            response: response,
            statusCode: response.statusCode,
          );
        }
      } else {
        // Regular JSON request without photo
        houseData.removeWhere((key, value) => value == null);

        LogUtil.info(houseData.toString());

        final response = await apiClient.patch(
          '/farms/$farmId/houses/$houseId',
          body: houseData,
        );

        final jsonResponse = jsonDecode(response.body);

        LogUtil.info(response.body);


        if (response.statusCode >= 200 && response.statusCode < 300) {
          return Success(null);
        } else {
          return Failure(
            message: jsonResponse['message'] ?? 'Failed to update house',
            response: response,
            statusCode: response.statusCode,
          );
        }
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in updateHouse: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in updateHouse: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to update house',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  // Delete house
  Future<Result<void>> deleteHouse(String farmId, String houseId) async {
    try {
      final response = await apiClient.delete('/farms/$farmId/houses/$houseId');
      LogUtil.info('Delete House Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Failure(
          message: jsonResponse['message'] ?? 'Failed to delete house',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error in deleteHouse: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error in deleteHouse: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to delete house',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

  Future<Result<List<BirdType>>> getBirdTypes() async {
    try {
      final response = await apiClient.get('/batches/bird-types');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        LogUtil.info('Bird Types API Response: $jsonResponse');

        final List<dynamic> data = jsonResponse;
        final birdTypes = data.map((item) => BirdType.fromJson(item)).toList();

        return Success(birdTypes);
      } else {
        LogUtil.error('Network error loading bird types: ${response.body}');
        return Failure(
          message: 'Failed to load bird types',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error loading bird types: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error loading bird types: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed to load bird types',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }
}
