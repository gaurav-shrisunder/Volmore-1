// File: lib/.../LogNowPage.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/event_data_model.dart';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../Utils/common_utils.dart';
import '../../Utils/shared_prefs.dart';
import '../../widgets/appbar_widget.dart';

import '../../Models/response_models/events_data_response_model.dart';
import '../../provider/time_logger_provider.dart';
import '../../Services/background_timer_service.dart';
import '../../Services/notification_service.dart';
// NOTE: BackgroundTaskHandler removed from usage to avoid two timers fighting.
// If you still want the file present, keep it but DO NOT call its start/pause/resume/stop.

class LogNowPage extends StatefulWidget {
  // final EventDataModel eventModel;
  final Event eventModel;
  final EventInstance eventInstance;

  const LogNowPage(this.eventModel, this.eventInstance, {super.key});

  @override
  State<LogNowPage> createState() => _LogNowPageState();
}

class _LogNowPageState extends State<LogNowPage> with WidgetsBindingObserver {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;

  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _pauseTime; // Track when timer was paused
  int _totalPausedDuration = 0; // Track total paused time in seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTimerState();

    // Only use BackgroundTimerService callbacks (single source of truth)
    BackgroundTimerService.onTimerUpdate = (int seconds) {
      if (mounted && _isRunning) {
        setState(() {
          _secondsElapsed = _computeElapsedSeconds();
        });
        NotificationService.updateTimerNotification(_secondsElapsed, true);
      }
    };

    BackgroundTimerService.onTimerStopped = () {
      if (mounted) {
        setState(() {
          _isRunning = false;
          _endTime = DateTime.now();
        });
        NotificationService.hideTimerNotification();
      }
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Save current state when app goes to background
      _saveTimerState();

      // If timer is running, ensure background timer service is started
      if (_isRunning) {
        BackgroundTimerService.startBackgroundTimer();
        // NOTE: Do NOT start BackgroundTaskHandler — it was causing conflicts
      }
    } else if (state == AppLifecycleState.resumed) {
      // Re-load state when app returns
      _loadTimerState();

      // If it was running, resume background service as well
      if (_isRunning) {
        BackgroundTimerService.resumeBackgroundTimer();
      }
    }
  }

  void _toggleStartPause() async {
    if (_isRunning) {
      // Pausing the timer
      setState(() {
        _isRunning = false;
        _pauseTime = DateTime.now();
        _secondsElapsed = _computeElapsedSeconds();
      });
      _timer?.cancel(); // Stop periodic UI updates
      await BackgroundTimerService
          .pauseBackgroundTimer(); // Pause background timer
      await NotificationService.updateTimerNotification(
          _secondsElapsed, false); // Show paused notification
    } else {
      // Starting or resuming the timer
      setState(() {
        if (_startTime == null) {
          _startTime = DateTime.now();
        } else if (_pauseTime != null) {
          _totalPausedDuration +=
              DateTime.now().difference(_pauseTime!).inSeconds;
          _pauseTime = null;
        }
        _isRunning = true;
        _secondsElapsed = _computeElapsedSeconds();
      });
      await BackgroundTimerService
          .startBackgroundTimer(); // Start background timer
      _startTicker(); // Restart periodic UI updates
      await NotificationService.showTimerNotification(
          _formatTime(_secondsElapsed)); // Show running notification
    }
    await _saveTimerState();
  }

  void _stopTimer() async {
    setState(() {
      _isRunning = false;
      _endTime = DateTime.now();
      if (_pauseTime != null) {
        // If we were paused, don't add more pause time
        _pauseTime = null;
      }
    });
    _timer?.cancel();
    await BackgroundTimerService.stopBackgroundTimer();
    await NotificationService.hideTimerNotification();
    await _saveTimerState();
  }

  void _resetTimer() async {
    setState(() {
      _secondsElapsed = 0;
      _isRunning = false;
      _startTime = null;
      _endTime = null;
      _pauseTime = null;
      _totalPausedDuration = 0;
    });
    _timer?.cancel();
    await BackgroundTimerService.resetBackgroundTimer();
    await NotificationService.hideTimerNotification();
    await _clearTimerState();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed = _computeElapsedSeconds();
      });
      // Keep notification in sync
      if (_isRunning) {
        NotificationService.updateTimerNotification(_secondsElapsed, true);
      }
    });
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();

    // Save running flag
    await prefs.setBool('is_running', _isRunning);

    // Save total paused duration
    await prefs.setInt('total_paused_duration', _totalPausedDuration);

    // Save start_time only if it's set (we keep it for UI/submission)
    if (_startTime != null) {
      await prefs.setString('start_time', _startTime!.toIso8601String());
    } else {
      await prefs.remove('start_time');
    }

    // Save end_time if present
    if (_endTime != null) {
      await prefs.setString('end_time', _endTime!.toIso8601String());
    } else {
      await prefs.remove('end_time');
    }

    // Save pause_time if present
    if (_pauseTime != null) {
      await prefs.setString('pause_time', _pauseTime!.toIso8601String());
    } else {
      await prefs.remove('pause_time');
    }

    // Save current elapsed seconds for accurate restoration
    await prefs.setInt('seconds_elapsed', _secondsElapsed);
  }

  Future<void> _loadTimerState() async {
    // Use SharedPreferences as the single source of truth for persistence
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool('is_running') ?? false;
    final startTimeStr = prefs.getString('start_time');
    final endTimeStr = prefs.getString('end_time');
    final pauseTimeStr = prefs.getString('pause_time');
    final totalPausedDuration = prefs.getInt('total_paused_duration') ?? 0;
    final savedSecondsElapsed = prefs.getInt('seconds_elapsed') ?? 0;

    final start = startTimeStr != null ? DateTime.tryParse(startTimeStr) : null;
    final end = endTimeStr != null ? DateTime.tryParse(endTimeStr) : null;
    final pause = pauseTimeStr != null ? DateTime.tryParse(pauseTimeStr) : null;

    setState(() {
      _startTime = start;
      _endTime = end;
      _pauseTime = pause;
      _totalPausedDuration = totalPausedDuration;
      _isRunning = isRunning;
      _secondsElapsed = _computeElapsedSeconds();

      if (_startTime != null) {
        if (_isRunning) {
          // Timer is currently running - calculate from now minus paused time
          final totalElapsed = DateTime.now().difference(_startTime!).inSeconds;
          _secondsElapsed = totalElapsed - _totalPausedDuration;
        } else {
          // Timer is stopped/paused
          if (_endTime != null) {
            // Timer was stopped - show final duration
            final totalElapsed = _endTime!.difference(_startTime!).inSeconds;
            _secondsElapsed = totalElapsed - _totalPausedDuration;
          } else if (_pauseTime != null) {
            // Timer is paused - show duration up to pause time
            final totalElapsed = _pauseTime!.difference(_startTime!).inSeconds;
            _secondsElapsed = totalElapsed - _totalPausedDuration;
          } else {
            // Use saved elapsed time
            _secondsElapsed = savedSecondsElapsed;
          }
        }
      } else {
        _secondsElapsed = 0;
      }
    });

    if (_isRunning) {
      _startTicker();
      // Resume notification if timer was running
      await NotificationService.showTimerNotification(
          _formatTime(_secondsElapsed));
    }
  }

  // Helper method to update notification during timer ticks
  void _updateNotificationTimer() {
    if (_isRunning) {
      NotificationService.updateTimerNotification(_secondsElapsed, true);
    }
  }

  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('is_running');
    prefs.remove('start_time');
    prefs.remove('end_time');
    prefs.remove('pause_time');
    prefs.remove('total_paused_duration');
    prefs.remove('seconds_elapsed');
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

  int _computeElapsedSeconds() {
    if (_startTime == null) return 0;
    if (_isRunning) {
      return DateTime.now().difference(_startTime!).inSeconds -
          _totalPausedDuration;
    } else if (_pauseTime != null) {
      return _pauseTime!.difference(_startTime!).inSeconds -
          _totalPausedDuration;
    } else if (_endTime != null) {
      return _endTime!.difference(_startTime!).inSeconds - _totalPausedDuration;
    }
    return 0;
  }

  bool _isSubmitEnabled() {
    if (_startTime != null && _endTime != null) {
      final totalElapsed = _endTime!.difference(_startTime!).inSeconds;
      final actualDuration = totalElapsed - _totalPausedDuration;
      return actualDuration >= 60; // At least 1 minute of actual time
    }
    return false;
  }

  void _submitData() {
    if (_isSubmitEnabled()) {
      final startUTC = _startTime?.toUtc();
      final endUTC = _endTime?.toUtc();
      print('Start Time (UTC): $startUTC');
      print('End Time (UTC): $endUTC');
      print('Total Paused Duration: $_totalPausedDuration seconds');
      print('Actual Duration: $_secondsElapsed seconds');
      // Add your API call logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
            onPressed: () async {
              await _clearTimerState();
              await NotificationService.hideTimerNotification();
              Navigator.pop(context);
            },
            icon: const Icon(CupertinoIcons.chevron_left)),
        //  backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
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
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 28.0),
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
                          if (_isRunning) {
                            Fluttertoast.showToast(
                                msg: "Please end the event first");
                          } else {
                            final startUTC = _startTime?.toUtc();
                            final endUTC = _endTime?.toUtc();
                            final startUTCiSO =
                                _startTime?.toUtc().toIso8601String();
                            final endUTCiSO =
                                _endTime?.toUtc().toIso8601String();
                            if (startUTCiSO != null && endUTCiSO != null) {
                              // Use actual elapsed seconds instead of total duration
                              if (_secondsElapsed < 60) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Duration cannot be less than 1 minute");
                              } else {
                                widget.eventModel.eventParticipatedDuration =
                                    "$startUTC::$endUTC";
                                timerProvider.submitLogging(context,
                                    widget.eventModel, widget.eventInstance);
                              }
                            }
                          }
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
      ),
    );
  }
}
