/*


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:volunterring/api_constants.dart';
import 'package:volunterring/api_handler.dart';
import 'package:volunterring/dio_instance.dart';

import '../Models/response_models/sign_up_response_model.dart';

class SignupLoginServices{
  final ApiHandler apiHandler = ApiHandler();

  Future<SignUpResponseModel?> loginUser(String email, String password) async {
    var requestBody = {
      "emailId":email,
      "password":password
    };
    Response? response = await apiHandler.post(loginApi,data: requestBody );
    if (response != null && response.statusCode == 200) {
      final userModel = SignUpResponseModel.fromJson(response.data);
      await  DioInstance.storeTokens(userModel.data!.accessToken!, userModel.data!.refreshToken!);
      return userModel;
    } else {
      if (kDebugMode) {
        print('Failed to load user data');
      }
      return null;
    }

  }

}*/
