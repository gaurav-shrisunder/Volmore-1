
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  print('BearerToken get to $bearerToken');
  return bearerToken;
}

Future<void> setRefreshToken(String refreshToken) async {
  SharedPreferences token = await SharedPreferences.getInstance();
  token.setString('refreshToken', refreshToken);
  print('refreshToken setting to ${await getBearerToken()}');
}

getRefreshToken() async {
  SharedPreferences token = await SharedPreferences.getInstance();
  String refreshToken = token.getString('refreshToken') ?? "0";
  // String oldRefreshToken = await getRefreshToken();

  print('refreshToken get to $refreshToken');
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

  print('BearerToken get to $userId');
  return userId;
}