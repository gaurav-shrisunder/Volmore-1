import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:volunterring/Models/response_models/leaderboard_influenced_response_model.dart';

import 'package:volunterring/api_constants.dart';
import 'package:volunterring/api_handler.dart';

class LeaderboardServices {
  final ApiBaseHelper apiHandler = ApiBaseHelper();
  Future<LeaderboardInfluencedResponseModel?> getLeaderboardData(
      String endpoint,
      {String? locationState,
      String? yearOfStudy}) async {
    Map<String, dynamic> queryParams = {};
    if (locationState != null) queryParams['locationState'] = locationState;
    if (yearOfStudy != null) queryParams['yearOfStudy'] = yearOfStudy;

     String queryString = queryParams.isEmpty
        ? ''
        : '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    Response? response = await apiHandler.get("$leaderboardApi/$endpoint$queryString");
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
