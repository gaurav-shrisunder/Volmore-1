import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:volunterring/Screens/BottomSheet/AccountPage.dart';
import 'package:volunterring/Screens/BottomSheet/FAQPage.dart';
import 'package:volunterring/Screens/BottomSheet/SupportPage.dart';

import 'package:volunterring/Screens/Event/events_page.dart';

import 'package:volunterring/Screens/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Screens/TermsScreen.dart';
import 'package:volunterring/Screens/leaderboard_screen.dart';
import 'package:volunterring/Utils/Colors.dart';

import 'CreateLogScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const EventPage(),
    const LeaderboardScreen(),
    const Text('Transcript Screen'),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'VOLMORE',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: headingBlue,),
        ),
        centerTitle: false,
        elevation: 1,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 32),
            onPressed: _showSettingsBottomSheet,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
       showUnselectedLabels: true,
        elevation: 5,
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/icons/bottom_events_icon_light.svg"),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/icons/bottom_leadership_icon_light.svg"),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/icons/bottom_transcript_light.svg"),
            label: 'Transcript',
          ),
          BottomNavigationBarItem(
            icon:SvgPicture.asset("assets/icons/bottom_profile_light.svg"),
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
              _buildSettingsTile("Create Log", Icons.arrow_forward_ios_outlined, ()=>  Get.to(const CreateLogScreen())),
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }
}
