import 'package:flutter/foundation.dart';
import 'package:volunterring/Models/response_models/transcript_response.dart';
import 'package:volunterring/Models/response_models/weekly_stats_response_model.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/api_constants.dart';
import 'package:volunterring/api_handler.dart';
import 'package:dio/dio.dart';

class ProfileServices {
  final ApiBaseHelper apiHandler = ApiBaseHelper();
  Future<WeeklyStatsResponseModel?> getWeeklyStats() async {
    var userId = await getUserId();
    Response? response = await apiHandler.get(getWeeklyStat + userId);
    if (response != null && response.statusCode == 200) {
      final WeeklyStatsResponseModel weeklyStats =
          WeeklyStatsResponseModel.fromJson(response.data);
      return weeklyStats;
    } else {
      if (kDebugMode) {
        print('Failed to load Weekly Stats data');
      }
      return null;
    }
  }

  Future<TranscriptResponse?> getTranscript() async {
    var userId = await getUserId();
    Response? response = await apiHandler.get(getTranscripts + userId);
    if (response != null && response.statusCode == 200) {
      final TranscriptResponse transcriptResponse =
          TranscriptResponse.fromJson(response.data);
      return transcriptResponse;
    } else {
      if (kDebugMode) {
        print('Failed to load Transcript');
      }
      return null;
    }
  }
}
