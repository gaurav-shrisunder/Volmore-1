import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/button.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Forgot \nPassword',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: height * 0.065, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: height * 0.015,
              ),
              SizedBox(
                height: height * 0.02,
              ),
              TextFieldInput(
                  textEditingController: emailController,
                  label: "Email",
                  hintText: 'Enter your email',
                  textInputType: TextInputType.text),
              SizedBox(
                height: height * 0.015,
              ),
              MyButtons(onTap: () => _resetPassword, text: "Send Email"),
              SizedBox(
                height: height * 0.01,
              ),
            ],
          ),
        ));
  }
}
