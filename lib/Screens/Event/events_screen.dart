// ignore_for_file: prefer_is_empty

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:volunterring/Screens/Event/past_event_verification_page.dart';
import 'package:volunterring/main.dart';

import '../../Models/event_data_model.dart';
import '../../Models/response_models/events_data_response_model.dart';
import '../../Services/deep_links.dart';
import '../../Services/events_services.dart';
import '../../Utils/Colors.dart';
import '../../Utils/shared_prefs.dart';
import '../CreateLogScreen.dart';
import 'events_widget.dart';
import 'log_now_page.dart';

//enum SortOption { def, az, za, dateAsc, dateDesc }

class EventsScreen extends StatefulWidget {
  final SortOption initialSortOption;
  const EventsScreen({super.key, required this.initialSortOption});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  final EventsServices _eventsServices = EventsServices();
  EventsDataResponseModel pastEvent = EventsDataResponseModel();
  SortOption? _selectedOption;
  late TabController _tabController;
  late Future<EventsDataResponseModel?> pastEventFuture;
  late Future<EventsDataResponseModel?> upcomingEventFuture;
  late Future<EventsDataResponseModel?> todayEventFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedOption = widget.initialSortOption;
    apiCalling();
  }

  apiCalling() async {
    pastEventFuture = _eventsServices.getEventsData("past");
    upcomingEventFuture = _eventsServices.getEventsData("upcoming");
    todayEventFuture = _eventsServices.getEventsData("today");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          bottom: TabBar(
            controller: _tabController,
            labelStyle: const TextStyle(fontSize: 14),
            tabs: const [
              Tab(text: "Today's"),
              Tab(text: "Upcoming"),
              Tab(text: "Past"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildEventsFutureBuilder("Today Event", todayEventFuture),
          buildEventsFutureBuilder("Upcoming Event", upcomingEventFuture),
          buildEventsFutureBuilder("Past Event", pastEventFuture),
        ],
      ),
    );
  }

  FutureBuilder<EventsDataResponseModel?> buildEventsFutureBuilder(
      String tabName, Future<EventsDataResponseModel?> eventFuture) {
    return FutureBuilder<EventsDataResponseModel?>(
        future: eventFuture,
        builder: (context, snapshot) {
          if (ConnectionState.done == snapshot.connectionState) {
            return Column(
              children: [
                //   const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tabName,
                        style: const TextStyle(
                          //     color: headingBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          if (tabName.contains("Today Event"))
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFfa6513),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              onPressed: () {
                                Get.to(const CreateLogScreen());
                              },
                              child: const Text(
                                'Create Event',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    SortOption? selectedOption =
                                        _selectedOption;

                                    return SimpleDialog(
                                      //  backgroundColor: Colors.white,
                                      title: const Text("Sort by"),
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RadioListTile<SortOption>(
                                              title: const Text(
                                                  'Default: By Name'),
                                              value: SortOption.def,
                                              groupValue: selectedOption,
                                              onChanged: (SortOption? value) {
                                                setState(() {
                                                  selectedOption = value;
                                                  _selectedOption =
                                                      selectedOption;
                                                  //   events.sort((a, b) => a.event!.title!.compareTo(b.event!.title!));
                                                  // Update the main event list
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            RadioListTile<SortOption>(
                                              title: const Text('A-Z'),
                                              value: SortOption.az,
                                              groupValue: selectedOption,
                                              onChanged: (SortOption? value) {
                                                setState(() {
                                                  selectedOption = value;
                                                  _selectedOption =
                                                      selectedOption;

                                                  //   events.sort((a, b) => a.event!.title!.compareTo(b.event!.title!));
                                                  //   _updateEventList(events); // Update the main event list
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            RadioListTile<SortOption>(
                                              title: const Text('Z-A'),
                                              value: SortOption.za,
                                              groupValue: selectedOption,
                                              onChanged: (SortOption? value) {
                                                setState(() {
                                                  selectedOption = value;
                                                  _selectedOption =
                                                      selectedOption;
                                                  //   events.sort((a, b) => b.event!.title!.compareTo(a.event!.title!));
                                                  //    _updateEventList(events); // Update the main event list
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            RadioListTile<SortOption>(
                                              title:
                                                  const Text('Date: Ascending'),
                                              value: SortOption.dateAsc,
                                              groupValue: selectedOption,
                                              onChanged: (SortOption? value) {
                                                setState(() {
                                                  selectedOption = value;
                                                  _selectedOption =
                                                      selectedOption;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            RadioListTile<SortOption>(
                                              title: const Text(
                                                  'Date: Descending'),
                                              value: SortOption.dateDesc,
                                              groupValue: selectedOption,
                                              onChanged: (SortOption? value) {
                                                setState(() {
                                                  selectedOption = value;
                                                  _selectedOption =
                                                      selectedOption;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.sort))
                        ],
                      ),
                    ],
                  ),
                ),
                snapshot.data?.eventDetails?.events?.length == 0
                    ? const Expanded(
                        child: Center(
                          child: Text(
                            "No Events Found",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount:
                              snapshot.data?.eventDetails?.events?.length,
                          itemBuilder: (context, index) {
                            // EventDataModel? event = events[index].event;
                            // DateTime date = DateTime.parse(snapshot.data!.events![index].eventInstance!.eventStartDateTime!);

                            //  Color color =colorMap[getGroupColor(event!)] ?? Colors.pink;

                            bool isEnabled = false;
                            String buttonText = "";
                            //   bool isVerified = snapshot.data!.events![index].eventParticipant?.verifierSignatureHash != "";/*isLogSignatureVerified(event, date);*/
                            if (tabName.contains("Today")) {
                              isEnabled = true;
                              buttonText = "Log Now";
                            } else if (tabName.contains("Upcoming")) {
                              isEnabled = false;
                              buttonText = "Log Now";
                            } else {
                              bool isVerified = snapshot
                                      .data!
                                      .eventDetails
                                      ?.events![index]
                                      .eventParticipant
                                      ?.verifierSignatureHash !=
                                  ""; /*isLogSignatureVerified(event, date);*/
                              if (isVerified) {
                                isEnabled = false;
                                buttonText = "Verify";
                              } else {
                                isEnabled = true;
                                buttonText = "Verify";
                              }
                            }


                            if(snapshot.data != null){
                              return /*snapshot.data?.eventDetails?.events?[index].eventParticipant?.verifierSignatureHash != "" */ /*&& isToday*/ /*
                             ? const SizedBox()
                             :*/
                                Center(
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot
                                                    .data
                                                    ?.eventDetails
                                                    ?.events?[index]
                                                    .event
                                                    ?.eventTitle
                                                    ?.capitalize ??
                                                    "",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: HexColor(snapshot
                                                        .data!
                                                        .eventDetails!
                                                        .events![index]
                                                        .event!
                                                        .eventColorCode!)),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                      //  color: Colors.white,
                                                      borderRadius:
                                                      BorderRadius.circular(8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          spreadRadius: 1,
                                                          blurRadius: 2,
                                                          offset:
                                                          const Offset(0, 1),
                                                        ),
                                                      ],
                                                      border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(0.5)),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.date_range,
                                                            size: 16,
                                                            color: Colors.green),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          DateFormat.yMMMd().format(
                                                              DateTime.parse(snapshot
                                                                  .data!
                                                                  .eventDetails!
                                                                  .events![index]
                                                                  .eventInstance!
                                                                  .eventStartDateTime!)),
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                              fontWeight: FontWeight
                                                                  .normal),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                      //  color: Colors.white,
                                                      borderRadius:
                                                      BorderRadius.circular(8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          spreadRadius: 1,
                                                          blurRadius: 2,
                                                          offset:
                                                          const Offset(0, 1),
                                                        ),
                                                      ],
                                                      border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(0.5)),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.person,
                                                            size: 16,
                                                            color: Colors.blue),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'Host by: ${snapshot.data!.eventDetails!.events![index].event?.hostName}',
                                                          softWrap: true,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                              fontWeight: FontWeight
                                                                  .normal),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Event Description: ${snapshot.data!.eventDetails!.events![index].event?.eventDescription ?? "Description"}",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Image.asset(
                                                            'assets/icons/share.png'),
                                                        onPressed: () async {
                                                          final String? uid =
                                                          await getUserId();
                                                          String url =
                                                          await createDynamicLink(
                                                        snapshot
                                                            .data!
                                                            .eventDetails!
                                                            .events![index]
                                                            .eventInstance!
                                                            .eventInstanceId!,
                                                      );
                                                      print("URL: $url");
                                                      Share.share(url);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Image.asset(
                                                        'assets/icons/add.png'),
                                                    onPressed: () {},
                                                  ),
                                                  IconButton(
                                                    icon: Image.asset(
                                                        'assets/icons/edit.png'),
                                                    onPressed: () {},
                                                  ),
                                                ],
                                              ),
                                              ActionChip(
                                                backgroundColor:
                                                    Colors.lightBlue,
                                                    side: BorderSide.none,
                                                    disabledColor: Colors.grey
                                                        .withOpacity(0.6),
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 5),
                                                    label: Text(
                                                      buttonText,
                                                      style: const TextStyle(
                                                          color: /*isEnabled*/ false
                                                              ? Colors.white
                                                              : Colors.black,
                                                          fontSize: 16),
                                                    ),
                                                    onPressed: isEnabled
                                                        ? () {
                                                      if (tabName.contains(
                                                          "Today")) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => LogNowPage(
                                                                snapshot
                                                                    .data!
                                                                    .eventDetails!
                                                                    .events![
                                                                index]
                                                                    .event!,
                                                                snapshot
                                                                    .data!
                                                                    .eventDetails!
                                                                    .events![
                                                                index]
                                                                    .eventInstance!),
                                                          ),
                                                        );
                                                      }
                                                      if (tabName
                                                          .contains("Past")) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PastEventVerification(
                                                                  date: snapshot
                                                                      .data!
                                                                      .eventDetails!
                                                                      .events![
                                                                  index]
                                                                      .event!
                                                                      .reccurencePattern!
                                                                      .eventStartDateTime!,
                                                                  event: snapshot
                                                                      .data!
                                                                      .eventDetails!
                                                                      .events![index],
                                                                  eventInstanceId: snapshot
                                                                      .data!
                                                                      .eventDetails!
                                                                      .events![
                                                                  index]
                                                                      .eventInstance!
                                                                      .eventInstanceId!,
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    labelPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 5),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.5),
                                          child: Container(
                                            width: 5,
                                            decoration: BoxDecoration(
                                              color: HexColor(snapshot
                                                  .data!
                                                  .eventDetails!
                                                  .events![index]
                                                  .event!
                                                  .eventColorCode!),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                            }else{
                              return Center(
                                child: ActionChip(label: Text("Reload"),onPressed: (){
                                  main();
                                },),
                              );
                            }


                          },
                        ),
                      ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

/*  bool isLogSignatureVerified(EventParticipant event, DateTime date) {
  */ /*  if (event. == null) return false;*/ /*

    for (var log in event.logs!) {
      if (isSameDate(log.date.toDate(), date)) {
        return log.isSignatureVerified == true;
      }
    }

    return false;
  }*/

  /*bool isLogPresent(EventParticipant event, DateTime date) {
    if (event.logs == null) return false;

    for (var log in event.logs!) {
      if (isSameDate(log.date.toDate(), date)) {
        return true;
      }
    }

    return false;
  }*/
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
