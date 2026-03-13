import 'dart:convert';
import 'dart:io';
import 'package:agriflock/core/models/bird_type.dart';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/main.dart';
import 'package:http/http.dart' as http;

class BirdTypeRepository {
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
