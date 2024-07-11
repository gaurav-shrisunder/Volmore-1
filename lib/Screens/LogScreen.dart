import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Services/logService.dart';
import 'package:volunterring/widgets/snackbar.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  late Stopwatch stopwatch;
  late Timer t;
  String startTime = "";
  String endTime = "";
  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }

  String returnFormattedText() {
    var milli = stopwatch.elapsed.inMilliseconds;

    // String milliseconds = (milli % 1000).toString().padLeft(3, "0");
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0");
    String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0");
    String hours = (((milli ~/ 1000) ~/ 60) ~/ 60).toString().padLeft(2, "0");

    return "$hours:$minutes:$seconds";
  }

  void handleStartStop() async {
    if (stopwatch.isRunning) {
      setState(() {
        stopwatch.stop();
        endTime = formatTime(DateTime.now());
      });
      var res = await LogServices().createLog(
          startTime: startTime,
          endTime: endTime,
          duration: returnFormattedText());
      if (res == "Log Updated SuccessFully") {
        showSnackBar(context, res.toString());
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        print("Some error occurred");
        showSnackBar(context, res.toString());
      }
    } else {
      setState(() {
        stopwatch.start();
        startTime = formatTime(DateTime.now());
        endTime = ""; // Clear end time when starting
      });
    }
  }

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();

    t = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // title: const Text('Log Screen'),
            ),
        body: Center(
          child: Column(
            children: [
              Container(
                child: const Text(
                  'Log Now',
                  style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 190,
              ),
              Text(
                returnFormattedText(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 59,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Start Time:",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        startTime.isNotEmpty ? "$startTime" : "--:--",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      const Text(
                        "End Time",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        endTime.isNotEmpty ? " $endTime" : "--:--",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              CupertinoButton(
                onPressed: () {
                  handleStartStop();
                },
                padding: const EdgeInsets.all(0),
                child: Container(
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepOrange,
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
