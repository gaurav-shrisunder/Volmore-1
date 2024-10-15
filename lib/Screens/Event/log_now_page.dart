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
   final String eventInstanceId;

  const LogNowPage( this.eventModel, this.eventInstanceId ,{super.key});

  @override
  State<LogNowPage> createState() => _LogNowPageState();
}

class _LogNowPageState extends State<LogNowPage> {


  @override
  void dispose() {
    // TODO: implement dispose
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
                      Text(
                        "Log Now",
                        style: TextStyle(
                            fontSize: screenWidth * 0.09,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Shift Hours",
                        style:
                            TextStyle(fontSize: 24, color: Colors.orange[400]),
                      ),
                      Text(
                        '${(timerProvider.elapsedTime ~/ 3600).toString().padLeft(2, '0')}:${((timerProvider.elapsedTime % 3600) ~/ 60).toString().padLeft(2, '0')}:${(timerProvider.elapsedTime % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                            fontSize: screenWidth * 0.14,
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
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    widget.eventModel.eventTitle!,
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
                                          Icons.restart_alt,
                                          size: 40,
                                        )),
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
                                context, widget.eventModel, widget.eventInstanceId);
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
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
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
                                color: Colors.black,
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
