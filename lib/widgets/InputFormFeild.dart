import 'package:flutter/material.dart';
import 'package:volunterring/Utils/Colors.dart';

class InputFeildWidget extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final int maxlines;
  final String hintText;
  final String? errorText;
  final Icon? prefixicon;
  final bool? isEnabled;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const InputFeildWidget({
    super.key,
    required this.title,
    required this.controller,
    this.hintText = '',
    this.prefixicon,
    this.isEnabled,
    this.errorText,
    this.isPassword = false,
    this.maxlines = 1,
    this.keyboardType = TextInputType.name,
    this.validator,
  });

  @override
  State<InputFeildWidget> createState() => _InputFeildWidgetState();
}

class _InputFeildWidgetState extends State<InputFeildWidget> {
  String? _errorMessage;

  void _validateInput() {
    final error = widget.validator?.call(widget.controller.text);
    setState(() {
      _errorMessage = error;
    });
  }

  bool isObsecure = false;
  void togglePassword() {
    setState(() {
      isObsecure = !isObsecure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          textCapitalization: TextCapitalization.words,
          enabled: widget.isEnabled,
          controller: widget.controller,
          maxLines: widget.maxlines,
          keyboardType:widget.keyboardType,
          obscureText: widget.isPassword && !isObsecure,
          decoration: InputDecoration(
            filled: true,
            labelText: widget.title,
            hintText: widget.hintText,
            hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            //  fillColor: Colors.white,
            prefixIcon: widget.prefixicon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 213, 215, 215),
                width: 1.0,
              ),
            ),

            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: isObsecure
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    onPressed: () {
                      togglePassword();
                    },
                  )
                : const SizedBox(),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 213, 215, 215),
                width: 1.0,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey[400]!,
                width: 2.0,
              ),
            ),
            errorText: _errorMessage, // Display the error message
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 2.0,
              ),
            ),
          ),
          onChanged: (value) {
            _validateInput(); // Validate input on change
          },
        ),
      ],
    );
  }
}

// Example Validators
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email cannot be empty';
  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? nameValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name cannot be empty';
  } else if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value.trim())) {
    return 'Enter a valid name (letters, numbers, and spaces only)';
  }
  return null;
}

String? highSchoolYearValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Year cannot be empty';
  }

  // Check if it is a 4-digit number
  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
    return 'Enter a valid 4-digit year';
  }

  // Parse the year as an integer
  int year = int.parse(value);

  // Check year range
  int currentYear = DateTime.now().year;
  if (year < 1975) {
    return 'Year cannot be earlier than 1975';
  } else if (year > currentYear) {
    return 'Year cannot be later than $currentYear';
  }

  return null; // No error
}


String? phoneValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number cannot be empty';
  } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
    return 'Enter a valid 10-digit phone number';
  }
  return null;
}
