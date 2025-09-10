import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lendavolunterring/Screens/dashboard_screen.dart';

import '../../Models/request_models/update_profile_request_model.dart';
import '../../Models/response_models/sign_up_response_model.dart';

import '../../Services/user_services.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/shared_prefs.dart';
import '../../widgets/text_input_form_field_widget.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/profile_image_widget.dart';
import '../login_screen.dart';

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
    print("School ${user.school}");
    if (user.school != null) {
      schoolController.text = user.school!;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setVariables();
    Future.delayed(const Duration(seconds: 1));
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
              const Center(
                child: ProfileImageWidget(),
              ),
              const SizedBox(
                height: 15,
              ),
              ExpansionTile(
                title: const Text("Update Profile"),
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: Colors.grey[200]!)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: Colors.grey[200]!)),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputFieldWidget(
                    title: 'Name',
                    controller: nameController,
                    hintText: 'Enter your name',
                    validator: nameValidator,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputFieldWidget(
                    title: 'Email',
                    isEnabled: false,
                    controller: emailController,
                    hintText: 'Enter your email address',
                    validator: phoneValidator,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputFieldWidget(
                    title: 'Phone',
                    controller: phoneController,
                    hintText: 'Enter your phone number',
                    validator: phoneValidator,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputFieldWidget(
                    title: 'School',
                    controller: schoolController,
                    hintText: 'Enter your School name',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputFieldWidget(
                    title: 'University',
                    controller: universityController,
                    hintText: 'Enter your University name',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(headingBlue)),
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
                              updateProfile.userName =
                                  nameController.text.isEmpty
                                      ? null
                                      : nameController.text;
                              updateProfile.school =
                                  schoolController.text.isEmpty
                                      ? null
                                      : schoolController.text;
                              updateProfile.university =
                                  universityController.text.isEmpty
                                      ? null
                                      : universityController.text;
                              //    updateProfile.yearOfStudy = yearOfGradController.text;
                              updateProfile.contactNumber =
                                  phoneController.text.isEmpty
                                      ? null
                                      : phoneController.text;

                              if (kDebugMode) {
                                print('Payload:::: ${jsonEncode(updateProfile)}');
                              }

                              await UserServices()
                                  .updateUserApi(updateProfile)
                                  .then((onValue) {
                                if (onValue.message!.contains("successfully")) {
                                  Get.back();
                                  Fluttertoast.showToast(
                                      msg: "Profile Updated Successfully");
                                  setVariables();
                                  Get.to(const DashboardScreen());

                                  setState(() {});
                                } else {
                                  Get.back();
                                  Fluttertoast.showToast(
                                      msg: "Some Error Try again later",
                                      backgroundColor: Colors.red);

                                  setState(() {});
                                }
                              });
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ExpansionTile(
                title: const Text("Change Password"),
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: Colors.grey[200]!)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: Colors.grey[200]!)),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputFieldWidget(
                    title: 'Old Password',
                    controller: oldPasswordController,
                    hintText: 'Enter your old password',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputFieldWidget(
                    title: 'New Password',
                    controller: newPasswordController,
                    hintText: 'Enter new password here',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputFieldWidget(
                    title: 'Confirm Password',
                    controller: confirmPasswordController,
                    hintText: 'Re-enter new password',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 15),
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(headingBlue)),
                            onPressed: () async {
                              if (newPasswordController.text !=
                                  confirmPasswordController.text) {
                                Fluttertoast.showToast(
                                    msg:
                                        "New Passwords and Confirm Password does not match",
                                    backgroundColor: Colors.red,
                                    gravity: ToastGravity.TOP);
                                return;
                              }
                              if (oldPasswordController.text.isNotEmpty &&
                                  newPasswordController.text.isNotEmpty &&
                                  confirmPasswordController.text.isNotEmpty) {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    });
                                await UserServices()
                                    .changePassword(oldPasswordController.text,
                                        newPasswordController.text)
                                    .then((onValue) {
                                  Get.back();
                                  if (onValue.contains("successfully")) {
                                    Fluttertoast.showToast(
                                        msg: onValue,
                                        backgroundColor: Colors.green,
                                        gravity: ToastGravity.TOP);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: onValue,
                                        backgroundColor: Colors.red,
                                        gravity: ToastGravity.TOP);
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
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red)),
                    onPressed: () {
                      //  Get.to(const EditAccountScreen());

                      showDialog(
                          context: context,
                          builder: (_) {
                            return SimpleDialog(
                              title: const Text(
                                "Are you sure you want to delete your account? \nDeleting your account is permanent and will result in the loss of access to your account, along with all associated data, including user details and events. This action cannot be undone.",
                                style: TextStyle(fontSize: 14),
                              ),
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
                                        onPressed: () async {
                                          await UserServices()
                                              .deleteUser()
                                              .then((onValue) {
                                            if (onValue.toString().contains(
                                                "permanently deleted successfully")) {
                                              Fluttertoast.showToast(
                                                  msg: onValue.toString(),
                                                  toastLength:
                                                      Toast.LENGTH_LONG);
                                              clearPreferences();
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen()),
                                                (Route<dynamic> route) =>
                                                    false, // This condition makes sure all the routes are removed.
                                              );
                                            }
                                          });
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
            ],
          ),
        ),
      ),
    );
  }
}
