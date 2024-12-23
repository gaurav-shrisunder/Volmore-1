

import 'package:intl/intl.dart';

String formatDateTime(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate);
  // Use DateFormat to format the date in a readable format.
  return DateFormat('YYYY:MM:DD - hh:mm:ss a').format(dateTime);
}

String formatTime(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate);
  // Use DateFormat to format the date in a readable format.
  return DateFormat('hh:mm:ss a').format(dateTime);
}

int getDifferenceInMinutes(String startTime, String endTime) {
  // Parse the start and end times from the UTC strings
  DateTime start = DateTime.parse(startTime);
  DateTime end = DateTime.parse(endTime);

  // Calculate the difference
  Duration difference = end.difference(start);

  // Return the difference in minutes
  return difference.inMinutes;
}



