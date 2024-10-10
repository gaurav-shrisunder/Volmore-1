
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:volunterring/Models/response_models/events_data_response_model.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/api_constants.dart';

import '../api_handler.dart';

class EventsServices {
  final ApiBaseHelper apiHandler = ApiBaseHelper();

  Future<EventsDataResponseModel?> getEventsData(String endpoint) async {
    var userId = await getUserId();
    Response? response = await apiHandler.get("${getTodayEventApi+userId}/$endpoint");
    if (response != null && response.statusCode == 200) {
      final EventsDataResponseModel userRole = EventsDataResponseModel.fromJson(response.data);
      return userRole;
    } else {
      if (kDebugMode) {
        print('Failed to load user roles data');
      }
      return EventsDataResponseModel(message: response?.data["message"]);
    }

  }
}