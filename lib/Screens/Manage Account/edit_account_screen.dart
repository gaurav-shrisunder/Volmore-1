import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/appbar_widget.dart';
import 'package:volunterring/widgets/button.dart';

class EditAccountScreen extends StatefulWidget {
  final String name;
  final String phone;
  const EditAccountScreen(this.name, this.phone, {super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  var oldPasswordController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = widget.name;
    phoneController.text = widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: simpleAppBar(context, "Edit Profile"),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFieldInput(
                textEditingController: nameController,
                label: 'Name',
                hintText: 'Enter your name here',
                textInputType: TextInputType.name,
              ),
              TextFieldInput(
                textEditingController: phoneController,
                label: 'Phone',
                hintText: 'Enter your phone number',
                textInputType: TextInputType.phone,
              ),
              TextFieldInput(
                textEditingController: oldPasswordController,
                label: 'Old Password*',
                hintText: 'Enter old password here',
                textInputType: TextInputType.text,
              ),
              TextFieldInput(
                textEditingController: newPasswordController,
                label: 'New Password*',
                hintText: 'Enter new password here',
                textInputType: TextInputType.text,
              ),
              TextFieldInput(
                textEditingController: confirmPasswordController,
                label: 'Confirm Password*',
                hintText: 'Re-enter new password',
                textInputType: TextInputType.text,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(headingBlue)),
                    onPressed: () {
                      AuthMethod().changePassword(
                          oldPassword: oldPasswordController.text,
                          newPassword: newPasswordController.text,
                          confirmNewPassword: confirmPasswordController.text);
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
