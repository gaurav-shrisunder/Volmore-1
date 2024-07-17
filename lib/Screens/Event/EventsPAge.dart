import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:volunterring/Services/authentication.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _authMethod = AuthMethod();
  late Future<List<Map<String, dynamic>>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _authMethod.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> colorMap = {
      'Green': Colors.green,
      'Pink': Colors.pink,
      'Orange': Colors.orange,
      'Red': Colors.red,
      'Yellow': Colors.yellow,
      'Blue': Colors.blue,
      'Purple': Colors.purple,
      'Brown': Colors.brown,
      'Grey': Colors.grey,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found'));
          } else {
            List<Map<String, dynamic>> events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> event = events[index];
                Color eventColor =
                    colorMap[event['group_color']] ?? Colors.black;
                return Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  surfaceTintColor: Colors.white,
                  shadowColor: Colors.grey,
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(
                        event['group'].toString().capitalize!,
                        style: TextStyle(
                            color: eventColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 2),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 6,
                                        width: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                          'Date: ${DateFormat.yMd().format(event['date'].toDate())}'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text('${event['description']}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
