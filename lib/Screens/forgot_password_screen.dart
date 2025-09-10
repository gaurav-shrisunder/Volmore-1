import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Screens/verify_otp_screen.dart';
import '../../Services/signUp_login_services.dart';
import '../../widgets/button.dart';
import '../Utils/app_colors.dart';
import '../widgets/text_input_form_field_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SignupLoginServices signupLoginServices = SignupLoginServices();

  final TextEditingController emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,

        body: SingleChildScrollView(
          child: Column(
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
          
          
                    Center(child: SvgPicture.asset("assets/images/forgot_pwd_image.svg",height: MediaQuery.of(context).size.width/2,)),
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
                    TextInputFieldWidget(
                      title: 'Email*',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
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
          ),
        ));
  }
}
