import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:volunterring/Models/request_models/sign_up_request_model.dart';
import 'package:volunterring/Models/response_models/sign_up_response_model.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Screens/LoginPage.dart';
import 'package:volunterring/Screens/dashboard.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Services/signUp_login_services.dart';
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
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController gradYearController = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  String selectedCountryCode = '+1'; // Default country code

  final List<String> countryCodes = ['+1', '+91', '+44', '+61', '+81'];

  bool isLoading = false;
  String? _errorMessage;
  bool isIndividualChecked = false;

  void _validateInput() {
    final error = phoneValidator(numberController.text);
    setState(() {
      _errorMessage = error;
    });
  }

  void signUp(SignUpRequestModel requestBody) async {
    setState(() {
      isLoading = true;
    });

    // signup user using our authmethod
    // String res = await AuthMethod().signupUser(
    //     email: emailController.text,
    //     password: passwordController.text,
    //     confirmPassword: confirmPasswordController.text,
    //     name: nameController.text,
    //     phone: numberController.text);

    SignupLoginServices signupServices = SignupLoginServices();
  SignUpLoginResponseModel? res = await signupServices.signUpUser(requestBody);

    if (res?.data?.user != null) {
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
      Fluttertoast.showToast(msg: res?.message ?? "Something went wrong!!!", toastLength: Toast.LENGTH_LONG);
      //   showSnackBar(context, res);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();

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
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: Colors.grey[300]!)),
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            underline: Container(),
                            borderRadius: BorderRadius.circular(9),
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            value: selectedCountryCode,
                            items: countryCodes.map((String code) {
                              return DropdownMenuItem<String>(
                                value: code,
                                child: Text(code),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCountryCode = newValue!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: numberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9.0),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9.0),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9.0),
                                borderSide: BorderSide(
                                  color: Colors.blue[200]!,
                                ),
                              ),
                              errorText: _errorMessage, // Display the error message
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.red[400]!,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              _validateInput();
                            },

                            // validator: phoneValidator,
                          ),
                        ),
                      ],
                    ),
                   /* InputFeildWidget(
                      title: 'Phone number*',
                      controller: numberController,
                      maxlines: 1,
                      hintText: "Enter Your phone number",
                    ),*/
                    SizedBox(
                      height: height  * 0.009,
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
                      controller: confirmPasswordController,
                      maxlines: 1,
                      hintText: "Re-enter Your Password",
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),

                    Visibility(
                      visible: !isIndividualChecked,
                      child: InputFeildWidget(
                        title: 'Graduation Year',
                        controller: gradYearController,
                        maxlines: 1,
                        hintText: "Enter your graduation year",
                      ),
                    ),
                    Visibility(
                      visible: !isIndividualChecked,
                      child: SizedBox(
                        height: height * 0.009,
                      ),
                    ),
                    Visibility(
                      visible: !isIndividualChecked,
                      child: InputFeildWidget(
                        title: 'College/University/Organisation Name',
                        controller: collegeNameController,
                        maxlines: 1,
                        hintText: "Enter your graduation year",
                      ),
                    ),
                    Visibility(
                      visible: !isIndividualChecked,
                      child: SizedBox(
                        height: height * 0.009,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(value: isIndividualChecked, onChanged: (value){
                          setState(() {
                            isIndividualChecked = value!;
                          });
                        }),
                        const Text("Want to sign up as an Individual?", style: TextStyle(fontSize: 16,),)

                      ],
                    ),

                    SizedBox(
                      height: height * 0.009,
                    ),

                    MyButtons(onTap: (){
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_){
                            return const Center(child: CircularProgressIndicator());
                          });
                      SignUpRequestModel signUpRequestBody = SignUpRequestModel();
                      signUpRequestBody.userName = nameController.text;
                      signUpRequestBody.emailId = emailController.text;
                      signUpRequestBody.passwordHash = passwordController.text;
                      signUpRequestBody.userRoleId = isIndividualChecked ? "3" : "4";
                      if(!isIndividualChecked){
                        signUpRequestBody.yearOfStudy = int.parse(gradYearController.text);
                        signUpRequestBody.organization?.name = collegeNameController.text;
                      }
                      signUpRequestBody.contactNumber = selectedCountryCode+numberController.text;

                      signUp(signUpRequestBody);
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
