import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Screens/BottomSheet/user_profile_page.dart';
import '../../Screens/BottomSheet/FAQPage.dart';
import '../../Screens/BottomSheet/SupportPage.dart';

import '../../Screens/Event/events_page.dart';
import '../../Screens/Event/events_screen.dart';

import '../../Screens/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Screens/TermsScreen.dart';
import '../../Screens/leaderboard_screen.dart';
import '../../Screens/transcript_screen.dart';
import '../../Services/authentication.dart';
import '../../Utils/Colors.dart';

import '../Utils/shared_prefs.dart';
import '../provider/theme_manager_provider.dart';
import 'CreateLogScreen.dart';
import 'WebviewScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // const EventPage(initialSortOption: SortOption.def),
    const EventsScreen(initialSortOption: SortOption.def),
    const LeaderboardScreen(),
    const TranscriptScreen(),
    const UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'lenda',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 1,
        automaticallyImplyLeading: false,
        //   backgroundColor: Colors.white,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 30),
            onPressed: _showSettingsBottomSheet,
          ),
          const SizedBox(width: 10),
          /* IconButton(
            icon: Icon(
              themeManager.themeData.brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: themeManager.themeData.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey,
            ),
            onPressed: () {
              setState(() {});
              themeManager.toggleTheme();
            },
            iconSize: 30.0,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: const ButtonStyle(
                shape: MaterialStatePropertyAll(CircleBorder())),
            splashRadius: 24.0,
          )*/
        ],
      ),
      body: Center(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              "assets/icons/bottom_events_icon_light.svg",
              isSelected: _selectedIndex == 0,
            ),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              "assets/icons/bottom_leadership_icon_light.svg",
              isSelected: _selectedIndex == 1,
            ),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              "assets/icons/bottom_transcript_light.svg",
              isSelected: _selectedIndex == 2,
            ),
            label: 'Transcript',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              "assets/icons/bottom_profile_light.svg",
              isSelected: _selectedIndex == 3,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(String assetPath, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isSelected ? Colors.blueAccent : Colors.grey.shade500,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            _buildSettingsTile(
              title: 'Support - I need help',
              icon: Icons.support_agent_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WebViewScreen(
                    'https://www.lendavolunteering.com/contact-us',
                  ),
                ),
              ),
            ),

            _buildSettingsTile(
              title: 'Frequently Asked Questions',
              icon: Icons.help_outline,
              onTap: () => Get.to(const FAQPage()),
            ),

            const Divider(height: 20),

            _buildSettingsTile(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WebViewScreen(
                    'https://www.lendavolunteering.com/privacy-policy',
                  ),
                ),
              ),
            ),

            _buildSettingsTile(
              title: 'Terms and Conditions',
              icon: Icons.article_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WebViewScreen(
                    'https://www.lendavolunteering.com/terms-and-condition',
                  ),
                ),
              ),
            ),

            const Divider(height: 20),

            _buildSettingsTile(
              title: 'Log Out',
              icon: Icons.logout,
              onTap: logout,
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      visualDensity: const VisualDensity(vertical: -2),
    );
  }

  Future<void> logout() async {
    clearPreferences();
    AuthMethod().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) =>
          false, // This condition makes sure all the routes are removed.
    );
  }
}
