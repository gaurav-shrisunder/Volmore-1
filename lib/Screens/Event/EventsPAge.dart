import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'package:intl/intl.dart';
import 'package:volunterring/Screens/CreateLogScreen.dart';
import 'package:volunterring/Screens/Event/CreateEventPage.dart';
import 'package:volunterring/Screens/Event/events_widget.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colors.dart';

import '../../Models/event_data_model.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  final _authMethod = AuthMethod();
  late Future<List<EventDataModel>> _eventsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _authMethod.fetchEvents();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, Color> colorMap = {
    'Green': Colors.green,
    'Pink': Colors.pink,
    'Orange': Colors.orange,
    'Red': Colors.red,
    'Yellow': Colors.yellow,
    'Grey': Colors.grey,
    'Blue': Colors.blue,
    'Purple': Colors.purple,
    'Brown': Colors.brown,
    'Cyan': Colors.cyan,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SizedBox(height: 100,),
            TabBar(
              labelStyle: const TextStyle(fontSize: 12),
              controller: _tabController,
              tabs: [
                const Tab(text: "Today's Event"),
                const Tab(text: "Upcoming Event"),
                const Tab(text: "Past Event"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today's Events",
                              style: TextStyle(
                                  color: headingBlue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.orange, // Background color

                                  textStyle: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                onPressed: () {
                                  Get.to(const CreateLogScreen());
                                },
                                child: const Text(
                                  'Start Logging',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ))
                          ],
                        ),
                      ),
                      FutureBuilder<List<EventDataModel>>(
                        future: _eventsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('No events found'));
                          } else {
                            // List<EventDataModel> events = snapshot.data!;
                            return Expanded(
                              child: ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  EventDataModel event = snapshot.data![index];
                                  Color color =
                                      colorMap[event.groupColor] ?? Colors.pink;
                                  print(
                                      "event Date: ${event.date.toString().split(' ')[0]}");
                                  print(
                                      DateTime.now().toString().split(' ')[0]);
                                  return event.date.toString().split(' ')[0] ==
                                          DateTime.now()
                                              .toString()
                                              .split(' ')[0]
                                      ? EventWidget(event, color)
                                      : Container();
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Upcoming Events",
                              style: TextStyle(
                                  color: headingBlue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<EventDataModel>>(
                        future: _eventsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('No events found'));
                          } else {
                            // List<EventDataModel> events = snapshot.data!;
                            return Expanded(
                              child: ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  EventDataModel event = snapshot.data![index];
                                  Color color =
                                      colorMap[event.groupColor] ?? Colors.pink;
                                  DateTime eventDate =
                                      DateTime.parse(event.date.toString());
                                  DateTime today = DateTime.now();
                                  if (eventDate.isAfter(today)) {
                                    return EventWidget(event, color);
                                  } else {
                                    return Container(); // Or SizedBox.shrink() if you want to hide the item
                                  }
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Past Events",
                              style: TextStyle(
                                  color: headingBlue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<EventDataModel>>(
                        future: _eventsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('No events found'));
                          } else {
                            // List<EventDataModel> events = snapshot.data!;
                            return Expanded(
                              child: ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  EventDataModel event = snapshot.data![index];
                                  Color color =
                                      colorMap[event.groupColor] ?? Colors.pink;
                                  DateTime eventDate =
                                      DateTime.parse(event.date.toString());
                                  DateTime today = DateTime.now()
                                      .subtract(Duration(days: 1));
                                  if (eventDate.isBefore(today)) {
                                    return EventWidget(event, color);
                                  } else {
                                    return Container(); // Or SizedBox.shrink() if you want to hide the item
                                  }
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        )

        // Column(
        //   children: [
        //     FutureBuilder<List<EventDataModel>>(
        //       future: _eventsFuture,
        //       builder: (context, snapshot) {
        //         if (snapshot.connectionState == ConnectionState.waiting) {
        //           return Center(child: CircularProgressIndicator());
        //         } else if (snapshot.hasError) {
        //           return Center(child: Text('Error: ${snapshot.error}'));
        //         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //           return Center(child: Text('No events found'));
        //         } else {
        //          // List<EventDataModel> events = snapshot.data!;
        //           return Expanded(
        //             child: ListView.builder(
        //               itemCount: snapshot.data?.length,
        //               itemBuilder: (context, index) {
        //                 EventDataModel event = snapshot.data![index];
        //                 return EventWidget(event);
        //               },
        //             ),
        //           );
        //         }
        //       },
        //     ),

        //   ],
        // ),
        );
  }
}
