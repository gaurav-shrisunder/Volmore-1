import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunterring/Utils/Colors.dart';

import '../../Models/event_data_model.dart';

class EventWidget extends StatelessWidget {
  final EventDataModel event;
  final Color color;

  const EventWidget(this.event, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title ?? "",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
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
                Text(
                  'Host by: ${event.host ?? "You"}',
                  softWrap: true,
                ),
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
                  onPressed: () {},
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
