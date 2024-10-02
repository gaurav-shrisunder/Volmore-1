import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:volunterring/Models/response_models/sign_up_response_model.dart';
import 'package:volunterring/Screens/ForgotPasswordPage.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Screens/SignUpPage.dart';
import 'package:volunterring/Screens/dashboard.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Services/signUp_login_services.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/InputFormFeild.dart';
import 'package:volunterring/widgets/button.dart';
import 'package:volunterring/widgets/snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // email and passowrd auth part
  void loginUser() async {

    setState(() {
      isLoading = true;
    });
    // signup user using our authmethod
    // String res = await AuthMethod().loginUser(
    //     email: emailController.text, password: passwordController.text);

    SignUpResponseModel? res = await SignupLoginServices().loginUser(emailController.text, passwordController.text);
    if (res?.data?.user != null) {
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      //navigate to the home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,  // This condition makes sure all the routes are removed.
      );
      Fluttertoast.showToast(msg: "Login successfully",toastLength: Toast.LENGTH_LONG);
    } else {
      setState(() {
        isLoading = false;
        Navigator.pop(context);

      });
      // show error
      Fluttertoast.showToast(msg:res?.message ?? "Something went wrong!!",toastLength: Toast.LENGTH_LONG);
     // showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: const Color(0xFF7Fd8de),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  "assets/icons/login.png",
                  height: height * 0.3911,
                ),
                Container(
                  height: height * 0.567,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: height * 0.03,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Welcome Back!',
                              style: TextStyle(
                                  fontSize: height * 0.045,
                                  fontWeight: FontWeight.w500,
                                  color: headingBlue),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.015,
                          ),
                          // Text(
                          //   'Sign in to continue',
                          //   style: TextStyle(
                          //       color: greyColor,
                          //       fontSize: height * 0.023,
                          //       fontWeight: FontWeight.normal),
                          // ),
                          // SizedBox(
                          //   height: height * 0.06,
                          // ),
                          InputFeildWidget(
                            title: 'Email*',
                            controller: emailController,
                            maxlines: 1,
                            hintText: "Enter Your email",
                          ),
                          SizedBox(
                            height: height * 0.009,
                          ),
                          InputFeildWidget(
                            title: 'Password*',
                            controller: passwordController,
                            maxlines: 1,
                            hintText: "Enter Your Password",
                          ),
                          SizedBox(
                            height: height * 0.008,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword())),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  ' Forgot Password?',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.lightBlue[500],
                                      fontWeight: FontWeight.normal),
                                ),
                                const SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * 0.015,
                          ),
                          MyButtons(onTap: (){
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_){
                              return const Center(child: CircularProgressIndicator());
                            });
                            loginUser();
                          }, text: "Log In"),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: width * 0.05),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    ' New User?',
                                    style: TextStyle(
                                        fontSize: height * 0.02,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUpPage())),
                                    child: Text(
                                      '  Create Account',
                                      style: TextStyle(
                                          fontSize: height * 0.02,
                                          color: Colors.lightBlue[500],
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
