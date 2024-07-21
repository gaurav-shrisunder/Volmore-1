import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:volunterring/Screens/Event/log_now_page.dart';
import 'package:volunterring/Utils/Colors.dart';

import '../../Models/event_data_model.dart';

class EventWidget extends StatelessWidget {
  final EventDataModel event;

  const EventWidget(this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title ?? "",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: event.title == 'Trash Cleanup'
                    ? Colors.orange
                    : Colors.pink,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text('Date: ${DateFormat.yMMMd().format(event.date)}'),
                SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text('Host by: ${event.host ?? "You"}'),
              ],
            ),
            SizedBox(height: 8),
            Text("Event Description: ${event.description ?? "Description"}"),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {},
                    ),
                  ],
                ),
                ActionChip(
                  backgroundColor: Colors.lightBlue,
                  side: BorderSide.none,
                  label: Text(
                    'Log Now',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                  Get.to( LogNowPage(event.title!));
                  },
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
