import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> createLog({
    required String startTime,
    required String endTime,
    required String duration,
  }) async {
    String res = "Some error occurred";
    final SharedPreferences prefs = await _prefs;
    var uid = prefs.getString("uid");
    try {
      if (startTime.isNotEmpty && endTime.isNotEmpty && duration.isNotEmpty) {
        // Add log to your Firestore database
        await _firestore.collection("users").doc(uid).collection("logs").add({
          'startTime': startTime,
          'endTime': endTime,
          'duration': duration,
          'userId': prefs.getString("uid"),
        });

        res = "Log Updated SuccessFully";
      } else {
        res = "Some Error Occurred";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}
