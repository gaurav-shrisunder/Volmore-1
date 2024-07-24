import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';



class TimerProvider with ChangeNotifier {
  int _elapsedTime = 0;
  bool _isLogging = false;
  bool _locationTracking = false;
  loc.LocationData? _locationData;
  String _address = "";
  late DateTime _startTime;
  final loc.Location _location = loc.Location();

  int get elapsedTime => _elapsedTime;

  bool get isLogging => _isLogging;

  bool get locationTracking => _locationTracking;

  loc.LocationData? get locationData => _locationData;

  String get address => _address;

  DateTime get startTime => _startTime;

  Future<void> toggleLogging(BuildContext context) async {
    if (_isLogging) {
      _isLogging = false;
      showDialog(
          context: context,
          builder: (context) {
            return Lottie.asset("assets/images/loader_lottie.json");
          });

      CollectionReference logs = FirebaseFirestore.instance.collection('logs');
      await logs.add({
        'elapsedTime(hh:mm:ss)':
            "${_elapsedTime ~/ 3600}:${(_elapsedTime % 3600) ~/ 60}:${_elapsedTime % 60}",
        'location': _locationData != null
            ? GeoPoint(_locationData!.latitude!, _locationData!.longitude!)
            : null,
        'startTime': _startTime,
        'address': _address,
        'endTime': DateTime.now(),
      }).then((onValue) {
        Navigator.of(context).pop();
      });
      showDialog(context: context, builder: (_){
        return SimpleDialog();

      });
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => SavedLogsScreen(
      //             elapsedTime: _elapsedTime,
      //             locationData: _locationData,
      //             startTime: _startTime,
      //             endTime: DateTime.now(),
      //             address: _address,
      //           )),
      // );
    } else {
      _isLogging = true;
      _startTime = DateTime.now();
      _startTimer();
    }
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