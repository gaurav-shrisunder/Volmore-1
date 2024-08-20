import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Services/logService.dart';
import 'package:volunterring/Utils/Colormap.dart';
import 'package:volunterring/Utils/Colors.dart';

import '../../widgets/InputFormFeild.dart';

class PastEventVerification extends StatefulWidget {
  final EventDataModel event;
  final DateTime date;
  const PastEventVerification(
      {super.key, required this.event, required this.date});

  @override
  State<PastEventVerification> createState() => _PastEventVerificationState();
}

class _PastEventVerificationState extends State<PastEventVerification> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final logMethods = LogServices();

  String? _errorMessage;

  void _validateInput() {
    final error = phoneValidator(_phoneNumberController.text);
    setState(() {
      _errorMessage = error;
    });
  }

  Future<String> _exportSignatureAsString() async {
    final Uint8List? data = await _signatureController.toPngBytes();
    if (data != null) {
      return base64Encode(data);
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSameDate(DateTime date1, DateTime date2) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    }

    String? getLogIdForDate(EventDataModel event, DateTime date) {
      for (LogModel log in event.logs ?? []) {
        print(log.date.toDate());
        print(date.toIso8601String());
        if (log.date != null && isSameDate(log.date.toDate(), date)) {
          return log.logId;
        }
      }
      return null;
    }

    LogModel? getLogForDate(EventDataModel event, DateTime date) {
      for (LogModel log in event.logs ?? []) {
        print(log.date.toDate());
        print(date.toIso8601String());
        if (log.date != null && isSameDate(log.date.toDate(), date)) {
          return log;
        }
      }
      return null;
    }

    Color color = colorMap[widget.event.groupColor] ?? Colors.pink;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String selectedCountryCode = '+1'; // Default country code
    LogModel? log = getLogForDate(widget.event, widget.date);

    final List<String> countryCodes = ['+1', '+91', '+44', '+61', '+81'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Volunteer Confirmation",
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: headingBlue),
        ),
        automaticallyImplyLeading: false,
        // elevation: 4,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: Container(
            color: Colors.grey[200],
            height: 3.0,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomePage()));
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.amber[900]),
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.title.toString().capitalize ?? "",
                style: TextStyle(fontSize: 24, color: color),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                DateFormat.yMMMMEEEEd().format(widget.event.date),
                style: const TextStyle(fontSize: 16, color: greyColor),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                widget.event.description ?? "",
                style: const TextStyle(fontSize: 16, color: greyColor),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                "Duration :- ${log?.elapsedTime}" ?? "",
                style: const TextStyle(fontSize: 16, color: greyColor),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                "Start Time :- ${DateFormat('hh:mm a').format(log!.startTime.toDate())}" ??
                    "",
                style: const TextStyle(fontSize: 16, color: greyColor),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                "End Time :- ${DateFormat('hh:mm a').format(log.endTime.toDate())}" ??
                    "",
                style: const TextStyle(fontSize: 16, color: greyColor),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              const Text(
                "Signature",
                style: TextStyle(fontSize: 18, color: headingBlue),
              ),
              SizedBox(
                height: screenHeight * 0.007,
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(9)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Signature(
                    controller: _signatureController,
                    height: screenHeight * 0.2,
                    backgroundColor: Colors.grey[200]!,
                    dynamicPressureSupported: true,
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              const Text(
                "Volunteer Seeker's Phone Number",
                style: TextStyle(fontSize: 18, color: headingBlue),
              ),
              SizedBox(
                height: screenHeight * 0.007,
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.grey[300]!)),
                    child: DropdownButton<String>(
                      underline: Container(),
                      borderRadius: BorderRadius.circular(9),
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      value: selectedCountryCode,
                      items: countryCodes.map((String code) {
                        return DropdownMenuItem<String>(
                          value: code,
                          child: Text(code),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCountryCode = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
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
                        errorText: _errorMessage, // Display the error message
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
              SizedBox(
                height: screenHeight * 0.03,
              ),
              GestureDetector(
                onTap: () async {
                  String signatureString = await _exportSignatureAsString();

                  // Handle empty signature case
                  if (signatureString.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please provide your signature.')),
                    );
                    return;
                  }
                  print(getLogIdForDate(widget.event, widget.date));
                  print(widget.event.logs![0].logId);
                  logMethods.updateSignatureInFirebase(
                      getLogIdForDate(widget.event, widget.date) ?? "",
                      signatureString,
                      widget.event.id!);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.lightBlue[500],
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                      child: Text(
                    "Submit Event",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              )
            ]),
      )),
    );
  }
}
