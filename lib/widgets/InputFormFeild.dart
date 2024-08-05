import 'package:flutter/material.dart';
import 'package:volunterring/Utils/Colors.dart';

class InputFeildWidget extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final int maxlines;
  final String hintText;
  final Icon? prefixicon;
  bool isPassword;
  InputFeildWidget(
      {super.key,
      required this.title,
      required this.controller,
      this.hintText = '',
      this.prefixicon,
      this.isPassword = false,
      this.maxlines = 1});

  @override
  State<InputFeildWidget> createState() => _InputFeildWidgetState();
}

class _InputFeildWidgetState extends State<InputFeildWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: headingBlue,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0.2,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            maxLines: widget.maxlines,
            obscureText: widget.isPassword,
            decoration: InputDecoration(
              filled: true,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              fillColor: Colors.white,
              prefixIcon:  widget.prefixicon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 213, 215, 215),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:  BorderSide(
                  color: Colors.grey[
                  400]!, // Change this to your desired color
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
