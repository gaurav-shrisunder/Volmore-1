import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:volunterring/Screens/VerifyOtpScreen.dart';
import 'package:volunterring/Services/signUp_login_services.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/button.dart';

import '../Utils/Colors.dart';
import '../widgets/InputFormFeild.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SignupLoginServices signupLoginServices = SignupLoginServices();

  final TextEditingController emailController = TextEditingController();

  Future<void> _resetPassword(String email) async {


  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,

        body: Column(
          children: [
            SizedBox(
              height: height * 0.095,
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);

                },
              child: Align(
                alignment: Alignment.topLeft,
                child: Icon(Icons.chevron_left, size: 50,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Text(
                    'Forgot \nPassword',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: headingBlue,
                        fontSize: height * 0.035, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  InputFeildWidget(
                    title: 'Email*',
                    controller: emailController,
                    maxlines: 1,
                    hintText: "Enter Your email",
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),
                  MyButtons(onTap: ()async {

                    await signupLoginServices.sendOtp(emailController.text).then((onValue){
                      if(onValue!.message!.toLowerCase().contains("Failed to process request")){
                        Fluttertoast.showToast(msg: onValue.message!);
                      }else{
                        Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyOtpScreen(emailController.text)));

                      }


                    });

                  }, text: "Send Email"),
                  SizedBox(
                    height: height * 0.01,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
