import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Services/authentication.dart';
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
        return AlertDialog(
          title: Text(event.title ?? "Event Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${event.description ?? "No description"}'),
              Text('Location: ${event.location ?? "No location"}'),
              Text('Time: ${event.time ?? "No time"}'),
              Text('Host: ${event.host ?? "No host"}'),
              // Add more fields as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle Accept
                acceptInvite(event, context);
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                // Handle Reject

                Navigator.of(context).pop();
              },
              child: const Text('Reject'),
            ),
          ],
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

void acceptInvite(EventDataModel event, BuildContext context) async {
  // Update Firebase with the user's acceptance

  String res = await AuthMethod().addEvent(
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
    SnackBar(content: Text(res)),
  );

  if (res == "Event added successfully") {
    // Clear the form fields

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false);
  }
}
