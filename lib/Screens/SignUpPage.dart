import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Screens/LoginPage.dart';
import 'package:volunterring/Screens/dashboard.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/InputFormFeild.dart';
import 'package:volunterring/widgets/button.dart';
import 'package:volunterring/widgets/snackbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  final TextEditingController numberController = TextEditingController();

  bool isLoading = false;

  void signUp() async {
    setState(() {
      isLoading = true;
    });

    // signup user using our authmethod
    String res = await AuthMethod().signupUser(
        email: emailController.text,
        password: passwordController.text,
        confirmPassword: confirmpasswordController.text,
        name: nameController.text,
        phone: numberController.text);

    if (res == "success") {
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });

      //navigate to the home screen

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,  // This condition makes sure all the routes are removed.
      );
      Fluttertoast.showToast(
          msg: "Account created successfully.", toastLength: Toast.LENGTH_LONG);
    } else {
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      // show error
      Fluttertoast.showToast(msg: res, toastLength: Toast.LENGTH_LONG);
      //   showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Image.asset(
                      "assets/icons/signup.png",
                      height: height * 0.08,
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Text(
                      'Create Account ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1,
                          color: headingBlue,
                          letterSpacing: 1.3,
                          fontSize: 24,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: height * 0.007,
                    ),
                    InputFeildWidget(
                      title: 'Name',
                      controller: nameController,
                      maxlines: 1,
                      hintText: "Enter Your name",
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
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
                      height: height * 0.009,
                    ),
                    InputFeildWidget(
                      title: 'Re-Enter Password*',
                      controller: confirmpasswordController,
                      maxlines: 1,
                      hintText: "Re-enter Your Password",
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    InputFeildWidget(
                      title: 'Phone number*',
                      controller: numberController,
                      maxlines: 1,
                      hintText: "Enter Your phone number",
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    MyButtons(onTap: (){
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_){
                            return const Center(child: CircularProgressIndicator());
                          });
                      signUp();
                    }, text: "Sign Up"),
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
                              ' Existing User?',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                               /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()));*/
                              },
                              child: Text(
                                ' Log in',
                                style: TextStyle(
                                    fontSize: 18,
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
        ));
  }
}
