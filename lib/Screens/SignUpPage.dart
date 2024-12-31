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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController gradYearController = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  String selectedCountryCode = '+1'; // Default country code

  final List<String> countryCodes = ['+1', '+91', '+44', '+61', '+81'];
  String? selectedState;

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
      Fluttertoast.showToast(
          msg: "Account created successfully.", toastLength: Toast.LENGTH_LONG);
    } else {
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      // show error
      Fluttertoast.showToast(
          msg: res?.message ?? "Something went wrong!!!",
          toastLength: Toast.LENGTH_LONG);
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
                    const SizedBox(height: 40),
                    Image.asset(
                      "assets/icons/signup.png",
                      height: height * 0.08,
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    const Text(
                      'Create Account ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1,
                          color: headingBlue,
                          letterSpacing: 1.3,
                          fontSize: 24,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: height * 0.007,
                    ),
                    InputFeildWidget(
                      title: 'Name',
                      keyboardType: TextInputType.emailAddress,
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
                      keyboardType: TextInputType.emailAddress,
                      maxlines: 1,
                      hintText: "Enter Your email",

                      validator: emailValidator,
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),

                    Row(
                      children: [
                        // const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: numberController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,

                            decoration: InputDecoration(
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
                              errorText:
                                  _errorMessage, // Display the error message
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
                      height: height * 0.009,
                    ),
                    InputFeildWidget(
                      title: 'Password*',
                      keyboardType: TextInputType.emailAddress,
                      isPassword: true,
                      controller: passwordController,
                      maxlines: 1,
                      hintText: "Enter Your Password",
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    InputFeildWidget(
                      title: 'Re-Enter Password*',
                      keyboardType: TextInputType.emailAddress,
                      controller: confirmPasswordController,
                      maxlines: 1,
                      isPassword: true,
                      hintText: "Re-enter Your Password",
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    Visibility(
                      visible: !isIndividualChecked,
                      child: InputFeildWidget(
                        title: 'High School Graduation Year',
                        keyboardType: TextInputType.number,
                        validator: highSchoolYearValidator,
                        controller: gradYearController,
                        maxlines: 1,
                        hintText: "Enter your graduation year",
                      ),
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
                      child: InputFeildWidget(
                        title: 'High School Name',
                        keyboardType: TextInputType.emailAddress,
                        controller: schoolNameController,
                        maxlines: 1,
                        hintText: "Enter your High School Name",
                      ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
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
                    Visibility(
                      visible: !isIndividualChecked,
                      child: InputFeildWidget(
                        title: 'College/University Name',
                        keyboardType: TextInputType.emailAddress,
                        controller: collegeNameController,
                        maxlines: 1,
                        hintText: "Enter your College/University Name",
                      ),
                    ),
                    Visibility(
                      visible: !isIndividualChecked,
                      child: SizedBox(
                        height: height * 0.009,
                      ),
                    ),
              /*      Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                            value: isIndividualChecked,
                            onChanged: (value) {
                              setState(() {
                                isIndividualChecked = value!;
                              });
                            }),
                        const Text(
                          "Want to sign up as an Individual?",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),*/
                    SizedBox(
                      height: height * 0.009,
                    ),
                    MyButtons(
                        onTap: () {
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            Fluttertoast.showToast(
                                msg:
                                    "Password and Confirm password doesn't match");
                            return;
                          }
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              });
                          SignUpRequestModel signUpRequestBody =
                              SignUpRequestModel();
                          signUpRequestBody.userName = nameController.text;
                          signUpRequestBody.emailId = emailController.text;
                          signUpRequestBody.locationState = selectedState;
                          signUpRequestBody.passwordHash =
                              passwordController.text;
                         /* signUpRequestBody.userRoleId =
                              isIndividualChecked ? "3" : "4";*/
                          if (!isIndividualChecked) {
                            signUpRequestBody.yearOfStudy =
                                int.parse(gradYearController.text);
                            signUpRequestBody.university =
                                collegeNameController.text;
                            signUpRequestBody.school =
                                schoolNameController.text;
                          }
                          signUpRequestBody.contactNumber =
                              selectedCountryCode + numberController.text;
                          signUpRequestBody.sessionId =  "app-${emailController.text.split("@").first}";

                          signUp(signUpRequestBody);
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
        ));
  }
}
