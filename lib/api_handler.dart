
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';
import 'dio_instance.dart';
import 'package:http/http.dart' as http;

class ApiBaseHelper {
  Future<http.StreamedResponse> sendMultipartRequest(
      http.MultipartRequest request) async {
    try {
      http.StreamedResponse response = await request.send();
      return response;
    } catch (e) {
      throw Exception('Failed to send multipart request: $e');
    }
  }

  Future<dynamic> get(String url) async {
    print('Api Get, url $url');
    var responseJson;
    try {
      Dio instance = await DioInstance.createInstance();
      final response = await instance.get(url);
      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      print('DioError caught: ${e.response}');
      throw e.response ??
          Exception('Error sending request: ${e.message}');
    } on SocketException {
      print('No net');
      throw Exception('No Internet connection');
    }
    print('api get received!');
    return responseJson;
  }

  Future<dynamic> getWithQuery(String url, Map<String, dynamic> json) async {
    log('Api Get, url $url');
    log('Api Get, json $json');
    var responseJson;
    try {
      Dio instance = await DioInstance.createInstance();
      final response = await instance.get(url, queryParameters: json);
      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      print('DioError caught: ${e.response}');
      throw e.response ??
          Exception('Error sending request: ${e.message}');
    } on SocketException {
      print('No net');
      throw Exception('No Internet connection');
    }
    print('api get received!');
    return responseJson;
  }

  Future<dynamic> post(String url, dynamic body) async {
    print('Api Post, url $url');
    var responseJson;
    try {
      Dio instance = await DioInstance.createInstance();
      final response = await instance.post(url, data: body);
      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      print("In Dio exception - ApiHandler");
      return handleError(e.response);
    } on SocketException {
      print('No net');
      throw Exception('No Internet connection');
    }
    print('api post received!');
    return responseJson;
  }

  Future<dynamic> put(String url, dynamic body) async {
    print('Api Put, url $url');
    var responseJson;
    try {
      Dio instance = await DioInstance.createInstance();
      final response = await instance.put(url, data: body);
      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      print('DioError caught: ${e.response}');
      throw e.response ??
          Exception('Error sending request: ${e.message}');
    } on SocketException {
      print('No net');
      throw Exception('No Internet connection');
    }
    print('api put received!');
    return responseJson;
  }

  Future<dynamic> delete(String url, dynamic body) async {
    print('Api delete, url $url');
    var apiResponse;
    try {
      Dio instance = await DioInstance.createInstance();
      final response = await instance.delete(url, data: body);
      apiResponse = _returnResponse(response);
    } on DioException catch (e) {
      print('DioError caught: ${e.response}');
      throw e.response ??
          Exception('Error sending request: ${e.message}');
    } on SocketException {
      print('No net');
      throw Exception('No Internet connection');
    }
    print('api delete received!');
    return apiResponse;
  }

  Future<dynamic> uploadFaceId(String url, int userId, File imageFile) async {
    print('Uploading face ID for user: $userId to URL: $url');
    var responseJson;

    try {
      Dio instance = await DioInstance.createInstance();

      // Prepare multipart form data
      FormData formData = FormData.fromMap({
        'user_id': userId, // The user_id is added as part of form data
        'image': await MultipartFile.fromFile(imageFile.path,
            filename: imageFile.path.split('/').last),
      });

      // Set the content-type to 'multipart/form-data' explicitly
      final response = await instance.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Handle the response
      responseJson = _returnResponse(response);
    } on DioException catch (e) {
      print('DioError caught during face ID upload: ${e.response}');
      throw e.response ??
          Exception('Error sending request: ${e.message}');
    } on SocketException {
      print('No internet connection');
      throw Exception('No Internet connection');
    }

    print('Face ID upload response received!');
    return responseJson;
  }

  dynamic _returnResponse(Response<dynamic> response) {
    print("Inside return response");
    switch (response.statusCode) {
      case 200:
        return response;
      case 201:
        print('response >>>> ${response.statusCode} ${response.data}');
        return response;
      case 400:
        return response;
      //throw BadRequestException(response.data);
      case 401:
        return response;
      // throw FetchDataException();
      case 403:
        return response;
      // throw UnauthorisedException(response.data.toString());
      case 404:
        return response;
      //  return response.data['detail'];
      // throw UnauthorisedException(response.data);
      case 500:
      case 502:
      default:
        return response;
      // showLongToast(response.data['detail']);
      // throw FetchDataException(
      //     'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  dynamic handleError(Response<dynamic>? response) {
    if (response != null) {
      switch (response.statusCode) {
        case 200:
          return response;
        case 201:
          return response;
        case 400:
          return response;
        case 401:
          return response;
        case 403:
          if (response.data['detail']
              .contains('User is already logged in on another device.')) {
            print("$response");
            return response; // Disable toast
          }
          break;
        case 404:
          return response;

        case 500:
        default:
          return response;
      }
    } else {
      //  showLongToast("Something went wrong ! Please try after sometime");
    }
    return response;
  }
}
