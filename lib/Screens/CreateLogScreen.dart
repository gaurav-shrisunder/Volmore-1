import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:volunterring/Screens/Event/CreateEventPage.dart';
import 'package:volunterring/Screens/VolunteeringIdeas.dart';
import 'package:volunterring/Utils/Colors.dart';

class CreateLogScreen extends StatelessWidget {
  const CreateLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            height: Get.height * 0.04,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back_ios)),
              SizedBox(
                width: Get.width * 0.05,
              ),
              Text(
                "Create an Event",
                style: TextStyle(
                    decorationColor: headingBlue,
                    color: headingBlue,
                    fontSize: Get.height * 0.045,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: Get.height * 0.04,
          ),
          Divider(
            color: bodyBlue,
            thickness: 2,
          ),
          SizedBox(
            height: Get.height * 0.04,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              "Select if you have a past volunteer event that you want to add to your transcript.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Get.height * 0.022),
            ),
          ),
          SizedBox(
            height: Get.height * 0.04,
          ),
          Container(
            width: Get.width * 0.8,
            height: Get.height * 0.08,
            decoration: BoxDecoration(
                color: Color(0xFFC3D6EF),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(
              "Log Past Hours",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Get.height * 0.022),
            )),
          ),
          SizedBox(
            height: Get.height * 0.04,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              "Select if you want to create a new event",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Get.height * 0.022),
            ),
          ),
          SizedBox(
            height: Get.height * 0.04,
          ),
          GestureDetector(
            onTap: () {
              Get.to(CreateEventScreen());
            },
            child: Container(
              width: Get.width * 0.8,
              height: Get.height * 0.08,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(
                "Create New Event",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: Get.height * 0.022),
              )),
            ),
          ),
          SizedBox(
            height: Get.height * 0.04,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              "Need help coming up with volunteering ideas? Click here!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Get.height * 0.022),
            ),
          ),
          SizedBox(
            height: Get.height * 0.04,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VolunterringIdeasScreen()));
            },
            child: Container(
              width: Get.width * 0.8,
              height: Get.height * 0.08,
              decoration: BoxDecoration(
                  color: Color(0xFFF5C6E1),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(
                "Volunteering Ideas",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: Get.height * 0.022),
              )),
            ),
          )
        ]),
      ),
    ));
  }
}
