import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/appbar_widget.dart';

class VolunterringIdeasScreen extends StatelessWidget {
  const VolunterringIdeasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context, ""),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Get.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Volunterring Ideas",
                    style: TextStyle(
                        decorationColor: headingBlue,
                        color: headingBlue,
                        fontSize: Get.height * 0.04,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "1. Volunteer at your local shelters.",
                  textAlign: TextAlign.left,
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
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    decorationColor: bodyBlue,
                    color: headingBlue,
                    fontSize: Get.height * 0.018,
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "2. Volunteer at your local food bank",
                  textAlign: TextAlign.left,
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
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    decorationColor: bodyBlue,
                    color: headingBlue,
                    fontSize: Get.height * 0.018,
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "3. Collect and deliver for charities",
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
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decorationColor: bodyBlue,
                      color: headingBlue,
                      fontSize: Get.height * 0.018),
                ),
              ),
              SizedBox(
                height: Get.height * 0.04,
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: Get.width * 0.3,
                      height: Get.height * 0.05,
                      decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        "Exit",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Get.height * 0.022),
                      )),
                    ),
                    const SizedBox(
                      width: 20,
                    )
                  ],
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
