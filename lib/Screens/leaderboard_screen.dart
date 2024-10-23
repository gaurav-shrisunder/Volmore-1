import 'package:flutter/material.dart';
import 'package:volunterring/Models/response_models/leaderboard_influenced_response_model.dart';
import 'package:volunterring/Services/leaderboard_service.dart';
import 'package:volunterring/Services/user_services.dart';

import '../Models/UserModel.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardServices leaderboardServices = LeaderboardServices();

  final List<String> states = ["Arizona", "Alabama", "California", "Michigan"];
  final List<String> graduatingClasses = ["2024", "2023", "2022", "2021"];
  String? selectedState;
  String? selectedGraduatingClass;
  bool isLoading = true;
  List<LeaderboardUser?>? userList = [];
  List<LeaderboardUser?>? influencedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiCalling();
  }

  apiCalling() async {
    LeaderboardInfluencedResponseModel? leaderboardData =
        await leaderboardServices.getInflucendLeaderboard("influenceBoard");
    LeaderboardInfluencedResponseModel? leaderboardDatatotal =
        await leaderboardServices.getInflucendLeaderboard("participationBoard");

    setState(() {
      userList = leaderboardDatatotal?.leaderBoardDetails?.users ?? [];
      influencedList = leaderboardData?.leaderBoardDetails?.users ?? [];
      isLoading = false;
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
                      Tab(text: "Hour Influenced"),
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

  Widget buildVolunteerListView(List<LeaderboardUser?>? userList) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top 100 Volunteers by Total Hours",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // State Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "State",
                      labelStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey)),
                    ),
                    dropdownColor: Colors.white,
                    value: selectedState,
                    items: states.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedState = newValue;
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
                    items: graduatingClasses.map((String gradClass) {
                      return DropdownMenuItem<String>(
                        value: gradClass,
                        child: Text(gradClass),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGraduatingClass = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
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
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/profile_avatar.png'),
                            // Replace with actual image path
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
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            backgroundColor:
                                                Colors.orange.shade50,
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      )
                                    : const SizedBox(),
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
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            backgroundColor:
                                                Colors.orange.shade50,
                                          ),
                                          const SizedBox(width: 8),
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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top 100 Volunteers by Hours Influenced",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // State Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "State",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey)),
                    ),
                    value: selectedState,
                    items: states.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedState = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Graduating Class",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: selectedGraduatingClass,
                    items: graduatingClasses.map((String gradClass) {
                      return DropdownMenuItem<String>(
                        value: gradClass,
                        child: Text(gradClass),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGraduatingClass = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: userList!.length,
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemBuilder: (context, index) {
                userList[index]!.hostInfluenceHours;
                int hours = (userList[index]!.hostInfluenceHours ?? 0) ~/ 60;
                // Integer division to get hours
                int minutes = (userList[index]!.hostInfluenceHours ?? 0) %
                    60; // Remainder to get minutes

                String formattedTime = '${hours}h ${minutes}m';
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
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/profile_avatar.png'),
                            // Replace with actual image path
                            radius: 30,
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
                                          // Chip(
                                          //   side: const BorderSide(
                                          //       color: Colors.transparent, width: 0),
                                          //   padding: EdgeInsets.zero,
                                          //   label: Text(userList[index]!.state!),
                                          //   backgroundColor: Colors.orange.shade50,
                                          // ),
                                          const SizedBox(width: 8),
                                          Chip(
                                            padding: EdgeInsets.zero,
                                            side: const BorderSide(
                                                color: Colors.transparent,
                                                width: 0),
                                            label: Text(userList[index]!
                                                .yearOfStudy
                                                .toString()),
                                            backgroundColor:
                                                Colors.purple.shade50,
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                          //  const Spacer(),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    formattedTime,
                                    style: const TextStyle(color: Colors.black),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ))),
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
