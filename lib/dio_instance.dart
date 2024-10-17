import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Services/signUp_login_services.dart';
import 'package:volunterring/api_constants.dart';
import 'package:volunterring/main.dart';

import 'Models/response_models/referesh_token_response_model.dart';
import 'Utils/shared_prefs.dart';

class DioInstance {
  static Dio? _instance;
  static bool _isRefreshing = false;
  static List<Function> _queue = [];

  static Future<Dio> createInstance() async {
    if (_instance == null) {
      _instance = Dio(
        BaseOptions(
          baseUrl: baseUrl, // Replace with your base URL
          responseType: ResponseType.json,
          contentType: 'application/json',
          headers: {"Accept-Language" : "en"},
        ),
      );

      if (kDebugMode) {
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
      }

      _instance!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_shouldSkipAuth(options.path)) {
            var token = await getBearerToken();
            var userId = await getUserId();  // Fetch the userId
            if (token != null && userId != null) {
              options.headers['Authorization'] = 'Bearer $token';
              options.headers['x-userid'] = userId;  // Add x-userid to headers
            }
          }
          return handler.next(options);
        },
        onError: (DioError error, handler) async {
          if (error.response?.statusCode == 401 &&
              !_shouldSkipAuth(error.requestOptions.path)) {
            if (await _refreshToken()) {
              var newToken = await getBearerToken();
              var userId = await getUserId();  // Fetch the userId
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              error.requestOptions.headers['x-userid'] = userId;  // Add x-userid to retried request
              final retryReq = await _instance!.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(retryReq);
            } else {
              _handleTokenExpiration();
              return handler.next(error);
            }
          } else    if (error.response?.statusCode == 403 &&
              !_shouldSkipAuth(error.requestOptions.path)) {
            if (await _refreshToken()) {
              var newToken = await getBearerToken();
              var userId = await getUserId();  // Fetch the userId
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              error.requestOptions.headers['x-userid'] = userId;  // Add x-userid to retried request
              final retryReq = await _instance!.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(retryReq);
            } else {
              _handleTokenExpiration();
              return handler.next(error);
            }
          }

          else {
            return handler.next(error);
          }
        },
      ));
    }
    return _instance!;
  }

  static Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    final oldRefreshToken = await getRefreshToken();
    if (oldRefreshToken == null) {
      _isRefreshing = false;
      return false;
    }

    try {
      RefreshTokenResponseModel? newTokens = await SignupLoginServices().refreshTokenService(oldRefreshToken);
      if (newTokens != null && newTokens.token?.accessToken != null) {
        await setBearerToken(newTokens.token!.accessToken!);
        _isRefreshing = false;
        _processQueue(true);
        return true;
      } else {
        _handleTokenExpiration();
        _isRefreshing = false;
        _processQueue(false);
        return false;
      }
    } catch (e) {
      _handleTokenExpiration();
      _isRefreshing = false;
      _processQueue(false);
      return false;
    }
  }

  static void _processQueue(bool success) {
    for (var callback in _queue) {
      if (success) {
        callback();
      } else {
        callback(null);
      }
    }
    _queue.clear();
  }

  static void _handleTokenExpiration() {
    clearPreferences();
    main();
   // logoutAndNavigateToLogin();
  }

  static bool _shouldSkipAuth(String path) {
    const skipAuthPaths = [loginApi, signUpApi];
    return skipAuthPaths.contains(path);
  }
}

