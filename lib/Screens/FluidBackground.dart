import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FluidBackground extends StatefulWidget {
  @override
  _FluidBackgroundState createState() => _FluidBackgroundState();
}

class _FluidBackgroundState extends State<FluidBackground> {
  List<Color> colors = [
    const Color(0xff88d7dc), // Light Airy Blue
    Color(0xFFFFFFFF), // Pure White
  ];


  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    changeColor();
  }

  void changeColor() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        currentIndex = (currentIndex + 1) % colors.length;
      });
      changeColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors[currentIndex],
            colors[(currentIndex + 1) % colors.length],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
