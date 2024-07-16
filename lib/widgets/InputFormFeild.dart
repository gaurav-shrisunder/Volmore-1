import 'package:flutter/material.dart';

import 'package:volunterring/Utils/Colors.dart';

class InputFeildWidget extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final int maxlines;
   const InputFeildWidget(
      {super.key, required this.title, required this.controller,this.maxlines=1});

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
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4484D2)),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          cursorHeight: 25,
          controller: widget.controller,
          maxLines: widget.maxlines,
          decoration: InputDecoration(
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            fillColor: lightBlue,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
          ),
        )
      ],
    );
  }
}
