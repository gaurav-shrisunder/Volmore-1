import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Screens/Event/events_widget.dart';
import 'package:volunterring/Screens/HomePage.dart';
import 'package:volunterring/Services/authentication.dart';
import 'package:volunterring/Utils/Colormap.dart';
import 'package:volunterring/Utils/Colors.dart';

class VolunteerConfirmationScreen extends StatefulWidget {
  final EventDataModel event;
  const VolunteerConfirmationScreen({super.key, required this.event});

  @override
  State<VolunteerConfirmationScreen> createState() => _VolunteerConfirmationScreenState();
}

class _VolunteerConfirmationScreenState extends State<VolunteerConfirmationScreen> {
  final _authMethod = AuthMethod();
  late Future<List<EventDataModel>> _eventsFuture;
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _eventsFuture = _authMethod.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    Color color = colorMap[widget.event.groupColor] ?? Colors.pink;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final SignatureController controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,

    );

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
            onTap: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
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
        child: Padding(
          padding: const EdgeInsets.all(18.0),
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
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: greyColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.event.location ?? "",
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
                    widget.event.time ?? "",
                    style: const TextStyle(fontSize: 16, color: greyColor),
                  ),
                ],
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

                    controller: controller,
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
                      ),
                    ),
                  ),
                ],
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
                      return SizedBox(
                        height: screenHeight * 0.4, // Adjust as needed
                        child: buildEventList("Past Events", (event) {
                          DateTime eventDate =
                              DateTime.parse(event.date.toString());
                          DateTime today =
                              DateTime.now().subtract(const Duration(days: 1));
                          return eventDate.isBefore(today);
                        }, snapshot.data!),
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventList(String title, bool Function(EventDataModel) filter,
      List<EventDataModel> events) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              EventDataModel event = events[index];
              Color color = colorMap[event.groupColor] ?? Colors.pink;
              bool isEnabled = event.dates!.contains(
                      DateFormat('dd/MM/yyyy').format(DateTime.now())) &&
                  title == "Today's Events";

              return filter(event)
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.title.toString().capitalize ?? "",
                                    style:
                                        TextStyle(color: color, fontSize: 18)),
                                const SizedBox(
                                  height: 2,
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
                                      event.time ?? "",
                                      style: const TextStyle(
                                          fontSize: 16, color: greyColor),
                                    ),
                                  ],
                                ),
                              ]),
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: greyColor,
                                size: 30,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.document_scanner_outlined,
                                color: greyColor,
                                size: 30,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.timer,
                                color: greyColor,
                                size: 30,
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  : Container();
            },
          ),
        ),
        GestureDetector(
          onTap: (){

          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 15, horizontal: 15),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.lightBlue[500],
                borderRadius: BorderRadius.circular(10)),
            child: const Center(
                child: Text(
              "Submit Event",
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            )),
          ),
        )
      ],
    );
  }
}
