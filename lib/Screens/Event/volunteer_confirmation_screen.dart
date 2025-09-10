import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import '../../Models/event_data_model.dart';
import '../../Models/request_models/log_current_event_request_model.dart';
import '../../Models/response_models/events_data_response_model.dart';
import '../../Models/response_models/nonverified_events_response.dart';
import '../../Screens/dashboard_screen.dart';
import '../../Services/events_services.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/common_utils.dart';
import '../../Utils/shared_prefs.dart';
import '../../provider/time_logger_provider.dart';
import '../../widgets/text_input_form_field_widget.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_snackbar_widget.dart';

class VolunteerConfirmationScreen extends StatefulWidget {
  // final EventDataModel event;
  final Event event;
  final EventInstance eventInstance;

  // final DateTime date;
  const VolunteerConfirmationScreen(this.event, this.eventInstance,
      {super.key});

  @override
  State<VolunteerConfirmationScreen> createState() =>
      _VolunteerConfirmationScreenState();
}

class _VolunteerConfirmationScreenState
    extends State<VolunteerConfirmationScreen> {

  late Future<List<EventDataModel>> _eventsFuture;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final EventsServices _eventsServices = EventsServices();
  bool isSelectedAllPreviousCheckbox = false;
  NonVerifiedEventsResponseModel nonVerifiedEvents =
      NonVerifiedEventsResponseModel();
  List<CheckboxItem> checkboxItems = [];

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
    // _eventsFuture = _logMethod.fetchAllEventsWithLogs();
    getPreviousEventApiCalling();
    if(kDebugMode){
    print(
        'Start Time UTC : ${widget.event.eventParticipatedDuration!.split("::").first}');
    print(
        'End Time UTC : ${widget.event.eventParticipatedDuration!.split("::").last}');
  }}

  getPreviousEventApiCalling() async {
    nonVerifiedEvents = await _eventsServices
        .getNonVerifiedEventDetails(widget.event.eventCategoryId!);
    nonVerifiedEvents.nonVerifiedEvents?.forEach((action) {
      checkboxItems.add(CheckboxItem(
          eventName: action.eventTitle!,
          isChecked: false,
          time: DateFormat.yMMMMEEEEd()
              .format(DateTime.parse(action.eventStartDate!)),
          userLocation: action.userLocation,
          verifierSignatureHash: action.verifierSignatureHash,
          eventInstanceId: action.eventInstanceId));
    });

    setState(() {});
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
      if (isSameDate(log.date.toDate(), date)) {
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
      extendBody: false,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          "Volunteer Confirmation",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: headingBlue),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(CupertinoIcons.chevron_left)),

        actions: [
          GestureDetector(
            onTap: () async {
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
                Uint8List? pngBytes = await _signatureController.toPngBytes();
                var userId = await getUserId();
                String? signBase64Value =
                    await convertSignatureToBase64(pngBytes);
                LogEventRequestModel requestBody = LogEventRequestModel();
                int differenceInMinutes = getDifferenceInMinutes(
                    widget.event.eventParticipatedDuration!.split("::").first,
                    widget.event.eventParticipatedDuration!.split("::").last);
                requestBody.userId = await getUserId();
                requestBody.eventInstanceId =
                    widget.eventInstance.eventInstanceId;
                requestBody.userStartDateTime =
                    widget.event.eventParticipatedDuration?.split("::").first;
                requestBody.userEndDateTime =
                    widget.event.eventParticipatedDuration?.split("::").last;
                requestBody.userLocationName = widget.event.eventLocationName!
                        .toLowerCase()
                        .contains("not enabled!")
                    ? null
                    : widget.event.eventLocationName;
                requestBody.userNotes = null;
                requestBody.userMinutes = differenceInMinutes;
                //   requestBody.userEarnPoints = 4;
                requestBody.verifierSignatureHash =
                    _signatureController.isEmpty ? null : signBase64Value;
                requestBody.verifierInformation =
                    _phoneNumberController.text.isEmpty
                        ? null
                        : _phoneNumberController.text;
                requestBody.verifierNotes = _notesController.text.isEmpty
                    ? null
                    : _notesController.text;
                HostInformation hostInfo = HostInformation();
                hostInfo.eventId = widget.event.eventId;

                hostInfo.hostId = widget.event.hostId;
                if (userId != hostInfo.hostId) {
                  hostInfo.minutes = differenceInMinutes;
                } else {
                  hostInfo.minutes = 0;
                }
                requestBody.hostInformation = hostInfo;

                checkboxItems.any((test) {
                  if (!test.isChecked) {
                    requestBody.instancesToBeVerified = null;
                    return false;
                  } else {
                    requestBody.instancesToBeVerified
                        ?.add(test.eventInstanceId!);
                    return true;
                  }
                });

                await EventsServices()
                    .logEventData(requestBody)
                    .then((onValue) {
                  if (onValue.message!.contains(
                      "Event participant information updated successfully")) {
                    CustomSnackBar.show(context: context, message: onValue.message!, type: SnackBarType.success);

                    // Fluttertoast.showToast(msg: onValue.message!);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      (Route<dynamic> route) =>
                          false, // This condition makes sure all the routes are removed.
                    );
                  }
                });
                // submitEvent(context, _phoneNumberController.text);
              }
            },
            child: Text(
              "Skip",
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
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                DateFormat.yMMMMEEEEd().format(
                    DateTime.parse(widget.eventInstance.eventStartDateTime!).toLocal()),
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
                  SizedBox(
                    width: Get.width * 0.82,
                    child: Text(
                      widget.event.eventLocationName ?? "",
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 16,
                          color: greyColor,
                          overflow: TextOverflow.ellipsis),
                    ),
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
                    "${formatTime(DateTime.parse(widget.event.eventParticipatedDuration!.split("::").first).toLocal().toString())} to ${formatTime(DateTime.parse(widget.event.eventParticipatedDuration!.split("::").last).toLocal().toString())}" ??
                        "",
                    style: const TextStyle(fontSize: 16, color: greyColor),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Uint8List? pngBytes =
                          await _signatureController.toPngBytes();
                      String? signBase64Value =
                          await convertSignatureToBase64(pngBytes);

                    },
                    child: const Text(
                      "Verifier's Signature",
                      style: TextStyle(fontSize: 18, color: headingBlue),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _signatureController.clear();
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(fontSize: 16, color: headingBlue),
                    ),
                  ),
                ],
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
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: "Verifier's Mobile Number",

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
                  errorText: _errorMessage,
                  // Display the error message
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
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _notesController,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                maxLines: 3,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: "Verifier's Notes(Optional)",
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
                onChanged: (value) {},

                // validator: phoneValidator,
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              checkboxItems.isNotEmpty
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sign for all previous events",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ],
                    )
                  : const SizedBox(),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: checkboxItems.length,
                  //  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  //   physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                  value: checkboxItems[index].isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      checkboxItems[index].isChecked = value!;
                                    });
                                  }),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    checkboxItems[index].eventName,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    checkboxItems[index].time!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: checkboxItems[index]
                                        .userLocation!
                                        .isNotEmpty
                                    ? Colors.black
                                    : Colors.grey.shade400,
                                size: 30,
                              ),
                              const SizedBox(width: 5),
                              SvgPicture.asset(
                                "assets/icons/signature_icon.svg",
                                color: checkboxItems[index]
                                        .verifierSignatureHash!
                                        .isNotEmpty
                                    ? Colors.black
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.timer,
                                color: Colors.black,
                                size: 30,
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }),
              //  SizedBox(height: MediaQuery.of(context).size.height/3,)
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          //  height: 40,
          child: MyButtons(
              onTap: () async {
                String signatureString = await _exportSignatureAsString();
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
                  Uint8List? pngBytes = await _signatureController.toPngBytes();
                  String? signBase64Value =
                      await convertSignatureToBase64(pngBytes);
                  LogEventRequestModel requestBody = LogEventRequestModel();
                  int differenceInMinutes = getDifferenceInMinutes(
                      widget.event.eventParticipatedDuration!.split("::").first,
                      widget.event.eventParticipatedDuration!.split("::").last);
                  requestBody.userId = await getUserId();
                  requestBody.eventInstanceId =
                      widget.eventInstance.eventInstanceId;
                  requestBody.userStartDateTime =
                      widget.event.eventParticipatedDuration?.split("::").first;
                  requestBody.userEndDateTime =
                      widget.event.eventParticipatedDuration?.split("::").last;
                  requestBody.userLocationName = widget.event.eventLocationName!
                          .toLowerCase()
                          .contains("not enabled!")
                      ? null
                      : widget.event.eventLocationName;
                  requestBody.userNotes = null;
                  requestBody.userMinutes = differenceInMinutes;
                  //   requestBody.userEarnPoints = 4;
                  requestBody.verifierSignatureHash =
                      _signatureController.toString().isEmpty
                          ? null
                          : signBase64Value;
                  requestBody.verifierInformation =
                      _phoneNumberController.text.isEmpty
                          ? null
                          : _phoneNumberController.text;
                  requestBody.verifierNotes = _notesController.text.isEmpty
                      ? null
                      : _notesController.text;
                  HostInformation hostInfo = HostInformation();
                  hostInfo.eventId = widget.event.eventId;

                  hostInfo.hostId = widget.event.hostId;
                  hostInfo.minutes = differenceInMinutes;
                  requestBody.hostInformation = hostInfo;
                  checkboxItems.any((test) {
                    if (!test.isChecked) {
                      requestBody.instancesToBeVerified = null;
                      return false;
                    } else {
                      requestBody.instancesToBeVerified
                          ?.add(test.eventInstanceId!);
                      return true;
                    }
                  });
                  /*  for (var val in checkboxItems) {
                    if (val.isChecked) {
                      requestBody.instancesToBeVerified
                          ?.add(val.eventInstanceId!);
                    }
                  }*/

                  await EventsServices()
                      .logEventData(requestBody)
                      .then((onValue) {
                    if (onValue.message!.contains("updated successfully")) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashboardScreen()),
                        (Route<dynamic> route) =>
                            false, // This condition makes sure all the routes are removed.
                      );
                      CustomSnackBar.show(context: context, message: onValue.message!, type: SnackBarType.success);

                    } else {
                      CustomSnackBar.show(context: context, message:onValue.message ?? "Something went wrong.", type: SnackBarType.error);


                    }
                  });
                  // submitEvent(context, _phoneNumberController.text);
                }
              },
              text: "Submit")),
    );
  }


  Future<String?> convertSignatureToBase64(Uint8List? pngBytes) async {
    if (pngBytes == null) return null; // Check if bytes are null
    return base64Encode(pngBytes); // Encode to Base64
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

  Widget buildCheckboxItem(CheckboxItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        children: [
          // Checkbox and Name aligned left
          Row(
            children: [
              Checkbox(
                value: item.isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    item.isChecked = value ?? false;
                  });
                },
              ),
              Text(item.eventName),
            ],
          ),

          // Spacer to push icons to the right
          const Spacer(),

          // Icons aligned to the right
          const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckboxItem {
  final String eventName;
  bool isChecked;
  String? userLocation;
  String? verifierSignatureHash;
  String? time;
  String? eventInstanceId;

  CheckboxItem(
      {required this.eventName,
      this.isChecked = false,
      this.userLocation,
      this.time,
      this.verifierSignatureHash,
      this.eventInstanceId});
}
