import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Controllers/event_controller.dart';
import '../../Screens/splash_screen.dart';
import '../../Utils/app_themes.dart';
import '../../Utils/shared_prefs.dart';
import '../../provider/theme_manager_provider.dart';
import '../../provider/time_logger_provider.dart';
import '../../widgets/event_popup.dart';
import 'Utils/common_utils.dart'; // Import the new file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(EventController());
  // final appLink = AppLinks();
  // final sub = appLink.uriLinkStream.listen((uri) {
  //   print('App Link: $uri');
  // });



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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  bool isLoggedIn = false;
  final eventController = Get.find<EventController>();

  Future<void> initDynamicLinks() async {
    // Handle link when app is not opened
    try {
      final PendingDynamicLinkData? initialLink =
          await FirebaseDynamicLinks.instance.getInitialLink();

      if (initialLink != null) {
        final Uri deepLink = initialLink.link;
        print("Got initial link: ${deepLink.toString()}");
        handleDynamicLink(deepLink);
      }
    } catch (e) {
      print('Error getting initial dynamic link: $e');
    }
    FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData dynamicLinkData) {
        print("Got dynamic link: ${dynamicLinkData.link.toString()}");
        handleDynamicLink(dynamicLinkData.link);
      },
      onError: (error) {
        print('Dynamic Links error: $error');
      },
    );
  }

  void handleDynamicLink(Uri deepLink) {
    final String? eventId = deepLink.queryParameters['eventId'];
    print("Handling dynamic link with eventId: $eventId");

    if (eventId != null) {
      // Ensure we show popup on the main thread
      showEventPopup(eventId);
    }
  }

  @override
  void initState() {
    super.initState();


    // with WidgetsBindingObserver
     WidgetsBinding.instance.addObserver(this);
     if(Platform.isIOS){
       initDynamicLinks();
     }
    // Handle dynamic link when the app is launched via a deep link
    //  handleDynamicLink();

    // clearPreferences();
    checkLocalStorage();
  }

  @override
  void dispose() {
    //  WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Future<void> handleDynamicLink() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? uid = prefs.getString('uid');
  //   // This handles the case when the app is started with a dynamic link
  //   print("in handle dunmaic link $uid");
  //   final PendingDynamicLinkData? initialLink =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //   if (initialLink != null) {
  //     final Uri deepLink = initialLink.link;
  //     final String? eventId = deepLink.queryParameters['eventId'];

  //     if (eventId != null) {
  //       // Show the event popup
  //       showEventPopup(eventId);
  //     }
  //   }

  //   // This handles dynamic links when the app is already running in the background
  //   FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
  //     final Uri deepLink = data.link;
  //     final String? eventId = deepLink.queryParameters['eventId'];

  //     if (eventId != null) {
  //       // Show the event popup
  //       showEventPopup(eventId);
  //     }
  //   }).onError((error) {
  //     print('Dynamic Link Failed: $error');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return GetMaterialApp(
      title: 'lenda - Volunteering',
      debugShowCheckedModeBanner: false,
      theme: themeManager.themeData,
      home: const SplashScreen(),

      // home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }

  Future<void> checkLocalStorage() async {
    String? uid = await getUserId();
    if (uid != null && uid != "0") {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      // UID is not present in local storage
    }
  }
}
