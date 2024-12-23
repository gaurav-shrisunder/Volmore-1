import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:volunterring/Models/request_models/log_past_event_request_model.dart';
import 'package:volunterring/Models/response_models/event_category_response_model.dart';
import 'package:volunterring/Screens/HomePage.dart';

import 'package:volunterring/Services/events_services.dart';
import 'package:volunterring/Services/logService.dart';

import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/widgets/InputFormFeild.dart';
import 'package:volunterring/widgets/appbar_widget.dart';
import 'package:http/http.dart' as http;

class CreatePastEventsPage extends StatefulWidget {
  const CreatePastEventsPage({super.key});

  @override
  State<CreatePastEventsPage> createState() => _CreatePastEventsPageState();
}

class _CreatePastEventsPageState extends State<CreatePastEventsPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  TimeOfDay? picked = TimeOfDay.now();
  List<String> _groupNames = [];

  String? _selectedGroup;
  bool isLoading = true;

  List<EventCategories> eventCategoriesList = [];

  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  String startUtcDateTime = "";
  String endUtcDateTime = "";
  final List<String> colorOptions = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Purple',
    'Orange',
    'Pink',
    'Teal',
    'Brown'
  ];
  final Map<String, String> colorCodes = {
    'Red': '#FF0000',
    'Blue': '#0000FF',
    'Green': '#00FF00',
    'Yellow': '#FFFF00',
    'Purple': '#800080',
    'Orange': '#FFA500',
    'Pink': '#FFC0CB',
    'Teal': '#008080',
    'Brown': '#A52A2A'
  };
  String? selectedColor;

  // Lists to store date and time controllers
  List<TextEditingController> dateControllers = [];
  List<TextEditingController> timeControllers = [];
  List<TextEditingController> endTimeControllers = [];
  List<TextEditingController> startTimeControllers = [];
  List<DateTime> startDateTimes = [];
  List<DateTime> endDateTimes = [];
  var uuid = const Uuid();
  String? _sessionToken;
  // Generate a v1 (time-based) id
  bool _showPlaceList = false;
  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupNames();
    // Initialize with one date and time controller
    _addDateTimeController();
    locationController.addListener(() {
      _onChanged();
      setState(() {
        _showPlaceList = locationController.text.isNotEmpty;
      });
    });
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(locationController.text);
  }

  void getSuggestion(String input) async {
    String kplacesApiKey = "AIzaSyDBytohYWyW41AVjU3A04QOrilB0fmqsDA";
    String type = '(regions)';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kplacesApiKey&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<void> _fetchGroupNames() async {
    try {
      EventCategoryResponseModel? eventCategoryResponseModel =
          await EventsServices().getEventsCategoryData();

      List<String> groupNames = [];
      eventCategoryResponseModel?.eventCategories?.forEach((action) {
        groupNames.add(action.eventCategoryName!);
      });

      setState(() {
        eventCategoriesList = eventCategoryResponseModel!.eventCategories!;
        _groupNames = groupNames;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching group names: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _addGroup(String name, String colorCode) async {
    var userId = await getUserId();

    var req = {
      "eventCategoryName": name,
      "eventColorCode": colorCode,
      "createdBy": userId
    };

    try {
      EventCategoryResponseModel responseModel =
          await EventsServices().createEventCategoryData(req);

      _fetchGroupNames();
      return responseModel.message ?? "Group added successfully";
    } catch (e) {
      print("Error adding group: $e");
      return "Something went wrong! Please try again later";
    }
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to free up resources
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    for (var controller in dateControllers) {
      controller.dispose();
    }
    for (var controller in timeControllers) {
      controller.dispose();
    }
    for (var controller in endTimeControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newGroupName = '';
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add New Group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => newGroupName = value,
                  decoration: const InputDecoration(labelText: 'Group Name'),
                ),
                const SizedBox(
                  height: 10,
                ),
                DropdownButton<String>(
                  value: selectedColor,
                  hint: const Text('Select Color'),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedColor = newValue;
                    });
                  },
                  items: colorOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newGroupName.isNotEmpty && selectedColor != null) {
                    String colorCode = colorCodes[selectedColor]!;
                    await _addGroup(newGroupName, colorCode).then((onValue) {
                      Fluttertoast.showToast(msg: onValue);
                    });
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(msg: "Please fill all fields");
                  }
                },
                child: const Text('Add Group'),
              ),
            ],
          );
        });
      },
    );
  }

  void _addDateTimeController() {
    setState(() {
      dateControllers.add(TextEditingController());
      startTimeControllers.add(TextEditingController());
      endTimeControllers.add(TextEditingController());
      startDateTimes.add(DateTime.now());
      endDateTimes.add(DateTime.now());
    });
  }

  // Combine date and time for the start and convert to ISO 8601 format
  void _combineDateTimeForIndex(int index) {
    if (dateControllers[index].text.isNotEmpty &&
        startTimeControllers[index].text.isNotEmpty &&
        endTimeControllers[index].text.isNotEmpty) {

      try {
        // Parse the date
        DateTime date = DateFormat('MM/dd/yyyy').parse(dateControllers[index].text);
        print('date:: ${dateControllers[index].text}');
        print('Time:: ${startTimeControllers[index].text}');

        // Parse start time
        TimeOfDay startTime = _parseTimeOfDay(startTimeControllers[index].text);

        // Parse end time
        TimeOfDay endTime = _parseTimeOfDay(endTimeControllers[index].text);


        // Define the format of the input string
        DateFormat localFormat = DateFormat("MM/dd/yyyy h:mm a");

        // Parse the local time string into a DateTime object
        DateTime localDateTime = localFormat.parse("${dateControllers[index].text} ${startTimeControllers[index].text}");
        DateTime localEndDateTime = localFormat.parse("${dateControllers[index].text} ${endTimeControllers[index].text}");

        // Convert the local DateTime to UTC
        DateTime utcDateTime = localDateTime.toUtc();
        DateTime utcEndDateTime = localEndDateTime.toUtc();

        // Combine date and start time
        startDateTimes[index] = utcDateTime;

        // Combine date and end time
        endDateTimes[index] = utcEndDateTime;

        // Adjust if end time is before start time
        if (endDateTimes[index].isBefore(startDateTimes[index])) {
          endDateTimes[index] = endDateTimes[index].add(const Duration(days: 1));
        }
      } catch (e) {
        print("Error combining date and time: $e");
        throw const FormatException("Invalid date or time format.");
      }
    }
  }

  String convertToUtcIso8601(DateTime dateTime) {
    return dateTime.toUtc().toString();
  }

  void submitData() async {
    try {
      List<Dates> datesList = [];

      for (int i = 0; i < dateControllers.length; i++) {
        _combineDateTimeForIndex(i);
        datesList.add(Dates(
          startDateTime: convertToUtcIso8601(startDateTimes[i]),
          endDateTime: convertToUtcIso8601(endDateTimes[i]),
        ));
      }

      LogPastEventRequestModel requestModel = LogPastEventRequestModel(
        eventTitle: titleController.text.trim(),
        eventDescription: descriptionController.text.trim(),
        eventCategoryId: eventCategoriesList
            .firstWhere((category) => category.eventCategoryName == _selectedGroup)
            .eventCategoryId,
        eventLocationName: locationController.text.trim(),
        createdBy: await getUserId(),
        dates: datesList,
      );

      print('Request model: ${jsonEncode(requestModel)}');

      // Send API request
      var res = await EventsServices().logPastEventData(requestModel);
      if (res) {
        Fluttertoast.showToast(msg: "Past event created successfully");
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Fluttertoast.showToast(msg: "Something went wrong! Try again later");
      }
    } catch (e) {
      print("Error submitting data: $e");
      Fluttertoast.showToast(msg: "Error submitting data. Please try again.");
    }
  }


  TimeOfDay _parseTimeOfDay(String timeString) {
    // First, try parsing with AM/PM
    try {
      final DateTime dateTime = DateFormat.jm().parse(timeString);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      // If that fails, try parsing 24-hour format
      try {
        final DateTime dateTime = DateFormat.Hm().parse(timeString);
        return TimeOfDay.fromDateTime(dateTime);
      } catch (e) {
        // If all parsing attempts fail, throw an error
        throw FormatException('Invalid time format: $timeString');
      }
    }
  }

  // String convertToUtcIso8601(DateTime dateTime) {
  //   return dateTime.toUtc().toIso8601String();
  // }
  //
  // void submitData() async {
  //   List<Dates> datesList = [];
  //
  //   for (int i = 0; i < dateControllers.length; i++) {
  //     print('Submit date::: ${startDateTimes[i]}  :: ${endDateTimes[i]}');
  //     _combineDateTimeForIndex(i);
  //     datesList.add(Dates(
  //         startDateTime: convertToUtcIso8601(startDateTimes[i]),
  //         endDateTime: convertToUtcIso8601(endDateTimes[i])));
  //   }
  //   LogPastEventRequestModel requestModel = LogPastEventRequestModel(
  //       eventTitle: titleController.text,
  //       eventDescription: descriptionController.text,
  //       eventCategoryId: eventCategoriesList
  //           .where((test) => test.eventCategoryName == _selectedGroup)
  //           .first
  //           .eventCategoryId, // Assuming _selectedGroup is the ID
  //       eventLocationName: locationController.text,
  //       createdBy: await getUserId(), // Implement getUserId() method
  //       dates: datesList);
  //
  //   print('Dates send:: ${jsonEncode(datesList.first)}');
  //   try {
  //    // var res = await EventsServices().logPastEventData(requestModel);
  //     if (true == true) {
  //       Fluttertoast.showToast(msg: "Past event created successfully");
  //     } else {
  //       Fluttertoast.showToast(msg: "Something went wrong! Try again later");
  //     }
  //
  //     Navigator.pop(context);
  //
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => const HomePage()));
  //   } catch (e) {
  //     print("Error submitting data: $e");
  //     Fluttertoast.showToast(msg: "Error submitting data. Please try again.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      //  backgroundColor: Colors.white,
      appBar: simpleAppBar(context, ""),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset("assets/icons/l.png")),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Log Past Job',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      //  color: headingBlue,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Enter Detail about the new job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      //  color: Color(0xff0c4a6f),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InputFeildWidget(
                  title: 'Title',
                  controller: titleController,
                  maxlines: 1,
                  hintText: "Trash Clean Up",
                ),
                const SizedBox(height: 20),
                InputFeildWidget(
                  title: 'Job Description',
                  controller: descriptionController,
                  maxlines: 5,
                  hintText: 'Job Description',
                ),
                const SizedBox(height: 20),
                InputFeildWidget(
                  title: 'Location',
                  controller: locationController,
                  maxlines: 1,
                  prefixicon: const Icon(
                    Icons.location_on,
                    color: Colors.grey,
                  ),
                  hintText: '123 Main St., New York, NY 10001',
                ),
                if (_showPlaceList)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _placeList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          setState(() {
                            locationController.text =
                                _placeList[index]["description"];
                            _showPlaceList = false;
                          });
                        },
                        title: Text(_placeList[index]["description"]),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    //   color: headingBlue,
                  ),
                ),
                Column(
                  children: List.generate(dateControllers.length, (index) {
                    return Column(
                      children: [
                        const SizedBox(height: 5),
                        TextField(
                          controller: dateControllers[index],
                          decoration: InputDecoration(
                            filled: true,
                            labelText: 'Date',
                            suffixIcon: const Icon(Icons.calendar_today),
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
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
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                // Display the selected date in mm/dd/yyyy format
                                dateControllers[index].text = DateFormat('MM/dd/yyyy').format(picked);
                                // Store the UTC date format for API
                              //  _selectedDates[index] = picked.toUtc().toIso8601String();
                              });
                            }
                          },
                          readOnly: true,
                        )
                        ,
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: startTimeControllers[index],
                                onTap: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      startTimeControllers[index].text =
                                          picked.format(context);
                                      _combineDateTimeForIndex(index);
                                    });
                                  }
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  labelText: 'Start Time',
                                  suffixIcon: const Icon(Icons.access_time),

                                  hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  //  fillColor: Colors.white,
                                  // prefixIcon: widget.prefixicon,
                                  enabledBorder: OutlineInputBorder(
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
                                  // Display the error message
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
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: endTimeControllers[index],
                                onTap: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      endTimeControllers[index].text =
                                          picked.format(context);
                                      _combineDateTimeForIndex(index);
                                    });
                                  }
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  labelText: 'End Time',
                                  suffixIcon: const Icon(Icons.access_time),

                                  hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  //  fillColor: Colors.white,
                                  // prefixIcon: widget.prefixicon,
                                  enabledBorder: OutlineInputBorder(
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
                                  // Display the error message
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
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: const ButtonStyle(
                       backgroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                  onPressed: _addDateTimeController,
                  child: const Text(
                    'Add Another Date',
                    //     style: TextStyle(color: Colors.lightBlue[700]),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Grouping',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    //  color: headingBlue,
                  ),
                ),
                const SizedBox(height: 5),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 0.4,

                              blurRadius: 10,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          hint: const Text('Select a Group'),
                          value: _selectedGroup,
                          //   dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            hintStyle: const TextStyle(
                                //   color: Colors.grey[400],
                                fontSize: 19,
                                fontWeight: FontWeight.w400),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            //     fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 213, 215, 215),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[
                                    400]!, // Change this to your desired color
                                width: 2.0,
                              ),
                            ),
                          ),
                          onChanged: (String? newValue) {
                            if (newValue == 'add_new') {
                              _showAddGroupDialog();
                            } else {
                              setState(() {
                                _selectedGroup = newValue;
                              });
                            }
                          },
                          items: [
                            ..._groupNames.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList() ??
                                [],
                            const DropdownMenuItem<String>(
                              value: 'add_new',
                              child: Text('Add New Group'),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        dateControllers.isNotEmpty) {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return const Center(
                                child: CircularProgressIndicator());
                          });

                      submitData();
                    } else {
                      Fluttertoast.showToast(msg: "All fields are mandatory");
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[500],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Create Past Event',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
