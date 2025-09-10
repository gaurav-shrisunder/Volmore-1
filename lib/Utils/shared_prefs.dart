import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/response_models/sign_up_response_model.dart';

enum SortOption { def, az, za, dateAsc, dateDesc }

Future<void> clearPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  if (kDebugMode) {
    print('Cleared all shared prefs');
  }
}

Future<void> setBearerToken(String bearerToken) async {
  SharedPreferences token = await SharedPreferences.getInstance();
  token.setString('bearerToken', bearerToken);
  if (kDebugMode) {
    log('BearerToken setting to ${await getBearerToken()}');
  }
}

getBearerToken() async {
  SharedPreferences token = await SharedPreferences.getInstance();
  String bearerToken = token.getString('bearerToken') ?? "0";
  // String oldRefreshToken = await getRefreshToken();
  if (kDebugMode) {
    print('BearerToken get to $bearerToken');
  }
  return bearerToken;
}

Future<void> setRefreshToken(String refreshToken) async {
  SharedPreferences token = await SharedPreferences.getInstance();
  token.setString('refreshToken', refreshToken);
  if (kDebugMode) {
    print('refreshToken setting to ${await getBearerToken()}');
  }
}

getRefreshToken() async {
  SharedPreferences token = await SharedPreferences.getInstance();
  String refreshToken = token.getString('refreshToken') ?? "0";
  // String oldRefreshToken = await getRefreshToken();
  if (kDebugMode) {
    print('refreshToken get to $refreshToken');
  }
  return refreshToken;
}

Future<void> setUserId(String? userId) async {
  SharedPreferences token = await SharedPreferences.getInstance();
  token.setString('userId', userId ?? "0");
  if (kDebugMode) {
    log('userId setting to ${await getUserId()}');
  }
}

getUserId() async {
  SharedPreferences token = await SharedPreferences.getInstance();
  String userId = token.getString('userId') ?? "0";
  // String oldRefreshToken = await getRefreshToken();
  if (kDebugMode) {
    print('userId get to $userId');
  }
  return userId;
}

Future<void> setTimerEventId(String? timerEventId) async {
  SharedPreferences token = await SharedPreferences.getInstance();
  token.setString('timerEventId', timerEventId ?? "0");
  if (kDebugMode) {
    log('timerEventId setting to ${await getTimerEventId()}');
  }
}

getTimerEventId() async {
  SharedPreferences token = await SharedPreferences.getInstance();
  String timerEventId = token.getString('timerEventId') ?? "0";
  // String oldRefreshToken = await getRefreshToken();
  if (kDebugMode) {
    print('timerEventId get to $timerEventId');
  }
  return timerEventId;
}

getIsTimerRunning() async {
  SharedPreferences token = await SharedPreferences.getInstance();
  bool isTimerRunning = token.getBool('is_running') ?? false;
  // String oldRefreshToken = await getRefreshToken();
  if (kDebugMode) {
    print('isTimerRunning get to $isTimerRunning');
  }
  return isTimerRunning;
}

Future<void> setUser(User user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userJson = jsonEncode(user.toJson());
  if (kDebugMode) {
    print('User Data::: ${jsonDecode(userJson)}');
  }
  await prefs.setString('user', userJson);
}

// Function to retrieve the user object from SharedPreferences
Future<User?> getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  if (userJson != null) {
    Map<String, dynamic> userMap = jsonDecode(userJson);
    return User.fromJson(userMap);
  }
  return null; // Return null if no user is stored
}

Future<void> saveStartTime(DateTime startTime) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('timer_start_time', startTime.toIso8601String());
}

Future<DateTime?> getStartTime() async {
  final prefs = await SharedPreferences.getInstance();
  final savedTime = prefs.getString('timer_start_time');
  if (savedTime != null) {
    return DateTime.parse(savedTime);
  }
  return null;
}

Future<void> removeTimerData() async {
  SharedPreferences token = await SharedPreferences.getInstance();
  token.remove('seconds_elapsed');
  token.remove('start_time');
  token.remove('end_time');
}
