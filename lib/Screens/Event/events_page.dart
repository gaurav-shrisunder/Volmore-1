import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'package:volunterring/Screens/CreateLogScreen.dart';
import 'package:volunterring/Screens/Event/events_widget.dart';
import 'package:volunterring/Screens/Event/log_now_page.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colors.dart';
import '../../Models/event_data_model.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

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
    _tabController = TabController(length: 3, vsync: this);
    _eventsFuture = _authMethod.fetchEvents();
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
            String title = "Today's Events";
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (title == "Today's Events")
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFfa6513),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                          onPressed: () {
                            Get.to(const CreateLogScreen());
                          },
                          child: const Text(
                            'Start Logging',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Center(child: Text('No events found')),
                ],
              ),
            );
          } else {
            return TabBarView(
              controller: _tabController,
              children: [
                buildEventList("Today's Events", (event) {
                  return event.date.toString().split(' ')[0] ==
                          DateTime.now().toString().split(' ')[0] ||
                      event.occurence == "Daily";
                }, snapshot.data!),
                buildEventList("Upcoming Events", (event) {
                  DateTime eventDate = DateTime.parse(event.date.toString());
                  DateTime today = DateTime.now();
                  return eventDate.isAfter(today);
                }, snapshot.data!),
                buildEventList("Past Events", (event) {
                  DateTime eventDate = DateTime.parse(event.date.toString());
                  DateTime today =
                      DateTime.now().subtract(const Duration(days: 1));
                  return eventDate.isBefore(today);
                }, snapshot.data!),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildEventList(String title, bool Function(EventDataModel) filter,
      List<EventDataModel> events) {
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
                ElevatedButton(
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
                    'Start Logging',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              EventDataModel event = events[index];
              Color color = colorMap[event.groupColor] ?? Colors.pink;
              bool isEnabled = event.date.toString().split(' ')[0] ==
                  DateTime.now().toString().split(' ')[0];
              String buttonText = isEnabled ? "Log Now" : "Verify";
              return filter(event)
                  ? EventWidget(
                      event,
                      color,
                      isEnabled: isEnabled,
                      onPressed: isEnabled
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LogNowPage(event.title!, event)));
                            }
                          : null,
                      buttonText: buttonText,
                    )
                  : Container();
            },
          ),
        ),
      ],
    );
  }
}
