import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import 'package:intl/intl.dart';
import '../../Models/response_models/sign_up_response_model.dart';
import '../../Models/response_models/weekly_stats_response_model.dart';
import '../../Screens/Manage%20Account/edit_account_screen.dart';

import '../../Services/profile_services.dart';
import '../../Utils/Colors.dart';
import '../../Utils/shared_prefs.dart';
import '../../widgets/weekly_stats_chart.dart';

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

        user = user;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    fetchWeeklyStats();
    super.initState();
  }

  List<DataRow> generateWeeklyLogRows(List<EventDetail?> events) {
    List<DataRow> logRows = [];

    DateTime now = DateTime.now();

    for (var event in events) {
      logRows.add(
        DataRow(cells: [
          DataCell(Text(event?.title ?? "")),
          DataCell(Text(DateFormat.yMMMd()
              .format(DateTime.parse(event!.date.split(" ")[0].trim())))),
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
    var width = MediaQuery.of(context).size.width;

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
                            Get.to(EditAccountScreen(user!));
                          },
                          icon: const Icon(Icons.edit)))),
              // const CircleAvatar(
              //   radius: 60,
              //   backgroundImage: AssetImage("assets/images/profile_avatar.png"),
              // ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: user == null
                    ? Center(child: _buildFallbackImage())
                    : ClipOval(
                        child: Builder(
                          builder: (context) {
                            print(
                                "user Profile Picture ${user?.profilePicture}");
                       /*     if (user!.profilePicture != null &&
                                user!.profilePicture!.isNotEmpty) {
                              try {
                                String formattedString = user!.profilePicture!;
                                if (!user!.profilePicture!
                                    .startsWith("data:image")) {
                                  formattedString =
                                      "data:image/png;base64,${user!.profilePicture!}";
                                }

                                // Decode the base64 string
                                Uint8List bytes = base64Decode(
                                    formattedString.split(",").last);
                                return Image.network(
                                  user!.profilePicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackImage(),
                                );
                              } catch (e) {
                                print("error in image $e");
                                return _buildFallbackImage();
                              }
                            }*/ if(user?.profilePicture == null){
                              return  Image.network(
                                  'https://ui-avatars.com/api/?name=${user?.userName ?? "User"}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Inside error builder: ${ user!.profilePicture!}');
                                    return   _buildFallbackImage();

                                  }
                              );
                            }else{
                              return  Image.network(
                                  user!.profilePicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Inside error builder: ${ user!.profilePicture!}');
                                    return   _buildFallbackImage();

                                  }
                              );
                            }

                          },
                        ),
                      ),
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
                      child: SizedBox(
                        width: width * 0.34,
                        height: width * 0.11,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
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
                                  "${weeklyStats!.lifeTimeHours! ~/ 60} Hour",
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
                  ),
                  Card(
                    elevation: 10,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: width * 0.34,
                        height: width * 0.11,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
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
                                  "${(weeklyStats?.weekTotalHour ?? 0) ~/ 60} Hrs",
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
                      "Tue",
                      "Wed",
                      "Thur",
                      "Fri",
                      "Sat",
                      "Sun"
                    ],
                    yAxisList: [
                      ((weeklyStats?.userHoursByDay?.monday.toDouble() ??
                                  0.0) ~/
                              60)
                          .toDouble(),
                      ((weeklyStats?.userHoursByDay?.tuesday.toDouble() ??
                                  0.0) ~/
                              60)
                          .toDouble(),
                      ((weeklyStats?.userHoursByDay?.wednesday.toDouble() ??
                                  0.0) ~/
                              60)
                          .toDouble(),
                      ((weeklyStats?.userHoursByDay?.thursday.toDouble() ??
                                  0.0) ~/
                              60)
                          .toDouble(),
                      ((weeklyStats?.userHoursByDay?.friday.toDouble() ??
                                  0.0) ~/
                              60)
                          .toDouble(),
                      ((weeklyStats?.userHoursByDay?.saturday.toDouble() ??
                                  0.0) ~/
                              60)
                          .toDouble(),
                      ((weeklyStats?.userHoursByDay?.sunday.toDouble() ??
                                  0.0) ~/
                              60)
                          .toDouble(),
                    ],
                    xAxisName: "Days",
                    yAxisName: "Hours",
                    interval: 5,
                  ),
                ),
              ),

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
              weeklyStats!.eventDetails!.isEmpty
                  ? Card(
                      elevation: 10,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.12,
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.only(top: 20, right: 20),
                        decoration: BoxDecoration(
                          color:
                              Colors.white, // Background color of the container
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                        child: const Center(
                            child: Text(
                          "No data this week",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                      ),
                    )
                  : SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: width * 0.16,
                        columns: const [
                          DataColumn(
                              label: Text(
                            'Title',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Location',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ],
                        rows: generateWeeklyLogRows(weeklyStats!.eventDetails!),
                        border: TableBorder.all(
                            borderRadius: BorderRadius.circular(8)),
                        // TableBorder.symmetric(outside: const BorderSide())
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Image.network(
      'https://ui-avatars.com/api/?name=${user?.userName ?? "User"}',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.person,
          size: 60,
          color: Colors.grey,
        );
      },
    );
  }
}
