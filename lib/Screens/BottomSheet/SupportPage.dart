import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:volunterring/Utils/Colors.dart';

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(''),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  SizedBox(height: height * 0.07),
                  Container(
                    height: height * 0.2,
                    width: width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFffc5de),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.support_agent, size: height * 0.05),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Support',
                            style: TextStyle(
                              fontSize: height * 0.035,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    'Need to get in touch?',
                    style: TextStyle(
                      fontSize: height * 0.025,
                      color: headingBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Container(
                    height: height * 0.06,
                    width: width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromARGB(255, 210, 217, 243),
                    ),
                    child: Center(
                      child: Text(
                        'Call us',
                        style: TextStyle(
                          fontSize: height * 0.025,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text('(248)-721-3421',
                      style: TextStyle(
                        fontSize: height * 0.025,
                        color: headingBlue,
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: height * 0.02),
                  Container(
                    height: height * 0.06,
                    width: width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromARGB(255, 210, 217, 243),
                    ),
                    child: Center(
                      child: Text(
                        'Email us',
                        style: TextStyle(
                          fontSize: height * 0.025,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text('Help.Volmore@gmail.com',
                      style: TextStyle(
                        fontSize: height * 0.025,
                        color: headingBlue,
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: height * 0.02),
                  Text(
                    'Frequent Problems',
                    style: TextStyle(
                      fontSize: height * 0.035,
                      color: headingBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Can't create an event?",
                      style: TextStyle(
                        fontSize: height * 0.022,
                        color: headingBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Try refreshing the app and logging in and out. ",
                      style: TextStyle(
                        fontSize: height * 0.019,
                        color: headingBlue,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Data won't save?",
                      style: TextStyle(
                        fontSize: height * 0.022,
                        color: headingBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Contact support  ",
                      style: TextStyle(
                        fontSize: height * 0.019,
                        color: headingBlue,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Spotted a BUG?",
                      style: TextStyle(
                        fontSize: height * 0.022,
                        color: headingBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Contact support ",
                      style: TextStyle(
                        fontSize: height * 0.019,
                        color: headingBlue,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
