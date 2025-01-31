import 'package:flutter/foundation.dart';
import '../../Models/request_models/share_transcript_request_model.dart';
import '../../Models/response_models/shared_transcript_response.dart';
import '../../Models/response_models/transcript_response.dart';
import '../../Models/response_models/weekly_stats_response_model.dart';
import '../../Utils/shared_prefs.dart';
import '../../api_constants.dart';
import '../../api_handler.dart';
import 'package:dio/dio.dart';

class ProfileServices {
  final ApiBaseHelper apiHandler = ApiBaseHelper();
  Future<WeeklyStatsResponseModel?> getWeeklyStats() async {
    var userId = await getUserId();
    String now = DateTime.now().toUtc().toIso8601String();
    var query = {
      "now": now,
    };
    Response? response =
        await apiHandler.getWithQuery(getWeeklyStat + userId, query);
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
    // Add current time in ISO8601 format
    String now = DateTime.now().toUtc().toIso8601String();
    var query = {
      "now": now,
    };
    Response? response = await apiHandler.getWithQuery(
      "$getTranscripts$userId",
      query,
    );
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

  Future<SharedTranscriptResponse> getTranscriptSharedEmails() async {
    var userId = await getUserId();
    Response? response = await apiHandler.get(sharedTranscriptEmails + userId);
    if (response != null && response.statusCode == 200) {
      final SharedTranscriptResponse transcriptResponse =
          SharedTranscriptResponse.fromJson(response.data);
      return transcriptResponse;
    } else {
      if (kDebugMode) {
        print('Failed to load Transcript');
      }
      return SharedTranscriptResponse();
    }
  }

  Future<dynamic> shareWithTeacher(
      ShareResponseRequestModel requestBody) async {
    Response? response =
        await apiHandler.post(shareWithTeacherApi, requestBody);
    if (response != null && response.statusCode == 200) {
      return "Transcript shared Successfully";
    } else {
      if (kDebugMode) {
        print('Failed to load user data');
      }
      //  response.statusMessage
      return response?.data["errors"][0];
    }
  }
}
