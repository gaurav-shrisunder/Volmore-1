import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:volunterring/Models/event_data_model.dart';

import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colors.dart';
// Assuming this is the file where fetchEventById is defined

void showEventPopup(String userId, String eventId) async {
  List<dynamic> generateDates(
      DateTime startDate, DateTime endDate, String occurrence) {
    List<dynamic> dates = [];
    DateTime currentDate = startDate;

    if (occurrence == 'Weekly') {
      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        dates.add({
          "date": currentDate,
          "isVerified": false,
          "isLocation": false,
          "duration": "00:00"
        });
        currentDate = currentDate.add(const Duration(days: 7));
      }
    } else {
      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        dates.add({
          "date": currentDate,
          "isVerified": false,
          "isLocation": false,
          "duration": "00:00"
        });
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return dates;
  }

  // Fetch event details from Firestore using eventId
  var authServices = AuthMethod();
  EventDataModel? event = await authServices.fetchEventById(userId, eventId);

  if (event != null) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(event.title ?? "Event Details"),
              content: SizedBox(
                width: Get.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' ${event.description ?? "No description"}',
                          style: const TextStyle(color: greyColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: greyColor),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Location: ${event.location ?? "No location"}',
                          style: const TextStyle(color: greyColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: greyColor),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Date: ${DateFormat.yMMMd().format(event.date)}',
                          style: const TextStyle(color: greyColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: greyColor),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Time: ${event.time ?? "No time"}',
                          style: const TextStyle(color: greyColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: greyColor),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Host: ${event.host ?? "No host"}',
                          style: const TextStyle(color: greyColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[350], // Background color
                            borderRadius:
                                BorderRadius.circular(10.0), // Rounded corners
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                  color: Colors.grey[700]), // Text color
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue, // Background color
                            borderRadius:
                                BorderRadius.circular(10.0), // Rounded corners
                          ),
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await acceptInvite(event, context);

                                    setState(() {
                                      isLoading = false;
                                    });

                                    // Optionally close the dialog after acceptance
                                    Navigator.of(context).pop();
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : const Text(
                                    'Accept',
                                    style: TextStyle(
                                        color: Colors.white), // White text
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  } else {
    // Show a message if the event is not found
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Event Not Found"),
          content: const Text("The event you are looking for does not exist."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> acceptInvite(EventDataModel event, BuildContext context) async {
  // Update Firebase with the user's acceptance
  dynamic res = await AuthMethod().addEvent(
    title: event.title ?? "",
    description: event.description ?? "",
    date: event.date,
    location: event.location ?? "",
    occurrence: event.occurence ?? "No occurence",
    group: event.group!,
    time: event.time ?? "",
    endDate: event.endTime,
    dates: event.dates!,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(res['res'])),
  );

  if (res['res'] == "Event added successfully") {
    Navigator.of(context).pop();
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.to(const HomePage());
    });
  }
}
