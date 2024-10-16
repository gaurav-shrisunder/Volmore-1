
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:volunterring/Models/response_models/leaderboard_influenced_response_model.dart';

import 'package:volunterring/api_constants.dart';
import 'package:volunterring/api_handler.dart';

class LeaderboardServices {
  final ApiBaseHelper apiHandler = ApiBaseHelper();
  Future<LeaderboardInfluencedResponseModel?> getInflucendLeaderboard(
      String endpoint) async {
   
    Response? response = await apiHandler.get("$leaderboardApi/$endpoint");
    if (response != null && response.statusCode == 200) {
      final LeaderboardInfluencedResponseModel topInfluencedUser =
          LeaderboardInfluencedResponseModel.fromJson(response.data);
      return topInfluencedUser;
    } else {
      if (kDebugMode) {
        print('Failed to load user roles data');
      }
      return LeaderboardInfluencedResponseModel(
          message: response?.data["message"]);
    }
  }
}
