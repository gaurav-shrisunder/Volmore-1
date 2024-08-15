import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Screens/CreateLogScreen.dart';
import 'package:volunterring/Screens/Event/log_now_page.dart';
import 'package:volunterring/Screens/Event/events_widget.dart';
import 'package:volunterring/Screens/Event/past_event_verification_page.dart';
import 'package:volunterring/Services/logService.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/Services/authentication.dart';

enum SortOption { def, az, za, dateAsc, dateDesc }

class EventPage extends StatefulWidget {
  final SortOption initialSortOption;

  const EventPage({super.key, required this.initialSortOption});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  final _authMethod = AuthMethod();
  final _logMethod = LogServices();
  late Future<List<EventDataModel>> _eventsFuture;
  late TabController _tabController;
  List<Map<String, dynamic>> _groups = [];

  SortOption? _selectedOption;

  List<EventListDataModel> mainEventList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _eventsFuture = _logMethod.fetchAllEventsWithLogs();
    _selectedOption = widget.initialSortOption;
    _fetchGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchGroups() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();
      print("querySnapshot.docs: ${querySnapshot.docs}");

      List<Map<String, dynamic>> groups = querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'] as String,
          'color':
              doc['color'] as String, // Assuming color is stored as a String
        };
      }).toList();

      setState(() {
        _groups = groups;
      });
    } catch (e) {
      print("Error fetching group names and colors: $e");
    }
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

  String? getGroupColor(EventDataModel event) {
    String? groupName = event.group;

    if (groupName == null) return null;

    // Assuming _groups is your list of maps that contains group names and colors
    for (var group in _groups) {
      if (group['name'] == groupName) {
        return group['color'];
      }
    }

    return null; // Return null if no matching group name is found
  }

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
          upcomingEvents.add(EventListDataModel(date: date, event: event));
        }
      }
    }
    print('_selectedOption ==$_selectedOption');
    if (_selectedOption == SortOption.az) {
      upcomingEvents.sort((a, b) => a.event!.title!.compareTo(b.event!.title!));
      return upcomingEvents;
    } else if (_selectedOption == SortOption.za) {
      upcomingEvents.sort((a, b) => b.event!.title!.compareTo(a.event!.title!));
      return upcomingEvents;
    } else if (_selectedOption == SortOption.dateAsc) {
      upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
      return upcomingEvents;
    } else if (_selectedOption == SortOption.dateDesc) {
      upcomingEvents.sort((a, b) => b.date!.compareTo(a.date));
      return upcomingEvents;
    } else {
      return upcomingEvents;
    }
  }

  List<EventListDataModel> getPastEvents(List<EventDataModel> events) {
    DateTime today = DateTime.now().subtract(const Duration(days: 1));
    List<EventListDataModel> pastEvents = [];
    for (var event in events) {
      for (var dateMap in event.dates!) {
        Timestamp timestamp = dateMap['date'];
        DateTime date = timestamp.toDate();

        if (date.isBefore(today) && event.logs != null) {
          if (event.logs!.isNotEmpty && isLogPresent(event, date)) {
            pastEvents.add(EventListDataModel(date: date, event: event));
          }
        }
      }
    }
    print('_selectedOption ==$_selectedOption');
    if (_selectedOption == SortOption.az) {
      pastEvents.sort((a, b) => a.event!.title!.compareTo(b.event!.title!));
      return pastEvents;
    } else if (_selectedOption == SortOption.za) {
      pastEvents.sort((a, b) => b.event!.title!.compareTo(a.event!.title!));
      return pastEvents;
    } else if (_selectedOption == SortOption.dateAsc) {
      pastEvents.sort((a, b) => a.event!.date.compareTo(b.event!.date));
      return pastEvents;
    } else if (_selectedOption == SortOption.dateDesc) {
      pastEvents.sort((a, b) => b.event!.date!.compareTo(a.event!.date));
      return pastEvents;
    } else {
      return pastEvents;
    }
  }

  bool isLogSignatureVerified(EventDataModel event, DateTime date) {
    if (event.logs == null) return false;

    for (var log in event.logs!) {
      if (log.date != null && isSameDate(log.date.toDate(), date)) {
        return log.isSignatureVerified == true;
      }
    }

    return false;
  }

  bool isLogPresent(EventDataModel event, DateTime date) {
    if (event.logs == null) return false;

    for (var log in event.logs!) {
      if (log.date != null && isSameDate(log.date.toDate(), date)) {
        return true;
      }
    }

    return false;
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
            return Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfa6513),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
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
            List<EventListDataModel> upcomingEvents =
                getUpcomingEvents(snapshot.data ?? []);
            List<EventListDataModel> pastEvents =
                getPastEvents(snapshot.data ?? []);

            for (var event in snapshot.data!) {
              if (containsToday(event.dates!)) {
                todaysEvents.add(
                    EventListDataModel(event: event, date: DateTime.now()));
                print('_selectedOption ==$_selectedOption');
                if (_selectedOption == SortOption.az) {
                  todaysEvents.sort(
                      (a, b) => a.event!.title!.compareTo(b.event!.title!));
                } else if (_selectedOption == SortOption.za) {
                  todaysEvents.sort(
                      (a, b) => b.event!.title!.compareTo(a.event!.title!));
                } else if (_selectedOption == SortOption.dateAsc) {
                  todaysEvents
                      .sort((a, b) => a.event!.date.compareTo(b.event!.date));
                } else if (_selectedOption == SortOption.dateDesc) {
                  todaysEvents
                      .sort((a, b) => b.event!.date!.compareTo(a.event!.date));
                }
              }
            }
            return TabBarView(
              controller: _tabController,
              children: [
                buildEventList("Today's Events", todaysEvents, isToday: true),
                buildEventList("Upcoming Events", upcomingEvents,
                    isUpcoming: true),
                buildEventList("Past Events", pastEvents, isPast: true),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildEventList(String title, List<EventListDataModel> events,
      {bool isToday = false, bool isUpcoming = false, bool isPast = false}) {
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
              Row(
                children: [
                  if (title == "Today's Events")
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
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            SortOption? selectedOption = _selectedOption;

                            return SimpleDialog(
                              backgroundColor: Colors.white,
                              title: const Text("Sort by"),
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RadioListTile<SortOption>(
                                      title: const Text('Default: By Name'),
                                      value: SortOption.def,
                                      groupValue: selectedOption,
                                      onChanged: (SortOption? value) {
                                        setState(() {
                                          selectedOption = value;
                                          _selectedOption = selectedOption;
                                          //   events.sort((a, b) => a.event!.title!.compareTo(b.event!.title!));
                                          // Update the main event list
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    RadioListTile<SortOption>(
                                      title: const Text('A-Z'),
                                      value: SortOption.az,
                                      groupValue: selectedOption,
                                      onChanged: (SortOption? value) {
                                        setState(() {
                                          selectedOption = value;
                                          _selectedOption = selectedOption;

                                          //   events.sort((a, b) => a.event!.title!.compareTo(b.event!.title!));
                                          //   _updateEventList(events); // Update the main event list
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
                                          _selectedOption = selectedOption;
                                          //   events.sort((a, b) => b.event!.title!.compareTo(a.event!.title!));
                                          //    _updateEventList(events); // Update the main event list
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
                                          _selectedOption = selectedOption;
                                          //    events.sort((a, b) => a.event!.date.compareTo(b.event!.date));
                                          //   _updateEventList(events); // Update the main event list
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
                                          _selectedOption = selectedOption;
                                          //    events.sort((a, b) => b.event!.date!.compareTo(a.event!.date));
                                          //   _updateEventList(events); // Update the main event list
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
                      icon: const Icon(Icons.sort))
                ],
              ),
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
                    print("color ${event?.groupColor ?? ""}");
                    Color color =
                        colorMap[getGroupColor(event!)] ?? Colors.pink;

                    bool isEnabled = false;
                    String buttonText = "";
                    bool isVerified = isLogSignatureVerified(event, date);
                    if (isToday) {
                      isEnabled = true;
                      buttonText = "Log Now";
                    } else if (isUpcoming) {
                      isEnabled = false;
                      buttonText = "Log Now";
                    } else if (isPast) {
                      bool isVerified = isLogSignatureVerified(event, date);
                      if (isVerified) {
                        isEnabled = false;
                        buttonText = "Verify";
                      } else {
                        isEnabled = true;
                        buttonText = "Verify";
                      }
                    }

                    return isVerified && isToday
                        ? const SizedBox.shrink()
                        : EventWidget(
                            event,
                            color,
                            date: date, // Pass the date to the EventWidget
                            isEnabled: isEnabled,
                            onPressed: isEnabled
                                ? () {
                                    if (isToday) {
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
                                    if (isPast) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PastEventVerification(
                                            date: date,
                                            event: event,
                                          ),
                                        ),
                                      );
                                    }
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
}

extension DateTimeCompare on DateTime {
  bool isSameDateAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
