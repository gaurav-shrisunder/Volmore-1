

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:volunterring/Screens/ResetPasswordScreen.dart';
import 'package:volunterring/Services/signUp_login_services.dart';

import '../Utils/Colors.dart';
import '../widgets/button.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen(this.email,{super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {

  TextEditingController otpController = TextEditingController();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify OTP',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: headingBlue,
                      fontSize: height * 0.035, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: height * 0.010,
                ),

                Text(
                  'An email with OTP has been send to ${widget.email}. Please enter the code to verify your email address',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: headingBlue,
                      fontSize: 14, fontWeight: FontWeight.normal),
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
                    autofocus: true,  // Automatically focuses on the first field
                    showCursor: true,
                  ),
                ),
                SizedBox(
                  height: height * 0.050,
                ),
                MyButtons(onTap: ()async {
                //  Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(widget.email, "")));

                  await SignupLoginServices().verifyOtp(widget.email, otpController.text).then((onValue){
                    if(onValue!.message!.toLowerCase().contains("verified successfully")){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(widget.email)));


                    }else{
                    //  Navigator.push(context, MaterialPageRoute(builder: (_) => Reset(emailController.text)));
                      Fluttertoast.showToast(msg: onValue.message!);
                    }


                  });

                }, text: "Submit"),

              ],

            ),
          )

        ],


      ),
    );
  }
}
