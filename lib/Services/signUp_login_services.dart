

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:volunterring/Models/request_models/sign_up_request_model.dart';
import 'package:volunterring/api_constants.dart';
import 'package:volunterring/api_handler.dart';
import 'package:volunterring/dio_instance.dart';

import '../Models/response_models/sign_up_response_model.dart';

class SignupLoginServices{
  final ApiBaseHelper apiHandler = ApiBaseHelper();


  Future<SignUpResponseModel?> signUpUser(SignUpRequestModel requestBody) async {
    Response? response = await apiHandler.post(signUpApi,requestBody );
    if (response != null && response.statusCode == 201) {
      final SignUpResponseModel userModel = SignUpResponseModel.fromJson(response.data);
      await  DioInstance.saveTokens(userModel.data!.accessToken!, userModel.data!.refreshToken!);
      return userModel;
    } else {
      if (kDebugMode) {
        print('Failed to load user data');
      }
      //  response.statusMessage
      return SignUpResponseModel(message: response?.data["message"]);
    }

  }



  Future<SignUpResponseModel?> loginUser(String email, String password) async {
    var requestBody = {
      "emailId":email,
      "password":password
    };
    Response? response = await apiHandler.post(loginApi,requestBody );
    if (response != null && response.statusCode == 200) {
      final SignUpResponseModel userModel = SignUpResponseModel.fromJson(response.data);
      await  DioInstance.saveTokens(userModel.data!.accessToken!, userModel.data!.refreshToken!);
      return userModel;
    } else {
      if (kDebugMode) {
        print('Failed to load user data');
      }
      return SignUpResponseModel(message: response?.data["message"]);
    }

  }

}
