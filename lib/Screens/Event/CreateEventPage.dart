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
  String _selectedColor = 'Green'; // Initial color value
  DateTime selectedDate = DateTime.now();
  final _authMethod = AuthMethod();

  String selectedOccurrence =
      'No occurrence'; // Initial value set to prevent null issues
  List<String> _groupNames = [];
  Map<String, String> _groupColors = {};
  String? _selectedGroup;
  final Uuid _uuid = Uuid();

  final Map<String, Color> colorMap = {
    'Green': Colors.green,
    'Pink': Colors.pink,
    'Orange': Colors.orange,
    'Red': Colors.red,
    'Yellow': Colors.yellow,
  };

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
      List<String> groupNames = querySnapshot.docs.map((doc) {
        _groupColors[doc['name']] =
            doc['color']; // Save the color for each group
        return doc['name'] as String;
      }).toList();
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
    _nameController.dispose();
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
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: InputDecoration(labelText: 'Group Color'),
                items: colorMap.keys.map((String colorName) {
                  return DropdownMenuItem<String>(
                    value: colorName,
                    child: Text(colorName),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedColor = newValue!;
                  });
                },
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
                if (name.isNotEmpty && _selectedColor.isNotEmpty) {
                  _addGroup(name, _selectedColor);
                  _nameController.clear();
                  setState(() {
                    _selectedColor = 'Green'; // Reset to default value
                  });
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
      appBar: AppBar(title: const Text('')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Schedule New Job',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: headingBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InputFeildWidget(
                  title: 'Title',
                  controller: titleController,
                  maxlines: 1,
                ),
                const SizedBox(height: 20),
                InputFeildWidget(
                  title: 'Description',
                  controller: descriptionController,
                  maxlines: 5,
                ),
                const SizedBox(height: 20),
                InputFeildWidget(
                  title: 'Location',
                  controller: locationController,
                  maxlines: 1,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Occurrence',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4484D2),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedOccurrence,
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    fillColor: lightBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
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
                const SizedBox(height: 20),
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4484D2),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  onTap: () => _selectDate(context),
                  readOnly: true,
                  // Prevent keyboard from appearing
                  decoration: InputDecoration(
                    hintText: 'Select Date',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    filled: true,
                    fillColor: lightBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Grouping',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4484D2),
                  ),
                ),
                const SizedBox(height: 10),
                _groupNames.isEmpty
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        hint: Text('Select a Group'),
                        value: _selectedGroup,
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          fillColor: lightBlue,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
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
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red[200],
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedDate != null &&
                        titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        _selectedGroup != "" &&
                        selectedOccurrence.isNotEmpty) {
                      String groupColor = _groupColors[_selectedGroup] ??
                          'Green'; // Default color if not found
                      String res = await _authMethod.addEvent(
                        title: titleController.text,
                        description: descriptionController.text,
                        date: selectedDate,
                        location: locationController.text,
                        occurrence: selectedOccurrence,
                        group: _selectedGroup!,
                        groupColor: groupColor, // Save group color
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
                  child: Text(
                    'Add Event',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
