import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Controllers/event_controller.dart';
import 'package:volunterring/Models/UserModel.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:intl/intl.dart';
import 'package:volunterring/Screens/Manage%20Account/edit_account_screen.dart';
import 'package:volunterring/Services/logService.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/weekly_stats_chart.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isLoading = true;
  final eventController = Get.find<EventController>();
  UserModel? user;
  List<double> weeklyHours = [];
  var durationString = "";
  var weeklyDuration = "";
  List<EventDataModel>? events;
  final _authMethods = LogServices();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('uid');
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
    events = eventController.getEventList();
    // durationString = calculateTotalDuration(events!);
    weeklyDuration = calculateWeeklyDuration(events!);
    weeklyHours = calculateWeeklyHours(events!);

    setState(() {
      isLoading = false;
    });
  }

  String calculateWeeklyDuration(List<EventDataModel> events) {
    int totalSeconds = 0;

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    print("Start of week $startOfWeek");

    for (var event in events) {
      event.logs?.forEach((log) {
        if (log.elapsedTime != null) {
          DateTime logDate = log.date.toDate();
          if (logDate.isAfter(startOfWeek) &&
              logDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
            List<String> parts = log.elapsedTime!.split(':');
            if (parts.length == 3) {
              int hours = int.parse(parts[0]);
              int minutes = int.parse(parts[1]);
              int seconds = int.parse(parts[2]);

              totalSeconds += (hours * 3600) + (minutes * 60) + seconds;
            }
          }
        }
      });
    }

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    print("hours: $hours");
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<double> calculateWeeklyHours(List<EventDataModel> events) {
    List<double> weeklyHours = List.filled(7, 0);

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var event in events) {
      if (event.logs != null) {
        for (var log in event.logs!) {
          DateTime logDate = log.date.toDate();
          if (logDate.isAfter(startOfWeek) &&
              logDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
            int dayIndex = logDate.weekday - 1;

            List<String> timeParts = log.elapsedTime!.split(':');
            int hours = int.parse(timeParts[0]);
            int minutes = int.parse(timeParts[1]);

            weeklyHours[dayIndex] +=
                hours.toDouble() + (minutes / 60).round().toDouble();
          }
        }
      }
    }
    print("Weekly hours $weeklyHours");

    return weeklyHours;
  }

  List<DataRow> generateWeeklyLogRows(List<EventDataModel> events) {
    List<DataRow> logRows = [];

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var event in events) {
      event.logs?.forEach((log) {
        DateTime logDate = log.date.toDate();
        if (logDate.isAfter(startOfWeek) &&
            logDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
          logRows.add(
            DataRow(cells: [
              DataCell(Text(event.title ?? "")),
              DataCell(Text(DateFormat.yMMMd().format(logDate))),
              DataCell(Text(event.location ?? "No location")),
            ]),
          );
        }
      });
    }

    if (logRows.isEmpty) {
      logRows.add(
        const DataRow(cells: [
          DataCell(Text("No data this week",
              style: TextStyle(fontStyle: FontStyle.italic))),
          DataCell(Text("")),
          DataCell(Text("")),
        ]),
      );
    }

    return logRows;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                      backgroundColor: headingBlue,
                      child: IconButton(
                          onPressed: () {
                            Get.to(
                                EditAccountScreen(user!.name!, user!.phone!));
                          },
                          icon: const Icon(Icons.edit)))),
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/images/profile_avatar.png"),
              ),
              const SizedBox(height: 10),
              Text(
                user!.name!,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                user!.email!,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
              ),
              SizedBox(height: height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              "assets/images/timer.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text(
                                "${(user!.totalMinutes / 60).toStringAsFixed(1) ?? 0} Hour",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: headingBlue),
                              ),
                              const Text("Lifetime Hours",
                                  style: TextStyle(
                                    fontSize: 12,
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 10,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              "assets/images/timer.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text(
                                "${weeklyDuration.split(":")[0]} Hrs",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: headingBlue),
                              ),
                              const Text("This week",
                                  style: TextStyle(
                                    fontSize: 12,
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Weekly Stats",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))),
              SizedBox(height: height * 0.02),
              Card(
                elevation: 10,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.27,
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color of the container
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: WeeklyStatsChart(
                    xAxisList: const [
                      "Mon",
                      "Tues",
                      "Wed",
                      "Thru",
                      "Fri",
                      "Sat",
                      "Sun"
                    ],
                    yAxisList: weeklyHours,
                    xAxisName: "",
                    yAxisName: "",
                    interval: 1,
                  ),
                ),
              ),
              // SizedBox(height: height * 0.02),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: generateWeeklyLogWidgets(events!),
              // ),
              SizedBox(height: height * 0.02),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Weekly Logs",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              SizedBox(height: height * 0.02),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Location')),
                  ],
                  rows: generateWeeklyLogRows(events!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
