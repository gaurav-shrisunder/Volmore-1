import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lendavolunterring/widgets/customSnackbar.dart';

import '../../Models/response_models/sign_up_response_model.dart';
import '../../Screens/ForgotPasswordPage.dart';
import '../../Screens/HomePage.dart';
import '../../Screens/SignUpPage.dart';
import '../../Services/signUp_login_services.dart';
import '../Utils/common_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>  with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<Offset> _emailSlideAnimation;
  late Animation<Offset> _passwordSlideAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _buttonScaleAnimation;


  @override
  void initState() {
    super.initState();
    // apiCalling();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _emailSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5), // Slide up
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _passwordSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Start off-screen
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Timer(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  apiCalling ()async{
    String tzName = await getTimezoneName();
    print('Timezone: $tzName');
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // email and passowrd auth part
  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    // signup user using our authmethod
    // String res = await AuthMethod().loginUser(
    //     email: emailController.text, password: passwordController.text);
var sessionId  = "app-${emailController.text.split("@").first}";
    SignUpLoginResponseModel? res = await SignupLoginServices()
        .loginUser(emailController.text, passwordController.text,sessionId);
    if (res?.userDetails?.user != null) {
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      //navigate to the home screen
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) =>
            false, // This condition makes sure all the routes are removed.
      );
      CustomSnackBar.show(context: context, message: "Login successfully", type: SnackBarType.success);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res?.message ?? "Something went wrong!!"),
          duration: const Duration(seconds: 3), // Set the duration of the toast
          behavior: SnackBarBehavior.floating, // Makes the toast float above the UI
          backgroundColor: Colors.black, // Optional: Customize the background color
        ),
      );
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      // show error

      // showSnackBar(context, res);
    }
  }

  bool isObsecure = false;
  void togglePassword() {
    setState(() {
      isObsecure = !isObsecure;
    });
  }

  @override
  Widget build(BuildContext context) {


    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF7FD8DE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Image.asset(
                  "assets/icons/login.png",
                  height: height * 0.3,
                  alignment: Alignment.center,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: FadeTransition(
                          opacity: _opacityAnimation,
                          child: Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: height * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Email Field
                      SlideTransition(
                        position: _emailSlideAnimation,
                        child: TextField(
                          controller: emailController,
                          // textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: "Enter Your Email",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),

                      // Password Field
                      SlideTransition(
                        position: _passwordSlideAnimation,
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: passwordController,
                          obscureText: isObsecure,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: "Enter Your Password",
                            filled: true,
                            suffixIcon: IconButton(
                              icon: isObsecure
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                              onPressed: togglePassword,
                            ),
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),

                      // Forgot Password
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPassword()),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.lightBlue[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Login Button
                      SlideTransition(
                        position: _buttonSlideAnimation,
                        child: GestureDetector(
                          onTapDown: (_) => _controller.reverse(),
                          onTapUp: (_) => _controller.forward(),
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            loginUser();
                          },
                          child: ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: Container(
                              height: height * 0.07,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7FD8DE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: height * 0.025,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),

                      // New User? Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("New User? ", style: TextStyle(fontSize: height * 0.02)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            ),
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: height * 0.02,
                                color: Colors.lightBlue[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
