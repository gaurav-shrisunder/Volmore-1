import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Models/response_models/leaderboard_influenced_response_model.dart';
import '../../Services/leaderboard_service.dart';
import '../../Services/user_services.dart';

import '../Models/UserModel.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardServices leaderboardServices = LeaderboardServices();

  final List<String> states = [
    "Alabama",
    "Alaska",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "Florida",
    "Georgia",
    "Hawaii",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississippi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming"
  ];

  final List<String> graduatingClasses = [
    "1970",
    "1971",
    "1972",
    "1973",
    "1974",
    "1975",
    "1976",
    "1977",
    "1978",
    "1979",
    "1980",
    "1981",
    "1982",
    "1983",
    "1984",
    "1985",
    "1986",
    "1987",
    "1988",
    "1989",
    "1990",
    "1991",
    "1992",
    "1993",
    "1994",
    "1995",
    "1996",
    "1997",
    "1998",
    "1999",
    "2000",
    "2001",
    "2002",
    "2003",
    "2004",
    "2005",
    "2006",
    "2007",
    "2008",
    "2009",
    "2010",
    "2011",
    "2012",
    "2013",
    "2014",
    "2015",
    "2016",
    "2017",
    "2018",
    "2019",
    "2020",
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
    "2026",
    "2027",
    "2028",
    "2029",
    "2030",
    "2031",
    "2032",
    "2033",
    "2034",
    "2035",
    "2036",
    "2037",
    "2038",
    "2039",
    "2040",
  ];

  String? selectedStateVolunteered;
  String? selectedGraduatingClassVolunteered;
  String? selectedStateInfluenced;
  String? selectedGraduatingClassInfluenced;
  bool isLoading = true;
  List<LeaderboardUser?>? userList = [];
  List<LeaderboardUser?>? influencedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiCalling(true);
  }

  apiCalling(bool isVolunteeredTab) async {
    setState(() {
      isLoading = true;
    });

    if (isVolunteeredTab) {
      LeaderboardInfluencedResponseModel? leaderboardDatatotal =
          await leaderboardServices.getLeaderboardData(
        "participationBoard",
        locationState: selectedStateVolunteered,
        yearOfStudy: selectedGraduatingClassVolunteered,
      );
      LeaderboardInfluencedResponseModel? influencedLeaderboardData =
          await leaderboardServices.getLeaderboardData(
        "influenceBoard",
        locationState: selectedStateInfluenced,
        yearOfStudy: selectedGraduatingClassInfluenced,
      );
      setState(() {
        userList = leaderboardDatatotal?.leaderBoardDetails ?? [];
        influencedList = influencedLeaderboardData?.leaderBoardDetails ?? [];
      });
    } else {
      LeaderboardInfluencedResponseModel? influencedLeaderboardData =
          await leaderboardServices.getLeaderboardData(
        "influenceBoard",
        locationState: selectedStateInfluenced,
        yearOfStudy: selectedGraduatingClassInfluenced,
      );
      setState(() {
        print(
            'Influcence data:: ${influencedLeaderboardData?.leaderBoardDetails?.first.userName}');
        influencedList = influencedLeaderboardData?.leaderBoardDetails ?? [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void resetFilters(bool isVolunteeredTab) {
    setState(() {
      if (isVolunteeredTab) {
        selectedStateVolunteered = null;
        selectedGraduatingClassVolunteered = null;
      } else {
        selectedStateInfluenced = null;
        selectedGraduatingClassInfluenced = null;
      }
      apiCalling(isVolunteeredTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: !isLoading
            ? Column(
                children: [
                  const TabBar(
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Hours Volunteered"),
                      Tab(text: "Hours Influenced"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildVolunteerListView(userList),
                        buildHoursInfluencedListView(influencedList),
                        // buildHoursInfluencedListView(influencedList),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
        //  bottomNavigationBar: buildPageChanger(),
      ),
    );
  }

  Widget buildFiltersRow({
    required bool isVolunteeredTab,
    required String? selectedState,
    required String? selectedGraduatingClass,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              labelText: "State",
              labelStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            dropdownColor: Colors.white,
            value: selectedState,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text("All States"),
              ),
              ...states.map((String state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                );
              }),
            ],
            onChanged: (String? newValue) {
              setState(() {
                if (isVolunteeredTab) {
                  selectedStateVolunteered = newValue;
                } else {
                  selectedStateInfluenced = newValue;
                }
                apiCalling(isVolunteeredTab);
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Graduating Class",
              labelStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            value: selectedGraduatingClass,
            dropdownColor: Colors.white,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text("All Classes"),
              ),
              ...graduatingClasses.map((String gradClass) {
                return DropdownMenuItem<String>(
                  value: gradClass,
                  child: Text(gradClass),
                );
              }),
            ],
            onChanged: (String? newValue) {
              setState(() {
                if (isVolunteeredTab) {
                  selectedGraduatingClassVolunteered = newValue;
                } else {
                  selectedGraduatingClassInfluenced = newValue;
                }
                apiCalling(isVolunteeredTab);
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
            onTap: () {
              resetFilters(isVolunteeredTab);
            },
            child: Icon(Icons.refresh, color: Colors.blue))
      ],
    );
  }

  Widget buildVolunteerListView(List<LeaderboardUser?>? userList) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top 100 Volunteers by Total Hours",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              if (selectedStateVolunteered != null ||
                  selectedGraduatingClassVolunteered != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Filtered Results',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: buildFiltersRow(
              isVolunteeredTab: true,
              selectedState: selectedStateVolunteered,
              selectedGraduatingClass: selectedGraduatingClassVolunteered,
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (userList?.isEmpty ?? true)
            const Center(
              child: Text('No results found for the selected filters'),
            )
          else
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                itemCount: userList!.length,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  userList[index]!.participantHours;
                  int hours = (userList[index]!.participantHours ?? 0) ~/ 60;
                  // Integer division to get hours
                  int minutes = (userList[index]!.participantHours ?? 0) %
                      60; // Remainder to get minutes

                  String formattedTime = '${hours}h  ${minutes}m';
                  print('Name of: ${userList[index]?.userName}');
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                    ),
                    child: Container(
                      color: Colors.white30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "#${index + 1}.",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 10),

                            if (userList[index]?.profilePicture == null ||
                                userList[index]?.profilePicture == "")
                              CircleAvatar(
                                /*  backgroundImage: AssetImage(
                                  'assets/images/profile_avatar.png'),*/
                                // Replace with actual image path
                                radius: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade200),
                                  child: Center(
                                    child: Text(
                                      "${userList[index]!.userName?[0].capitalize}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            if (userList[index]?.profilePicture != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    userList[index]!.profilePicture!),
                                radius: 20,
                              ),

                            /*  CircleAvatar(

                            */ /*  backgroundImage: AssetImage(
                                  'assets/images/profile_avatar.png'),*/ /*
                              // Replace with actual image path
                              radius: 20,
                              child: Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1),shape: BoxShape.circle,color: Colors.grey.shade200),
                                child: Center(
                                  child: Text("${userList[index]!.userName?[0].capitalize}", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
                                ),
                              ),
                            ),*/
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${userList[index]!.userName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  userList[index]!.yearOfStudy != 0
                                      ? Row(
                                          children: [
                                            Chip(
                                              side: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0),
                                              padding: EdgeInsets.zero,
                                              label: Text(
                                                userList[index]!
                                                    .yearOfStudy
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              backgroundColor:
                                                  Colors.orange.shade50,
                                            ),
                                            const SizedBox(width: 8),
                                            Chip(
                                              side: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0),
                                              padding: EdgeInsets.zero,
                                              label: Text(
                                                userList[index]!
                                                    .locationState
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              backgroundColor:
                                                  Colors.pink.shade50,
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                            //  const Spacer(),
                            Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  formattedTime,
                                  style: const TextStyle(color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget buildHoursInfluencedListView(List<LeaderboardUser?>? userList) {
    //   print('Receved Influ:: ${userList?.first?.userName}');

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top 100 Volunteers by Hours Influenced",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              if (selectedStateInfluenced != null ||
                  selectedGraduatingClassInfluenced != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Filtered Results',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: buildFiltersRow(
              isVolunteeredTab: false,
              selectedState: selectedStateInfluenced,
              selectedGraduatingClass: selectedGraduatingClassInfluenced,
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (userList?.isEmpty ?? true)
            const Center(
              child: Text('No results found for the selected filters'),
            )
          else
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                itemCount: userList!.length,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  print('User Image:: ${userList[index]?.profilePicture}');
                  userList[index]!.hostInfluenceHours;
                  int hours = (userList[index]!.hostInfluenceHours ?? 0) ~/ 60;
                  // Integer division to get hours
                  int minutes = (userList[index]!.hostInfluenceHours ?? 0) %
                      60; // Remainder to get minutes

                  String formattedTime = '${hours}h  ${minutes}m';
                  print('Name of: ${userList[index]?.userName}');
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                    ),
                    child: Container(
                      color: Colors.white30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "#${index + 1}.",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 10),
                            if (userList[index]?.profilePicture == null ||
                                userList[index]?.profilePicture == "")
                              CircleAvatar(
                                /*  backgroundImage: AssetImage(
                                  'assets/images/profile_avatar.png'),*/
                                // Replace with actual image path
                                radius: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade200),
                                  child: Center(
                                    child: Text(
                                      "${userList[index]!.userName?[0].capitalize}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            if (userList[index]?.profilePicture != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    userList[index]!.profilePicture!),
                                radius: 20,
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${userList[index]!.userName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  userList[index]!.yearOfStudy != 0
                                      ? Row(
                                          children: [
                                            Chip(
                                              side: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0),
                                              padding: EdgeInsets.zero,
                                              label: Text(
                                                userList[index]!
                                                    .yearOfStudy
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              backgroundColor:
                                                  Colors.orange.shade50,
                                            ),
                                            const SizedBox(width: 8),
                                            Chip(
                                              side: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0),
                                              padding: EdgeInsets.zero,
                                              label: Text(
                                                userList[index]!
                                                    .locationState
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              backgroundColor:
                                                  Colors.pink.shade50,
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                            //  const Spacer(),
                            Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  formattedTime,
                                  style: const TextStyle(color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPageChanger() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
            onPressed: () {},
          ),
          const Text(
            "Page 1 of 10",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
