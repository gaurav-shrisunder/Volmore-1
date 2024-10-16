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
import 'package:volunterring/Models/response_models/sign_up_response_model.dart';
import 'package:volunterring/Models/response_models/weekly_stats_response_model.dart';
import 'package:volunterring/Screens/Manage%20Account/edit_account_screen.dart';
import 'package:volunterring/Services/logService.dart';
import 'package:volunterring/Services/profile_services.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/widgets/weekly_stats_chart.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isLoading = true;
  WeeklyStatsResponseModel? weeklyStats;
  ProfileServices profileServices = ProfileServices();
  User? user;

  void fetchWeeklyStats() async {
    WeeklyStatsResponseModel? temp = await profileServices.getWeeklyStats();
    user = await getUser();
    if (temp != null) {
      setState(() {
        weeklyStats = temp;
        isLoading = false;
        user = user;
      });
    }
  }

  @override
  void initState() {
    fetchWeeklyStats();
    super.initState();
  }

  List<DataRow> generateWeeklyLogRows(List<EventDetail> events) {
    List<DataRow> logRows = [];

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var event in events) {
      logRows.add(
        DataRow(cells: [
          DataCell(Text(event.title ?? "")),
          DataCell(Text(DateFormat.yMMMd().format(DateTime.parse(event.date)))),
          DataCell(Text(event.location ?? "No location")),
        ]),
      );
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
                            // Get.to(
                            // EditAccountScreen(user!.name!, user!.phone!));
                          },
                          icon: const Icon(Icons.edit)))),
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/images/profile_avatar.png"),
              ),
              const SizedBox(height: 10),
              Text(
                user?.userName ?? "User",
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.emailId ?? "user@gmail.com",
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
                                "${weeklyStats!.lifeTimeHours.toString()} Hour",
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
                                "${weeklyStats?.weekTotalHour.toString() ?? "0"} Hrs",
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
                    yAxisList: [
                      weeklyStats?.userHoursByDay?.monday.toDouble() ?? 0.0,
                      weeklyStats?.userHoursByDay?.tuesday.toDouble() ?? 0.0,
                      weeklyStats?.userHoursByDay?.wednesday.toDouble() ?? 0.0,
                      weeklyStats?.userHoursByDay?.thursday.toDouble() ?? 0.0,
                      weeklyStats?.userHoursByDay?.friday.toDouble() ?? 0.0,
                      weeklyStats?.userHoursByDay?.saturday.toDouble() ?? 0.0,
                      weeklyStats?.userHoursByDay?.sunday.toDouble() ?? 0.0,
                    ],
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
                  rows: generateWeeklyLogRows(weeklyStats!.eventDetails!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
