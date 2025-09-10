import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utils/app_colors.dart';
import '../../widgets/appbar_widget.dart';

class VolunteeringIdeasScreen extends StatelessWidget {
  const VolunteeringIdeasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ideas = [
      {
        "title": "Collect and Deliver for Charities",
        "description":
        "Charities often need volunteers to help collect, sort, and deliver donations. You might pick up bags from local neighborhoods, organize them for resale in charity shops, or make deliveries to people without transportation. It’s a simple but powerful way to directly support families and individuals in your community."
      },
      {
        "title": "Tutoring Younger Students",
        "description":
        "Offer homework help in subjects like reading, math, or science. You’ll build confidence in younger kids while reinforcing your own knowledge. Best of all, you become a role model who makes learning fun and less intimidating."
      },
      {
        "title": "Park and River Clean-Ups",
        "description":
        "Join a cleanup crew and spend a few hours outdoors making parks, rivers, or trails more beautiful. With gloves and a trash bag in hand, you’ll see the results of your effort instantly while helping protect wildlife and the environment."
      },
      {
        "title": "Senior Center Visitor",
        "description":
        "Bring joy to older adults by playing games, reading aloud, or simply sharing conversation. Your time and energy brighten their days and often lead to heartwarming friendships across generations."
      },
      {
        "title": "Library Assistant",
        "description":
        "Help keep the library running smoothly by shelving books, assisting with events, or reading to children during story hours. Libraries are vibrant community spaces, and your support helps them thrive for everyone."
      },
    ];

    return Scaffold(
      appBar: simpleAppBar(context, "Volunteering Ideas"),

      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemCount: ideas.length + 1, // +1 for Exit button
        itemBuilder: (context, index) {
          if (index < ideas.length) {
            final idea = ideas[index];
            return VolunteeringIdeaTile(
              index: index + 1,
              title: idea["title"]!,
              description: idea["description"]!,
            );
          } else {
            // Exit button as the last item
            return SizedBox();
          }
        },
      ),
    );
  }
}

/// Common Reusable Widget as a Card
class VolunteeringIdeaTile extends StatelessWidget {
  final int index;
  final String title;
  final String description;

  const VolunteeringIdeaTile({
    super.key,
    required this.index,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      color: Colors.lightGreen.shade50,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              "$index. $title",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Get.height * 0.022,
                color: headingBlue,
              ),
            ),
            const SizedBox(height: 10),

            /// Description
            Text(
              description,
              style: TextStyle(
                fontSize: Get.height * 0.018,
                color: headingBlue.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
