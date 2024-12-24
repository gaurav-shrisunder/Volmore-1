import 'dart:async';

import 'package:flutter/material.dart';

import 'package:volunterring/Models/event_data_model.dart';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:volunterring/widgets/appbar_widget.dart';

import '../../Models/response_models/events_data_response_model.dart';
import '../../provider/time_logger_provider.dart';

class LogNowPage extends StatefulWidget {
  // final EventDataModel eventModel;
  final Event eventModel;
  final EventInstance eventInstance;

  const LogNowPage(this.eventModel, this.eventInstance, {super.key});

  @override
  State<LogNowPage> createState() => _LogNowPageState();
}

class _LogNowPageState extends State<LogNowPage> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;

  DateTime? _startTime;
  DateTime? _endTime;

  void _toggleStartPause() {
    if (_isRunning) {
      // Pause the timer
      setState(() {
        _isRunning = false;
        _endTime = DateTime.now();
      });
      _timer?.cancel();
    } else {
      // Start or resume the timer
      setState(() {
        _startTime ??= DateTime.now(); // Record start time only once
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsElapsed++;
        });
      });
    }
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _endTime = DateTime.now();
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _secondsElapsed = 0;
      _isRunning = false;
      _startTime = null;
      _endTime = null;
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  String _formatTimeOfDay(DateTime? dateTime) {
    return dateTime != null ? DateFormat('HH:mm').format(dateTime) : '--:--';
  }

  bool _isSubmitEnabled() {
    if (_startTime != null && _endTime != null) {
      final duration = _endTime!.difference(_startTime!).inMinutes;
      return duration >= 1;
    }
    return false;
  }

  void _submitData() {
    if (_isSubmitEnabled()) {
      final startUTC = _startTime?.toUtc();
      final endUTC = _endTime?.toUtc();
      print('Start Time (UTC): $startUTC');
      print('End Time (UTC): $endUTC');
      // Add your API call logic here
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: simpleAppBar(context, ""),
      body: Container(
        width: screenWidth,
        decoration: const BoxDecoration(
            //  color: Colors.white
            // gradient: backgroundGradient,
            ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Consumer<TimerProvider>(
            builder: (context, timerProvider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  /* Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            CupertinoIcons.back,
                            size: 40,
                          )),
                    ],
                  ),*/
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    /*  Text(
                        "Log Now",
                        style: TextStyle(
                            fontSize: screenWidth * 0.09,
                            fontWeight: FontWeight.bold),
                      ),*/

                      Text(
                        widget.eventModel.eventTitle!,
                        style: TextStyle(
                            fontSize: screenWidth * 0.09,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        _formatTime(_secondsElapsed),
                        style: TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                      ),

                        Visibility(
                          visible: (timerProvider.locationTracking &&
                              timerProvider.locationData != null),
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: const Icon(Icons.location_on)),

                        Visibility(
                          maintainState: true,
                          maintainSize: true,
                          maintainAnimation: true,
              visible: (timerProvider.locationTracking &&
              timerProvider.locationData != null),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28.0),
                            child: Text(
                              timerProvider.address,
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: screenWidth * 0.03),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(height: screenWidth * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Text('Start Time'),
                            SizedBox(height: 8),
                            Text(
                              _formatTimeOfDay(_startTime),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Text('End Time'),
                            SizedBox(height: 8),
                            Text(
                              _formatTimeOfDay(_endTime),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enable Location Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          //  color: Colors.black,
                        ),
                      ),
                      Switch(
                        activeColor: Colors.white,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.white,
                        activeTrackColor: Colors.black,
                        value: timerProvider.locationTracking,
                        onChanged: (value) {
                          if (!timerProvider.locationTracking) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Lottie.asset(
                                      "assets/images/loader_lottie.json");
                                });
                          }

                          timerProvider.toggleLocationTracking(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _resetTimer,
                            child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.restart_alt,
                                  size: 40,
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Restart",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _toggleStartPause,
                            child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    shape: BoxShape.circle),
                                child: Icon(
                                  _isRunning
                                      ? Icons.pause
                                      : Icons.play_arrow_rounded,
                                  size: 40,
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            _isRunning ? "Pause" : "Start",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _stopTimer,
                            child: Container(
                                padding: const EdgeInsets.all(21),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.square_rounded,
                                  size: 35,
                                  color: Colors.red,
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "End",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  GestureDetector(
                      onTap: () {
                        final startUTC = _startTime?.toUtc();
                        final endUTC = _endTime?.toUtc();
                        widget.eventModel.eventParticipatedDuration = "$startUTC::$endUTC";
                        timerProvider.submitLogging(
                            context, widget.eventModel, widget.eventInstance);
                      },
                      child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(21),
                              decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  shape: BoxShape.circle),
                              child: const Icon(
                                Icons.chevron_right_sharp,
                                size: 35,
                                color: Colors.black,
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Proceed",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ))
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
