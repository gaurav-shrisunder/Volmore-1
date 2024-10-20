import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:volunterring/Models/request_models/create_event_request_model.dart';
import 'package:volunterring/Models/request_models/log_current_event_request_model.dart';
import 'package:volunterring/Models/request_models/log_past_event_request_model.dart';
import 'package:volunterring/Models/response_models/event_category_response_model.dart';
import 'package:volunterring/Models/response_models/events_data_response_model.dart';
import 'package:volunterring/Models/response_models/sign_up_response_model.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/api_constants.dart';

import '../api_handler.dart';

class EventsServices {
  final ApiBaseHelper apiHandler = ApiBaseHelper();

  Future<EventsDataResponseModel?> getEventsData(String endpoint) async {
    var userId = await getUserId();

    Response? response =
        await apiHandler.get("${getEventApi + userId}/$endpoint");
    if (response != null && response.statusCode == 200) {
      final EventsDataResponseModel userRole =
          EventsDataResponseModel.fromJson(response.data);
      return userRole;
    } else {
      if (kDebugMode) {
        print('Failed to load user roles data');
      }
      return EventsDataResponseModel(message: response?.data["message"]);
    }
  }

  Future<EventCategoryResponseModel?> getEventsCategoryData() async {
    var userId = await getUserId();
    Response? response = await apiHandler.get(getEventCategoryApi + userId);
    if (response != null && response.statusCode == 200) {
      final EventCategoryResponseModel eventCategory =
          EventCategoryResponseModel.fromJson(response.data);
      return eventCategory;
    } else {
      if (kDebugMode) {
        print('Failed to load eventCategory data');
      }
      return EventCategoryResponseModel(message: response?.data["message"]);
    }
  }

  createEventCategoryData(var requestPayload) async {
    Response? response =
        await apiHandler.post(getEventCategoryApi, requestPayload);
    if (response != null && response.statusCode == 201) {
      final EventCategoryResponseModel eventCategory =
          EventCategoryResponseModel.fromJson(response.data);
      return eventCategory;
    } else {
      if (kDebugMode) {
        print('Failed to load eventCategory data');
      }
      return EventCategoryResponseModel(message: response?.data["message"]);
    }
  }

  Future<EventCategoryResponseModel> createEventData(
      CreateEventRequestModel requestPayload) async {
    print('Payload::: ${jsonEncode(requestPayload)}');
    Response? response = await apiHandler.post(createEventApi, requestPayload);
    if (response != null && response.statusCode == 201) {
      print('Event Created:::${response.data}');
      final EventCategoryResponseModel eventCategory =
          EventCategoryResponseModel.fromJson(response.data);
      return eventCategory;
    } else {
      if (kDebugMode) {
        print('Failed to load create Event data');
      }
      return EventCategoryResponseModel(
          message: response?.data["message"].toString());
    }
  }

  Future<bool> logPastEventData(LogPastEventRequestModel requestPayload) async {
    print('Payload::: ${jsonEncode(requestPayload)}');
    Response? response = await apiHandler.post(logPastHours, requestPayload);
    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      print('Event Created:::${response.data}');
      final EventCategoryResponseModel eventCategory =
          EventCategoryResponseModel.fromJson(response.data);
      return true;
    } else {
      if (kDebugMode) {
        print('Failed to load create Event data');
      }
      return false;
    }
  }

  Future<dynamic> logEventData(LogEventRequestModel requestPayload) async {
    print('Payload::: ${jsonEncode(requestPayload)}');
    Response? response =
        await apiHandler.post(eventParticipantsApi, requestPayload);
    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      print('Event Created:::${response.data}');
      final EventCategoryResponseModel eventCategory =
          EventCategoryResponseModel.fromJson(response.data);
      return response.data;
    } else {
      if (kDebugMode) {
        print('Failed to load create Event data');
      }
      return response?.data ?? "";
    }
  }
}
