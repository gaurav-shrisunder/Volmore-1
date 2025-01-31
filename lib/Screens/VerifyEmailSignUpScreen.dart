import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import '../../Screens/ResetPasswordScreen.dart';
import '../../Services/signUp_login_services.dart';

import '../Models/request_models/sign_up_request_model.dart';
import '../Models/response_models/sign_up_response_model.dart';
import '../Utils/Colors.dart';
import '../widgets/button.dart';
import 'HomePage.dart';

class VerifyEmailSignUpScreen extends StatefulWidget {
  final SignUpRequestModel signUpRequestModel;

  const VerifyEmailSignUpScreen(this.signUpRequestModel, {super.key});

  @override
  State<VerifyEmailSignUpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyEmailSignUpScreen> {
  TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  final defaultPinTheme = PinTheme(
    width: 50,
    height: 50,
    textStyle: const TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey),
    ),
  );

  void signUp(SignUpRequestModel requestBody) async {
    setState(() {
      isLoading = true;
    });

    SignupLoginServices signupServices = SignupLoginServices();
    SignUpLoginResponseModel? res =
        await signupServices.signUpUser(requestBody);

    if (res?.userDetails?.user != null) {
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });

      //navigate to the home screen

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) =>
            false, // This condition makes sure all the routes are removed.
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res?.message ?? "Account created successfully."),
          duration: const Duration(seconds: 3),
          // Set the duration of the toast
          behavior: SnackBarBehavior.floating,
          // Makes the toast float above the UI
          backgroundColor:
              Colors.black, // Optional: Customize the background color
        ),
      );
    } else {
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      // show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res?.message ?? "Something went wrong!!"),
          duration: const Duration(seconds: 3),
          // Set the duration of the toast
          behavior: SnackBarBehavior.floating,
          // Makes the toast float above the UI
          backgroundColor:
              Colors.black, // Optional: Customize the background color
        ),
      );
      //   showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: height * 0.095,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Align(
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
                  'Verify your email address',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: headingBlue,
                      fontSize: height * 0.035,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: height * 0.010,
                ),
                Text(
                  'An email with OTP has been send to ${widget.signUpRequestModel.emailId}. Please enter the code to verify your email address',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: headingBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: height * 0.030,
                ),
                Center(
                  child: Pinput(
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: Colors.blue),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: Colors.lightBlueAccent.withOpacity(0.1),
                      ),
                    ),
                    // Automatically move focus to next input field
                    onCompleted: (pin) {
                      print('Entered PIN: $pin');
                      setState(() {
                        otpController.text = pin;
                      });
                    },
                    onChanged: (value) {
                      // Handle value change if needed
                    },
                    autofocus: true,
                    // Automatically focuses on the first field
                    showCursor: true,
                  ),
                ),
                SizedBox(
                  height: height * 0.050,
                ),
                MyButtons(
                    onTap: () async {
                        if (otpController.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter the OTP");
                      } else {
                        await SignupLoginServices()
                            .verifyOtp(widget.signUpRequestModel.emailId!,
                                otpController.text)
                            .then((onValue) {
                          if (onValue!.message!
                              .toLowerCase()
                              .contains("verified successfully")) {
                            signUp(widget.signUpRequestModel);
                          } else {
                             Fluttertoast.showToast(msg: onValue.message!);
                          }
                        });
                      }
                    },
                    text: "Submit"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
