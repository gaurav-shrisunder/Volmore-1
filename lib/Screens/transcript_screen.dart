import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/request_models/share_transcript_request_model.dart';
import '../../Models/response_models/shared_transcript_response.dart';
import '../../Models/response_models/sign_up_response_model.dart';
import '../../Models/response_models/transcript_response.dart';
import '../../Services/profile_services.dart';
import '../../Utils/shared_prefs.dart';

import '../Models/UserModel.dart';
import '../Models/event_data_model.dart';
import '../Services/logService.dart';
import '../Utils/Colors.dart';
import '../Utils/common_utils.dart';

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
  SharedTranscriptResponse sharedTranscriptResponse =
      SharedTranscriptResponse();

  TranscriptResponse? transcript;
  List<Event> events = [];

  String lifetimeMinutes = "";

  Future<void> createAndSharePdf(String lifetimeHours) async {
    User? user = await getUser();
    // List<EventDataModel> data = await _logMethod.fetchAllEventsWithLogs();

    pw.Document pdf = await generatePdf(events, user!, lifetimeHours);

    String filename = "${user.userName}-${getFormatedDate()}";
    await saveAndSharePdf(pdf, filename);
  }

  void _showShareOptions(BuildContext context, String lifetimeHours) {
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
                createAndSharePdf(lifetimeHours);
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
            SizedBox(
              height: 40,
            )
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
          backgroundColor: Colors.white,
          title: const Text('Share with Teacher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
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
    sharedTranscriptResponse =
        (await profileServices.getTranscriptSharedEmails());

    for (var eve in temp!.transcripts!) {
      for (var event in eve.event!) {
        events.add(event);
      }
    }

    setState(() {
      transcript = temp;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTranscript();
  }

  Future<pw.Document> generatePdf(
      List<Event> data, User user, String lifetimeHours) async {
    final pdf = pw.Document();
    const pageFormat = PdfPageFormat.letter;
    const margin = 20.0;
    const maxRowsPerPage = 30;
    final logoBytes = await loadAssetImage('assets/icons/lenda_logo.png');
    final logoImage = pw.MemoryImage(logoBytes);

    final chunkedData = List.generate(
      (data.length / maxRowsPerPage).ceil(),
      (index) =>
          data.skip(index * maxRowsPerPage).take(maxRowsPerPage).toList(),
    );

    final totalHours = lifetimeHours;

    try {
      for (var i = 0; i < chunkedData.length; i++) {
        final chunk = chunkedData[i];
        pdf.addPage(
          pw.MultiPage(
            pageFormat: pageFormat,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            margin: const pw.EdgeInsets.all(margin),
            footer: (pw.Context context) {
              if (context.pageNumber == context.pagesCount) {
                final timeStamp =
                    formatDateTime(DateTime.now().toLocal().toIso8601String());
                return pw.Center(
                    child: pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 40),
                  child: pw.Text(
                    'Lenda is a product of the MaizeLab.\nFor any questions, please email collaborate@maize-lab.com \n Generated on $timeStamp',
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.center,
                  ),
                ));
              } else {
                return pw.SizedBox(); // Empty footer for all other pages
              }
            },
            build: (pw.Context context) {
              return [
                // Header Section (only on first page)
                if (i == 0)
                  pw.Container(
                    padding: const pw.EdgeInsets.only(bottom: 30),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Section: User Info
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Official Volunteering Transcript',
                                style: pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(height: 8),
                            pw.Text(user.userName ?? '',
                                style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('Email: ${user.emailId}',
                                style: pw.TextStyle(fontSize: 12)),
                            pw.Text('Class of ${user.yearOfStudy ?? '____'}',
                                style: pw.TextStyle(fontSize: 12)),
                          ],
                        ),
                        // Right Section: Total Hours
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // pw.Text('Recorded by', style: const pw.TextStyle(fontSize: 10)),
                            pw.Row(children: [
                              pw.Text('lenda',
                                  style: pw.TextStyle(
                                      fontSize: 24,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.green800)),
                              pw.SizedBox(width: 4),
                              // Spacing between text and image
                              pw.Image(logoImage, width: 24, height: 24),
                            ]),
                            pw.Text('Your social volunteering app.',
                                style: const pw.TextStyle(fontSize: 8)),
                            pw.SizedBox(height: 6),
                            // Spacing between text and image

                            if (i == 0)
                              pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColors.green,
                                    ),
                                    borderRadius: pw.BorderRadius.all(
                                        pw.Radius.circular(8))),
                                alignment: pw.Alignment.centerRight,
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.center,
                                  children: [
                                    pw.Text('Total Hours: ',
                                        style: pw.TextStyle(
                                            fontSize: 14,
                                            color: PdfColors.green)),
                                    pw.Text(totalHours,
                                        style: pw.TextStyle(
                                            fontSize: 16,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.green)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Branding Header Row

                // Table
                pw.TableHelper.fromTextArray(
                  border:
                      pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  headerStyle: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2), // Title
                    1: const pw.FlexColumnWidth(2), // Host
                    2: const pw.FlexColumnWidth(2), // Address
                    3: const pw.FlexColumnWidth(2), // Time Elapsed
                    4: const pw.FlexColumnWidth(2), // Sign
                    5: const pw.FlexColumnWidth(2), // User Location
                  },
                  headers: [
                    'Volunteer',
                    'Event',
                    'Event Location',
                    'Start and End Time',
                    'Signed by Organizer',
                    'Location Verified'
                  ],
                  data: chunk.map((record) {
                    final userTimeParts = record.userDateTime!.split('|');
                    final startDate = DateFormat('MM/dd/yyyy  hh:mm a')
                        .format(DateTime.parse(userTimeParts.first).toLocal());
                    final endDate = DateFormat('MM/dd/yyyy  hh:mm a')
                        .format(DateTime.parse(userTimeParts.last).toLocal());
                    return [
                      record.hostName ?? '',
                      record.eventTitle ?? '',
                      record.eventLocation ?? '',
                      '$startDate to $endDate',
                      (record.verifierSignatureHash?.isNotEmpty ?? false)
                          ? 'Yes'
                          : 'No',
                      record.isLoggedAsPast == true
                          ? 'N/A'
                          : (record.userLocation != ""
                              ? record.userLocation
                              : 'N/A'),
                    ];
                  }).toList(),
                ),
              ];
            },
          ),
        );
      }
    } catch (e) {
      print("Error generating PDF: $e");
    }

    return pdf;
  }

  Future<Uint8List> loadAssetImage(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<void> saveAndSharePdf(pw.Document pdf, String fileName) async {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'lenda Transcript-$fileName.pdf',
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
                              "Lifetime volunteer : ${(transcript?.lifeTimeHour ?? 0) ~/ 60} Hours ${(transcript?.lifeTimeHour ?? 0) % 60} Mins ",
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
                                /*${(transcript?.lifeTimeHour ?? 0) % 60}Mins*/
                                _showShareOptions(context,
                                    "${(transcript?.lifeTimeHour ?? 0) ~/ 60}.${(transcript?.lifeTimeHour ?? 0) % 60}");
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
                                shrinkWrap: true,
                                // Ensures the ListView doesn't take infinite height
                                physics: const NeverScrollableScrollPhysics(),
                                // Disables internal scrolling since SingleChildScrollView handles scrolling
                                itemCount: transcript?.transcripts?.length ?? 0,
                                // Set item count based on the length of transcripts
                                itemBuilder: (context, index) {
                                  return buildGroupedContainer(
                                      transcript!.transcripts![index]);
                                },
                              ),
                              (sharedTranscriptResponse.sharedInfo != null &&
                                      sharedTranscriptResponse
                                              .sharedInfo?.length !=
                                          0)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Transcripts Shared:"),
                                        ListView.builder(
                                            itemCount: sharedTranscriptResponse
                                                .sharedInfo?.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "Email:${sharedTranscriptResponse.sharedInfo![index].emailId}"),
                                                    Text(
                                                        " ${DateFormat.yMMMd().format(DateTime.parse(sharedTranscriptResponse.sharedInfo![index].sharedDate!).toLocal())}"),
                                                  ],
                                                ),
                                              );
                                            }),
                                      ],
                                    )
                                  : SizedBox()
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

  Widget buildGroupedContainer(Transcript transcripts) {
    final eventColor = HexColor(transcripts.eventColorCode!).withOpacity(0.1);
    final borderColor = HexColor(transcripts.eventColorCode!).withOpacity(0.5);
    final titleColor = HexColor(transcripts.eventColorCode!);

    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor, width: 1),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              backgroundColor: eventColor,
              collapsedBackgroundColor: eventColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                transcripts.eventCategoryName ?? "Unknown Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              subtitle: Text(
                "Total: ${transcripts.totalHours! ~/ 60}h ${transcripts.totalHours! % 60}m",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transcripts.event?.length ?? 0,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = transcripts.event![index];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.eventTitle?.capitalize ?? "Untitled Event",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat.yMMMMEEEEd().format(
                                    DateTime.parse(
                                        event.eventDateTime!.split("|")[0]),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16),
                                const SizedBox(width: 6),
                                Text("Host: ${event.hostName ?? "---"}",
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time_outlined,
                                    size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "Duration: ${DateFormat('h:mm a').format(DateTime.parse(event.userDateTime!.split("|")[0]).toLocal())} - ${DateFormat('h:mm a').format(DateTime.parse(event.userDateTime!.split("|")[1]).toLocal())}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    event.eventLocation ?? "---",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: event.isLoggedAsPast!
                                      ? Colors.grey.shade400
                                      : (event.userLocation!.isNotEmpty
                                          ? titleColor
                                          : Colors.grey.shade400),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  "assets/icons/signature_icon.svg",
                                  color: event.verifierSignatureHash!.isNotEmpty
                                      ? titleColor
                                      : Colors.grey.shade400,
                                  width: 24,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.timer,
                                  color: event.isLoggedAsPast!
                                      ? Colors.grey.shade400
                                      : (event.userLocation!.isNotEmpty
                                          ? titleColor
                                          : Colors.grey.shade400),
                                  size: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
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
