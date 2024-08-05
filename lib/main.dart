import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Screens/LoginPage.dart';
import 'package:volunterring/Screens/dashboard.dart';
import 'package:volunterring/firebase_options.dart';
import 'package:volunterring/provider/time_logger_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (_) => TimerProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    checkLocalStorage();
    return GetMaterialApp(
      title: 'Volunteer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          surface: Colors.white,
          surfaceTint: Colors.white,
          seedColor: Colors.black,
          secondary: Colors.white,
          primary: Colors.black,
          shadow: Colors.white,
          // surfaceContainer: Colors.white
        ),
        useMaterial3: true,
      ),
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
      // Do something else
    }
  }
}
