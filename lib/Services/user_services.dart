import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/UserModel.dart';
import '../Models/event_data_model.dart';
import '../Utils/shared_prefs.dart';
import '../api_handler.dart';

class UserServices {
  final ApiBaseHelper apiHandler = ApiBaseHelper();

  Future<dynamic> updateUserApi(dynamic requestBody) async {
    var userId = await getUserId();
    Response? response = await apiHandler.put("api/v1/users/$userId/profile", requestBody);
    if (response != null && response.statusCode == 200) {

      return response.body;
    } else {
      if (kDebugMode) {
        print('Failed to load token data');
      }
      return null;
    }
  }


  Future<dynamic> changePassword(String newPass, String oldPass) async {

    var userId = await getUserId();
    var reqBody = {

    };
    Response? response = await apiHandler.put("api/v1/users/$userId/profile", reqBody);
    if (response != null && response.statusCode == 200) {

      return response.body;
    } else {
      if (kDebugMode) {
        print('Failed to load token data');
      }
      return null;
    }
  }



  /*final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<UserModel?>?> fetchAllUsers() async {
    try {
      List<UserModel> userList = [];

      QuerySnapshot<Map<String, dynamic>> allUsers =
          await FirebaseFirestore.instance.collection('users').get();
      for (var user in allUsers.docs) {
        UserModel userModel = UserModel();
        // dynamic totalhours = await fetchUserTotalHours(user.get("uid"));

        print('User:::: ${user.data()}');
        userModel.name = user.get("name");
        userModel.state = *//*user.get("state") ??*//* "Michigan";
        userModel.gradYear = *//*user.get("grad_year") ?? *//* "2024";
        userModel.totalMinutes = user.get("total_minutes");
        userModel.minutesInfluenced = user.get("minutes_influenced");

        userList.add(userModel);
      }

      userList
          .sort((a, b) => (b.totalMinutes ?? 0).compareTo(a.totalMinutes ?? 0));
      log('UserList:::: ${jsonEncode(userList)}');

      // Convert document data to UserModel
      //  return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      return userList;
    } catch (e) {
      print('Catch error : ${e.toString()}');
      // Handle any errors that occur

      return null;
    }
  }

  Future<num> fetchUserTotalHours(String uid) async {
    int lifetimeCountedMinutes = 0;
    try {
      // Fetch all events for the user
      QuerySnapshot eventSnapshot = await _firestore
          .collection("users")
          .doc(uid)
          .collection("events")
          .get();

      List<EventDataModel> events = [];

      // Iterate through each event document
      for (var eventDoc in eventSnapshot.docs) {
        String eventId = eventDoc.id;

        // Fetch logs associated with this event
        QuerySnapshot logsSnapshot = await _firestore
            .collection("users")
            .doc(uid)
            .collection("events")
            .doc(eventId)
            .collection("logs")
            .get();

        List<LogModel> logs = logsSnapshot.docs.map((doc) {
          return LogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Create an instance of EventModel
        EventDataModel event = EventDataModel.fromMap(
          eventDoc.data() as Map<String, dynamic>,
          eventId,
          logs,
        );
        events.add(event);
      }

      // return events;

      for (var event in events) {
        for (var action in event.logs!) {
          lifetimeCountedMinutes = (lifetimeCountedMinutes +
              int.parse(action.elapsedTime!.split(":")[0]));
        }
      }
      return lifetimeCountedMinutes;
    } catch (e) {
      print(e);
      return lifetimeCountedMinutes; // Handle errors appropriately
    }
  }*/
}
