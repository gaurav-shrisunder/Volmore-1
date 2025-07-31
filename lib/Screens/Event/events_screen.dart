// ignore_for_file: prefer_is_empty

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../Models/response_models/update_event_response_model.dart';
import '../../Screens/Event/past_event_verification_page.dart';
import '../../Screens/Event/timer_screen.dart';
import '../../main.dart';

import '../../Models/event_data_model.dart';
import '../../Models/request_models/create_event_request_model.dart';
import '../../Models/response_models/event_category_response_model.dart';
import '../../Models/response_models/events_data_response_model.dart';
import '../../Services/deep_links.dart';
import '../../Services/events_services.dart';
import '../../Utils/Colors.dart';
import '../../Utils/shared_prefs.dart';
import '../../widgets/InputFormFeild.dart';
import '../CreateLogScreen.dart';
import '../HomePage.dart';
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
  List<String> _groupNames = [];
  String? _selectedGroup;
  late Future<EventsDataResponseModel?> pastEventFuture;
  late Future<EventsDataResponseModel?> upcomingEventFuture;
  late Future<EventsDataResponseModel?> todayEventFuture;
  TextEditingController title = TextEditingController();
  TextEditingController eventLocation = TextEditingController();
  TextEditingController eventDescription = TextEditingController();
  TextEditingController eventCategory = TextEditingController();
  String sortByValue = "eventStartDateTime";
  String sortDirectionValue = "desc";
  List<EventCategories> eventCategoriesList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedOption = widget.initialSortOption;
    apiCalling(sortByValue, sortDirectionValue);
  }

  apiCalling(String sortByValue, String sortDirectionValue) async {
    pastEventFuture = _eventsServices.getEventsData("past",
        sortBy: sortByValue, sortDirection: sortDirectionValue);
    upcomingEventFuture = _eventsServices.getEventsData("upcoming",
        sortBy: sortByValue, sortDirection: sortDirectionValue);
    todayEventFuture = _eventsServices.getEventsData("today",
        sortBy: sortByValue, sortDirection: sortDirectionValue);
    _fetchGroupNames();
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
      if(kDebugMode) {
        print("Error adding group: $e");
      }
      return "Something went wrong! Please try again later";
    }
  }

  Future<void> _fetchGroupNames() async {
    try {
      /* QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();*/
      EventCategoryResponseModel? eventCategoryResponseModel =
          await EventsServices().getEventsCategoryData();

      List<String> groupNames = [];
      eventCategoryResponseModel?.eventCategories?.forEach((action) {
        groupNames.add(action.eventCategoryName!);
      });

      setState(() {
        eventCategoriesList = eventCategoryResponseModel!.eventCategories!;
        _groupNames = groupNames;
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

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newGroupName = '';
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
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
                onPressed: () async {
                  if (newGroupName.isNotEmpty && selectedColor != null) {
                    String colorCode = colorCodes[selectedColor]!;
                    await _addGroup(newGroupName, colorCode).then((onValue) {
                      Fluttertoast.showToast(msg: onValue);
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(msg: "Please fill all fields");
                  }
                },
                child: const Text('Add Group'),
              ),
            ],
          );
        });
      },
    );
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
              Tab(text: "Today"),
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
                                    return StatefulBuilder(
                                        builder: (context, state) {
                                      return SimpleDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text("Sort by"),
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              RadioListTile<SortOption>(
                                                title: const Text(
                                                    'Date: Descending - Default'),
                                                value: SortOption.def,
                                                groupValue: selectedOption,
                                                onChanged: (SortOption? value) {
                                                  setState(() {
                                                    selectedOption = value;
                                                    _selectedOption =
                                                        selectedOption;
                                                    apiCalling(sortByValue,
                                                        sortDirectionValue);

                                                    //   events.sort((a, b) => a.event!.title!.compareTo(b.event!.title!));
                                                    // Update the main event list
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              RadioListTile<SortOption>(
                                                title: const Text(
                                                    'Date: Ascending'),
                                                value: SortOption.dateDesc,
                                                groupValue: selectedOption,
                                                onChanged: (SortOption? value) {
                                                  setState(() {
                                                    selectedOption = value;
                                                    _selectedOption =
                                                        selectedOption;
                                                    apiCalling(
                                                        sortByValue, "asc");
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
                                                    apiCalling(
                                                        "eventTitle", "asc");

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
                                                    apiCalling("eventTitle",
                                                        sortDirectionValue);
                                                    //   events.sort((a, b) => b.event!.title!.compareTo(a.event!.title!));
                                                    //    _updateEventList(events); // Update the main event list
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      );
                                    });
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
                    ? Expanded(
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TimerScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "No Events Found",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
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
                                      null &&
                                  snapshot
                                          .data!
                                          .eventDetails
                                          ?.events![index]
                                          .eventParticipant
                                          ?.verifierSignatureHash !=
                                      ""; /*isLogSignatureVerified(event, date);*/
                              if (isVerified) {
                                isEnabled = false;
                                buttonText = "Verified";
                              } else {
                                isEnabled = true;
                                buttonText = "Verify";
                              }
                            }

                            if (snapshot.data != null) {
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    //  color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                      const Icon(
                                                          Icons.date_range,
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
                                                                .eventStartDateTime!).toLocal()),
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    //  color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              " Description: ${snapshot.data!.eventDetails!.events![index].event?.eventDescription ?? "Description"}",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  " Start Time: ${DateFormat("hh:mm aa").format(DateTime.parse(snapshot.data!.eventDetails!.events![index].eventInstance?.eventStartDateTime ?? "2024-11-23T15:48:00.000Z").toLocal())}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                                /*    if (tabName.contains(
                                                    "Past"))
                                                Text(
                                                  " End Time: ${DateFormat("hh:mm aa").format(DateTime.parse(snapshot.data!.eventDetails!.events![index].eventInstance?.eventEndDateTime ?? "2024-11-23T15:48:00.000Z").toLocal())}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.normal),
                                                ),*/
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              " Location: ${snapshot.data!.eventDetails!.events![index].event?.eventLocationName ?? "Location"}",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Image.asset(
                                                          'assets/icons/share.png'),
                                                      onPressed: () async {
                                                        final String? uid =
                                                            await getUserId();
                                                        String url = await createAppLink(
                                                            eventId: snapshot
                                                                .data!
                                                                .eventDetails!
                                                                .events![index]
                                                                .eventInstance!
                                                                .eventInstanceId!);
                                                        if (kDebugMode) {
                                                          print("URL: $url");
                                                        }
                                                        Share.share(url);
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Image.asset(
                                                        'assets/icons/delete.png',
                                                        height: 27,
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (_) {
                                                              return SimpleDialog(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                title: Text(
                                                                    "Delete"),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            20),
                                                                children: [
                                                                  ActionChip(
                                                                    backgroundColor:
                                                                        Color(
                                                                            0xFF7FD8DE),
                                                                    label:
                                                                        const Text(
                                                                      "Delete",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      _eventsServices
                                                                          .deleteEvent(snapshot
                                                                              .data!
                                                                              .eventDetails!
                                                                              .events![index]
                                                                              .event!
                                                                              .eventId!)
                                                                          .then((onValue) {
                                                                        if (onValue
                                                                            .message!
                                                                            .contains("successfully")) {
                                                                          Fluttertoast.showToast(
                                                                              msg: onValue.message!);
                                                                          Navigator
                                                                              .pushAndRemoveUntil(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => const HomePage()),
                                                                            (Route<dynamic> route) =>
                                                                                false, // This condition makes sure all the routes are removed.
                                                                          );
                                                                        } else {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Something went wrong. Please try again later.");
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                  SizedBox(
                                                                    height: 6,
                                                                  ),
                                                                  ActionChip(
                                                                    backgroundColor:
                                                                        Color(
                                                                            0xFF7FD8DE),
                                                                    label:
                                                                        const Text(
                                                                      "Delete Single Event Instance",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      _eventsServices
                                                                          .deleteEventInstance(snapshot
                                                                              .data!
                                                                              .eventDetails!
                                                                              .events![index]
                                                                              .eventInstance!
                                                                              .eventInstanceId!)
                                                                          .then((onValue) {
                                                                        if (onValue
                                                                            .message!
                                                                            .contains("successfully")) {
                                                                          Fluttertoast.showToast(
                                                                              msg: onValue.message!);
                                                                          Navigator
                                                                              .pushAndRemoveUntil(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => const HomePage()),
                                                                            (Route<dynamic> route) =>
                                                                                false, // This condition makes sure all the routes are removed.
                                                                          );
                                                                        } else {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Something went wrong. Please try again later.");
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      },
                                                    ),
                                                    snapshot
                                                                    .data!
                                                                    .eventDetails
                                                                    ?.events![
                                                                        index]
                                                                    .eventParticipant
                                                                    ?.verifierSignatureHash !=
                                                                null &&
                                                            snapshot
                                                                    .data!
                                                                    .eventDetails
                                                                    ?.events![
                                                                        index]
                                                                    .eventParticipant
                                                                    ?.verifierSignatureHash !=
                                                                ""
                                                        ? const SizedBox()
                                                        : IconButton(
                                                            icon: Image.asset(
                                                                'assets/icons/edit.png'),
                                                            onPressed: () {
                                                              title.text = snapshot
                                                                  .data!
                                                                  .eventDetails!
                                                                  .events![
                                                                      index]
                                                                  .event!
                                                                  .eventTitle!;
                                                              eventDescription
                                                                      .text =
                                                                  snapshot
                                                                      .data!
                                                                      .eventDetails!
                                                                      .events![
                                                                          index]
                                                                      .event!
                                                                      .eventDescription!;
                                                              eventLocation
                                                                      .text =
                                                                  snapshot
                                                                      .data!
                                                                      .eventDetails!
                                                                      .events![
                                                                          index]
                                                                      .event!
                                                                      .eventLocationName!;
                                                              _selectedGroup = snapshot
                                                                  .data!
                                                                  .eventDetails!
                                                                  .events![
                                                                      index]
                                                                  .event!
                                                                  .eventCategoryName!;
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return SimpleDialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      title:
                                                                          const Text(
                                                                        "Edit Event",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              20),
                                                                      children: [
                                                                        const SizedBox(
                                                                            height:
                                                                                8),
                                                                        InputFeildWidget(
                                                                          title:
                                                                              'Event Name',
                                                                          controller:
                                                                              title,
                                                                          hintText:
                                                                              'New Name',
                                                                          validator:
                                                                              nameValidator,
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                8),
                                                                        InputFeildWidget(
                                                                          title:
                                                                              'Event Description',
                                                                          controller:
                                                                              eventDescription,
                                                                          hintText:
                                                                              '',
                                                                          validator:
                                                                              nameValidator,
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                8),
                                                                        InputFeildWidget(
                                                                          title:
                                                                              'Event Location',
                                                                          controller:
                                                                              eventLocation,
                                                                          hintText:
                                                                              '',
                                                                          validator:
                                                                              nameValidator,
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                8),
                                                                        Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.grey.withOpacity(0.2),
                                                                                spreadRadius: 0.4,

                                                                                blurRadius: 10,
                                                                                offset: const Offset(0, 3), // changes position of shadow
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                              DropdownButtonFormField<String>(
                                                                            hint:
                                                                                const Text('Select a Group'),
                                                                            value:
                                                                                _selectedGroup,
                                                                            dropdownColor:
                                                                                Colors.white,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              filled: true,
                                                                              hintStyle: const TextStyle(
                                                                                  //    color: Colors.grey[400],
                                                                                  fontSize: 19,
                                                                                  fontWeight: FontWeight.w400),
                                                                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                                                                                  color: Colors.grey[400]!,
                                                                                  // Change this to your desired color
                                                                                  width: 2.0,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              if (newValue == 'add_new') {
                                                                                _showAddGroupDialog();
                                                                              } else {
                                                                                setState(() {
                                                                                  _selectedGroup = newValue;
                                                                                });
                                                                              }
                                                                            },
                                                                            items: [
                                                                              ..._groupNames.map<DropdownMenuItem<String>>((String value) {
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
                                                                            height:
                                                                                10),
                                                                        ActionChip(
                                                                          backgroundColor:
                                                                              Colors.blue,
                                                                          label:
                                                                              const Text(
                                                                            "Submit",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            if (title.text.isNotEmpty &&
                                                                                eventDescription.text.isNotEmpty &&
                                                                                eventLocation.text.isNotEmpty &&
                                                                                _selectedGroup != null) {
                                                                              CreateEventRequestModel requestModel = CreateEventRequestModel();
                                                                              requestModel.eventTitle = title.text;
                                                                              requestModel.eventDescription = eventDescription.text;
                                                                              requestModel.eventLocationName = eventLocation.text;
                                                                              requestModel.eventCategoryId = eventCategoriesList.where((test) => test.eventCategoryName == _selectedGroup).first.eventCategoryId;
                                                                              UpdateEventResponseModel? eventCreatedResponse = await EventsServices().updateEventData(requestModel, snapshot.data!.eventDetails!.events![index].event!.eventId!);

                                                                              if (eventCreatedResponse.message!.contains("successfully")) {
                                                                                Fluttertoast.showToast(msg: eventCreatedResponse.message!);
                                                                                Navigator.pushAndRemoveUntil(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => const HomePage()),
                                                                                  (Route<dynamic> route) => false, // This condition makes sure all the routes are removed.
                                                                                );
                                                                              } else {
                                                                                Fluttertoast.showToast(msg: "Something went wrong. Pls try again later");
                                                                                Navigator.pop(context);
                                                                              }
                                                                            } else {
                                                                              Fluttertoast.showToast(msg: "Fields cannot be empty");
                                                                            }
                                                                          },
                                                                        )
                                                                        /*  InputFeildWidget(
                                                                title: 'Event Name',
                                                                controller: title,
                                                                hintText: 'New Name',
                                                                validator: nameValidator,
                                                              )*/
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                          ),
                                                  ],
                                                ),
                                                ActionChip(
                                                  backgroundColor:
                                                      Colors.lightBlue,
                                                  side: BorderSide.none,
                                                  disabledColor: Colors.grey
                                                      .withOpacity(0.6),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 7,
                                                      vertical: 5),
                                                  label: Text(
                                                    buttonText,
                                                    style: TextStyle(
                                                        color: isEnabled
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
                                                          if (tabName.contains(
                                                              "Past")) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
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
                                                  labelPadding: const EdgeInsets
                                                      .symmetric(
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
                                            borderRadius:
                                                const BorderRadius.only(
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
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
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
