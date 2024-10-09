import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:volunterring/Models/UserModel.dart';
import 'package:volunterring/Models/event_data_model.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Sign Up User
  Future<String> signupUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String phone,
  }) async {
    String res = "Some error occurred";
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (password != confirmPassword) {
        res = "Passwords do not match";
      } else if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Register user in auth with email and password
        UserCredential cred =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Generate initials for the user profile picture
        String initials = name.isNotEmpty
            ? name
                .trim()
                .split(' ')
                .map((e) => e[0])
                .take(2)
                .join()
                .toUpperCase()
            : "NA";

        // Generate profile link
        String profileLink =
            "https://ui-avatars.com/api/?name=$initials&background=random";

        // Add user to your Firestore database
        await FirebaseFirestore.instance
            .collection("users")
            .doc(cred.user!.uid)
            .set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
          'number': phone,
          'profile_link': profileLink,
          'total_minutes': 0,
          'minutes_influenced': 0 // Save profile link
        });

        // Save UID to SharedPreferences
        await prefs.setString("uid", cred.user!.uid);
        res = "success";
      } else {
        res = "Please fill in all fields";
      }
    } catch (err) {
      print("Error in signup ${err.toString()}");
      res = err.toString();
    }

    return res;
  }

  // Log In User
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await _prefs;
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Log in user with email and password
        UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save UID to SharedPreferences
        await prefs.setString("uid", cred.user!.uid);
        res = "success";
      } else {
        res = "Please enter all fields";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  // Sign Out User
  Future<void> signOut() async {
    await _auth.signOut();
    final SharedPreferences prefs = await _prefs;
    await prefs.remove("uid");
  }

/*  Future<String> changePassword(String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email!, password: currentPassword);

    user.reauthenticateWithCredential(cred).then((value) {
      user.updatePassword(newPassword).then((_) {
        return "Password changed successfully";
        //Success, do something
      }).catchError((error) {
        return error.toString();
        //Error, show something
      });
    }).catchError((err) {
      return "Something went wrong";
    });
    return "Something went wrong";
  }*/

  Future<String> _resetPassword(String email) async {
    var res = "Some error occurred";
    try {
      await _auth.sendPasswordResetEmail(email: email);
      res = "Password reset email sent";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Upload Profile Picture
  /*Future<String> uploadProfilePicture() async {
    String res = "Some error occurred";
    final SharedPreferences prefs = await _prefs;
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        File file = File(image.path);

        // Get user id
        String uid = prefs.getString("uid") ?? _auth.currentUser!.uid;

        // Upload to Firebase Storage
        TaskSnapshot snapshot =
            await _storage.ref().child("profilePictures/$uid").putFile(file);

        // Get download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with new profile picture link
        await _firestore.collection("users").doc(uid).update({
          'profile_link': downloadUrl,
        });

        res = "Profile picture updated successfully";
      } else {
        res = "No image selected";
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }*/

  // Change Password
  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    String res = "Some error occurred";
    try {
      User user = _auth.currentUser!;
      String email = user.email!;

      // Re-authenticate user with old password
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: oldPassword);
      await user.reauthenticateWithCredential(credential);

      if (newPassword != confirmNewPassword) {
        res = "New passwords do not match";
        Get.snackbar('Error', res);
      } else {
        // Update password
        await user.updatePassword(newPassword);
        res = "Password updated successfully";
        Get.snackbar('Hurray', res);
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //Events CRUD
  Future<dynamic> addEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String occurrence,
    String group = "General",
    DateTime? endDate,
    required String time,
    TimeOfDay? endTime,
    required List<dynamic> dates,
  }) async {
    String res = "Some error occurred";
    final SharedPreferences prefs = await _prefs;
    String eventId = _uuid.v4();
    try {
      // Get user id
      String uid = prefs.getString("uid") ?? _auth.currentUser!.uid;
      UserModel? user = await fetchUserData();

      // Generate UUID for the event

      print("user: ${user.toString()}");

      // Add event to Firestore
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("events")
          .doc(eventId)
          .set({
        'id': eventId,
        'title': title,
        'description': description,
        'date': date,
        'location': location,
        'occurrence': occurrence,
        'group': group,
        'host': user!.name,
        'host_id': uid,
        'time': time,
        'end_date': endDate ?? date,
        'dates': dates,
      });

      res = "Event added successfully";
    } catch (e) {
      res = e.toString();
    }

    return {"res": res, "id": eventId};
  }

  Future<dynamic> acceptEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String occurrence,
    String group = "General",
    DateTime? endDate,
    required String time,
    TimeOfDay? endTime,
    required List<dynamic> dates,
    required eventId,
    required hostId,
  }) async {
    String res = "Some error occurred";
    final SharedPreferences prefs = await _prefs;

    try {
      // Get user id
      String uid = prefs.getString("uid") ?? _auth.currentUser!.uid;
      UserModel? user = await fetchUserData();

      // Generate UUID for the event

      print("user: ${user.toString()}");

      // Add event to Firestore
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("events")
          .doc(eventId)
          .set({
        'id': eventId,
        'title': title,
        'description': description,
        'date': date,
        'location': location,
        'occurrence': occurrence,
        'group': group,
        'host': user!.name,
        'host_id': uid,
        'time': time,
        'end_date': endDate ?? date,
        'dates': dates,
      });

      if (uid != hostId) {
        print("In if condition");
        await _firestore
            .collection("users")
            .doc(hostId)
            .collection("referrals")
            .doc(eventId)
            .set({
          'id': uid,
          'isLogged': false,
          'duration': 0, //in seconds
        });
      }

      res = "Event added successfully";
    } catch (e) {
      res = e.toString();
    }

    return {"res": res, "id": eventId};
  }

  Future<UserModel?> fetchUserData() async {
    try {
      // Retrieve uid from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? uid = prefs.getString('uid');

      // Check if uid is not null
      if (uid == null) {
        return null;
      }

      // Retrieve user document from Firestore
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Check if document exists
      if (!doc.exists) {
        Get.snackbar("Error", "No user Found");
        return null;
      }

      // Convert document data to UserModel
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      // Handle any errors that occur

      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchGroups() async {
    List<Map<String, dynamic>> groups = [];
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();
      print("querySnapshot.docs: ${querySnapshot.docs}");

      groups = querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'] as String,
          'color':
              doc['color'] as String, // Assuming color is stored as a String
        };
      }).toList();
    } catch (e) {
      print("Error fetching group names and colors: $e");
    }
    return groups;
  }

  //Fetch Events
  Future<List<EventDataModel>> fetchEvents() async {
    final SharedPreferences prefs = await _prefs;
    List<EventDataModel> events = [];

    try {
      // Get user id
      String uid = prefs.getString("uid") ?? _auth.currentUser!.uid;

      // Fetch events from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection("users")
          .doc(uid)
          .collection("events")
          .get();

      events = querySnapshot.docs
          .map((doc) =>
              EventDataModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      print("events ${querySnapshot.docs[2].data()}");
    } catch (e) {
      print("Error fetching events: $e");
    }

    return events;
  }

  Future<EventDataModel?> fetchEventById(String userId, String eventId) async {
    try {
      // Get the document reference of the specific event
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .get();

      // Check if the document exists
      if (eventSnapshot.exists) {
        // Convert the snapshot to EventDataModel
        Map<String, dynamic> eventData =
            eventSnapshot.data() as Map<String, dynamic>;
        EventDataModel event = EventDataModel.fromJson(eventData);

        return event;
      } else {
        print("Event with ID $eventId does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching event: $e");
      return null;
    }
  }
}
