import 'dart:async';
import 'dart:io';


import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
// import 'package:app_links/app_links.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Controllers/event_controller.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Screens/LoginPage.dart';
import 'package:volunterring/Screens/splash_screen.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/provider/theme_manager_provider.dart';
import 'package:volunterring/provider/time_logger_provider.dart';
import 'package:volunterring/Utils/app_themes.dart';

import 'package:volunterring/widgets/event_popup.dart'; // Import the new file

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
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

}


class _MyAppState extends State<MyApp>  {
  bool isLoggedIn = false;
  final eventController = Get.find<EventController>();



  @override
  void initState() {
    super.initState();
    // with WidgetsBindingObserver
  //  WidgetsBinding.instance.addObserver(this);

    // Handle dynamic link when the app is launched via a deep link
  //  handleDynamicLink();

    // clearPreferences();
    checkLocalStorage();
  }
  String? screen;
  Uri? _initialUri;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;


  Future<void> initDeepLinksIOS() async {
    if (Platform.isIOS) {
      //  await _getCurrentPosition();
      _appLinks = AppLinks();
      // Check initial link if app was in cold state (terminated)
      /// Replaced the below::  final appLink = await _appLinks.getInitialAppLink();
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        print('getInitialAppLink: $appLink');
        setState(() {
          _initialUri = appLink;
        });
      }
      // Handle link when app is in warm state (front or background)
      _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
        print('onAppLink: $uri');
        _initialUri = uri;
        screen = uri.queryParameters["artworktype"];
        initDynamicLinksIOS();
        // setState(() {
        //
        // });
      });
    }
  }

  Future<void> initDynamicLinksIOS() async {
    // await _getCurrentPosition();

    /*   setState(() {
  locale = locale;
  print('Inside::::::: $locale');
});*/

    print('Initial Url: ${_initialUri.toString()}');
    if (_initialUri == null) {
      setState(() {
        screen = "splash";
      });
      // return "splash";
    } else {
  /*    print('ArtwornTye:; ${_initialUri?.queryParameters["artworkName"]}');
      pdpParamRequest.sku = _initialUri?.queryParameters["artworkName"];
      pdpParamRequest.isFromCollage = false;
      pdpParamRequest.sku = _initialUri?.queryParameters["sku"];
      pdpParamRequest.productUrl = _initialUri?.queryParameters["productUrl"];
      pdpParamRequest.productId = _initialUri?.queryParameters["productId"];
      pdpParamRequest.isSaleable =
          _initialUri?.queryParameters["isSaleable"] == "true";
      pdpParamRequest.artworkType = _initialUri?.queryParameters["artworktype"];
      pdpParamRequest.isFromCustomLink = true;
      navigatorKey.currentState
          ?.pushNamed(splashScreen, arguments: pdpParamRequest);*/
      /*if (pdpParamRequest.artworkType == "framerprod") {
        screen = "pdp";
        navigatorKey.currentState
            ?.pushNamed(product_detail, arguments: pdpParamRequest);
      } else if (pdpParamRequest.artworkType == "simple") {
        screen = "painting_pdp";
        navigatorKey.currentState
            ?.pushNamed(product_painting_detail, arguments: pdpParamRequest);
      }*/
    }
  }
  Future<void> initDeepLinks() async {
    if (Platform.isAndroid) {
      //   await _getCurrentPosition();
      _appLinks = AppLinks();
      // Check initial link if app was in cold state (terminated)
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        print('getInitialAppLink: $appLink');
        setState(() {
          _initialUri = appLink;
        });
      }
      // Handle link when app is in warm state (front or background)
      _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
        print('onAppLink: $uri');
        setState(() {
          _initialUri = uri;
          screen = uri.queryParameters["artworktype"];
        });
      });
    }
  }

  Future<String> initDynamicLinks() async {
//    await _getCurrentPosition();
    await initDeepLinks();


    /*   setState(() {
      locale = locale;
      print('Inside::::::: $locale');
    });*/

    print('Initial Url: ${_initialUri.toString()}');
    if (_initialUri == null) {
      setState(() {
        screen = "splash";
      });
      return "splash";
    } else {
     /* print('ArtwornTye:; ${_initialUri?.queryParameters["artworkName"]}');

      pdpParamRequest.artistName = _initialUri?.queryParameters["artworkName"];
      pdpParamRequest.sku = _initialUri?.queryParameters["sku"];
      pdpParamRequest.productUrl = _initialUri?.queryParameters["productUrl"];
      pdpParamRequest.productId = _initialUri?.queryParameters["productId"];
      pdpParamRequest.isSaleable = _initialUri?.queryParameters["isSaleable"] as bool?;
      pdpParamRequest.isFromCollage = false;
      pdpParamRequest.artworkType = _initialUri?.queryParameters["artworktype"];*/
      setState(() {
        screen = _initialUri?.queryParameters["artworktype"] == "framerprod"
            ? "pdp"
            : "painting_pdp";
      });
      return _initialUri?.queryParameters["artworktype"] == "framerprod"
          ? "pdp"
          : "painting_pdp";
    }
  }



  @override
  void dispose() {
  //  WidgetsBinding.instance.removeObserver(this);
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

      if (eventId != null) {
        // Show the event popup
        showEventPopup(eventId);
      }
    }

    // This handles dynamic links when the app is already running in the background
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
      final Uri deepLink = data.link;
      final String? eventId = deepLink.queryParameters['eventId'];

      if (eventId != null) {
        // Show the event popup
        showEventPopup(eventId);
      }
    }).onError((error) {
      print('Dynamic Link Failed: $error');
    });
  }

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
