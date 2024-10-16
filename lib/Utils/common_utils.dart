

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