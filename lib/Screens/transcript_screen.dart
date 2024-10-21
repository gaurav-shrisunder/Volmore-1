import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Models/response_models/transcript_response.dart';
import 'package:volunterring/Services/profile_services.dart';

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
  final LogServices _logMethod = LogServices();
  int lifetimeCountedMinutes = 0;
  List<EventDataModel> groupTrashCleanUp = [];
  List<EventDataModel> groupFoodService = [];
  List<EventDataModel> groupTestOthers = [];
  List<EventDataModel> groupHospitalService = [];
  int trashHours = 0;
  int foodHours = 0;
  int hospServiceHours = 0;
  int otherHours = 0;
  List<Record> records = [];
  TranscriptResponse? transcript;

  String lifetimeMinutes = "";

  Future<void> createAndSharePdf() async {
    records.clear();
    UserModel userDetails = await fetchUserData();
    // List<EventDataModel> data = await _logMethod.fetchAllEventsWithLogs();
    for (var action in groupTrashCleanUp) {
      action.logs?.forEach((log) {
        records.add(Record(
            group: action.group!,
            title: action.title!,
            host: action.host!,
            address: log.address!,
            timeElapsed: log.elapsedTime!,
            signature: log.isSignatureVerified.toString(),
            location: log.isLocationVerified.toString(),
            timer: log.isTimeVerified.toString()));
      });
    }
    pw.Document pdf = await generatePdf(records, userDetails);
    await saveAndSharePdf(pdf);
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
  }

  Future<pw.Document> generatePdf(List<Record> data, UserModel user) async {
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
                pw.Text('Name: ${user.name}'),
                pw.Text('Email: ${user.email}'),
                pw.Text('University: Pule University'),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  border:
                      pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  headers: [
                    'Group',
                    'Title',
                    'Host',
                    'Address',
                    'Time Elapsed',
                    'Sign',
                    'Location',
                    'Timer',
                  ],
                  data: records.map((record) {
                    return [
                      record.group,
                      record.title,
                      record.host,
                      record.address,
                      record.timeElapsed,
                      record.signature,
                      record.location,
                      record.timer,
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
                              onPressed: createAndSharePdf,
                              child: const Text(
                                'Export',
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
    return Container(
      // padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: Colors.grey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: HexColor(transcripts.eventColorCode!).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              //   border: Border.all(width: 1, color: Colors.black)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transcripts.eventCategoryName ?? "Trash",
                  style: TextStyle(
                      color: HexColor(transcripts.eventColorCode!),
                      fontSize: 16),
                ),
                Text("Total Hours ${transcripts.totalHours}"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transcripts.event?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Event? event = transcripts.event?[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event?.eventTitle ?? "",
                        style: TextStyle(
                            color: HexColor(transcripts.eventColorCode!),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat.yMMMMEEEEd().format(DateTime.parse(
                            event!.eventDateTime!.split("|")[0])),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      // Text(
                      //   "${DateFormat('h:mm a').format(groupName[index].logs![i].startTime.toDate())} - ${DateFormat('h:mm a').format(groupName[index].logs![i].endTime.toDate())}",
                      //   style:
                      //       const TextStyle(color: Colors.black, fontSize: 14),
                      // ),
                      Text(
                        "Host: ${event.hostName}",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${event.userLocation}",
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
                                    ? Colors.black
                                    : Colors.grey.shade400,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              SvgPicture.asset(
                                "assets/icons/signature_icon.svg",
                                color: event.verifierSignatureHash!.isNotEmpty
                                    ? Colors.black
                                    : Colors.grey.shade400,

                                //  size: 30,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.timer,
                                color: Colors.black,
                                size: 30,
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  );
                }),
          ),
        ],
      ),
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
