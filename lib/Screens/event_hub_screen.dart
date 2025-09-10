import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../Screens/Event/create_event_screen.dart';
import '../../Screens/Event/create_past_events_page.dart';
import '../../Screens/volunteering_ideas_screen.dart';
import '../../Utils/app_colors.dart';
import '../../widgets/appbar_widget.dart';

class EventHubScreen extends StatefulWidget {
  const EventHubScreen({super.key});

  @override
  State<EventHubScreen> createState() => _CreateLogScreenState();
}

class _CreateLogScreenState extends State<EventHubScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Create staggered slide animations for the cards
    _slideAnimations = List.generate(3, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 * (index + 1),
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    // Start the animation when the screen is built
    Timer(const Duration(milliseconds: 200), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context, ""),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.2),
                      end: Offset.zero,
                    ).animate(_animationController),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Let's get started",
                          style: TextStyle(
                            color: headingBlue,
                            fontSize: Get.height * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "What would you like to do today?",
                          style: TextStyle(
                            fontSize: Get.height * 0.018,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SlideTransition(
                  position: _slideAnimations[0],
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.history_edu,
                      title: "Log Past Hours",
                      subtitle: "Add a past volunteered event to your transcript.",
                      gradientColors: [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
                      onTap: () => Get.to(() => const CreatePastEventsScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideAnimations[1],
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.add_circle_outline,
                      title: "Create New Event",
                      subtitle: "Organize and set up a new volunteering opportunity.",
                      gradientColors: [const Color(0xFF76B852), const Color(0xFF8DC26F)],
                      onTap: () => Get.to(() => const CreateEventScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideAnimations[2],
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.lightbulb_outline,
                      title: "Volunteering Ideas",
                      subtitle: "Need inspiration? Explore ideas for your next activity.",
                      gradientColors: [const Color(0xFFDA4453), const Color(0xFF89216B)],
                      onTap: () => Get.to(() => const VolunteeringIdeasScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A reusable widget to build the feature cards for a more modular and clean UI.
  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required List<Color> gradientColors,
        required VoidCallback onTap,
      }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Get.height * 0.022,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: Get.height * 0.016,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}