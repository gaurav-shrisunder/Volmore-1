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

class PastEventsPage extends StatefulWidget {
  const PastEventsPage({super.key});

  @override
  State<PastEventsPage> createState() => _PastEventsPageState();
}

class _PastEventsPageState extends State<PastEventsPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  TimeOfDay? picked = TimeOfDay.now();
  List<String> _groupNames = [];

  String? _selectedGroup;

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

  @override
  void initState() {
    super.initState();
    _fetchGroupNames();
    // Initialize with one date and time controller
    _addDateTimeController();
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
      });
    } catch (e) {
      print("Error fetching group names: $e");
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
        return AlertDialog(
          title: const Text('Add New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => newGroupName = value,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              DropdownButton<String>(
                value: selectedColor,
                hint: const Text('Select Color'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedColor = newValue;
                  });
                },
                items:
                    colorOptions.map<DropdownMenuItem<String>>((String value) {
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
      DateTime date =
          DateFormat('dd/MM/yyyy').parse(dateControllers[index].text);

      // Parse start time
      TimeOfDay startTime = _parseTimeOfDay(startTimeControllers[index].text);

      // Parse end time
      TimeOfDay endTime = _parseTimeOfDay(endTimeControllers[index].text);

      startDateTimes[index] = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );

      endDateTimes[index] = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      // If end time is before start time, assume it's the next day
      if (endDateTimes[index].isBefore(startDateTimes[index])) {
        endDateTimes[index] = endDateTimes[index].add(const Duration(days: 1));
      }

      print("Combined start date time: ${startDateTimes[index]}");
      print("Combined end date time: ${endDateTimes[index]}");
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

  String convertToUtcIso8601(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  void submitData() async {
    List<Dates> datesList = [];

    for (int i = 0; i < dateControllers.length; i++) {
      _combineDateTimeForIndex(i);
      datesList.add(Dates(
          startDateTime: convertToUtcIso8601(startDateTimes[i]),
          endDateTime: convertToUtcIso8601(endDateTimes[i])));
    }
    LogPastEventRequestModel requestModel = LogPastEventRequestModel(
        eventTitle: titleController.text,
        eventDescription: descriptionController.text,
        eventCategoryId: eventCategoriesList
            .where((test) => test.eventCategoryName == _selectedGroup)
            .first
            .eventCategoryId, // Assuming _selectedGroup is the ID
        eventLocationName: locationController.text,
        createdBy: await getUserId(), // Implement getUserId() method
        dates: datesList);
    try {
      var res = await EventsServices().logPastEventData(requestModel);
      if (res == true) {
        Fluttertoast.showToast(msg: "Past Hours Logged Successfully");
      } else {
        Fluttertoast.showToast(msg: "Some error occured Try again later");
      }

      Navigator.pop(context);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    } catch (e) {
      print("Error submitting data: $e");
      Fluttertoast.showToast(msg: "Error submitting data. Please try again.");
    }
  }

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
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2025),
                            );
                            if (picked != null) {
                              setState(() {
                                dateControllers[index].text =
                                    DateFormat('dd/MM/yyyy').format(picked);
                                _combineDateTimeForIndex(index);
                              });
                            }
                          },
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
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
                                decoration: const InputDecoration(
                                  labelText: 'Start Time',
                                  suffixIcon: Icon(Icons.access_time),
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
                                decoration: const InputDecoration(
                                  labelText: 'End Time',
                                  suffixIcon: Icon(Icons.access_time),
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
                      // backgroundColor: MaterialStateProperty.all(Colors.blue.shade50),
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
                _groupNames.isEmpty
                    ? const CircularProgressIndicator()
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
                            ..._groupNames
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
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
