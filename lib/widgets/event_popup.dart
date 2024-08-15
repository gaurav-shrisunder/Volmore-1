import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Services/authentication.dart';
// Assuming this is the file where fetchEventById is defined

void showEventPopup(String userId, String eventId) async {
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
                acceptInvite(userId, eventId);
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                // Handle Reject
                rejectInvite(userId, eventId);
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

void acceptInvite(String userId, String eventId) {
  // Update Firebase with the user's acceptance
  FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('events')
      .doc(eventId)
      .update({
    'acceptedUsers': FieldValue.arrayUnion([userId]),
  });
}

void rejectInvite(String userId, String eventId) {
  // Update Firebase with the user's rejection
  FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('events')
      .doc(eventId)
      .update({
    'rejectedUsers': FieldValue.arrayUnion([userId]),
  });
}
