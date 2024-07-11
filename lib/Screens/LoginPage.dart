import 'package:flutter/material.dart';
import 'package:volunterring/Screens/ForgotPasswordPage.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Screens/SignUpPage.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/widgets/FormFeild.dart';
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
    String res = await AuthMethod().loginUser(
        email: emailController.text, password: passwordController.text);

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
        body: Center(
          child: SingleChildScrollView (
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                      fontSize: height * 0.065, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: height * 0.015,
                ),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                      fontSize: height * 0.023, fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: height * 0.06,
                ),
                TextFieldInput(
                    textEditingController: emailController,
                    label: "Email",
                    hintText: 'Enter your email',
                    textInputType: TextInputType.text),
                TextFieldInput(
                  textEditingController: passwordController,
                  hintText: 'Enter your passord',
                  label: "Password",
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPassword())),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        ' Forgot Password?',
                        style: TextStyle(
                            fontSize: height * 0.023,
                            color: Colors.blue,
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.015,
                ),
                MyButtons(onTap: loginUser, text: "Log In"),
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
                              fontSize: height * 0.023,
                              fontWeight: FontWeight.normal),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage())),
                          child: Text(
                            ' Create Acoount',
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
        ));
  }
}
