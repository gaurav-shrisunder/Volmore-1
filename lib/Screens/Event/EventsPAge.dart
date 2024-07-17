import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
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
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Today's Events", style: TextStyle(color: headingBlue, fontSize: 22, fontWeight: FontWeight.bold),),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(

             backgroundColor: Colors.orange, // Background color
        
            textStyle: TextStyle(fontSize: 14, color: Colors.white),
          ),
                              onPressed: (){}, child: Text('Start Logging', style: TextStyle(fontSize: 14, color: Colors.white),))
                          ],
                        ),
                      ),
                      FutureBuilder<List<EventDataModel>>(
                        future: _eventsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
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
                                  return EventWidget(event);
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const Center(
                      child: Text("Upcoming Event Content",
                          style: TextStyle(fontSize: 24))),
                  const Center(
                      child: Text("Past Event Content",
                          style: TextStyle(fontSize: 24))),
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
