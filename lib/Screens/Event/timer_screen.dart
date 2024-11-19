import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
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
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Timer display
            Text(
              _formatTime(_secondsElapsed),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reset Button
                CircleAvatar(
                  radius: 30,
                  child: IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: _resetTimer,
                  ),
                  backgroundColor: Colors.blue,
                ),
                // Start/Pause Button
                CircleAvatar(
                  radius: 30,
                  child: IconButton(
                    icon: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _toggleStartPause,
                  ),
                  backgroundColor: _isRunning ? Colors.orange : Colors.green,
                ),

                // Stop Button
                CircleAvatar(
                  radius: 30,
                  child: IconButton(
                    icon: Icon(Icons.stop, color: Colors.white),
                    onPressed: _stopTimer,
                  ),
                  backgroundColor: Colors.red,
                ),


              ],
            ),
            SizedBox(height: 20),
            // Start and End Time Containers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('Start Time'),
                      SizedBox(height: 8),
                      Text(
                        _formatTimeOfDay(_startTime),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('End Time'),
                      SizedBox(height: 8),
                      Text(
                        _formatTimeOfDay(_endTime),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitEnabled() ? _submitData : null,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSubmitEnabled() ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
