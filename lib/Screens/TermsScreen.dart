import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:volunterring/Utils/Colors.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool agree = false;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: headingBlue,
              color: headingBlue,
              fontSize: Get.height * 0.045,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(children: [
              Text(
                'Terms and Conditions',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: height * 0.035,
                  color: headingBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                "1. Acceptance of Terms: By downloading, accessing, or using the Volunteer Tracker App, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the app.",
                style: TextStyle(
                  decorationColor: bodyBlue,
                  color: headingBlue,
                  fontSize: Get.height * 0.022,
                ),
              ),
              Text(
                "2. Eligibility: The app is intended for use by individuals who are 13 years of age or older. By using the app, you represent and warrant that you meet this eligibility requirement.",
                style: TextStyle(
                  decorationColor: bodyBlue,
                  color: headingBlue,
                  fontSize: Get.height * 0.022,
                ),
              ),
              Text(
                "3. User Accounts: You must create an account to use certain features of the app. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.",
                style: TextStyle(
                  decorationColor: bodyBlue,
                  color: headingBlue,
                  fontSize: Get.height * 0.022,
                ),
              ),
              Text(
                "4. Use of the App: You agree to use the app for lawful purposes only. You shall not use the app to engage in any activity that is illegal, harmful, or interferes with the operation of the app or the enjoyment of the app by other users",
                style: TextStyle(
                  decorationColor: bodyBlue,
                  color: headingBlue,
                  fontSize: Get.height * 0.022,
                ),
              ),
              Text(
                "5. Content Ownership: All content, including but not limited to text, graphics, logos, and software, is the property of Volunteer Tracker App and is protected by intellectual property laws. You may not use, reproduce, or distribute any content without our express permission",
                style: TextStyle(
                  decorationColor: bodyBlue,
                  color: headingBlue,
                  fontSize: Get.height * 0.022,
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: agree,
                        onChanged: (value) {
                          setState(() {
                            agree = value!;
                            // Save the value in local storage
                            // TODO: Implement local storage saving logic
                          });
                        },
                      ),
                      Text(
                        'Agree to the terms and conditions',
                        style: TextStyle(
                          decorationColor: bodyBlue,
                          color: headingBlue,
                          fontSize: Get.height * 0.022,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: !agree,
                        onChanged: (value) {
                          setState(() {
                            agree = !value!;
                            // Save the value in local storage
                            // TODO: Implement local storage saving logic
                          });
                        },
                      ),
                      Text(
                        'Disagree to the terms and conditions',
                        style: TextStyle(
                          decorationColor: bodyBlue,
                          color: headingBlue,
                          fontSize: Get.height * 0.022,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ]),
          ),
        ));
  }
}
