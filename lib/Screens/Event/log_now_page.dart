import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:volunterring/Models/event_data_model.dart';
import '../../Utils/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../provider/time_logger_provider.dart';

class LogNowPage extends StatefulWidget {
  final String taskName;
  final EventDataModel eventModel;
  const LogNowPage(this.taskName, this.eventModel, {super.key});

  @override
  State<LogNowPage> createState() => _LogNowPageState();
}

class _LogNowPageState extends State<LogNowPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        decoration: const BoxDecoration(color: Colors.white
            // gradient: backgroundGradient,
            ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Consumer<TimerProvider>(
            builder: (context, timerProvider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  Row(
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
                  ),
                  // Container(
                  //   padding: const EdgeInsets.all(15),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     shape: BoxShape.circle,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.blueGrey.withOpacity(0.5),
                  //         spreadRadius: 9,
                  //         blurRadius: 15,
                  //         offset: const Offset(0, 3),
                  //       ),
                  //     ],
                  //   ),
                  //   child: CircleAvatar(
                  //     backgroundColor: Colors.white,
                  //     radius: MediaQuery.of(context).size.width / 3,
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text(
                  //           '${(timerProvider.elapsedTime ~/ 3600).toString().padLeft(2, '0')}:${((timerProvider.elapsedTime % 3600) ~/ 60).toString().padLeft(2, '0')}:${(timerProvider.elapsedTime % 60).toString().padLeft(2, '0')}',
                  //           style: TextStyle(
                  //               fontSize: screenWidth * 0.10,
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //         if (timerProvider.locationTracking &&
                  //             timerProvider.locationData != null)
                  //           const Icon(Icons.location_on),
                  //         if (timerProvider.locationTracking &&
                  //             timerProvider.locationData != null)
                  //           Text(
                  //             timerProvider.address,
                  //             maxLines: 3,
                  //             textAlign: TextAlign.center,
                  //             overflow: TextOverflow.ellipsis,
                  //             style: TextStyle(fontSize: screenWidth * 0.03),
                  //           ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  CircularPercentIndicator(
                    radius: MediaQuery.of(context).size.width / 2.7,
                    lineWidth: 15.0,
                    percent: timerProvider.elapsedTime.toDouble() / (600 * 60),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(timerProvider.elapsedTime ~/ 3600).toString().padLeft(2, '0')}:${((timerProvider.elapsedTime % 3600) ~/ 60).toString().padLeft(2, '0')}:${(timerProvider.elapsedTime % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: screenWidth * 0.10,
                              fontWeight: FontWeight.bold),
                        ),
                        if (timerProvider.locationTracking &&
                            timerProvider.locationData != null)
                          const Icon(Icons.location_on),
                        if (timerProvider.locationTracking &&
                            timerProvider.locationData != null)
                          Text(
                            timerProvider.address,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: screenWidth * 0.03),
                          ),
                      ],
                    ),
                    progressColor: Colors.blue,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    widget.taskName,
                    style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: () {
                            timerProvider.toggleLogging();
                          },
                          child: timerProvider.isLogging
                              ? Column(
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.pause,
                                          size: 40,
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Stop",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )
                              : Column(
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          size: 40,
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Start",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )),
                      GestureDetector(
                          onTap: () {
                            timerProvider.endLogging(
                                context, widget.eventModel);
                          },
                          child: Column(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(21),
                                  decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      shape: BoxShape.circle),
                                  child: const Icon(
                                    Icons.square_rounded,
                                    size: 35,
                                    color: Colors.red,
                                  )),
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
                          )),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!)),
                        child: Column(
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  fontSize: screenWidth * 0.04),
                            ),
                            Text(
                              timerProvider.elapsedTime != 0
                                  ? DateFormat('HH:mm')
                                      .format(timerProvider.startTime.toLocal())
                                  : '--:--',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!)),
                        child: Column(
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  fontSize: screenWidth * 0.04),
                            ),
                            Text(
                              !(timerProvider.isLogging ||
                                      timerProvider.elapsedTime == 0)
                                  ? DateFormat('HH:mm')
                                      .format(DateTime.now().toLocal())
                                  : '--:--',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
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
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
