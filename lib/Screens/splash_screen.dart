// ignore_for_file: use_build_context_synchronously

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Screens/HomePage.dart';
import '../../Screens/LoginPage.dart';
import '../../Utils/shared_prefs.dart';

import '../widgets/event_popup.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver{
  bool isLoggedIn = false;
  String? eventIDD;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    handleDynamicLink();
    _navigateToNextScreen();
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
      print('Dynamic Link Failed: $error');
    });

  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    String? uid = await getUserId();

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
            // Adjust the duration of the animation
            const duration =
                Duration(milliseconds: 800); // Slows down the animation
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

            // return FadeTransition(
            //   opacity: animation,
            //   child: child,
            // );
          },
          transitionDuration:
              const Duration(milliseconds: 600), // Duration of the transition
        ),
      );
      if(eventIDD!= null) {
        showEventPopup(eventIDD!);
      }
    } else {
      // UID is not present in local storage
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Adjust the duration of the animation
            const duration =
                Duration(milliseconds: 800); // Slows down the animation
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
          transitionDuration:
              const Duration(milliseconds: 600), // Duration of the transition
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/5.jpg"),
      ),
    );
  }
}
