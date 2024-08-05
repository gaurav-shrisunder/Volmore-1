// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Screens/Event/volunteer_confirmation_screen.dart';

class TimerProvider with ChangeNotifier {
  int _elapsedTime = 0;
  bool _isLogging = false;
  final int _points = 0;
  bool _locationTracking = false;
  loc.LocationData? _locationData;
  String _address = "";
  late DateTime _startTime;
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
    } else {
      if (elapsedTime == 0) {
        _startTime = DateTime.now();
      }
      _isLogging = true;

      _startTimer();
    }
    notifyListeners();
  }

  Future<void> endLogging(BuildContext context, EventDataModel event) async {
    final SharedPreferences prefs = await _prefs;
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
    await logs.add({
      'elapsedTime(hh:mm:ss)':
          "${_elapsedTime ~/ 3600}:${(_elapsedTime % 3600) ~/ 60}:${_elapsedTime % 60}",
      'location': _locationData != null
          ? GeoPoint(_locationData!.latitude!, _locationData!.longitude!)
          : null,
      'startTime': _startTime,
      'address': _address,
      'title': event.title,
      'description': event.description,
      'group': event.group,
      'dateTime': [
        {
          'date': event.date,
          'startTime': _startTime,
          'endTime': DateTime.now(),
          'duration': "${_elapsedTime ~/ 3600}:${(_elapsedTime % 3600)}",
        }
      ]
    }).then((onValue) {
      Navigator.of(context).pop();
    });
    showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            title: Lottie.asset("assets/images/hurrah_lotttie.json"),
            children: [
              const Center(
                child: Text(
                  "Log Saved Succesfully",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VolunteerConfirmationScreen(
                                    event: event,
                                  )));
                    },
                    child: const Text("OK")),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          );
        });

    _elapsedTime = 0;
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
