import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import '../../config/app_helper/app_extension.dart';

enum RequestType { post, get, put, delete }

class ApiProvider {
  final Dio _dio;

  ApiProvider(this._dio);

  Future<dynamic> requestAPI({
    required String url,
    dynamic body,
    required Map<String, String> headers,
    RequestType type = RequestType.post,
  }) async {
    headers.addAll({});

    try {
      var response = await _dio.request(
        url,
        options: Options(method: type.name.capitalize(), headers: headers),
        data: body,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204 ||
          response.statusCode == 206) {
        return response.data;
      } else {
        Map data = response.data;
        throw Exception(data['message'] ?? 'error from server');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('please check internet connection');
      } else if (e.type == DioExceptionType.unknown &&
          e.error is SocketException) {
        throw Exception('please check internet connection');
      } else if (e.response != null) {
        Map data = e.response?.data;
        var message = data['error']['message'] ?? 'an error occurred';
        throw Exception(message);
      } else {
        rethrow;
      }
    }
  }
}
