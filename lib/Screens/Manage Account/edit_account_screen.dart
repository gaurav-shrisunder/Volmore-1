import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:volunterring/Models/request_models/update_Profile_request_model.dart';
import 'package:volunterring/Screens/BottomSheet/user_profile_page.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Services/user_services.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/appbar_widget.dart';
import 'package:volunterring/widgets/button.dart';

import '../../Models/response_models/sign_up_response_model.dart';
import '../../widgets/InputFormFeild.dart';

class EditAccountScreen extends StatefulWidget {
  final User userData;
  const EditAccountScreen(this.userData, {super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController universityController = TextEditingController();
  TextEditingController yearOfGradController = TextEditingController();
  var oldPasswordController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool isLoading = false;

  void setVariables() async {
    User user = await getUser() ?? widget.userData;
    nameController.text = user.userName!;
    emailController.text = user.emailId!;
    if (user.university != null) {
      universityController.text = user.university!;
    }
    if (user.contactNumber != null) {
      phoneController.text = user.contactNumber!;
    }
    print("School ${user.organizationName}");
    if (user.organizationName != null) {
      schoolController.text = user.organizationName!;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setVariables();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      //  backgroundColor: Colors.white,
      appBar: simpleAppBar(context, "Edit Profile"),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFeildWidget(
                title: 'Name',
                controller: nameController,
                hintText: 'Enter your name',
                validator: nameValidator,
              ),
              const SizedBox(
                height: 10,
              ),
              InputFeildWidget(
                title: 'Email',
                isEnabled: false,
                controller: emailController,
                hintText: 'Enter your email address',
                validator: phoneValidator,
              ),
              const SizedBox(
                height: 10,
              ),
              InputFeildWidget(
                title: 'Phone',
                controller: phoneController,
                hintText: 'Enter your phone number',
                validator: phoneValidator,
              ),
              const SizedBox(
                height: 10,
              ),
              InputFeildWidget(
                title: 'School',
                controller: schoolController,
                hintText: 'Enter your School name',
              ),
              const SizedBox(
                height: 10,
              ),
              InputFeildWidget(
                title: 'University',
                controller: universityController,
                hintText: 'Enter your University name',
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(headingBlue)),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return const Center(
                                child: CircularProgressIndicator());
                          });
                      UpdateProfileRequest updateProfile =
                          UpdateProfileRequest();
                      updateProfile.userId = await getUserId();
                      updateProfile.userName = nameController.text.isEmpty
                          ? null
                          : nameController.text;
                      updateProfile.school = schoolController.text.isEmpty
                          ? null
                          : schoolController.text;
                      updateProfile.university =
                          universityController.text.isEmpty
                              ? null
                              : universityController.text;
                      //    updateProfile.yearOfStudy = yearOfGradController.text;
                      updateProfile.contactNumber = phoneController.text.isEmpty
                          ? null
                          : phoneController.text;

                      print('Payload:::: ${jsonEncode(updateProfile)}');

                      await UserServices()
                          .updateUserApi(updateProfile)
                          .then((onValue) {
                        if (onValue.message!.contains("successfully")) {
                          Get.back();
                          Fluttertoast.showToast(
                              msg: "Profile Updated Successfully");
                          setVariables();

                          setState(() {});
                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (_) => const UserProfilePage()));
                        } else {
                          Get.back();
                          Fluttertoast.showToast(
                              msg: "Some Error Try again later",
                              backgroundColor: Colors.red);

                          setState(() {});
                        }
                      });
                      /*   if(oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty){
                        AuthMethod().changePassword(
                            oldPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                            confirmNewPassword: confirmPasswordController.text);
                      }else{
                        Fluttertoast.showToast(msg: "Password fields cannot be empty");

                      }*/
                    },
                    child: const Text(
                      "Apply",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              InputFeildWidget(
                title: 'Old Password',
                controller: oldPasswordController,
                hintText: 'Enter your old password',
              ),
              const SizedBox(
                height: 10,
              ),
              InputFeildWidget(
                title: 'New Password',
                controller: newPasswordController,
                hintText: 'Enter new password here',
              ),
              const SizedBox(
                height: 10,
              ),
              InputFeildWidget(
                title: 'Confirm Password',
                controller: confirmPasswordController,
                hintText: 'Re-enter new password',
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(headingBlue)),
                    onPressed: () async {
                      if (oldPasswordController.text.isNotEmpty &&
                          newPasswordController.text.isNotEmpty &&
                          confirmPasswordController.text.isNotEmpty) {
                        await UserServices()
                            .changePassword(oldPasswordController.text,
                                newPasswordController.text)
                            .then((onValue) {
                          if (onValue.contains("successfully")) {
                            Fluttertoast.showToast(msg: onValue);
                          } else {
                            Fluttertoast.showToast(msg: onValue);
                          }
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg: "Password fields cannot be empty");
                      }
                    },
                    child: const Text(
                      "Change Password",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              /* Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(EditPassword());
                        },
                        child: Container(
                          height: height * 0.05,
                          width: Get.width * 0.6,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 210, 217, 243),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: height * 0.019,
                                  color: headingBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),*/
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red)),
                    onPressed: () {
                      //  Get.to(const EditAccountScreen());

                      showDialog(
                          context: context,
                          builder: (_) {
                            return SimpleDialog(
                              title: const Text(
                                  "Are you sure you want to delete your account?"),
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ActionChip(
                                        label: const Text("No"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }),
                                    /* ElevatedButton(
                                    onPressed: (){
                                  Navigator.pop(context);
                                }, child: Text("No")),*/
                                    ActionChip(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Oops! Something went wrong. Please try after sometime.");
                                        },
                                        label: const Text("Yes"))
                                  ],
                                )
                              ],
                            );
                          });
                    },
                    child: const Text(
                      "Delete Account",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              /*   MyButtons(
              onTap: () {
                AuthMethod().changePassword(
                    oldPassword: oldPasscontroller.text,
                    newPassword: newPasscontroller.text,
                    confirmNewPassword: ConfirmPasscontroller.text);
              },
              text: "Save Changes")*/
            ],
          ),
        ),
      ),
    );
  }
}
