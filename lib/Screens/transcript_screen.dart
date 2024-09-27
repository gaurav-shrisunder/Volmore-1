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
  List<EventDataModel> _eventsFuture = [];
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

  String lifetimeMinutes = "";

  Future<void> createAndSharePdf() async {
    records.clear();
    UserModel userDetails = await fetchUserData();
   // List<EventDataModel> data = await _logMethod.fetchAllEventsWithLogs();
    for (var action in groupTrashCleanUp) {
      action.logs?.forEach((log){
        records.add(Record(group: action.group!, title: action.title!, host: action.host!, address: log.address!, timeElapsed: log.elapsedTime!, signature: log.isSignatureVerified.toString(), location: log.isLocationVerified.toString(), timer: log.isTimeVerified.toString()));
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }


  Future<pw.Document> generatePdf(List<Record>  data, UserModel user) async {
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
                  border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
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
        child: FutureBuilder<List<EventDataModel>>(
            future: _logMethod.fetchAllEventsWithLogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {

                _eventsFuture = snapshot.data!;
                print('Event liss:: ${_eventsFuture}');
                if(_eventsFuture.isNotEmpty){


                for (var event in _eventsFuture) {
                  // log("_eventsFutureGroup :: ${event.group}");
                  event.logs!.forEach((action) {
                    if (event.group!.contains("Trash")) {
                      trashHours = (trashHours +
                          int.parse(action.elapsedTime!.split(":")[1]))!;
                    } else if (event.group!.toLowerCase().contains("Food")) {
                      foodHours = (foodHours +
                          int.parse(action.elapsedTime!.split(":")[1]))!;
                    } else if (event.group!
                        .toLowerCase()
                        .contains("hospital")) {
                      hospServiceHours = (hospServiceHours +
                          int.parse(action.elapsedTime!.split(":")[1]))!;
                    } else {
                      otherHours = (otherHours +
                          int.parse(action.elapsedTime!.split(":")[1]))!;
                    }
                    lifetimeCountedMinutes = (lifetimeCountedMinutes +
                        int.parse(action.elapsedTime!.split(":")[1]))!;
                  });
                }
                print('Counted minutes : ${lifetimeCountedMinutes}');
                groupTrashCleanUp.clear();
                groupFoodService.clear();
                groupTestOthers.clear();
                groupHospitalService.clear();
                groupTrashCleanUp.addAll(_eventsFuture
                    .where((test) => test.group!.contains("Trash Cleaning")));
                groupFoodService.addAll(_eventsFuture
                    .where((test) => test.group!.contains("food service")));
                groupHospitalService.addAll(_eventsFuture
                    .where((test) => test.group!.contains("hospital service")));
                groupTestOthers.addAll(_eventsFuture
                    .where((test) => test.group!.contains("test")));

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Lifetime volunteer minutes: $lifetimeCountedMinutes",
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
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
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
                            buildGroupedContainer(
                                groupTrashCleanUp, trashHours),
                            const SizedBox(
                              height: 20,
                            ),
                            buildGroupedContainer(groupFoodService, foodHours),
                            const SizedBox(
                              height: 20,
                            ),
                            buildGroupedContainer(
                                groupHospitalService, hospServiceHours),
                            const SizedBox(
                              height: 20,
                            ),
                            buildGroupedContainer(groupTestOthers, otherHours),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );} else{
                  return const Center(child: Text("No Transcript yet"));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

   buildGroupedContainer(
      List<EventDataModel> groupName, int totalMinutes) {
    return Container(
      // padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: Colors.grey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: groupName.first.group!.toLowerCase().contains("trash") ? Colors.pink.shade50 : groupName.first.group!.toLowerCase().contains("hospital") ? Colors.green.shade50 : groupName.first.group!.toLowerCase().contains("food") ? Colors.orange.shade100 : Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              //   border: Border.all(width: 1, color: Colors.black)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  groupName.first.group!,
                  style: TextStyle(color: groupName.first.group!.toLowerCase().contains("trash") ? Colors.pink : groupName.first.group!.toLowerCase().contains("hospital") ? Colors.green : groupName.first.group!.toLowerCase().contains("food") ? Colors.orange : Colors.grey,
                      fontSize: 16),
                ),
                Text("Total minutes: $totalMinutes"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupName.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: groupName[index].logs?.length,
                      itemBuilder: (context, i) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              groupName[index].title!,
                              style:
                                  TextStyle(color: groupName.first.group!.toLowerCase().contains("trash") ? Colors.pink : groupName.first.group!.toLowerCase().contains("hospital") ? Colors.green : groupName.first.group!.toLowerCase().contains("food") ? Colors.orange : Colors.grey,
                                      fontSize: 16),
                            ),
                            Text(
                              DateFormat.yMMMMEEEEd().format(
                                  groupName[index].logs![i].date.toDate()),
                              style:
                                  const TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            Text(
                              "${DateFormat('h:mm a').format(groupName[index].logs![i].startTime.toDate())} - ${DateFormat('h:mm a').format(groupName[index].logs![i].endTime.toDate())}",
                              style:
                                  const TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            Text(
                              "Host: ${groupName[index].host!}",
                              style:
                                  const TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${groupName[index].logs![i].address}",
                                    maxLines: 3,
                                    softWrap: true,textAlign: TextAlign.left,
                                    style: const TextStyle(
                                  
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: groupName[index]
                                              .logs![i]
                                              .isLocationVerified!
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    SvgPicture.asset(
                                      "assets/icons/signature_icon.svg",
                                      color: groupName[index]
                                              .logs![i]
                                              .isSignatureVerified!
                                          ? Colors.black
                                          : Colors.grey.shade400,

                                      //  size: 30,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.timer,
                                      color: groupName[index]
                                              .logs![i]
                                              .isTimeVerified!
                                          ? Colors.black
                                          : Colors.grey.shade400,
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
                      });
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





