import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

String formatDuration(int totalMinutes) {
  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;
  return "$hours Hrs $minutes Mins";
}

String formatDateTime(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate);
  // Use DateFormat to format the date in a readable format.
  return DateFormat('yyyy:MM:dd - hh:mm:ss a').format(dateTime);
}

String getFormatedDate() {
  DateTime dateTime = DateTime.now();
  // Use DateFormat to format the date in a readable format.
  return DateFormat('yyyyMMdd').format(dateTime);
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

Duration calculateElapsedTime(DateTime startTime) {
  final now = DateTime.now();
  return now.difference(startTime);
}

Future<String> getTimezoneName() async {
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  final location = tz.getLocation(timeZoneName); // optional
  return timeZoneName;
}
