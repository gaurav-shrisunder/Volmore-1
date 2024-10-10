

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:volunterring/Models/request_models/sign_up_request_model.dart';
import 'package:volunterring/Models/response_models/user_role_response_model.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/api_constants.dart';
import 'package:volunterring/api_handler.dart';
import 'package:volunterring/dio_instance.dart';

import '../Models/response_models/sign_up_response_model.dart';

class SignupLoginServices{
  final ApiBaseHelper apiHandler = ApiBaseHelper();


  Future<SignUpLoginResponseModel?> signUpUser(SignUpRequestModel requestBody) async {
    Response? response = await apiHandler.post(signUpApi,requestBody );
    if (response != null && response.statusCode == 201) {
      final SignUpLoginResponseModel userModel = SignUpLoginResponseModel.fromJson(response.data);
      await  DioInstance.saveTokens(userModel.userDetails!.accessToken!, userModel.userDetails!.refreshToken!);
      await setUserId(userModel.userDetails!.user!.userId!);
      return userModel;
    } else {
      if (kDebugMode) {
        print('Failed to load user data');
      }
      //  response.statusMessage
      return SignUpLoginResponseModel(message: response?.data["message"]);
    }

  }


  Future<SignUpLoginResponseModel?> loginUser(String email, String password) async {
    var requestBody = {
      "emailId":email,
      "password":password
    };
    Response? response = await apiHandler.post(loginApi,requestBody );
    if (response != null && response.statusCode == 200) {
       SignUpLoginResponseModel? userModel = SignUpLoginResponseModel.fromJson(response.data);
       print('UserModel::: ${jsonEncode(userModel)}');

      await  DioInstance.saveTokens(userModel.userDetails!.accessToken!, userModel.userDetails!.refreshToken!);
        await setUserId(userModel.userDetails!.user!.userId!);

      return userModel;
    } else {
      if (kDebugMode) {
        print('Failed to load user data');
      }
      return SignUpLoginResponseModel(message: response?.data["message"]);
    }

  }

  Future<UserRoleResponseModel?> getUserRoles() async {
    Response? response = await apiHandler.get(rolesApi);
    if (response != null && response.statusCode == 200) {
      final UserRoleResponseModel userRole = UserRoleResponseModel.fromJson(response.data);
      return userRole;
    } else {
      if (kDebugMode) {
        print('Failed to load user roles data');
      }
      return UserRoleResponseModel(message: response?.data["message"]);
    }

  }

   refreshTokenApi(String refreshToken) async {
    var requestBody = {
      "refreshToken":refreshToken
    };

    Response? response = await apiHandler.post(refreshToken,requestBody );
    if (response != null && response.statusCode == 200) {
      final SignUpLoginResponseModel userModel = SignUpLoginResponseModel.fromJson(response.data);
      await  DioInstance.saveTokens(userModel.userDetails!.accessToken!, refreshToken);
      return userModel;
    } else {
      if (kDebugMode) {
        print('Failed to load user data');
      }
      return SignUpLoginResponseModel(message: response?.data["message"]);
    }

  }

}
