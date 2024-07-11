
import 'package:flutter/material.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Screens/LoginPage.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/button.dart';
import 'package:volunterring/widgets/snackbar.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
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
        name: emailController.text,
        phone: numberController.text);

    if (res == "success") {
      setState(() {
        isLoading = false;
      });

      //navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      // show error
      showSnackBar(context, res);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Text(
                    'Create an Account ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        height: 1.1,
                        letterSpacing: 1.3,
                        fontSize: height * 0.067,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                        fontSize: height * 0.023,
                        fontWeight: FontWeight.normal),
                  ),
                  SizedBox(
                    height: height * 0.0,
                  ),
                  TextFieldInput(
                      textEditingController: emailController,
                      label: "Email*",
                      hintText: 'Enter your email',
                      textInputType: TextInputType.text),
                  TextFieldInput(
                    textEditingController: passwordController,
                    hintText: 'Enter your passord',
                    label: "Password*",
                    textInputType: TextInputType.text,
                    isPass: true,
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextFieldInput(
                    textEditingController: confirmpasswordController,
                    hintText: 'Re-Enter your passord',
                    label: "Re-Enter Password*",
                    textInputType: TextInputType.text,
                    isPass: true,
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextFieldInput(
                    textEditingController: numberController,
                    hintText: 'Phone Number',
                    label: "Phone Number*",
                    textInputType: TextInputType.text,
                    isPass: true,
                  ),
                  SizedBox(
                    height: height * 0.003,
                  ),
                  MyButtons(onTap: signUp, text: "Sign Up"),
                  SizedBox(
                    height: height * 0.0,
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
                                fontSize: height * 0.023,
                                fontWeight: FontWeight.normal),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage())),
                            child: Text(
                              ' Log in',
                              style: TextStyle(
                                  fontSize: height * 0.023,
                                  color: Colors.blue,
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
        ));
  }
}
