import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Services/deep_links.dart';

import '../../Models/event_data_model.dart';
import '../../Utils/shared_prefs.dart';
import '../CreateLogScreen.dart';





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
    print("Event id ${event.id}");
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
                        fontSize: 18,
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
                          //  color: Colors.white,
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
                            Text(
                              DateFormat.yMMMd().format(date),
                              style: const TextStyle(
                                fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          //  color: Colors.white,
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
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Event Description: ${event.description ?? "Description"}",
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Image.asset('assets/icons/share.png'),
                            onPressed: () async {
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              final String? uid = prefs.getString('uid');
                              String url =
                                  await createDynamicLink(event.id!);
                              print("URL: $url");
                              Share.share(url);
                            },
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


