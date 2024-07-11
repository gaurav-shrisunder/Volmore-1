import 'package:flutter/material.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/button.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  var oldPasscontroller = TextEditingController();
  var newPasscontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Center(
            child: Column(
          children: [
            Text(
              'Edit Password',
              style: TextStyle(
                fontSize: height * 0.035,
                color: headingBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.02),
            TextFieldInput(
              textEditingController: oldPasscontroller,
              label: 'Old Password',
              hintText: 'Old Password',
              textInputType: TextInputType.text,
            ),
            TextFieldInput(
              textEditingController: newPasscontroller,
              label: 'New Password',
              hintText: 'New Password',
              textInputType: TextInputType.text,
            ),
            MyButtons(onTap: () {}, text: "Save Changes")
          ],
        )),
      ),
    );
  }
}
