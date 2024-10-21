import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Models/request_models/share_transcript_request_model.dart';
import 'package:volunterring/Models/response_models/sign_up_response_model.dart';
import 'package:volunterring/Models/response_models/transcript_response.dart';
import 'package:volunterring/Services/profile_services.dart';
import 'package:volunterring/Utils/shared_prefs.dart';

import '../Models/UserModel.dart';
import '../Models/event_data_model.dart';
import '../Services/logService.dart';
import '../Utils/Colors.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  int lifetimeCountedMinutes = 0;
  List<EventDataModel> groupTrashCleanUp = [];
  List<EventDataModel> groupFoodService = [];
  List<EventDataModel> groupTestOthers = [];
  List<EventDataModel> groupHospitalService = [];
  int trashHours = 0;
  int foodHours = 0;
  int hospServiceHours = 0;
  int otherHours = 0;

  TranscriptResponse? transcript;
  List<Event> events = [];

  String lifetimeMinutes = "";

  Future<void> createAndSharePdf() async {
    User? user = await getUser();
    // List<EventDataModel> data = await _logMethod.fetchAllEventsWithLogs();

    pw.Document pdf = await generatePdf(events, user!);
    await saveAndSharePdf(pdf);
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                createAndSharePdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Share with Teacher'),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _showShareWithTeacherModal(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showShareWithTeacherModal(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    ProfileServices profileServices = ProfileServices();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share with Teacher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Teacher\'s Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the modal
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
                // Padding
              ),
              onPressed: () async {
                String teacherEmail = emailController.text;
                User? user = await getUser();
                // Add your Share functionality here using teacherEmail
                var res = await profileServices.shareWithTeacher(
                    ShareResponseRequestModel(
                        emailId: teacherEmail, userId: user!.userId!));
                Fluttertoast.showToast(msg: res);

                Navigator.pop(context); // Close the modal after sharing
              },
              child: const Text(
                'Share',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<UserModel> fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('uid');
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  ProfileServices profileServices = ProfileServices();
  bool isLoading = true;
  bool isError = false;

  void fetchTranscript() async {
    TranscriptResponse? temp = await profileServices.getTranscript();

    for (var eve in temp!.transcripts!) {
      for (var event in eve.event!) {
        events.add(event);
      }
    }

    if (temp != null) {
      setState(() {
        transcript = temp;
        isLoading = false;
      });
    } else {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTranscript();
  }

  Future<pw.Document> generatePdf(List<Event> data, User user) async {
    final pdf = pw.Document();
    const pageFormat = PdfPageFormat.a4;
    const margin = 20.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(margin),
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Volmore',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Name: ${user.userName}'),
                pw.Text('Email: ${user.emailId}'),
                pw.Text('Year of Study: ${user.yearOfStudy}'),
                pw.Text('University: ${user.university}'),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  border:
                      pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  headers: [
                    'Title',
                    'Host',
                    'Address',
                    'Time Elapsed',
                    'Sign',
                    'Location',
                  ],
                  data: data.map((record) {
                    return [
                      record.eventTitle,
                      record.hostName,
                      record.userLocation,
                      record.userDateTime,
                      record.verifierSignatureHash,
                      record.userLocation,
                    ];
                  }).toList(),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  Future<void> saveAndSharePdf(pw.Document pdf) async {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'my_transcript.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<TranscriptResponse?>(
            future: profileServices.getTranscript(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                transcript = snapshot.data!;
                print('Event liss:: $transcript');
                if (transcript != null) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Lifetime volunteer Hours: ${transcript?.lifeTimeHour ?? 0}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              onPressed: () {
                                _showShareOptions(context);
                              },
                              child: const Text(
                                'Share',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap:
                                    true, // Ensures the ListView doesn't take infinite height
                                physics:
                                    const NeverScrollableScrollPhysics(), // Disables internal scrolling since SingleChildScrollView handles scrolling
                                itemCount: transcript?.transcripts?.length ??
                                    0, // Set item count based on the length of transcripts
                                itemBuilder: (context, index) {
                                  return buildGroupedContainer(
                                      transcript!.transcripts![index]);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text("No Transcript yet"));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  buildGroupedContainer(Transcript transcripts) {
    return Column(
      children: [
        ExpansionTile(
          title: Text(
            transcripts.eventCategoryName ?? "Trash",
            style: const TextStyle(fontSize: 16),
          ),
          subtitle: Text("Total Hours ${transcripts.totalHours}"),
          collapsedBackgroundColor:
              HexColor(transcripts.eventColorCode!).withOpacity(0.2),
          // backgroundColor:
          //     HexColor(transcripts.eventColorCode!).withOpacity(0.1),
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: const BorderSide()),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: const BorderSide()),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transcripts.event?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Event? event = transcripts.event?[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                              width: 2,
                              color: HexColor(transcripts.eventColorCode!)
                                  .withOpacity(0.2))),
                      color: Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event?.eventTitle.toString().capitalize ?? "",
                              style: TextStyle(
                                  color: HexColor(transcripts.eventColorCode!),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              DateFormat.yMMMMEEEEd().format(DateTime.parse(
                                  event!.eventDateTime!.split("|")[0])),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Host: ${event.hostName}",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Duration : ${DateFormat('h:mm a').format(DateTime.parse(event.userDateTime!.split("|")[0]))} - ${DateFormat('h:mm a').format(DateTime.parse(event.userDateTime!.split("|")[1]))}",
                              maxLines: 3,
                              softWrap: true,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Location : ${event.userLocation}",
                                    maxLines: 3,
                                    softWrap: true,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: event.userLocation!.isNotEmpty
                                          ? HexColor(
                                              transcripts.eventColorCode!)
                                          : Colors.grey.shade400,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 5),
                                    SvgPicture.asset(
                                      "assets/icons/signature_icon.svg",
                                      color: event
                                              .verifierSignatureHash!.isNotEmpty
                                          ? HexColor(
                                              transcripts.eventColorCode!)
                                          : Colors.grey.shade400,
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.timer,
                                      color:
                                          HexColor(transcripts.eventColorCode!),
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}

class Record {
  final String group;
  final String title;
  final String host;
  final String address;
  final String timeElapsed;
  final String signature;
  final String location;
  final String timer;

  Record({
    required this.group,
    required this.title,
    required this.host,
    required this.address,
    required this.timeElapsed,
    required this.signature,
    required this.location,
    required this.timer,
  });
}
