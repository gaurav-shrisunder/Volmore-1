

import 'package:flutter/material.dart';

import 'Colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      surface: Colors.white10,
      surfaceTint: Colors.white,
      seedColor: Colors.black,
      secondary: Colors.white,
      primary: Colors.black,
      shadow: Colors.white,
      onPrimaryContainer: Colors.white,
      primaryContainer: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: headingBlue, fontSize: 30, fontWeight: FontWeight.bold,  fontFamily: "Plus Jakarta Sans",)
    ),
    datePickerTheme:
    const DatePickerThemeData(backgroundColor: Colors.white),
    dialogBackgroundColor: Colors.white,
    timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        dayPeriodColor: Colors.blue.shade50,
        dialBackgroundColor: Colors.blue.shade50,
        hourMinuteTextColor: Colors.black,
        hourMinuteColor: Colors.blue.shade50),
    fontFamily: "Plus Jakarta Sans",
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    hintColor: Colors.cyanAccent,
    scaffoldBackgroundColor: Colors.black,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    cardTheme:const CardTheme(color: Colors.black,),
    appBarTheme:  const AppBarTheme(
      color: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, fontFamily: "Plus Jakarta Sans",)
   //   backgroundColor: Colors.grey[800],
    ),

    fontFamily: "Plus Jakarta Sans",
    useMaterial3: true,

  );
}
