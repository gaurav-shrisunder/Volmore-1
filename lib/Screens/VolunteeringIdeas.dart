import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:volunterring/Utils/Colors.dart';

class VolunterringIdeasScreen extends StatelessWidget {
  const VolunterringIdeasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: Get.height * 0.08,
              ),
              Text(
                "Volunterring Ideas",
                style: TextStyle(
                    decorationColor: headingBlue,
                    color: headingBlue,
                    fontSize: Get.height * 0.045,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Volunteer at your local shelters.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Get.height * 0.022),
                ),
              ),
              SizedBox(
                height: Get.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Visit your local homeless and animal shelters to see if there are openings for any potential volunteering efforts. ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decorationColor: bodyBlue,
                    color: headingBlue,
                    fontSize: Get.height * 0.022,
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Volunteer at your local food bank",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Get.height * 0.022),
                ),
              ),
              SizedBox(
                height: Get.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "As a food bank volunteer, you make up food parcels for registered service users and meet members of the public. You keep the food bank stocked and organise and handle administration. Volunteers also collect food donations from people and businesses.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decorationColor: bodyBlue,
                    color: headingBlue,
                    fontSize: Get.height * 0.022,
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Collect and deliver for charities",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Get.height * 0.022),
                ),
              ),
              SizedBox(
                height: Get.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Charities seek volunteers to collect and coordinate donations. This involves acting as a driver to collect donation bags from a local area. Volunteers also process donations for onward sale in charity shops. Make deliveries to registered service users who don't have their own transport.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decorationColor: bodyBlue,
                    color: headingBlue,
                    fontSize: Get.height * 0.022,
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  width: Get.width * 0.8,
                  height: Get.height * 0.08,
                  decoration: BoxDecoration(
                      color: Color(0xFFF5C6E1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(
                    "Exit",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Get.height * 0.022),
                  )),
                ),
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
