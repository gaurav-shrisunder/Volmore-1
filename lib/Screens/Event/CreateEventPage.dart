import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colors.dart';
import 'package:volunterring/widgets/InputFormFeild.dart';
import 'package:uuid/uuid.dart';

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
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final _authMethod = AuthMethod();

  String selectedOccurrence =
      'No occurrence'; // Initial value set to prevent null issues
  List<String> _groupNames = [];
  String? _selectedGroup;
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _fetchGroupNames();
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
    dateController.dispose();

    super.dispose();
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Group Name'),
              ),
              TextField(
                controller: _colorController,
                decoration: InputDecoration(labelText: 'Group Color'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
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
              child: Text('Add Group'),
            ),
          ],
        );
      },
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
    // showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('')),
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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0c4a6f),
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
                  prefixicon: Icon(
                    Icons.location_on,
                    color: Colors.grey,
                  ),
                  hintText: '123 Main St New York, NY 10001',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Occurrence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: headingBlue,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.4,

                        blurRadius: 10,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedOccurrence,
                    decoration: InputDecoration(
                      filled: true,
                      hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 19,
                          fontWeight: FontWeight.w400),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
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
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: headingBlue,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.4,

                        blurRadius: 10,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: dateController,

                    onTap: () => _selectDate(context),
                    readOnly: true,

                    // Prevent keyboard from appearing
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Select Date',
                      hintStyle: TextStyle(
                          color: Colors.grey[900],
                          fontSize: 19,
                          fontWeight: FontWeight.w400),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
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
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Grouping',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: headingBlue,
                  ),
                ),
                const SizedBox(height: 10),
                _groupNames.isEmpty
                    ? CircularProgressIndicator()
                    : Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 0.4,

                              blurRadius: 10,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          hint: Text('Select a Group'),
                          value: _selectedGroup,
                          decoration: InputDecoration(
                            filled: true,
                            hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 19,
                                fontWeight: FontWeight.w400),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
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
                            DropdownMenuItem<String>(
                              value: 'add_new',
                              child: Text('Add New Group'),
                            ),
                          ],
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    if (selectedDate != null &&
                        titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        _selectedGroup != "" &&
                        selectedOccurrence.isNotEmpty) {
                      String res = await _authMethod.addEvent(
                        title: titleController.text,
                        description: descriptionController.text,
                        date: selectedDate!,
                        location: locationController.text,
                        occurrence: selectedOccurrence,
                        group: _selectedGroup!,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res)),
                      );

                      if (res == "Event added successfully") {
                        // Clear the form fields
                        titleController.clear();
                        descriptionController.clear();
                        locationController.clear();
                        setState(() {
                          dateController.clear();
                          selectedDate = DateTime.now();
                          selectedOccurrence = 'No occurrence';
                          _selectedGroup = null;
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill in all fields")),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[500],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Submit Event',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(
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
