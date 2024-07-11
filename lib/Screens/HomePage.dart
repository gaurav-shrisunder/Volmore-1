import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:volunterring/Screens/BottomSheet/AccountPage.dart';
import 'package:volunterring/Screens/BottomSheet/FAQPage.dart';
import 'package:volunterring/Screens/BottomSheet/SupportPage.dart';
import 'package:volunterring/Screens/CreateLogScreen.dart';

import 'package:volunterring/Screens/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Screens/TermsScreen.dart';
import 'package:volunterring/Utils/Colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'VolMore',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: headingBlue),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                size: 32,
              ),
              onPressed: () {
                Get.bottomSheet(
                    Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30))),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  tileColor: Color(0xFFECECEC),
                                  title: const Text(
                                    'Support - I need help',
                                    style: TextStyle(
                                        color: headingBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: headingBlue,
                                  ),
                                  onTap: () {
                                    Get.to(SupportPage());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  tileColor: Color(0xFFECECEC),
                                  title: const Text(
                                    'Frequently Asked Questions',
                                    style: TextStyle(
                                        color: headingBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: headingBlue,
                                  ),
                                  onTap: () {
                                    Get.to(FAQPage());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  tileColor: Color(0xFFECECEC),
                                  title: const Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                        color: headingBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: headingBlue,
                                  ),
                                  onTap: () {
                                    Get.back();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  tileColor: Color(0xFFECECEC),
                                  title: const Text(
                                    'Terms and Conditions',
                                    style: TextStyle(
                                        color: headingBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: headingBlue,
                                  ),
                                  onTap: () {
                                    Get.to(TermsScreen());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  tileColor: Color(0xFFECECEC),
                                  title: const Text(
                                    'Manage your Account',
                                    style: TextStyle(
                                        color: headingBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: headingBlue,
                                  ),
                                  onTap: () {
                                    Get.to(UserProfilePage());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  title: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                        color: headingBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  tileColor: Color(0xFFECECEC),
                                  onTap: () {
                                    Logout();
                                  },
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: headingBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    backgroundColor: Colors.white,
                    elevation: 1);
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                child: const Text(
                  'Welcome to Home Page',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(
                height: 190,
              ),
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the second screen using a named route.
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateLogScreen()));
                  },
                  child: const Text(
                    'Create Log',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox(
                height: 190,
              ),
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    // Navigate to the second screen using a named route.
                    Logout();
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> Logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
