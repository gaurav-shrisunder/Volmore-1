import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/event_data_model.dart';

class EventWidget extends StatelessWidget {
  final EventDataModel event;
  final Color color;
  final bool isEnabled;
  final VoidCallback? onPressed;
  final String buttonText;
  final DateTime date;

  const EventWidget(this.event, this.color,
      {super.key,
      required this.isEnabled,
      this.onPressed,
      required this.buttonText,
      required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title?.capitalize ?? "",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('Date: ${DateFormat.yMMMd().format(date)}'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              'Host by: ${event.host?.split(" ")[0] ?? "You"}',
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      "Event Description: ${event.description ?? "Description"}"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Image.asset('assets/icons/share.png'),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Image.asset('assets/icons/add.png'),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Image.asset('assets/icons/edit.png'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      ActionChip(
                        backgroundColor: Colors.lightBlue,
                        side: BorderSide.none,
                        disabledColor: Colors.grey.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 5),
                        label: Text(
                          buttonText,
                          style: TextStyle(
                              color: isEnabled ? Colors.white : Colors.black,
                              fontSize: 16),
                        ),
                        onPressed: isEnabled ? onPressed : null,
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.5),
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
