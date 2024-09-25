import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/appbar_widget.dart';
import 'package:volunterring/widgets/button.dart';

import '../../widgets/InputFormFeild.dart';

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
              InputFeildWidget(
                title: 'Phone',
                controller: phoneController,
                hintText: 'Enter your phone number',
                validator: phoneValidator,
              ),
              InputFeildWidget(
                title: 'Old Password',
                controller: oldPasswordController,
                hintText: 'Enter your old password',
              ),
              InputFeildWidget(
                title: 'New Password',
                controller: newPasswordController,
                hintText: 'Enter new password here',

              ),  InputFeildWidget(
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
                    onPressed: () {
                      if(oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty){
                        AuthMethod().changePassword(
                            oldPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                            confirmNewPassword: confirmPasswordController.text);
                      }else{
                        Fluttertoast.showToast(msg: "Password fields cannot be empty");

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

                      showDialog(context: context, builder: (_){
                        return SimpleDialog(
                          title: Text("Are you sure you want to delete your account?"),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ActionChip(label:  Text("No"),onPressed: (){
                                  Navigator.pop(context);
                                }),
                               /* ElevatedButton(
                                    onPressed: (){
                                  Navigator.pop(context);
                                }, child: Text("No")),*/
                                ActionChip(onPressed: (){
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(msg: "Oops! Something went wrong. Please try after sometime.");

                                }, label: Text("Yes"))
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
