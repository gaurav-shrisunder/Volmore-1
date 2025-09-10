import 'package:flutter/material.dart';

const Color headingBlue = Color(0xff0c4a6f);
const Color bodyBlue = Color(0xFF0B4F83);

const Color greyColor = Color(0xFF667085);


const Color primaryTextColor = Colors.blueGrey;
const Color secondaryTextColor = Colors.black;


class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}