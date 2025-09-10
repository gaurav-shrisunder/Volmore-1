import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FluidBackground extends StatefulWidget {
  const FluidBackground({super.key});

  @override
  _FluidBackgroundState createState() => _FluidBackgroundState();
}

class _FluidBackgroundState extends State<FluidBackground> {
  List<Color> colors = [
    const Color(0xff89d8bd), // Light Airy Blue
    Color(0xFFFFFFFF), // Pure White
  ];


  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    changeColor();
    super.didChangeDependencies();
  }

  void changeColor() {
    Future.delayed(const Duration(seconds: 2), () {
      // setState(() {
        currentIndex = (currentIndex + 1) % colors.length;
      // });
      changeColor();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
