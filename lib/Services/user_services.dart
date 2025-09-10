import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../Models/request_models/reset_password_request_model.dart';
import '../../Models/response_models/update_user_response_model.dart';

import '../Models/request_models/update_profile_request_model.dart';
import '../Utils/shared_prefs.dart';
import '../api_constants.dart';
import '../api_handler.dart';

class UserServices {
  final ApiBaseHelper apiHandler = ApiBaseHelper();

  Future<UpdateProfileResponseModel> updateUserApi(
      UpdateProfileRequest requestBody) async {
    Response? response =
        await apiHandler.put("api/v1/users/profile", requestBody);
    if (response != null && response.statusCode == 200) {
      final UpdateProfileResponseModel responseModel =
          UpdateProfileResponseModel.fromJson(response.data);
      await setUser(responseModel.user!);
      return responseModel;
    } else {
      if (kDebugMode) {
        print('Failed to update data');
      }
      return UpdateProfileResponseModel.fromJson(response!.data);
    }
  }

  Future<dynamic> changePassword(String oldPass, String newPass) async {
    var userId = await getUserId();
    var reqBody = {
      "userId": "$userId",
      "oldPassword": oldPass,
      "newPassword": newPass
    };

    Response? response = await apiHandler.post(changePasswordApi, reqBody);
    if (response != null && response.statusCode == 200) {
      return response.data['message'];
    } else {
      if (kDebugMode) {
        print('Failed to load token data');
      }
      return response?.data['errors'][0];
    }
  }

  Future<dynamic> resetPassword(ResetPasswordRequestModel reqBody) async {
    Response? response = await apiHandler.post(resetPasswordApi, reqBody);
    if (response != null && response.statusCode == 200) {
      return response.data['message'];
    } else {
      if (kDebugMode) {
        print('Failed to load token data');
      }
      return response?.data['errors'][0];
    }
  }

  Future<dynamic> deleteUser() async {
    var userId = await getUserId();
    Response? response = await apiHandler.delete(deleteUserApi + userId, null);
    if (response != null && response.statusCode == 200) {
      return response.data['message'];
    } else {
      if (kDebugMode) {
        print('Failed to load token data');
      }
      return response?.data['errors'][0];
    }
  }
}
