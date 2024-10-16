import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Models/request_models/log_current_event_request_model.dart';
import 'package:volunterring/Screens/Event/events_widget.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Services/events_services.dart';
import 'package:volunterring/Utils/Colormap.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/provider/time_logger_provider.dart';
import 'package:volunterring/widgets/InputFormFeild.dart';

import '../../Models/response_models/events_data_response_model.dart';
import '../../Services/logService.dart';
import '../../Utils/common_utils.dart';

class VolunteerConfirmationScreen extends StatefulWidget {
 // final EventDataModel event;
  final Event event;
  final EventInstance eventInstance;

  // final DateTime date;
  const VolunteerConfirmationScreen(this.event,this.eventInstance,
      {super.key});

  @override
  State<VolunteerConfirmationScreen> createState() =>
      _VolunteerConfirmationScreenState();
}

class _VolunteerConfirmationScreenState
    extends State<VolunteerConfirmationScreen> {
  final _authMethod = AuthMethod();
  late Future<List<EventDataModel>> _eventsFuture;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _verifierNameController = TextEditingController();
  final TextEditingController _verifierContactInfoController = TextEditingController();
  final LogServices _logMethod = LogServices();

  String? _errorMessage;

  void _validateInput() {
    final error = phoneValidator(_phoneNumberController.text);
    setState(() {
      _errorMessage = error;
    });
  }

  @override
  void initState() {
    super.initState();
    _eventsFuture = _logMethod.fetchAllEventsWithLogs();
  }

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Future<String> _exportSignatureAsString() async {
    final Uint8List? data = await _signatureController.toPngBytes();
    if (data != null) {
      return base64Encode(data);
    } else {
      return '';
    }
  }

/*  List<EventListDataModel> getPastEvents(List<EventDataModel> events) {
    DateTime today = DateTime.now().subtract(const Duration(days: 1));
    List<EventListDataModel> pastEvents = [];
    for (var event in events) {
      for (var dateMap in event.dates!) {
        Timestamp timestamp = dateMap['date'];
        DateTime date = timestamp.toDate();

        if (date.isBefore(today) && event.logs != null) {
          if (event.logs!.isNotEmpty &&
              event.group == widget.event.group &&
              event.logs!.any((test) => test.isSignatureVerified == false)) {
            pastEvents.add(EventListDataModel(date: date, event: event));
          }
        }
      }
    }
    return pastEvents;
  }*/

  LogModel? fetchLog(EventDataModel event, DateTime date) {
    if (event.logs == null) return null;

    for (var log in event.logs!) {
      if (log.date != null && isSameDate(log.date.toDate(), date)) {
        return log;
      }
    }

    return null;
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Map<String, String>> selectedEvents = [];
  @override
  Widget build(BuildContext context) {
    Color color = HexColor(widget.event.eventColorCode!);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String selectedCountryCode = '+1'; // Default country code

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
              Navigator.pop(context);
           /*   final timerProvider =
                  Provider.of<TimerProvider>(context, listen: false);
              timerProvider
                  .createSingleLog(context, widget.event, widget.date, null,
                      null, selectedEvents)
                  .then((onValue) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomePage()));
              });*/
            },
            child: Text(
              "Back",
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
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.eventTitle.toString().capitalize ?? "",
                style: TextStyle(fontSize: 24, color: color),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                 DateFormat.yMMMMEEEEd().format(DateTime.parse(widget.eventInstance.eventStartDateTime!)),

                style: const TextStyle(fontSize: 16, color: greyColor),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: greyColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  widget.event.eventLocationName != "" ?  Text(
                    widget.event.eventLocationName ?? "",
                    style: const TextStyle(fontSize: 16, color: greyColor),
                  ) : Text(
                    "Location not shared",
                    style: const TextStyle(fontSize: 16, color: greyColor),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.timer_sharp,
                    color: greyColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "${formatTime(widget.event.eventParticipatedDuration!.split("::").first)} to ${formatTime(widget.event.eventParticipatedDuration!.split("::").last)}" ?? "",
                    style: const TextStyle(fontSize: 16, color: greyColor),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              TextFormField(
                controller: _verifierNameController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Verifier Name',
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
                  // Display the error message
                ),
                onChanged: (value) {
                },

                // validator: phoneValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _verifierContactInfoController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Email/Phone(Optional)',
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
                  // Display the error message
                ),
                onChanged: (value) {
                },

                // validator: phoneValidator,
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                keyboardType: TextInputType.text,
                maxLines: 3,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Notes(Optional)',
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
                  // Display the error message
                ),
                onChanged: (value) {
                },

                // validator: phoneValidator,
              ),
           /*   const Text(
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
              ),*/

              const SizedBox(height: 10),
              const Text(
                "Signature",
                style: TextStyle(fontSize: 16, color: headingBlue),
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
                    height: screenHeight * 0.1,
                    backgroundColor: Colors.grey[200]!,
                    dynamicPressureSupported: true,
                  ),
                ),
              ),

              SizedBox(
                height: screenHeight * 0.03,
              ),

              const Text(
                "Sign for all previous events too",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              FutureBuilder<List<EventDataModel>>(
                  future: _eventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      print("Data ${snapshot.data}");
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Center(child: Text('No Previous events found')),
                          ],
                        ),
                      );
                    } else {
                      return SizedBox();
                     /* List<EventListDataModel> pastEvents =
                          getPastEvents(snapshot.data ?? []);
                      return SizedBox(
                        height: screenHeight * 0.4, // Adjust as needed
                        child: buildEventList("Past Events", pastEvents),
                      );*/
                    }
                  }),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child:  GestureDetector(
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) {
                return Lottie.asset(
                    "assets/images/loader_lottie.json");
              });

            if (_errorMessage != null) {
              Fluttertoast.showToast(
                  msg: "Enter valid phone number",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              LogEventRequestModel requestBody = LogEventRequestModel();
              requestBody.userId= await getUserId();
              requestBody.eventInstanceId = widget.eventInstance.eventInstanceId;
              requestBody.userStartDateTime = widget.event.eventParticipatedDuration?.split("::").first;
              requestBody.userEndDateTime = widget.event.eventParticipatedDuration?.split("::").last;
              requestBody.userLocationName = widget.event.eventLocationName;
              requestBody.userNotes = _notesController.text;
              requestBody.userHours = 4;
              requestBody.userEarnPoints = 4;
              String signatureString = await _exportSignatureAsString();
              log("SignatureHash::: $signatureString");
              requestBody.verifierSignatureHash = signatureString;
              requestBody.verifierInformation = "Verifier name";
              requestBody.verifierNotes = "${_verifierNameController.text} | ${_verifierContactInfoController.text}";
              HostInformation hostInfo = HostInformation();
              hostInfo.eventId = widget.event.eventId;
              hostInfo.hostId = widget.event.hostId;
              hostInfo.hours = 4;
              requestBody.hostInformation = hostInfo;
              log("Payload:::: ${jsonEncode(requestBody)}");
              await EventsServices().logEventData(requestBody).then((onValue){
                print('OnLog::: ${(onValue)}');
                if(onValue.toString().contains("failed")){
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: onValue.toString(),toastLength: Toast.LENGTH_LONG);
                }else{
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: onValue.toString(),toastLength: Toast.LENGTH_LONG);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const HomePage()),
                          (route) => false);
                }

              });
              // submitEvent(context, _phoneNumberController.text);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
        ),
      ),
    );
  }

  Widget buildEventList(String title, List<EventListDataModel> events) {
   
    return Column(
      children: [
        const SizedBox(height: 15),
        events.isEmpty
            ? const SizedBox(
                height: 250,
                child: Center(
                  child: Text("No Events Found",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                   
                    print(events.length);
                    EventListDataModel event = events[index];
                    Color color =
                        colorMap[event.event!.groupColor] ?? Colors.pink;
                    LogModel? log = fetchLog(event.event!, event.date);
                    if (log == null) {
                      return const SizedBox();
                    }

                    if (events.isEmpty) {
                      return const Text("No Events Found",
                          style: TextStyle(
                            color: Colors.black,
                          ));
                    }

                    bool isSelected = selectedEvents.any((selectedEvent) =>
                        selectedEvent['eventId'] == event.event!.id &&
                        selectedEvent['logId'] == log.logId);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedEvents.add({
                                        'eventId': event.event!.id!,
                                        'logId': log.logId!,
                                      });
                                    } else {
                                      selectedEvents.removeWhere(
                                          (selectedEvent) =>
                                              selectedEvent['eventId'] ==
                                                  event.event!.id &&
                                              selectedEvent['logId'] ==
                                                  log.logId);
                                    }
                                  });
                                },
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      event.event!.title
                                              .toString()
                                              .capitalize ??
                                          "",
                                      style: TextStyle(
                                          color: color, fontSize: 18)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month,
                                        color: greyColor,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Date: ${DateFormat.yMMMd().format(event.date)}' ??
                                            "",
                                        style: const TextStyle(
                                            fontSize: 16, color: greyColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: log.isLocationVerified!
                                    ? Colors.blue
                                    : greyColor,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.document_scanner_outlined,
                                color: log.isSignatureVerified!
                                    ? Colors.blue
                                    : greyColor,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.timer,
                                color: log.isTimeVerified!
                                    ? Colors.blue
                                    : greyColor,
                                size: 30,
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
        GestureDetector(
          onTap: () {
            if (_errorMessage != null) {
              Fluttertoast.showToast(
                  msg: "Enter valid phone number",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              submitEvent(context, _phoneNumberController.text);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  void submitEvent(BuildContext context, String number) async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    // Capture and convert signature image to Base64 string
    String signatureString = await _exportSignatureAsString();

    // Handle empty signature case
    if (signatureString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your signature.')),
      );
      return;
    }
   /* timerProvider.createSingleLog(context, widget.event, widget.date,
        signatureString, number, selectedEvents);*/
  }
}
