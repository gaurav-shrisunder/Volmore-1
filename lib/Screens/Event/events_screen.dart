// ignore_for_file: prefer_is_empty

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
const String activeTimerKey = 'active_timer_event_instance_id';

/// Checks if an event has been started (i.e., has a start time) but not yet cleared.
/// This correctly identifies events that are running OR paused.
Future<bool> isEventInProgress(String eventInstanceId) async {
  final prefs = await SharedPreferences.getInstance();
  // The most reliable way to see if a timer is active (running or paused)
  // is to check if its start_time exists.
  final key = 'timer_start_time_$eventInstanceId';
  return prefs.containsKey(key);
}

/// Gets the ID of the event that has a currently active timer.
/// Returns null if no timer is active.
Future<String?> getActiveTimerEventId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(activeTimerKey);
}

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
   bool isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedOption = widget.initialSortOption;
    apiCalling(sortByValue, sortDirectionValue);
  }

  apiCalling(String sortByValue, String sortDirectionValue) async {
   /* isTimerRunning = await getIsTimerRunning();
    setState(()  {
    });*/
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
          buildEventsFutureBuilder("Today's Event", todayEventFuture),
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
                          if (tabName.contains("Today's Event"))
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.volunteer_activism_rounded,
                                    size: 40, color: Colors.blueAccent),
                                const SizedBox(height: 12),
                                const Text(
                                  "Welcome to Lenda!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Your one-stop shop for building your volunteering resume.\n\nTake a look around — when you're ready to add to your transcript, just tap on “Create Event”.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.6, // Line height
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
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
                            String currentEventInstanceId = snapshot
                                .data!.eventDetails!.events![index].eventInstance!.eventInstanceId!;

                            if (snapshot.data != null) {
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border(
                                      left: BorderSide(
                                        color: HexColor(snapshot
                                            .data!
                                            .eventDetails!
                                            .events![index]
                                            .event!
                                            .eventColorCode!),
                                        width: 5,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// Title
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
                                                .eventColorCode!),
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        /// Date & Host
                                        Row(
                                          children: [
                                            _infoTag(
                                              icon: Icons.date_range,
                                              text: DateFormat.yMMMd().format(
                                                DateTime.parse(snapshot
                                                    .data!
                                                    .eventDetails!
                                                    .events![index]
                                                    .eventInstance!
                                                    .eventStartDateTime!),
                                              ),
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 12),
                                            _infoTag(
                                              icon: Icons.person,
                                              text:
                                                  "Host: ${snapshot.data!.eventDetails!.events![index].event?.hostName}",
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        /// Description
                                        Text(
                                          snapshot
                                                  .data!
                                                  .eventDetails!
                                                  .events![index]
                                                  .event
                                                  ?.eventDescription ??
                                              "No Description",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                        const SizedBox(height: 12),

                                        /// Time & Location
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 18, color: Colors.orange),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Start: ${DateFormat("hh:mm aa").format(DateTime.parse(snapshot.data!.eventDetails!.events![index].eventInstance?.eventStartDateTime ?? "").toLocal())}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 18,
                                                color: Colors.redAccent),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                snapshot
                                                        .data!
                                                        .eventDetails!
                                                        .events![index]
                                                        .event
                                                        ?.eventLocationName ??
                                                    "No Location",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),

                                        /// Buttons (Edit, Delete, Share)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                _iconButton(
                                                    'assets/icons/share.png',
                                                    () async {
                                                  final String? uid =
                                                      await getUserId();
                                                  String url =
                                                      await createAppLink(
                                                    eventId: snapshot
                                                        .data!
                                                        .eventDetails!
                                                        .events![index]
                                                        .eventInstance!
                                                        .eventInstanceId!,
                                                  );
                                                  Share.share(url);
                                                }),
                                                const SizedBox(width: 10),
                                                _iconButton(
                                                    'assets/icons/delete.png',
                                                    () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) {
                                                      return Dialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16)),
                                                        insetPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 30,
                                                                vertical: 24),
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      24,
                                                                  vertical: 20),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .warning_rounded,
                                                                  size: 48,
                                                                  color: Colors
                                                                      .red),
                                                              const SizedBox(
                                                                  height: 12),
                                                              const Text(
                                                                "Delete Event",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              const Text(
                                                                "Are you sure you want to delete this event? This action cannot be undone.",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black87),
                                                              ),
                                                              const SizedBox(
                                                                  height: 24),

                                                              /// Delete All Occurrences
                                                              ElevatedButton
                                                                  .icon(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors.red
                                                                          .shade600,
                                                                  minimumSize:
                                                                      const Size(
                                                                          double
                                                                              .infinity,
                                                                          48),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .delete_forever_outlined),
                                                                label: const Text(
                                                                    "Delete All Occurrences"),
                                                                onPressed: () {
                                                                  _eventsServices
                                                                      .deleteEvent(snapshot
                                                                          .data!
                                                                          .eventDetails!
                                                                          .events![
                                                                              index]
                                                                          .event!
                                                                          .eventId!)
                                                                      .then(
                                                                          (onValue) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // close dialog
                                                                    if (onValue
                                                                        .message!
                                                                        .contains(
                                                                            "successfully")) {
                                                                      Fluttertoast.showToast(
                                                                          msg: onValue
                                                                              .message!);
                                                                      Navigator
                                                                          .pushAndRemoveUntil(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const HomePage()),
                                                                        (Route<dynamic>
                                                                                route) =>
                                                                            false,
                                                                      );
                                                                    } else {
                                                                      Fluttertoast
                                                                          .showToast(
                                                                              msg: "Something went wrong. Please try again later.");
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 12),

                                                              /// Delete Only This Instance
                                                              ElevatedButton
                                                                  .icon(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .orange
                                                                          .shade600,
                                                                  minimumSize:
                                                                      const Size(
                                                                          double
                                                                              .infinity,
                                                                          48),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .event_busy_outlined),
                                                                label: const Text(
                                                                    "Delete This Instance Only"),
                                                                onPressed: () {
                                                                  _eventsServices
                                                                      .deleteEventInstance(snapshot
                                                                          .data!
                                                                          .eventDetails!
                                                                          .events![
                                                                              index]
                                                                          .eventInstance!
                                                                          .eventInstanceId!)
                                                                      .then(
                                                                          (onValue) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // close dialog
                                                                    if (onValue
                                                                        .message!
                                                                        .contains(
                                                                            "successfully")) {
                                                                      Fluttertoast.showToast(
                                                                          msg: onValue
                                                                              .message!);
                                                                      Navigator
                                                                          .pushAndRemoveUntil(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const HomePage()),
                                                                        (Route<dynamic>
                                                                                route) =>
                                                                            false,
                                                                      );
                                                                    } else {
                                                                      Fluttertoast
                                                                          .showToast(
                                                                              msg: "Something went wrong. Please try again later.");
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 12),

                                                              /// Cancel
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                child: const Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }),
                                                const SizedBox(width: 10),
                                                if (snapshot
                                                        .data!
                                                        .eventDetails!
                                                        .events![index]
                                                        .eventParticipant
                                                        ?.verifierSignatureHash
                                                        ?.isEmpty ??
                                                    true)
                                                  _iconButton(
                                                      'assets/icons/edit.png',
                                                      () {
                                                    title.text = snapshot
                                                            .data!
                                                            .eventDetails!
                                                            .events![index]
                                                            .event!
                                                            .eventTitle ??
                                                        "";
                                                    eventDescription
                                                        .text = snapshot
                                                            .data!
                                                            .eventDetails!
                                                            .events![index]
                                                            .event!
                                                            .eventDescription ??
                                                        "";
                                                    eventLocation
                                                        .text = snapshot
                                                            .data!
                                                            .eventDetails!
                                                            .events![index]
                                                            .event!
                                                            .eventLocationName ??
                                                        "";
                                                    _selectedGroup = snapshot
                                                        .data!
                                                        .eventDetails!
                                                        .events![index]
                                                        .event!
                                                        .eventCategoryName;

                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16)),
                                                          insetPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      24,
                                                                  vertical: 20),
                                                          backgroundColor:
                                                              Colors.white,
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          24,
                                                                      vertical:
                                                                          20),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                    "Edit Event",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20),

                                                                  /// Event Name
                                                                  InputFeildWidget(
                                                                    title:
                                                                        'Event Name',
                                                                    controller:
                                                                        title,
                                                                    hintText:
                                                                        'Event title',
                                                                    validator:
                                                                        nameValidator,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          16),

                                                                  /// Event Description
                                                                  InputFeildWidget(
                                                                    title:
                                                                        'Event Description',
                                                                    controller:
                                                                        eventDescription,
                                                                    hintText:
                                                                        'Enter event description',
                                                                    validator:
                                                                        nameValidator,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          16),

                                                                  /// Event Location
                                                                  InputFeildWidget(
                                                                    title:
                                                                        'Event Location',
                                                                    controller:
                                                                        eventLocation,
                                                                    hintText:
                                                                        'Enter location',
                                                                    validator:
                                                                        nameValidator,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          16),

                                                                  /// Dropdown for Group
                                                                  DropdownButtonFormField<
                                                                      String>(
                                                                    value:
                                                                        _selectedGroup,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          "Event Group",
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                    ),
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      if (newValue ==
                                                                          'add_new') {
                                                                        _showAddGroupDialog();
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          _selectedGroup =
                                                                              newValue;
                                                                        });
                                                                      }
                                                                    },
                                                                    items: [
                                                                      ..._groupNames.map(
                                                                          (String
                                                                              value) {
                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              value,
                                                                          child:
                                                                              Text(value),
                                                                        );
                                                                      }),
                                                                      const DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            'add_new',
                                                                        child: Text(
                                                                            'Add New Group'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20),

                                                                  /// Submit button
                                                                  ElevatedButton
                                                                      .icon(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .blue,
                                                                      minimumSize: const Size(
                                                                          double
                                                                              .infinity,
                                                                          50),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                    ),
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .check),
                                                                    label: const Text(
                                                                        "Submit"),
                                                                    onPressed:
                                                                        () async {
                                                                      if (title
                                                                              .text
                                                                              .isNotEmpty &&
                                                                          eventDescription
                                                                              .text
                                                                              .isNotEmpty &&
                                                                          eventLocation
                                                                              .text
                                                                              .isNotEmpty &&
                                                                          _selectedGroup !=
                                                                              null) {
                                                                        CreateEventRequestModel
                                                                            requestModel =
                                                                            CreateEventRequestModel();
                                                                        requestModel.eventTitle =
                                                                            title.text;
                                                                        requestModel.eventDescription =
                                                                            eventDescription.text;
                                                                        requestModel.eventLocationName =
                                                                            eventLocation.text;
                                                                        requestModel.eventCategoryId = eventCategoriesList
                                                                            .where((test) =>
                                                                                test.eventCategoryName ==
                                                                                _selectedGroup)
                                                                            .first
                                                                            .eventCategoryId;

                                                                        UpdateEventResponseModel?
                                                                            eventCreatedResponse =
                                                                            await EventsServices().updateEventData(
                                                                          requestModel,
                                                                          snapshot
                                                                              .data!
                                                                              .eventDetails!
                                                                              .events![index]
                                                                              .event!
                                                                              .eventId!,
                                                                        );

                                                                        if (eventCreatedResponse
                                                                            .message!
                                                                            .contains("successfully")) {
                                                                          Fluttertoast.showToast(
                                                                              msg: eventCreatedResponse.message!);
                                                                          Navigator
                                                                              .pushAndRemoveUntil(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => const HomePage()),
                                                                            (Route<dynamic> route) =>
                                                                                false,
                                                                          );
                                                                        } else {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Something went wrong. Pls try again later");
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      } else {
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                "Fields cannot be empty");
                                                                      }
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    child: const Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey)),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }),
                                              ],
                                            ),

                                            /// Log Button
                                            FutureBuilder<List<Object?>>(
                                              // Fetch both pieces of information at once
                                              future: Future.wait([
                                                // [0]: Is this event in progress (running OR paused)?
                                                isEventInProgress(currentEventInstanceId),
                                                // [1]: Is ANY timer currently ticking? (for the restriction)
                                                getActiveTimerEventId(),
                                              ]),
                                              builder: (context, asyncSnapshot) {
                                                // Default UI while loading data from SharedPreferences
                                                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                                                  return ActionChip(
                                                    label: Text(
                                                      buttonText,
                                                      style: TextStyle(color: Colors.black54),
                                                    ),
                                                    backgroundColor: Colors.grey.shade300,
                                                    onPressed: null,
                                                  );
                                                }

                                                // Extract data after futures complete
                                                final bool isThisEventInProgress = asyncSnapshot.data?[0] as bool? ?? false;
                                                final String? activeTickingEventId = asyncSnapshot.data?[1] as String?;

                                                // --- LOGIC FOR BUTTON TEXT AND COLOR ---
                                                String dynamicButtonText = buttonText;
                                                Color chipColor = isEnabled ? Colors.blue : Colors.grey.shade300;

                                                if (tabName.contains("Today") && isThisEventInProgress) {
                                                  // *** CHANGE 1: Set text to "Continue" if in progress (running or paused) ***
                                                  dynamicButtonText = "Continue";
                                                  // *** CHANGE 2: Set color to green for "Continue" button ***
                                                  chipColor = Colors.green;
                                                }

                                                // Now, build the final ActionChip
                                                return ActionChip(
                                                  label: Text(
                                                    dynamicButtonText,
                                                    style: TextStyle(
                                                      color: isEnabled ? Colors.white : Colors.black54,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  // Use the dynamic color, but fall back to grey if disabled
                                                  backgroundColor: isEnabled ? chipColor : Colors.grey.shade300,
                                                  onPressed: isEnabled
                                                      ? () {
                                                    // --- RESTRICTION LOGIC ---
                                                    // Check if a timer is actively ticking for a DIFFERENT event.
                                                    if (tabName.contains("Today") &&
                                                        activeTickingEventId != null &&
                                                        activeTickingEventId != currentEventInstanceId) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              "Ongoing event still active, complete the event before logging to this event"),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                      return; // Block navigation
                                                    }

                                                    // --- NAVIGATION LOGIC (if not blocked) ---
                                                    if (tabName.contains("Today")) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => LogNowPage(
                                                            snapshot.data!.eventDetails!.events![index].event!,
                                                            snapshot.data!.eventDetails!.events![index].eventInstance!,
                                                          ),
                                                        ),
                                                      );
                                                    } else if (tabName.contains("Past")) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => PastEventVerification(
                                                            date: snapshot.data!.eventDetails!.events![index].event!
                                                                .reccurencePattern!.eventStartDateTime!,
                                                            event: snapshot.data!.eventDetails!.events![index],
                                                            eventInstanceId: snapshot
                                                                .data!.eventDetails!.events![index].eventInstance!.eventInstanceId!,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                      : null,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                );
                                              },
                                            )
                                          /*  ActionChip(
                                              label: Text(
                                                buttonText,
                                              // (getTimerEventId() != "0" && isTimerRunning) ? "Continue" : buttonText ,
                                                style: TextStyle(
                                                  color: isEnabled
                                                      ? Colors.white
                                                      : Colors.black54,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              backgroundColor: isEnabled
                                                  ? Colors.blue
                                                  : Colors.grey.shade300,
                                              onPressed: isEnabled
                                                  ? () {
                                                      if (tabName
                                                          .contains("Today")) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    LogNowPage(
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
                                                                  .eventInstance!,
                                                            ),
                                                          ),
                                                        );
                                                      } else if (tabName
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                            ),*/
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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

  Widget _infoTag(
      {required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _iconButton(String assetPath, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(assetPath, height: 24),
      ),
    );
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
