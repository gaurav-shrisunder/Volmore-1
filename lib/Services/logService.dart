import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:volunterring/Models/UserModel.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Services/authentication.dart';

class LogServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final Uuid _uuid = const Uuid();
  final authMethods = AuthMethod();

  Future<String> createLogs({
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

  Future<String> createLog(Map<String, dynamic> eventData) async {
    String res = "Some error occurred";
    final SharedPreferences prefs = await _prefs;
    var uid = prefs.getString("uid");
    String logId = _uuid.v4();
    try {
      if (eventData.isNotEmpty) {
        // Add log to your Firestore database
        await _firestore
            .collection("users")
            .doc(uid)
            .collection("logs")
            .doc(logId)
            .set({
          'dateTimes': eventData['dateTimes'],
          'title': eventData['title'],
          'description': eventData['description'],
          'userId': prefs.getString("uid"),
          'id': logId,
          'location': eventData['location'],
          'address': eventData['address'],
          'group': eventData['group'],
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

  Future<List<EventDataModel>> fetchAllEventsWithLogs() async {
    final SharedPreferences prefs = await _prefs;
    String? uid = prefs.getString("uid");

    if (uid == null) {
      return []; // Handle the case where UID is null
    }

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

      return events;
    } catch (e) {
      print(e);
      return []; // Handle errors appropriately
    }
  }


  Future<String> createPastLog(Map<String, dynamic> eventData) async {
    String res = "Some error occurred";
    final SharedPreferences prefs = await _prefs;
    String? uid = prefs.getString("uid");
    String eventId = _uuid.v4();
    String logId = _uuid.v4();
    // Get user id
    String useruid = prefs.getString("uid") ?? _auth.currentUser!.uid;
    UserModel? user = await authMethods.fetchUserData();

    // Generate UUID for the event

    try {
      if (eventData.isNotEmpty && uid != null) {
        // Step 1: Create the event in Firestore
        await _firestore
            .collection("users")
            .doc(uid)
            .collection("events")
            .doc(eventId)
            .set({
          'id': eventId,
          'title': eventData['title'],
          'description': eventData['description'],
          'date': eventData['date'], // Ensure 'date' is in eventData
          'location':
              eventData['location'], // Keep this null as per the requirement
          'occurrence': eventData['occurrence'] ??
              "No occurence", // Default to "One-time" if not provided
          'group': eventData['group'] ?? "General",
          'host':
              user?.name ?? "You", // Assuming you have host data in eventData
          'host_id': uid,
          // 'time': eventData['time'], // Ensure 'time' is in eventData
          // Use 'endDate' if provided, else 'date'
          'dates': eventData['dates'], // Ensure 'dates' is in eventData
        });

        CollectionReference logsCollection = _firestore
            .collection("users")
            .doc(uid)
            .collection("events")
            .doc(eventId)
            .collection("logs");

        List<Map<String, dynamic>> logs = eventData['logs'];
        for (Map<String, dynamic> log in logs) {
          String logId = _uuid.v4();
          await logsCollection.doc(logId).set({
            'elapsedTime(hh:mm:ss)':
                log['duration'], // Use the duration from logs
            'location': null, // Keep the location null as required
            'startTime': log['startTime'], // Start time from logs
            'endTime': log['endTime'], // End time from logs
            'address': null, // Keep the address null
            'signature': null, // Signature is null
            'phoneNumber': null, // Phone number is null
            'date': log['date'], // Date from logs
            'isLocationVerified': false, // Location verification set to false
            'isSignatureVerified': false,
            'isTimeVerified': log['duration'] != "00:00:00",
          });
        }
        res = "Event and Log created successfully";
      } else {
        res = "Event data is incomplete or UID is null";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<String> createSingleLog(EventDataModel eventData) async {
    String res = "Some error occurred";
    final SharedPreferences prefs = await _prefs;
    var uid = prefs.getString("uid");
    String logId = _uuid.v4();
    try {
      if (!eventData.isNull) {
        // Add log to your Firestore database
        await _firestore
            .collection("users")
            .doc(uid)
            .collection("logs")
            .doc(logId)
            .set({
          'dateTimes': eventData.dates,
          'title': eventData.title,
          'description': eventData.description,
          'userId': prefs.getString("uid"),
          'id': logId,
          'location': eventData.location,
          'address': eventData.address,
          'group': eventData.group,
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
