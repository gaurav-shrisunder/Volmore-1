import 'package:flutter/material.dart';
import '../../Utils/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../provider/time_logger_provider.dart';


class LogNowPage extends StatefulWidget {
    final String taskName;
  const LogNowPage(this.taskName,{super.key});

  @override
  State<LogNowPage> createState() => _LogNowPageState();
}

class _LogNowPageState extends State<LogNowPage> {
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        decoration: const BoxDecoration(
          gradient: backgroundGradient,
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
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: const Icon(CupertinoIcons.back, size: 40,)),
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
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
                          child: Icon(Icons.location_on)
                          //locationIcon(timerProvider.locationTracking),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.5),
                          spreadRadius: 9,
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: MediaQuery.of(context).size.width / 3,
                      child: Column(
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
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    widget.taskName,
                    style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04),
                            ),
                            Text(
                              timerProvider.isLogging
                                  ? DateFormat('HH:mm')
                                      .format(timerProvider.startTime.toLocal())
                                  : '--:--',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
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
                  SizedBox(height: screenWidth * 0.05),
                  GestureDetector(
                      onTap: () {
                        timerProvider.toggleLogging(context);
                      },
                      child: timerProvider.isLogging
                          ? SvgPicture.asset(
                              "assets/images/stop_svg_icon.svg",
                              width: screenWidth * 0.26,
                              color: Colors.blueGrey,
                            )
                          : SvgPicture.asset(
                              "assets/images/start_svg_icon.svg",
                              width: screenWidth * 0.24,
                              color: Colors.blueGrey,
                            )),

                            
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


