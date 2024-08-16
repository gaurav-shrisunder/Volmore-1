// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Screens/Event/volunteer_confirmation_screen.dart';
import 'package:volunterring/Screens/HomePage.dart';

class TimerProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  int _elapsedTime = 0;
  bool _isLogging = false;
  final int _points = 0;
  bool _locationTracking = false;
  loc.LocationData? _locationData;
  String _address = "";
  late DateTime _startTime;
  late DateTime _endTime;
  final loc.Location _location = loc.Location();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _phoneNo = "";
  bool _isSignatureVerified = false;

  int get elapsedTime => _elapsedTime;

  int get points => _points;

  bool get isLogging => _isLogging;

  bool get locationTracking => _locationTracking;

  loc.LocationData? get locationData => _locationData;

  String get address => _address;

  DateTime get startTime => _startTime;
  String get phoneNo => _phoneNo;
  bool get isSignatureVerified => _isSignatureVerified;

  set phoneNo(String value) {
    _phoneNo = value;
    notifyListeners();
  }

  set isSignatureVerified(bool value) {
    _isSignatureVerified = value;
    notifyListeners();
  }

  Future<void> toggleLogging() async {
    if (_isLogging) {
      _isLogging = false;
      /// added the below to reset the elapsed time when going to next page
      _elapsedTime = 0;
    } else {
      if (elapsedTime == 0) {
        _startTime = DateTime.now();
      }
      _isLogging = true;

      _startTimer();
    }
    notifyListeners();
  }

  Future<void> endLogging(
      BuildContext context, EventDataModel event, DateTime date) async {
    _endTime = DateTime.now();
    toggleLogging();

    notifyListeners();
    log('time is: ${event.toString()}');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VolunteerConfirmationScreen(
                  event: event,
                  date: date,
                )));
  }

  Future<void> createSingleLog(
      BuildContext context,
      EventDataModel event,
      DateTime date,
      String? signature,
      String? number,
      List<Map<String, String>>? selectedLogs) async {
    final SharedPreferences prefs = await _prefs;
    String logId = _uuid.v4();
    String uid = prefs.getString("uid") ?? "";
    _isLogging = false;
    showDialog(
        context: context,
        builder: (context) {
          return Lottie.asset("assets/images/loader_lottie.json");
        });

    CollectionReference logs = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events')
        .doc(event.id)
        .collection("logs");
    await logs.doc(logId).set({
      'id': logId,
      'elapsedTime(hh:mm:ss)':
          "${_elapsedTime ~/ 3600}:${(_elapsedTime % 3600) ~/ 60}:${_elapsedTime % 60}",
      'location': _locationData != null
          ? GeoPoint(_locationData!.latitude!, _locationData!.longitude!)
          : null,
      'startTime': _startTime,
      'endTime': _endTime,
      'address': _address,
      'signature': signature,
      'phoneNumber': number,
      'date': date,
      'isLocationVerified': _locationData != null ? true : false,
      'isSignatureVerified': signature != null ? true : false,
      'isTimeVerified': _elapsedTime != 0 ? true : false,
    }).then((onValue) {
      Navigator.of(context).pop();
    });
    if (selectedLogs!.isNotEmpty) {
      try {
        for (var selectedEvent in selectedLogs) {
          String eventId = selectedEvent['eventId']!;
          String logId = selectedEvent['logId']!;
          final FirebaseFirestore firestore = FirebaseFirestore.instance;

          // Specify the path to the log document
          DocumentReference logRef = firestore
              .collection('users')
              .doc(uid)
              .collection('events')
              .doc(eventId)
              .collection('logs')
              .doc(logId);
          await logRef.update({
            'signature': signature,
            'isSignatureVerified': true,
            'phoneNumber': number,
          });
        }
      } catch (e) {
        Get.snackbar("Error", "Some Error in past events");
      }
    }
    showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            title: Lottie.asset("assets/images/hurrah_lotttie.json"),
            children: [
              const Center(
                child: Text(
                  "Log Saved Successfully",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: TextButton(
                    onPressed: () {
                      event.startTime = _startTime;
                      event.endTime = DateTime.now();
                      event.address = _address;
                      event.location = _location.toString();
                      event.duration =
                          "${_elapsedTime ~/ 3600}:${(_elapsedTime % 3600)}";

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
                    },
                    child: const Text("OK")),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          );
        });
    toggleLogging();

    // _elapsedTime = 0;
    notifyListeners();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isLogging) {
        _elapsedTime++;
        notifyListeners();
        _startTimer();
      }
    });
  }

  void toggleLocationTracking(BuildContext context) async {
    if (_locationTracking) {
      _locationData = null;
      _address = "";
    } else {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          Navigator.pop(context);
          return;
        }
      }

      _locationData = await _location.getLocation();
      await _getAddressFromLatLng(
              _locationData!.latitude!, _locationData!.longitude!)
          .then((onValue) {
        Navigator.pop(context);
      });
    }
    _locationTracking = !_locationTracking;
    notifyListeners();
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks[0];
      _address =
          "${place.street},\n ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
