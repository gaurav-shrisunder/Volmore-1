import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:volunterring/Screens/CreateLogScreen.dart';
import 'package:volunterring/Screens/Event/events_widget.dart';
import 'package:volunterring/Screens/Event/log_now_page.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colors.dart';
import '../../Models/event_data_model.dart';


enum SortOption { az, za, dateAsc, dateDesc }

class EventPage extends StatefulWidget {
  final SortOption initialSortOption;
  const EventPage({super.key,  required this.initialSortOption});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  final _authMethod = AuthMethod();
  late Future<List<EventDataModel>> _eventsFuture;
  late TabController _tabController;

  SortOption? _selectedOption;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _eventsFuture = _authMethod.fetchEvents();
    _selectedOption = widget.initialSortOption;
  }

  @override
  void dispose() {
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

  bool containsToday(List<dynamic> dates) {
    DateTime today = DateTime.now();
    for (var dateMap in dates) {
      Timestamp timestamp = dateMap['date'];
      DateTime date = timestamp.toDate();
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        return true;
      }
    }
    return false;
  }

  List<EventListDataModel> getUpcomingEvents(List<EventDataModel> events) {
    DateTime today = DateTime.now();
    List<EventListDataModel> upcomingEvents = [];
    for (var event in events) {
      for (var dateMap in event.dates!) {
        Timestamp timestamp = dateMap['date'];
        DateTime date = timestamp.toDate();
        if (date.isAfter(today)) {
          upcomingEvents.add(EventListDataModel(date: date,event: event));
        }
      }
    }
    return upcomingEvents;
  }

  List<EventListDataModel> getPastEvents(List<EventDataModel> events) {
    DateTime today = DateTime.now();
    List<EventListDataModel> pastEvents = [];
    for (var event in events) {
      for (var dateMap in event.dates!) {
        Timestamp timestamp = dateMap['date'];
        DateTime date = timestamp.toDate();
        if (date.isBefore(today)) {
          pastEvents.add(EventListDataModel(date: date,event: event));
        }
      }
    }
    return pastEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Today's Event"),
              Tab(text: "Upcoming Event"),
              Tab(text: "Past Event"),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<EventDataModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfa6513),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle:
                  const TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () {
                  Get.to(const CreateLogScreen());
                },
                child: const Text(
                  'Create Event',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            );
          } else {
            List<EventListDataModel> todaysEvents = [];
            List<EventListDataModel> upcomingEvents = getUpcomingEvents(snapshot.data ?? []);
            List<EventListDataModel> pastEvents = getPastEvents(snapshot.data!);

            for (var event in snapshot.data!) {
              if (containsToday(event.dates!)) {

                todaysEvents.add(EventListDataModel(event: event, date: DateTime.now()));
              }
            }

            return TabBarView(
              controller: _tabController,
              children: [
                buildEventList("Today's Events", todaysEvents),
                buildEventList("Upcoming Events", upcomingEvents),
                buildEventList("Past Events", pastEvents),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildEventList(String title, List<EventListDataModel> events) {

    return Column(
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: headingBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (title == "Today's Events")
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFfa6513),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        textStyle:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      onPressed: () {
                        Get.to(const CreateLogScreen());
                      },
                      child: const Text(
                        'Create Event',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    IconButton(onPressed: (){
                      showSortDialogBox(events);
                    }, icon: Icon(Icons.sort))
                  ],
                ),
              if(title != "Today's Events")
                IconButton(onPressed: (){
                  showSortDialogBox(events);
                }, icon: Icon(Icons.sort))
            
            ],
          ),
        ),
        events.isEmpty
            ? const Expanded(
                child: Center(
                  child: Text(
                    "No Events Found",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    EventDataModel? event = events[index].event;

                    DateTime date = events[index].date;
                    Color color = colorMap[event?.groupColor] ?? Colors.pink;
                    bool isEnabled = containsToday(event!.dates!) &&
                        title == "Today's Events";
                    String buttonText = isEnabled ? "Log Now" : "Verify";
                    return EventWidget(
                      event,
                      color,
                      date: date, // Pass the date to the EventWidget
                      isEnabled: isEnabled,
                      onPressed: isEnabled
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LogNowPage(
                                    event,
                                    date: date,
                                  ),
                                ),
                              );
                            }
                          : null,
                      buttonText: buttonText,
                    );
                  },
                ),
              ),
      ],
    );
  }


  void showSortDialogBox(List<EventListDataModel> events) {
    showDialog(
      context: context,
      builder: (_) {
        SortOption? selectedOption = _selectedOption;

        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              backgroundColor: Colors.white,
              title: const Text("Sort by"),
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<SortOption>(
                      title: const Text('A-Z'),
                      value: SortOption.az,
                      groupValue: selectedOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          selectedOption = value;
                          events.sort((a, b) => a.event!.title!.compareTo(b.event!.title!));
                          _updateEventList(events); // Update the main event list
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    RadioListTile<SortOption>(
                      title: const Text('Z-A'),
                      value: SortOption.za,
                      groupValue: selectedOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          selectedOption = value;
                          events.sort((a, b) => b.event!.title!.compareTo(a.event!.title!));
                          _updateEventList(events); // Update the main event list
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    RadioListTile<SortOption>(
                      title: const Text('Date: Ascending'),
                      value: SortOption.dateAsc,
                      groupValue: selectedOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          selectedOption = value;
                          events.sort((a, b) => a.event!.date.compareTo(b.event!.date));
                          _updateEventList(events); // Update the main event list
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    RadioListTile<SortOption>(
                      title: const Text('Date: Descending'),
                      value: SortOption.dateDesc,
                      groupValue: selectedOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          selectedOption = value;
                          events.sort((a, b) => b.event!.date!.compareTo(a.event!.date));
                          _updateEventList(events); // Update the main event list
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  void _updateEventList(List<EventListDataModel> sortedEvents) {
    setState(() {
      // Replace the original list with the sorted one
   //   _mainEventList = List.from(sortedEvents);
    });
  }

}
