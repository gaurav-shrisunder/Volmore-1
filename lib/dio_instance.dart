import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/api_constants.dart';

import 'Utils/shared_prefs.dart';

class DioInstance {
  static Dio? _instance;

  static Future<Dio> createInstance() async {
    if (_instance == null) {
      _instance = Dio(
        BaseOptions(
          baseUrl: baseUrl, // Replace with your base URL
          responseType: ResponseType.json,
          contentType: 'application/json',
          headers: {"Accept-Language" : "en"},
          // validateStatus: (status) {
          //   print('status code: ${status}');
          //   // Consider 403 as a valid status code
          //   return status != null && status < 500;
          // }
        ),
      );

      _instance!.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
          request: true,
          maxWidth: 90,
        ),
      );

      _instance!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            if (!_shouldSkipAuth(options.path)) {
              var token = await getBearerToken();
              var userId = await getUserId();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
                options.headers['x-userid'] =userId;
              }
            }
            return handler.next(options);
          },
          onError: (DioError error, handler) async {
            print('Inside error.response? ');
            if (error.response?.statusCode == 401 &&
                !_shouldSkipAuth(error.requestOptions.path)) {
              print('Inside error.response?.statusCode == 401 ');

              RequestOptions options = error.requestOptions;

              if (await _refreshToken()) {
                var newToken = await getBearerToken();
                var userId = await getUserId();
                options.headers['Authorization'] = 'Bearer $newToken';
                options.headers['x-userid'] =userId;
                final cloneReq = await _instance!.request(
                  options.path,
                  options: Options(
                    method: options.method,
                    headers: options.headers,
                  ),
                  data: options.data,
                  queryParameters: options.queryParameters,
                );
                return handler.resolve(cloneReq);
              }
            } else if (error.response?.statusCode == 403) {
              // Handle the 403 response here
              print('403 Forbidden: ${error.response?.data}');
              // Process the response as needed and return it
              return handler.resolve(error.response!); // Return the response
            } else {
              return handler.next(error);
            }
          },
        ),
      );
    }

    return _instance!;
  }

  /// in the below method mention the api endpoints who doesnt need bearer token
  static bool _shouldSkipAuth(String path) {
    const skipAuthPaths = [
     loginApi,
      signUpApi
    ];
    return skipAuthPaths.contains(path);
  }

  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    await setBearerToken(accessToken);
    await setRefreshToken(refreshToken);
  }

  static Future<bool> _refreshToken() async {
    final oldRefreshToken = await getRefreshToken();
    if (oldRefreshToken == null) {
      return false;
    }

  /*  try {
      RefreshTokenResponseModel? newTokens =
      await LoginApi().refreshAccessTokenApi(oldRefreshToken);
      if (newTokens != null &&
          newTokens.access != null &&
          newTokens.refresh != null) {
        await _saveTokens(newTokens.access!, newTokens.refresh!);
        return true;
      }
    } catch (e) {
      print('Failed to refresh token: $e');
    }*/

    return false;
  }
}
