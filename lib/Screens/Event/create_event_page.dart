// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/UserModel.dart';

import '../../Models/request_models/create_event_request_model.dart';
import '../../Models/response_models/event_category_response_model.dart';
import '../../Screens/HomePage.dart';

import '../../Services/deep_links.dart';
import '../../Services/events_services.dart';

import '../../Utils/shared_prefs.dart';
import '../../widgets/InputFormFeild.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/appbar_widget.dart';
import 'package:http/http.dart' as http;

import '../../Models/response_models/create_event_response_model.dart';
import '../../widgets/customSnackbar.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  TimeOfDay? picked = TimeOfDay.now();

  UserModel? user;

  String selectedOccurrence =
      'No occurrence'; // Initial value set to prevent null issues
  List<String> _groupNames = [];

  String? _selectedGroup;
  var uuid = const Uuid();
  String? _sessionToken;
  // Generate a v1 (time-based) id
  bool _showPlaceList = false;
  List<dynamic> _placeList = [];
  List<EventCategories> eventCategoriesList = [];

  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  String startUtcDateTime = "";
  String endUtcDateTime = "";

  // Function to pick the start date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
      _selectStartTime(context); // Pick time after date
    }
  }

  // Function to pick the start time
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
        _combineStartDateTime(); // Combine date and time
      });
    }
  }

  // Function to pick the end date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
      _selectEndTime(context); // Pick time after date
    }
  }

  // Function to pick the end time
  Future<void> _selectEndTime(BuildContext context) async {
    if (startDate != null) {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null && picked != endTime) {
        if (endDate!.day == startDate!.day &&
            (picked.hour < startTime!.hour ||
                (picked.hour == startTime!.hour &&
                    picked.minute < startTime!.minute))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('End time cannot be before start time on the same day'),
            ),
          );
        } else {
          setState(() {
            endTime = picked;
            _combineEndDateTime(); // Combine date and time
          });
        }
      }
    } else {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null && picked != endTime) {
        setState(() {
          endTime = picked;
          _combineEndDateTime(); // Combine date and time
        });
      }
    }
  }

  // Combine date and time for the start and convert to ISO 8601 format
  void _combineStartDateTime() {
    if (startDate != null && startTime != null) {
      final DateTime combinedDateTime = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startTime!.hour,
        startTime!.minute,
      );

      // Convert to UTC and ISO 8601 format
      setState(() {
        startUtcDateTime = combinedDateTime.toUtc().toIso8601String();
      });
    }
  }

  // Combine date and time for the end and convert to ISO 8601 format
  void _combineEndDateTime() {
    if (endDate != null && endTime != null) {
      final DateTime combinedDateTime = DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
        endTime!.hour,
        endTime!.minute,
      );

      // Convert to UTC and ISO 8601 format
      setState(() {
        if(kDebugMode) {
          print(' before setting:: ${combinedDateTime.toUtc()}');
        }
        endUtcDateTime = combinedDateTime.toUtc().toIso8601String();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _sessionToken = uuid.v1();
    _fetchGroupNames();
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
        _sessionToken = uuid.v1();
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
    if(kDebugMode) {
      print('Respinse Map: ${json.decode(response.body)}');
    }
    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  List<dynamic> generateDates(
      DateTime startDate, DateTime endDate, String occurrence) {
    List<dynamic> dates = [];
    DateTime currentDate = startDate;

    if (occurrence == 'Weekly') {
      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        dates.add({
          "date": currentDate,
          "isVerified": false,
          "isLocation": false,
          "duration": "00:00"
        });
        currentDate = currentDate.add(const Duration(days: 7));
      }
    } else {
      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        dates.add({
          "date": currentDate,
          "isVerified": false,
          "isLocation": false,
          "duration": "00:00"
        });
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return dates;
  }

  Future<void> _fetchGroupNames() async {
    try {
      /* QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();*/
      EventCategoryResponseModel? eventCategoryResponseModel = await EventsServices().getEventsCategoryData();

      List<String> groupNames = [];
      eventCategoryResponseModel?.eventCategories?.forEach((action) {
        groupNames.add(action.eventCategoryName!);
      });

      setState(() {
        eventCategoriesList = eventCategoryResponseModel!.eventCategories!;
        _groupNames = groupNames;
        _selectedGroup = _groupNames.lastOrNull;
        isLoading = false;
      });
    } catch (e) {
      if(kDebugMode) {
        print("Error fetching group names: $e");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

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
  bool isLoading = true;
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
      if(kDebugMode)
      print("Error adding group: $e");
      return "Something went wrong! Please try again later";
    }
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newGroupName = '';
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Add New Group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) => newGroupName = value,
                  decoration: const InputDecoration(labelText: 'Group Name'),
                ),
                const SizedBox(
                  height: 10,
                ),
                DropdownButton<String>(
                  value: selectedColor,
                  dropdownColor: Colors.white,
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
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),

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
                child: const Text('Add Group', style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to free up resources
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    dateController.dispose();
    locationController.dispose();

    super.dispose();
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
                    'Schedule New Job',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      //   color: headingBlue,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Enter detail about the new job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      //   color: Color(0xff0c4a6f),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InputFeildWidget(
                  title: 'Job Title*',
                  keyboardType: TextInputType.name,
                  controller: titleController,
                  hintText: 'Trash Clean Up',
                  validator: nameValidator,
                ),
                const SizedBox(height: 20),
                InputFeildWidget(
                  title: 'Job Description',
                  keyboardType: TextInputType.name,
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
                  hintText: '123 Main St New York, NY 10001',
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
                  'Occurrence',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    //  color: headingBlue,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.4,
                        blurRadius: 10,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedOccurrence,
                    dropdownColor: Colors.white,
                    icon: const Icon(
                      CupertinoIcons.chevron_down,
                      size: 20,
                    ),
                    decoration: InputDecoration(
                      filled: true,

                      hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      //   fillColor: Colors.white,
                      focusColor: Colors.white,

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
                          color: Colors
                              .grey[400]!, // Change this to your desired color
                          width: 2.0,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'No occurrence',
                        child: Text('No occurrence'),
                      ),
                      DropdownMenuItem(
                        value: 'Daily',
                        child: Text('Daily'),
                      ),
                      DropdownMenuItem(
                        value: 'Weekly',
                        child: Text('Weekly'),
                      ),
                      DropdownMenuItem(
                        value: 'Custom',
                        child: Text('Custom'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedOccurrence = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Start Date & Time:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        //   color: headingBlue,
                      ),
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 12)),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.white),
                          elevation: MaterialStatePropertyAll(0),
                          shadowColor: MaterialStatePropertyAll(Colors.white),
                          side: MaterialStatePropertyAll(BorderSide(width: 1))),
                      onPressed: () => _selectStartDate(context),
                      child: startUtcDateTime.isNotEmpty
                          ? Text(
                              DateFormat('MM/dd/yyyy  hh:mm a').format(
                                  DateTime.parse(startUtcDateTime)
                                      .toUtc()
                                      .toLocal()),
                              textAlign: TextAlign.center,
                            )
                          : const Icon(Icons.calendar_month_rounded),
                    ),
                    /* Container(
                      width: width * 0.25,
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
                      child: TextField(
                        controller: timeController,

                        onTap: () => _selectTime(context, timeController),
                        readOnly: true,

                        // Prevent keyboard from appearing
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Time',
                          hintStyle: const TextStyle(
                              //  color: Colors.grey[900],
                              fontSize: 16,
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
                      ),
                    )*/
                  ],
                ),
                selectedOccurrence != 'No occurrence'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Occurrence End at: ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              //   color: headingBlue,
                            ),
                          ),
                          ElevatedButton(
                            style: const ButtonStyle(
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.symmetric(horizontal: 12)),
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                elevation: MaterialStatePropertyAll(0),
                                shadowColor:
                                    MaterialStatePropertyAll(Colors.white),
                                side: MaterialStatePropertyAll(
                                    BorderSide(width: 1))),
                            onPressed: () => _selectEndDate(context),
                            child: endUtcDateTime.isNotEmpty
                                ? Text(
                                    DateFormat('MM/dd/yyyy  hh:mm a').format(
                                        DateTime.parse(endUtcDateTime)
                                            .toUtc()
                                            .toLocal()),
                                    textAlign: TextAlign.center,
                                  )
                                : const Icon(Icons.calendar_month_rounded),
                          ),
                          /* Container(
                      width: width * 0.25,
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
                      child: TextField(
                        controller: timeController,

                        onTap: () => _selectTime(context, timeController),
                        readOnly: true,

                        // Prevent keyboard from appearing
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Time',
                          hintStyle: const TextStyle(
                              //  color: Colors.grey[900],
                              fontSize: 16,
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
                      ),
                    )*/
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 20),
                const Text(
                  'Grouping',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    //   color: headingBlue,
                  ),
                ),
                const SizedBox(height: 5),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
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
                          dropdownColor: Colors.white,
                          value: _selectedGroup,
                          //  dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            hintStyle: const TextStyle(
                                //    color: Colors.grey[400],
                                fontSize: 19,
                                fontWeight: FontWeight.w400),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            //   fillColor: Colors.white,
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
                  onTap: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return const Center(
                              child: CircularProgressIndicator());
                        });
                    titleController.text = titleController.text;
                    if(kDebugMode) {
                      print('Selected Group::: ${_selectedGroup}');
                    }

                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        selectedOccurrence.isNotEmpty && _selectedGroup != null) {
                      /*  DateTime endDate = selectedOccurrence == 'No occurrence'
                          ? selectedDate
                          : DateFormat('dd/MM/yyyy')
                              .parse(endDateController.text);
                      List<dynamic> allDates = generateDates(
                          selectedDate, endDate, selectedOccurrence);*/

                      CreateEventRequestModel requestModel =
                          CreateEventRequestModel();
                      requestModel.eventTitle = titleController.text;
                      requestModel.eventDescription =
                          descriptionController.text;
                      requestModel.eventLocationName = locationController.text;
                      requestModel.eventCategoryId = eventCategoriesList
                          .where((test) =>
                              test.eventCategoryName == _selectedGroup)
                          .first
                          .eventCategoryId;
                      requestModel.createdBy = await getUserId();
                      Recurrence recurrence = Recurrence();
                      recurrence.eventStartDateTime = startUtcDateTime;
                      recurrence.eventEndDateTime = endUtcDateTime.isEmpty  ? null : endUtcDateTime;
                      recurrence.recurInterval = 1;
                      recurrence.weekdays = _selectedGroup == "Weekly"
                          ? DateFormat('EEEE').format(
                              DateTime.parse(startUtcDateTime).toLocal())
                          : null;

                      recurrence.recurFrequency =
                          selectedOccurrence == "No occurrence"
                              ? "none"
                              : selectedOccurrence.toLowerCase();

                      requestModel.recurrence = recurrence;
                      if(kDebugMode) {
                        print('Payload ${jsonEncode(requestModel)}');
                      }

                      CreateEventResponse? eventCreatedResponse = await EventsServices().createEventData(requestModel);
                      //   Navigator.pop(context);

                      /* dynamic res = await _authMethod
                          .addEvent(
                        title: titleController.text,
                        description: descriptionController.text,
                        date: selectedDate,
                        location: locationController.text,
                        occurrence: selectedOccurrence,
                        group: _selectedGroup!,
                        time: timeController.text,
                        endDate: endDate,
                        dates: allDates,
                      )
                          .then((onValue) {
                        Navigator.pop(context);
                      });*/
                      // EventDataModel event = EventDataModel(
                      //   title: titleController.text,
                      //   description: descriptionController.text,
                      //   date: selectedDate,
                      //   location: locationController.text,
                      //   occurence: selectedOccurrence,
                      //   group: _selectedGroup!,
                      //   time: timeController.text,
                      //   endDate: endDate,
                      //   dates: allDates,
                      //   id: "",
                      //   host: user?.name ?? "",

                      if (eventCreatedResponse.message!
                          .contains("successfully")) {
                        // Clear the form fields
                        titleController.clear();
                        descriptionController.clear();
                        locationController.clear();
                        setState(() {
                          dateController.clear();
                          endDateController.clear();
                          selectedDate = DateTime.now();
                          selectedOccurrence = 'No occurrence';
                          _selectedGroup = null;
                        });
                        // Navigator.pushAndRemoveUntil(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const HomePage()),
                        //     (route) => false);
                        CustomSnackBar.show(context: context, message: eventCreatedResponse.message!, type: SnackBarType.success);

                        showDialog(
                          barrierDismissible: false,
                            context: context,
                            builder: (_) {
                              return SimpleDialog(
                                backgroundColor: Colors.white,
                                title: Column(
                                  children: [
                                    const Center(
                                      child: Text(
                                        "Event created successfully!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Lottie.asset(
                                        height: 380,
                                        width: width * 0.8,
                                        "assets/images/hurrah_lotttie.json"),
                                  ],
                                ),
                                children: [
                                  const Center(
                                    child: Text(
                                      "Want to make it a group effort? Invite your friends!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Center(
                                    child: GestureDetector(
                                        onTap: () async {
                                          final SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          https://volmore.page.link/e1ZW
                                          final String? uid = await getUserId();
                                          String url = await createDynamicLink(
                                              eventId: eventCreatedResponse.eventDetails!.eventIntanceId.toString());
                                          Share.share(url);
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomePage()),
                                              (route) => false);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 15),
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue[500],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "Share",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: GestureDetector(
                                        onTap: () {
                                          /* Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomePage()),
                                            (route) => false);*/

                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomePage()));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 15),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 6, 7, 7),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "Skip",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ],
                              );
                            });
                      } else {

                        CustomSnackBar.show(context: context, message: eventCreatedResponse.message!, type: SnackBarType.error);
                        Navigator.pop(context);
                        /* ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please fill in all fields")),
                      );*/
                      }
                      // );
                    } else {
                      Fluttertoast.showToast(msg: "All fields are mandatory");
                      Navigator.pop(context);
                      /* ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please fill in all fields")),
                      );*/
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
                        'Submit Event',
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
