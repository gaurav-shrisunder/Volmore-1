import 'dart:async';
import 'package:app_links/app_links.dart';
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
import 'Utils/common_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(EventController());

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
  final eventController = Get.find<EventController>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDeepLinks();
    checkLocalStorage();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      print("Initializing AppLinks...");
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print("Initial Universal Link: $initialUri");
        print(
            "Scheme: ${initialUri.scheme}, Host: ${initialUri.host}, Path: ${initialUri.path}, Query: ${initialUri.queryParameters}");
        _handleDeepLink(initialUri);
      } else {
        print("No initial Universal Link received");
      }

      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          print("Received Universal Link stream: $uri");
          print(
              "Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}, Query: ${uri.queryParameters}");
          _handleDeepLink(uri);
        },
        onError: (err) {
          print("AppLinks Error: $err");
        },
        cancelOnError: false,
      );
    } catch (e) {
      print("Failed to initialize AppLinks: $e");
    }
  }
  void _handleDeepLink(Uri uri) {
    print("Processing deep link: $uri");

    String? eventId;

    // Handle Universal Links (e.g., https://lendavolunteering.com/event/123)
    if (uri.host == 'lendavolunteering.com' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'event') {
      eventId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      print(
          "Parsed eventId from Universal Link (lendavolunteering.com): $eventId");
    }

    // Handle Firebase Dynamic Links (e.g., https://volmore.page.link?eventId=123)
    if (uri.host == 'volmore.page.link') {
      eventId = uri.queryParameters['eventId'];
      print(
          "Parsed eventId from Firebase Dynamic Link (volmore.page.link): $eventId");
    }

    // Handle custom scheme (e.g., applinks://event/123)
    if (uri.scheme == 'applinks' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'event') {
      eventId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      print("Parsed eventId from custom scheme (applinks): $eventId");
    }

    if (eventId != null && eventId.isNotEmpty) {
      print("Valid eventId found: $eventId");
      // Ensure popup is shown after the UI is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showEventPopup(eventId!);
      });
    } else {
      print("No valid eventId found in deep link: $uri");
    }
  }

  Future<void> checkLocalStorage() async {
    String? uid = await getUserId();
    if (uid != null && uid != "0") {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      print("No user ID found in local storage");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return GetMaterialApp(
      title: 'lenda - Volunteering',
      debugShowCheckedModeBanner: false,
      theme: themeManager.themeData,
      home: const SplashScreen(),
    );
  }
}
