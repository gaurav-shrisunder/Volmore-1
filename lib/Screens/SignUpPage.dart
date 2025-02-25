import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lendavolunterring/Screens/VerifyEmailSignUpScreen.dart';
import '../../Models/request_models/sign_up_request_model.dart';
import '../../Models/response_models/sign_up_response_model.dart';
import '../../Screens/HomePage.dart';
import '../../Screens/LoginPage.dart';
import '../../Screens/dashboard.dart';
import '../../Services/authentication.dart';
import '../../Services/signUp_login_services.dart';
import '../../Utils/Colors.dart';
import '../../widgets/FormFeild.dart';
import '../../widgets/InputFormFeild.dart';
import '../../widgets/button.dart';
import '../../widgets/snackbar.dart';
import 'WebviewScreen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController gradYearController = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  String selectedCountryCode = '+1'; // Default country code

  List<Color> colors = [
    const Color(0xff88d7dc), // Light Airy Blue
    const Color(0xFFFFFFFF), // Pure White
  ];

  int currentIndex = 0;
  late AnimationController _controller;
  late Animation<Offset> _emailSlideAnimation;

  late Animation<double> _opacityAnimation;



  final List<String> countryCodes = ['+1', '+91', '+44', '+61', '+81'];
  String? selectedState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _emailSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5), // Slide up
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));


    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);


    Timer(const Duration(milliseconds: 300), () {
      _controller.forward();
    });

  }

  // List of all US states with their abbreviations
  final List<Map<String, String>> states = [
    {"name": "Alabama", "abbreviation": "AL"},
    {"name": "Alaska", "abbreviation": "AK"},
    {"name": "Arizona", "abbreviation": "AZ"},
    {"name": "Arkansas", "abbreviation": "AR"},
    {"name": "California", "abbreviation": "CA"},
    {"name": "Colorado", "abbreviation": "CO"},
    {"name": "Connecticut", "abbreviation": "CT"},
    {"name": "Delaware", "abbreviation": "DE"},
    {"name": "Florida", "abbreviation": "FL"},
    {"name": "Georgia", "abbreviation": "GA"},
    {"name": "Hawaii", "abbreviation": "HI"},
    {"name": "Idaho", "abbreviation": "ID"},
    {"name": "Illinois", "abbreviation": "IL"},
    {"name": "Indiana", "abbreviation": "IN"},
    {"name": "Iowa", "abbreviation": "IA"},
    {"name": "Kansas", "abbreviation": "KS"},
    {"name": "Kentucky", "abbreviation": "KY"},
    {"name": "Louisiana", "abbreviation": "LA"},
    {"name": "Maine", "abbreviation": "ME"},
    {"name": "Maryland", "abbreviation": "MD"},
    {"name": "Massachusetts", "abbreviation": "MA"},
    {"name": "Michigan", "abbreviation": "MI"},
    {"name": "Minnesota", "abbreviation": "MN"},
    {"name": "Mississippi", "abbreviation": "MS"},
    {"name": "Missouri", "abbreviation": "MO"},
    {"name": "Montana", "abbreviation": "MT"},
    {"name": "Nebraska", "abbreviation": "NE"},
    {"name": "Nevada", "abbreviation": "NV"},
    {"name": "New Hampshire", "abbreviation": "NH"},
    {"name": "New Jersey", "abbreviation": "NJ"},
    {"name": "New Mexico", "abbreviation": "NM"},
    {"name": "New York", "abbreviation": "NY"},
    {"name": "North Carolina", "abbreviation": "NC"},
    {"name": "North Dakota", "abbreviation": "ND"},
    {"name": "Ohio", "abbreviation": "OH"},
    {"name": "Oklahoma", "abbreviation": "OK"},
    {"name": "Oregon", "abbreviation": "OR"},
    {"name": "Pennsylvania", "abbreviation": "PA"},
    {"name": "Rhode Island", "abbreviation": "RI"},
    {"name": "South Carolina", "abbreviation": "SC"},
    {"name": "South Dakota", "abbreviation": "SD"},
    {"name": "Tennessee", "abbreviation": "TN"},
    {"name": "Texas", "abbreviation": "TX"},
    {"name": "Utah", "abbreviation": "UT"},
    {"name": "Vermont", "abbreviation": "VT"},
    {"name": "Virginia", "abbreviation": "VA"},
    {"name": "Washington", "abbreviation": "WA"},
    {"name": "West Virginia", "abbreviation": "WV"},
    {"name": "Wisconsin", "abbreviation": "WI"},
    {"name": "Wyoming", "abbreviation": "WY"}
  ];

  bool isLoading = false;
  String? _errorMessage;
  bool isIndividualChecked = false;
  bool isTermsAgreed = false;

  void _validateInput() {
    final error = phoneValidator(numberController.text);
    setState(() {
      _errorMessage = error;
    });
  }

  void _validateEmailInput() {
    final error = emailValidator(emailController.text);
    setState(() {
      _errorMessage = error;
    });
  }

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

          child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors[currentIndex],
                    colors[(currentIndex + 1) % colors.length],
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            child: SingleChildScrollView(

              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _opacityAnimation, child:  Image.asset(
                        "assets/icons/signup.png",
                        height: height * 0.08,
                      )),
                      SizedBox(
                        height: height * 0.01,
                      ),
                       FadeTransition(
                          opacity: _opacityAnimation,
                          child: const Text(
                        'Create Account ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1,
                            color: headingBlue,
                            letterSpacing: 1.3,
                            fontSize: 24,
                            fontWeight: FontWeight.w500),
                      )),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: height * 0.007,
                      ),
                      SlideTransition(
                          position: _emailSlideAnimation,
                    child:  InputFeildWidget(
                        title: 'Name',
                        keyboardType: TextInputType.emailAddress,
                        controller: nameController,
                        maxlines: 1,
                        hintText: "Enter Your name",
                      )),
                      SizedBox(
                        height: height * 0.009,
                      ),
                      SlideTransition(
                          position: _emailSlideAnimation,
                    child:   InputFeildWidget(
                        title: 'Email*',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        maxlines: 1,
                        hintText: "Enter Your email",
                        validator: emailValidator,
                      )),
                      SizedBox(
                        height: height * 0.009,
                      ),
                      SlideTransition(
                          position: _emailSlideAnimation,
                          child:   InputFeildWidget(
                            title: 'Mobile Number*',
                            controller: numberController,
                            keyboardType: TextInputType.phone,
                            maxlines: 1,
                            hintText: "Enter Your email",
                            validator: phoneValidator,
                          )),
                 /* SlideTransition(
                    position: _emailSlideAnimation,
                    child:   Row(
                        children: [
                          // const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: numberController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,

                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                  focusColor: Colors.white,

                                counter: const SizedBox(),
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
                                errorText: _errorMessage,
                                // Display the error message
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
                      )),*/
                      /* InputFeildWidget(
                        title: 'Phone number*',
                        controller: numberController,
                        maxlines: 1,
                        hintText: "Enter Your phone number",
                      ),*/
                      SizedBox(
                        height: height * 0.009,
                      ),
                  SlideTransition(
                    position: _emailSlideAnimation,
                     child:  InputFeildWidget(
                        title: 'Password*',
                        keyboardType: TextInputType.emailAddress,
                        isPassword: true,
                        controller: passwordController,
                        maxlines: 1,
                        hintText: "Enter Your Password",
                      )),
                      SizedBox(
                        height: height * 0.009,
                      ),
                  SlideTransition(
                    position: _emailSlideAnimation,
                     child:  InputFeildWidget(
                        title: 'Re-Enter Password*',
                        keyboardType: TextInputType.emailAddress,
                        controller: confirmPasswordController,
                        maxlines: 1,
                        isPassword: true,
                        hintText: "Re-enter Your Password",
                      )),
                      SizedBox(
                        height: height * 0.009,
                      ),
                      Visibility(
                        visible: !isIndividualChecked,
                        child:
                        SlideTransition(
                          position: _emailSlideAnimation,
                      child:   InputFeildWidget(
                          title: 'High School Graduation Year',
                          keyboardType: TextInputType.number,
                          validator: highSchoolYearValidator,
                          controller: gradYearController,
                          maxlines: 1,
                          hintText: "Enter your graduation year",
                        )),
                      ),
                      /*     Visibility(
                        visible: !isIndividualChecked,
                        child: SizedBox(
                          height: height * 0.009,
                        ),
                      ),*/

                      SizedBox(
                        height: height * 0.009,
                      ),
                      Visibility(
                        visible: !isIndividualChecked,
                        child:
                        SlideTransition(
                          position: _emailSlideAnimation,
                      child:   InputFeildWidget(
                          title: 'High School Name',
                          keyboardType: TextInputType.emailAddress,
                          controller: schoolNameController,
                          maxlines: 1,
                          hintText: "Enter your High School Name",
                        )),
                      ),
                      SizedBox(
                        height: height * 0.009,
                      ),
                      /*   Visibility(
                        visible: !isIndividualChecked,
                        child: SizedBox(
                          height: height * 0.009,
                        ),
                      ),*/
                  SlideTransition(
                    position: _emailSlideAnimation,
                     child:  Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            value: selectedState,
                            hint: const Text('Select a state'),
                            isExpanded: true,
                            items: states.map((Map<String, String> state) {
                              return DropdownMenuItem<String>(
                                value: state['name'],
                                child: Text(
                                    '${state['name']} (${state['abbreviation']})'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedState = newValue;
                              });
                              if (newValue != null) {}
                            },
                          ),
                        ),
                      )),
                      SizedBox(
                        height: height * 0.009,
                      ),
                      /*   Visibility(
                        visible: !isIndividualChecked,
                        child: SizedBox(
                          height: height * 0.009,
                        ),
                      ),*/
                      Visibility(
                        visible: !isIndividualChecked,
                        child:
                        SlideTransition(
                          position: _emailSlideAnimation,
                      child:   InputFeildWidget(
                          title: 'College/University Name',
                          keyboardType: TextInputType.emailAddress,
                          controller: collegeNameController,
                          maxlines: 1,
                          hintText: "Enter your College/University Name",
                        )),
                      ),
                      Visibility(
                        visible: !isIndividualChecked,
                        child: SizedBox(
                          height: height * 0.009,
                        ),
                      ),

                  SlideTransition(
                    position: _emailSlideAnimation,
                     child:  Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                              value: isTermsAgreed,
                              onChanged: (value) {
                                setState(() {
                                  isTermsAgreed = value!;
                                });
                              }),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "I agree to the ",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const WebViewScreen(
                                              'https://www.lendavolunteering.com/terms-and-condition'),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Terms & Conditions ",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.blueAccent),
                                    ),
                                  ),
                                  const Text(
                                    "&",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),

                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const WebViewScreen(
                                              'https://www.lendavolunteering.com/privacy-policy'),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.blueAccent),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      )),
                      SizedBox(
                        height: height * 0.009,
                      ),
                      MyButtons(
                          onTap: () async {
                            if (isTermsAgreed) {
                              print('State: $selectedState');

                              if (nameController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Name cannot be empty");
                              } else if (emailController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Email cannot be empty");
                              } else if (passwordController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Password cannot be empty");
                              } else if (confirmPasswordController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Confirm password cannot be empty");
                              } else if (numberController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Contact number cannot be empty");
                              } else if (gradYearController.text.isEmpty && !isIndividualChecked) {
                                Fluttertoast.showToast(msg: "Graduation year cannot be empty");
                              } else if (schoolNameController.text.isEmpty && !isIndividualChecked) {
                                Fluttertoast.showToast(msg: "School name cannot be empty");
                              } else if (selectedState == null) {
                                Fluttertoast.showToast(msg: "State must be selected");
                              } else if (passwordController.text != confirmPasswordController.text) {
                                Fluttertoast.showToast(
                                    msg: "Password and Confirm password don't match");
                              } else {
                                // All fields are valid
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) {
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                );
                                SignUpRequestModel signUpRequestBody = SignUpRequestModel();
                                signUpRequestBody.userName = nameController.text;
                                signUpRequestBody.emailId = emailController.text;
                                signUpRequestBody.locationState = selectedState;
                                signUpRequestBody.passwordHash = passwordController.text;

                                if (!isIndividualChecked) {
                                  signUpRequestBody.yearOfStudy = int.parse(gradYearController.text);
                                  signUpRequestBody.university = collegeNameController.text.isEmpty ? null : collegeNameController.text;
                                  signUpRequestBody.school = schoolNameController.text;
                                }

                                signUpRequestBody.contactNumber =
                                    selectedCountryCode + numberController.text;
                                signUpRequestBody.sessionId =
                                "app-${emailController.text.split("@").first}";
                                signUp(signUpRequestBody);
                              }
                            } else {
                              Fluttertoast.showToast(msg: "Please agree to the Terms & Conditions");
                            }

                            /*  if (isTermsAgreed) {
                              if (nameController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Name cannot be empty");
                              } else if (emailController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Email cannot be empty");
                              } else if (passwordController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Password cannot be empty");
                              } else if (confirmPasswordController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Confirm password cannot be empty");
                              } else if (numberController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Contact number cannot be empty");
                              } else if (gradYearController.text.isEmpty && !isIndividualChecked) {
                                Fluttertoast.showToast(msg: "Graduation year cannot be empty");
                              } else if (schoolNameController.text.isEmpty && !isIndividualChecked) {
                                Fluttertoast.showToast(msg: "School name cannot be empty");
                              } else if (selectedState == null) {
                                Fluttertoast.showToast(msg: "State must be selected");
                              } else if (passwordController.text != confirmPasswordController.text) {
                                Fluttertoast.showToast(
                                    msg: "Password and Confirm password don't match");
                              } else {
                                // All fields are valid
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) {
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                );
                                SignUpRequestModel signUpRequestBody = SignUpRequestModel();
                                signUpRequestBody.userName = nameController.text;
                                signUpRequestBody.emailId = emailController.text;
                                signUpRequestBody.locationState = selectedState;
                                signUpRequestBody.passwordHash = passwordController.text;

                                if (!isIndividualChecked) {
                                  signUpRequestBody.yearOfStudy = int.parse(gradYearController.text);
                                  signUpRequestBody.university = collegeNameController.text.isEmpty ? null : collegeNameController.text;
                                  signUpRequestBody.school = schoolNameController.text;
                                }

                                signUpRequestBody.contactNumber =
                                    selectedCountryCode + numberController.text;
                                signUpRequestBody.sessionId = "app-${emailController.text.split("@").first}";

                              //  signUp(signUpRequestBody);

                            *//*    await SignupLoginServices().sendOtp(emailController.text).then((onValue){
                                  if(onValue!.message!.toLowerCase().contains("Failed to process request")){
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(msg: onValue.message!);
                                  }else{
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VerifyEmailSignUpScreen(signUpRequestBody)));
                                    }
                                });*//*

                              }
                            } else {
                              Fluttertoast.showToast(msg: "Please agree to the Terms & Conditions");
                            }*/
                          },
                          text: "Sign Up"),
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
                              const Text(
                                ' Existing User?',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.normal),
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
          ),
        ));
  }
}
