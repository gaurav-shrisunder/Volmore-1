import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Screens/LoginPage.dart';
import 'package:volunterring/provider/theme_manager_provider.dart';
import 'package:volunterring/provider/time_logger_provider.dart';
import 'package:volunterring/Utils/app_themes.dart';

import 'package:volunterring/widgets/event_popup.dart'; // Import the new file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(
            create: (_) => ThemeManager(AppThemes.lightTheme)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Handle dynamic link when the app is launched via a deep link
    handleDynamicLink();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> handleDynamicLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    // This handles the case when the app is started with a dynamic link
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      final String? eventId = deepLink.queryParameters['eventId'];
      final String? userId = deepLink.queryParameters['userId'];
      if (eventId != null) {
        // Show the event popup
        showEventPopup(userId!, eventId, uid!);
      }
    }

    // This handles dynamic links when the app is already running in the background
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
      final Uri deepLink = data.link;
      final String? eventId = deepLink.queryParameters['eventId'];
      final String? userId = deepLink.queryParameters['userId'];
      if (eventId != null) {
        // Show the event popup
        showEventPopup(userId!, eventId, uid!);
      }
    }).onError((error) {
      print('Dynamic Link Failed: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    checkLocalStorage();
    return GetMaterialApp(
      title: 'VOLMORE',
      debugShowCheckedModeBanner: false,
      theme: themeManager.themeData,
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }

  Future<void> checkLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    if (uid != null) {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      // UID is not present in local storage
    }
  }
}
