


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:volunterring/Models/request_models/reset_password_request_model.dart';
import 'package:volunterring/Screens/LoginPage.dart';
import 'package:volunterring/Services/user_services.dart';

import '../Services/signUp_login_services.dart';
import '../Utils/Colors.dart';
import '../widgets/InputFormFeild.dart';
import '../widgets/button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen(this.email, {super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passwordController =TextEditingController();
  TextEditingController confirmPasswordController =TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.095,
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: headingBlue,
                      fontSize: MediaQuery.of(context).size.height * 0.035, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.050,
                ),
                InputFeildWidget(
                  title: 'Password*',
                  controller: passwordController,
                  maxlines: 1,
                  hintText: "Enter Your Password",
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.010,
                ),
                InputFeildWidget(
                  title: 'Confirm Password*',
                  controller: confirmPasswordController,
                  maxlines: 1,
                  hintText: "Confirm Your Password",
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.070,
                ),
                MyButtons(onTap: ()async {
                  //  Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(widget.email, "")));

                  if(passwordController.text == confirmPasswordController.text){
                    ResetPasswordRequestModel req = ResetPasswordRequestModel();
                    req.emailId = widget.email;
                    req.password = confirmPasswordController.text;
                    await UserServices().resetPassword(req).then((onValue){
                      if(onValue!.message!.toLowerCase().contains("successfully")){
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                              (Route<dynamic> route) =>
                          false, // This condition makes sure all the routes are removed.
                        );
                        Fluttertoast.showToast(msg: onValue.message!);
                      }else{
                        //  Navigator.push(context, MaterialPageRoute(builder: (_) => Reset(emailController.text)));
                        Fluttertoast.showToast(msg: onValue.message!);
                      }


                    });
                  }else{
                    Fluttertoast.showToast(msg: "Password doesn't match");
                  }


                }, text: "Reset Password"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
