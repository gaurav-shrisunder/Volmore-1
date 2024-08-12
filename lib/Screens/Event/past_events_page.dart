import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Services/logService.dart';
import 'package:volunterring/Utils/Colors.dart';
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

  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final _logMethod = LogServices();
  TimeOfDay? picked = TimeOfDay.now();
  List<String> _groupNames = [];
  String? _selectedGroup;
  final Uuid _uuid = const Uuid();

  // Lists to store date and time controllers
  List<TextEditingController> dateControllers = [];
  List<TextEditingController> timeControllers = [];
  List<TextEditingController> endTimeControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupNames();
    // Initialize with one date and time controller
    _addDateTimeController();
  }

  Future<void> _fetchGroupNames() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();
      print("querySnapshot.docs: ${querySnapshot.docs}");
      List<String> groupNames =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        _groupNames = groupNames;
      });
    } catch (e) {
      print("Error fetching group names: $e");
    }
  }

  Future<void> _addGroup(String name, String color) async {
    try {
      String id = _uuid.v4();
      await FirebaseFirestore.instance.collection('groups').doc(id).set({
        'name': name,
        'color': color,
      });
      _fetchGroupNames();
    } catch (e) {
      print("Error adding group: $e");
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
        return AlertDialog(
          title: const Text('Add New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Group Color'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text;
                String color = _colorController.text;
                if (name.isNotEmpty && color.isNotEmpty) {
                  _addGroup(name, color);
                  _nameController.clear();
                  _colorController.clear();
                  Navigator.of(context).pop();
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
      timeControllers.add(TextEditingController());
      endTimeControllers.add(TextEditingController());
    });
  }

  void _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        controller.text = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
    }
  }

  void _selectTime(
      BuildContext context, TextEditingController controller) async {
    picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    setState(() {
      controller.text = picked!.format(context);
    });
  }

  DateTime _parseTime(String timeStr, DateTime date) {
    final timeParts = timeStr.split(" ");
    final time = timeParts[0].split(":");
    final period = timeParts[1].toLowerCase();

    int hour = int.parse(time[0]);
    int minute = int.parse(time[1]);

    // Convert to 24-hour format
    if (period == "pm" && hour != 12) {
      hour += 12;
    } else if (period == "am" && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Duration calculateDuration(String startTimeStr, String endTimeStr) {
    // Define time format
    DateFormat timeFormat = DateFormat('h:mm a');

    // Parse times
    DateTime startTime = timeFormat.parse(startTimeStr);
    DateTime endTime = timeFormat.parse(endTimeStr);

    // Calculate duration
    Duration duration;

    if (endTime.isBefore(startTime)) {
      // Add 24 hours to end time if it's before start time
      duration = endTime.add(const Duration(hours: 24)).difference(startTime);
    } else {
      duration = endTime.difference(startTime);
    }

    return duration;
  }

  void submitData() async {
    List<Map<String, dynamic>> dateTimes = [];
    List<Map<String, dynamic>> logs = [];
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    for (int i = 0; i < dateControllers.length; i++) {
      String startTime = timeControllers[i].text;
      String endTime = endTimeControllers[i].text;
      Duration duration = calculateDuration(startTime, endTime);
      print("Start Time $startTime");
      // Formatting duration as hours and minutes
      String durationString = '${duration.inHours}:${duration.inMinutes % 60}';

      dateTimes.add({
        "date": dateFormat.parse(dateControllers[i].text),
        "isVerified": false,
        "isLocation": false,
        "duration": "00:00"
      });
    }
    DateFormat timeFormat = DateFormat.jm();

    for (int i = 0; i < dateControllers.length; i++) {
      // Parse date
      DateTime date = dateFormat.parse(dateControllers[i].text);

      String startTimeString = timeControllers[i].text.trim();
      String endTimeString = endTimeControllers[i].text.trim();

      DateTime startDateTime = _parseTime(startTimeString, date);
      DateTime endDateTime = _parseTime(endTimeString, date);
      // Calculate duration
      Duration duration = endDateTime.difference(startDateTime);

      // Formatting duration as hours, minutes, and seconds
      String durationString = duration.toString().split('.').first;

      print("Start Time $startDateTime");
      print("End Time $endDateTime");
      print("Duration $durationString");

      logs.add({
        "date": date,
        "startTime": startDateTime,
        "endTime": endDateTime,
        "duration": durationString,
      });
    }

    print("dateTimes: $dateTimes");

    // Creating the data map
    Map<String, dynamic> eventData = {
      'title': titleController.text,
      'description': descriptionController.text,
      'address': locationController.text,
      'dateTimes': dateTimes,
      'group': _selectedGroup,
      'date': dateFormat.parse(dateControllers[0].text),
      'location': null,
      'endDate': dateFormat.parse(dateControllers.last.text),
      'dates': dateTimes,
      'logs': logs,
    };
    var res = await _logMethod.createPastLog(eventData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res)),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
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
                      color: headingBlue,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Enter Detail about the new job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0c4a6f),
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
                    color: headingBlue,
                  ),
                ),
                Column(
                  children: List.generate(dateControllers.length, (index) {
                    return Column(
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
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
                                  controller: dateControllers[index],
                                  onTap: () => _selectDate(
                                      context, dateControllers[index]),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                      color: greyColor,
                                    ),
                                    filled: true,
                                    hintText: 'Select Date',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 213, 215, 215),
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
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
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
                                  onTap: () => _selectTime(
                                      context, timeControllers[index]),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(
                                      Icons.access_time,
                                      color: greyColor,
                                    ),
                                    filled: true,
                                    hintText: 'Start Time',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 213, 215, 215),
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
                                  controller: timeControllers[index],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
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
                                  onTap: () => _selectTime(
                                      context, endTimeControllers[index]),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(
                                      Icons.access_time,
                                      color: greyColor,
                                    ),
                                    filled: true,
                                    hintText: 'End Time',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 213, 215, 215),
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
                                  controller: endTimeControllers[index],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue.shade50),
                  ),
                  onPressed: _addDateTimeController,
                  child: Text(
                    'Add Another Date',
                    style: TextStyle(color: Colors.lightBlue[700]),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Grouping',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: headingBlue,
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
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 19,
                                fontWeight: FontWeight.w400),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            fillColor: Colors.white,
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
                    submitData();
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
