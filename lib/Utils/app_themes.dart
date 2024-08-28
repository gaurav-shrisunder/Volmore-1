

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
    scaffoldBackgroundColor:  Colors.white,
    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.white),
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
    primaryColor:  const Color(0xFF101F30), // Dark navy background
    hintColor: Colors.cyanAccent,
    scaffoldBackgroundColor: const Color(0xFF101F30), // Match the background color

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white,
        fontFamily: "Plus Jakarta Sans",
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFAAB2B7), // Light gray for body text
        fontFamily: "Plus Jakarta Sans",
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: "Plus Jakarta Sans",
      ),

    ),
    dialogBackgroundColor: Color(0xFF1D2D44),

    cardTheme: const CardTheme(
      color: Color(0xFF1D2D44), // Dark card background with rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Match the card margin
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF101F30), // Dark app bar color
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: "Plus Jakarta Sans",
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),


textButtonTheme: TextButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF2E4A63)))),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF0199FF), // Button color matching the Log Now button
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      textTheme: ButtonTextTheme.primary,
      
    ),

    iconTheme: const IconThemeData(

      // applyTextScaling: true,
      color: Colors.white, // Icons inside the cards should be white
    ),

    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF2E4A63), // Chip background color
      labelStyle: TextStyle(
        color: Colors.white,
        fontFamily: "Plus Jakarta Sans",
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(unselectedIconTheme: IconThemeData(color: Colors.grey), selectedIconTheme: IconThemeData(color: Colors.blue)),

    fontFamily: "Plus Jakarta Sans",
    useMaterial3: true,
  );

/* static final ThemeData darkTheme = ThemeData(
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

  );*/
}
