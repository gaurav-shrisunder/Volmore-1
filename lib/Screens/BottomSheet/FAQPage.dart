import 'package:flutter/material.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/QnA.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    const qnaList = [
      {
        "question":
            "How do I log hours for a volunteering event I did in the past?",
        "answer":
            "Press the “Log Past Hours” button to log the hours. You can verify the event with a signature, but not geolocation and real-time tracking."
      },
      {
        "question":
            "What if the volunteer organization/ person I helped  couldn't sign at the event?",
        "answer":
            "Don't worry, we have got you covered try our text feature today by adding there phone number, they will receive a text and be able to verify your work. "
      },
      {
        "question": "How do I reset my password?  ",
        "answer":
            "Click on the settings button, from there you can go into manage my account and reset your password, change aspects of your profile, and even delete your account.  "
      },
    ];
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: SafeArea(
        child: Center(
            child: Column(
          children: [
            Text(
              'FAQ',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: height * 0.035,
                color: headingBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            QnAWidget(qnaList: qnaList)
          ],
        )),
      ),
    );
  }
}
