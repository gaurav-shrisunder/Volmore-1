// ignore_for_file: use_build_context_synchronously

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Screens/HomePage.dart';
import '../../Screens/LoginPage.dart';
import '../../Utils/shared_prefs.dart';

import '../widgets/event_popup.dart';
import 'FluidBackground.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin{
  bool isLoggedIn = false;
  String? eventIDD;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    handleDynamicLink();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Start navigation process after animation completes
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  Future<void> handleDynamicLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    // This handles the case when the app is started with a dynamic link
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      final String? eventId = deepLink.queryParameters['eventId'];

      if (eventId != null) {
        // Show the event popup
        setState(() {
          eventIDD = eventId;
        });
      //  return eventId;
      //  showEventPopup(eventId);
      }
    }

    // This handles dynamic links when the app is already running in the background
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
      final Uri deepLink = data.link;
      final String? eventId = deepLink.queryParameters['eventId'];

      if (eventId != null) {
        // Show the event popup
      //  return eventId;
        setState(() {
          eventIDD = eventId;
        });

      //  showEventPopup(eventId);
      }
    }).onError((error) {
      if(kDebugMode) {
        print('Dynamic Link Failed: $error');
      }
    });

  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    String? uid = await getUserId(); // Your function to get user ID

    if (uid != null && uid != "0") {
      setState(() {
        isLoggedIn = true;
      });

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            animation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0), // Slide from right to left
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );

      if (eventIDD != null) {
        showEventPopup(eventIDD!); // Function to show event popup
      }
    } else {
      // If user is not logged in, go to LoginPage
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            animation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0), // Slide from right to left
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FluidBackground(),
          Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset("assets/images/logo_full.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }



}
