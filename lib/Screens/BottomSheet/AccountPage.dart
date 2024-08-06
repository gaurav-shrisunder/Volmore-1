import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Models/UserModel.dart';
import 'package:volunterring/Screens/Manage%20Account/AccountDeletion.dart';
import 'package:volunterring/Screens/Manage%20Account/EditPassword.dart';
import 'package:volunterring/Utils/Colors.dart';

import '../../widgets/appbar_widget.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Future<UserModel> fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('uid');
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(


      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset("assets/images/profilecsreen_bg.png"),
          FutureBuilder<UserModel>(
            future: fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('User not found'));
              } else {
                UserModel user = snapshot.data!;
                print(user.profileLink);
                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                    child: Column(
                      children: [
                      /*  Text(
                          'Manage Your Account',
                          style: TextStyle(
                            fontSize: height * 0.035,
                            color: headingBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),*/
                        SizedBox(height: height * 0.02),
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage("assets/images/profile_avatar.png"),
                        ),
                        const SizedBox(height: 10),
                     Text(user.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
                     Text(user.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),),
                        SizedBox(height: height * 0.02),
                        Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         Card(
                           color: Colors.white,
                           elevation: 10,

                           child: Padding(
                             padding: const EdgeInsets.all(16.0),
                             child: Row(
                             children: [
                             //  Image.asset("assets/icons/hour_icon.png"),
                               const Column(
                                 children: [
                                   Text("600 hrs", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: headingBlue),),
                                   Text("Lifetime Hours"),
                                 ],
                               )
                             ],

                             ),
                           ),
                         ),
                         Card(
                           elevation: 10,
                           color: Colors.white,
                           child: Padding(
                             padding: const EdgeInsets.all(16.0),
                             child: Row(
                               children: [
                               //  Image.asset("assets/icons/hour_icon.png"),
                                 Column(
                                   children: [
                                     Text("55 hrs", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: headingBlue),),
                                     Text("This week"),
                                   ],
                                 )
                               ],

                             ),
                           ),
                         ),
                       ],
                     ),
                     /*   Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Personal info',
                              style: TextStyle(
                                fontSize: height * 0.025,
                                color: headingBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(EditPassword()),
                              child: Container(
                                height: height * 0.05,
                                width: Get.width * 0.23,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 210, 217, 243),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.edit),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: height * 0.019,
                                          color: headingBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),*/
                        SizedBox(height: height * 0.02),
                        CachedNetworkImage(
                          imageUrl: user.profileLink,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.error),
                          ),
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                            backgroundImage: imageProvider,
                            radius: 50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Name: ${user.name}',
                              style: const TextStyle(
                                  fontSize: 18, color: Color(0xFF4484D2))),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Email: ${user.email}',
                              style: const TextStyle(
                                  fontSize: 18, color: Color(0xFF4484D2))),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Phone: ${user.phone}',
                              style: const TextStyle(
                                  fontSize: 18, color: Color(0xFF4484D2))),
                        ),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(EditPassword());
                            },
                            child: Container(
                              height: height * 0.05,
                              width: Get.width * 0.6,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 210, 217, 243),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.edit),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontSize: height * 0.019,
                                      color: headingBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(AccountDeletion());
                            },
                            child: Container(
                              height: height * 0.05,
                              width: Get.width * 0.6,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 250, 168, 152),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      fontSize: height * 0.019,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
