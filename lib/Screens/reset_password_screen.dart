import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Models/request_models/reset_password_request_model.dart';
import '../../Screens/login_screen.dart';
import '../../Services/user_services.dart';
import '../Utils/app_colors.dart';
import '../widgets/text_input_form_field_widget.dart';
import '../widgets/button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen(this.email, {super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.095,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Icon(
                  Icons.chevron_left,
                  size: 50,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Password',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: headingBlue,
                        fontSize: MediaQuery.of(context).size.height * 0.035,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.050,
                  ),
                  TextInputFieldWidget(
                    title: 'Password*',
                    keyboardType: TextInputType.visiblePassword,
                    controller: passwordController,
                    maxlines: 1,
                    hintText: "Enter Your Password",
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.020,
                  ),
                  TextInputFieldWidget(
                    title: 'Confirm Password*',
                    keyboardType: TextInputType.visiblePassword,
                    controller: confirmPasswordController,
                    maxlines: 1,
                    hintText: "Confirm Your Password",
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.070,
                  ),
                  MyButtons(
                      onTap: () async {
                        //  Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(widget.email, "")));

                        if (passwordController.text ==
                            confirmPasswordController.text) {
                          ResetPasswordRequestModel req =
                              ResetPasswordRequestModel();
                          req.emailId = widget.email;
                          req.password = confirmPasswordController.text;
                          await UserServices()
                              .resetPassword(req)
                              .then((onValue) {
                            if (onValue!.contains("successfully")) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (Route<dynamic> route) =>
                                    false, // This condition makes sure all the routes are removed.
                              );
                              Fluttertoast.showToast(msg: onValue.message!);
                            } else {
                              //  Navigator.push(context, MaterialPageRoute(builder: (_) => Reset(emailController.text)));
                              Fluttertoast.showToast(msg: onValue.message!);
                            }
                          });
                        } else {
                          Fluttertoast.showToast(msg: "Password doesn't match");
                        }
                      },
                      text: "Reset Password"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
