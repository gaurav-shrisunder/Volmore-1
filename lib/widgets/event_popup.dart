import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:volunterring/Models/request_models/log_current_event_request_model.dart';
import 'package:volunterring/Models/response_models/get_event_response_model.dart';

import 'package:volunterring/Screens/HomePage.dart';

import 'package:volunterring/Services/events_services.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
// Assuming this is the file where fetchEventById is defined

void showEventPopup(String eventId) async {
  // Fetch event details from Firestore using eventId
  GetEventResponseModel eventData =
      await EventsServices().getEventDetails(eventId);
  Future<void> acceptInvite(String eventId, BuildContext context) async {
    LogEventRequestModel requestBody = LogEventRequestModel();
    requestBody.eventInstanceId = eventId;
    requestBody.userId = await getUserId();
    requestBody.userEndDateTime = null;
    requestBody.userStartDateTime = null;
    requestBody.userHours = null;
    dynamic res = await EventsServices().logEventData(requestBody);
    if (res["message"].toString().contains("success")) {
      Fluttertoast.showToast(msg: "Event Accepted Successfully");
      Get.to(const HomePage());
    } else {
      Fluttertoast.showToast(msg: "Some error occured");
      Get.back();
    }
  }

  if (eventData.events.isNotEmpty) {
    //   showDialog(
    //     context: Get.context!,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text("Event Already Accepted"),
    //         content: const Text("You have already accepted this invite."),
    //         actions: [
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: const Text('Close'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   return;
    // }
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        bool isLoading = false;
        Event event = eventData.events[0].event;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(event.eventTitle ?? "Event Details"),
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
                          ' ${event.eventDescription ?? "No description"}',
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
                          'Location: ${event.eventLocationName ?? "No location"}',
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
                          'Date: ${DateFormat.yMMMd().format(DateTime.parse(event.recurrencePattern.eventStartDateTime))}',
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
                          'Time: ${DateFormat('hh:mm a').format(DateTime.parse(event.recurrencePattern.eventStartDateTime)) ?? "No time"}',
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
                          'Host: ${event.hostName ?? "No host"}',
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

                                    await acceptInvite(eventId, context);

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
