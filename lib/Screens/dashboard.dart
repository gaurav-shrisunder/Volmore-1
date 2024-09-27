import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Screens/BottomSheet/user_profile_page.dart';
import 'package:volunterring/Screens/BottomSheet/FAQPage.dart';
import 'package:volunterring/Screens/BottomSheet/SupportPage.dart';
import 'package:volunterring/Screens/Event/events_page.dart';
import 'package:volunterring/Screens/LoginPage.dart';
import 'package:volunterring/Screens/TermsScreen.dart';

import '../Utils/Colors.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<Offset> _animation;

  static final List<Widget> _widgetOptions = <Widget>[
    const EventPage(initialSortOption: SortOption.az, ),
    const Text('Leaderboard Screen'),
    const Text('Transcript Screen'),
    const UserProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'VOLMORE',
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: headingBlue),
        ),
        centerTitle: false,
        elevation: 1,
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 30),
            onPressed: _showSettingsBottomSheet,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SlideTransition(
        position: _animation,
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 5,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transcript',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showSettingsBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildSettingsTile(
                  'Support - I need help',
                  Icons.arrow_forward_ios_outlined,
                  () => Get.to(SupportPage())),
              _buildSettingsTile(
                  'Frequently Asked Questions',
                  Icons.arrow_forward_ios_outlined,
                  () => Get.to(const FAQPage())),
              _buildSettingsTile('Privacy Policy',
                  Icons.arrow_forward_ios_outlined, () => Get.back()),
              _buildSettingsTile(
                  'Terms and Conditions',
                  Icons.arrow_forward_ios_outlined,
                  () => Get.to(const TermsScreen())),
              _buildSettingsTile(
                  'Manage your Account',
                  Icons.arrow_forward_ios_outlined,
                  () => Get.to(const UserProfilePage())),
              _buildSettingsTile(
                  'Log Out', Icons.arrow_forward_ios_outlined, Logout),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        tileColor: const Color(0xFFECECEC),
        title: Text(
          title,
          style: const TextStyle(
              color: headingBlue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(icon, color: headingBlue),
        onTap: onTap,
      ),
    );
  }

  Future<void> Logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,  // This condition makes sure all the routes are removed.
    );

  /*  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );*/
  }
}
