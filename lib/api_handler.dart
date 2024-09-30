/*
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dio_instance.dart';

class ApiHandler {
  // GET request
   Future<Response?> get(String endpoint, Map<String, dynamic>? params) async {
    try {
      final dio = await DioInstance.getDioInstance();
      final response = await dio.get(endpoint, queryParameters: params);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return null;
    }
  }

  // POST request
   Future<Response?> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final dio = await DioInstance.getDioInstance();
      final response = await dio.post(endpoint, data: data);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return null;
    }
  }

  // PUT request
  static Future<Response?> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final dio = await DioInstance.getDioInstance();
      final response = await dio.put(endpoint, data: data);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return null;
    }
  }

  // DELETE request
  static Future<Response?> delete(String endpoint) async {
    try {
      final dio = await DioInstance.getDioInstance();
      final response = await dio.delete(endpoint);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return null;
    }
  }

  // Handle Dio errors
  static void _handleError(DioError error) {
    if (error.response != null) {
      if (kDebugMode) {
        print('Error: ${error.response?.statusCode} -> ${error.response?.data}');
      }
    } else {
      print('Error: ${error.message}');
    }
  }
}
*/
