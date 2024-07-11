import 'package:flutter/material.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/FormFeild.dart';
import 'package:volunterring/widgets/button.dart';

class AccountDeletion extends StatefulWidget {
  const AccountDeletion({super.key});

  @override
  State<AccountDeletion> createState() => _AccountDeletionState();
}

class _AccountDeletionState extends State<AccountDeletion> {
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
              'Delete Account',
              style: TextStyle(
                fontSize: height * 0.035,
                color: headingBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.02),
            TextFieldInput(
              textEditingController: oldPasscontroller,
              label: ' Password',
              hintText: ' Password',
              textInputType: TextInputType.text,
            ),
            TextFieldInput(
              textEditingController: newPasscontroller,
              label: 'Confirm Password',
              hintText: 'Confirm Password',
              textInputType: TextInputType.text,
            ),
            MyButtons(onTap: () {}, text: "Delete Account")
          ],
        )),
      ),
    );
  }
}
