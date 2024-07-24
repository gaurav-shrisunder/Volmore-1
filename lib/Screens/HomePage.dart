import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:volunterring/Screens/BottomSheet/AccountPage.dart';
import 'package:volunterring/Screens/BottomSheet/FAQPage.dart';
import 'package:volunterring/Screens/BottomSheet/SupportPage.dart';
import 'package:volunterring/Screens/CreateLogScreen.dart';
import 'package:volunterring/Screens/Event/create_event_page.dart';
import 'package:volunterring/Screens/Event/events_page.dart';

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
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Center(
    //   child: Column(
    //     children: [
    //       Container(
    //         child: const Text(
    //           'Welcome to Home Page ',
    //           style: TextStyle(fontSize: 24),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 190,
    //       ),
    //       SizedBox(
    //         width: 200,
    //         height: 60,
    //         child: ElevatedButton(
    //           onPressed: () {
    //             Get.to(CreateLogScreen());
    //           },
    //           child: const Text(
    //             'Create Log',
    //             style: TextStyle(fontSize: 24),
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 190,
    //       ),
    //       SizedBox(
    //         width: 200,
    //         height: 60,
    //         child: ElevatedButton(
    //           onPressed: () async {},
    //           child: const Text(
    //             'Log Out ',
    //             style: TextStyle(fontSize: 24),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // ),

    const CreateLogScreen(),
    EventPage(),
    Center(
      child: Column(
        children: [
          const Text(
            'Settings Page',
            style: TextStyle(fontSize: 24),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 32,
            ),
            onPressed: () {
              Get.bottomSheet(
                  Container(
                      decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(30))),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                  Get.to(const FAQPage());
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                  Get.to(const TermsScreen());
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                  Get.to(const UserProfilePage());
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
                                onTap: () {},
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
    ),
    const UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VOLMORE ',
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: headingBlue),
        ),
        centerTitle: false,
        elevation: 1,
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              size: 32,
            ),
            onPressed: () {
              Get.bottomSheet(
                  Container(
                      decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(30))),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                  Get.to(const FAQPage());
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                  Get.to(const TermsScreen());
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
                                  Get.to(const UserProfilePage());
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                tileColor: const Color(0xFFECECEC),
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
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: headingBlue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> Logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }
}
