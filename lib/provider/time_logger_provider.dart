// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Models/UserModel.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Screens/Event/volunteer_confirmation_screen.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Utils/common_utils.dart';

import '../Models/response_models/events_data_response_model.dart';

class TimerProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  DateTime? _startTime;
  DateTime? _endTime;
  int _elapsedTime = 0;
  bool _isLogging = false;

  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  bool get isLogging => _isLogging;
  int get elapsedTime => _elapsedTime;
  // int _elapsedTime = 0;
  int duration = 0;
  // bool _isLogging = false;
  final int _points = 0;
  bool _locationTracking = false;
  loc.LocationData? _locationData;
  String _address = "";
  // late DateTime _startTime;
  // late DateTime _endTime;
  final loc.Location _location = loc.Location();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _phoneNo = "";
  bool _isSignatureVerified = false;

  // int get elapsedTime => _elapsedTime;

  int get points => _points;

  // bool get isLogging => _isLogging;

  bool get locationTracking => _locationTracking;

  loc.LocationData? get locationData => _locationData;

  String get address => _address;

  // DateTime get startTime => _startTime;
  // DateTime get endTime => _endTime;
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


  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isLogging) {
        _elapsedTime++;
        notifyListeners();
        _startTimer();
      }
    });
  }

  Future<void> toggleLogging() async {
    if (_isLogging) {
      // Stop the timer
      _isLogging = false;
      notifyListeners(); // Update the UI with the stopped state
    } else {
      // Start the timer
      _startTime = DateTime.now();
      _isLogging = true;
      _endTime = null; // Reset _endTime when starting fresh
      _startTimer();
    }
    notifyListeners();
  }

  Future<void> endLogging(
      BuildContext context, Event event, EventInstance eventInstance) async {
    if (_isLogging) {
      // Set end time and stop the timer
      _endTime = DateTime.now();
      if (_startTime != null &&
          _startTime!.difference(_endTime!).inMinutes.abs() >= 1) {
        _isLogging = false; // Stop logging
        notifyListeners(); // Update UI to reflect stopped state
        log('Logged duration: ${_startTime!.toIso8601String()} - ${_endTime!.toIso8601String()}');
      } else {
        Fluttertoast.showToast(msg: "Please log for at least 1 minute.");
      }
    }
  }

  Future<void> submitLogging(
      BuildContext context, Event event, EventInstance eventInstance) async {
    if (_startTime != null && _endTime != null) {
      event.eventParticipatedDuration =
      "${_startTime!.toIso8601String()}::${_endTime!.toIso8601String()}";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VolunteerConfirmationScreen(
            event,
            eventInstance,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Please start and end the logging first.");
    }
  }

  void resetTimer() {
    _elapsedTime = 0;
    _startTime = null;
    _endTime = null;
    _isLogging = false;
    notifyListeners();
  }



/*  Future<void> toggleLogging() async {
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
      BuildContext context, Event event, EventInstance eventInstance,) async {
    _endTime = DateTime.now();
    if( startTime.minute < endTime.minute) {
      toggleLogging();
      notifyListeners();
      event.eventParticipatedDuration =
      "${startTime.toIso8601String() + "::" + endTime.toIso8601String()}";
      log('time is: ${startTime.toIso8601String()} :: ${endTime
          .toIso8601String()}');

      ///Navigating to Confirmation form screen with the Event data

     *//* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VolunteerConfirmationScreen(
                      event, eventInstance

                  )));*//*
    }else{
      Fluttertoast.showToast(msg: "Should complete atleast 1 minute");
    }
  }

  Future<void> submitLogging(
      BuildContext context, Event event, EventInstance eventInstance,) async {
    _endTime = DateTime.now();
    if( startTime.minute < endTime.minute) {
      toggleLogging();
      notifyListeners();
      event.eventParticipatedDuration =
      "${startTime.toIso8601String() + "::" + endTime.toIso8601String()}";
      log('time is: ${startTime.toIso8601String()} :: ${endTime
          .toIso8601String()}');

      ///Navigating to Confirmation form screen with the Event data

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VolunteerConfirmationScreen(
                      event, eventInstance

                  )));
    }else{
      Fluttertoast.showToast(msg: "Should complete atleast 1 minute");
    }
  }


  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isLogging) {
        _elapsedTime++;
        duration++;
        notifyListeners();
        _startTimer();
      }
    });
  }*/

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
