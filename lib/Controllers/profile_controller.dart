import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunterring/Models/UserModel.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Services/logService.dart';

class UserProfileController extends GetxController {
  var isLoading = true.obs;
  var user = Rxn<UserModel>();
  var events = <EventDataModel>[].obs;
  var weeklyHours = <double>[].obs;
  var weeklyDuration = "".obs;
  final _authMethods = LogServices();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading(true);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? uid = prefs.getString('uid');

      // Fetch user data
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      user.value = UserModel.fromMap(doc.data() as Map<String, dynamic>);

      // Fetch event data
      var fetchedEvents = await _authMethods.fetchAllEventsWithLogs();
      events.value = fetchedEvents;

      // Calculate weekly hours and duration
      weeklyDuration.value = calculateWeeklyDuration(fetchedEvents);
      weeklyHours.value = calculateWeeklyHours(fetchedEvents);
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading(false);
    }
  }

  String calculateWeeklyDuration(List<EventDataModel> events) {
    int totalSeconds = 0;
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var event in events) {
      event.logs?.forEach((log) {
        if (log.elapsedTime != null) {
          DateTime logDate = log.date.toDate();
          if (logDate.isAfter(startOfWeek) &&
              logDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
            List<String> parts = log.elapsedTime!.split(':');
            if (parts.length == 3) {
              int hours = int.parse(parts[0]);
              int minutes = int.parse(parts[1]);
              int seconds = int.parse(parts[2]);
              totalSeconds += (hours * 3600) + (minutes * 60) + seconds;
            }
          }
        }
      });
    }

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<double> calculateWeeklyHours(List<EventDataModel> events) {
    List<double> weeklyHours = List.filled(7, 0);
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var event in events) {
      event.logs?.forEach((log) {
        DateTime logDate = log.date.toDate();
        if (logDate.isAfter(startOfWeek) &&
            logDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
          int dayIndex = logDate.weekday - 1;
          List<String> timeParts = log.elapsedTime!.split(':');
          int hours = int.parse(timeParts[0]);
          int minutes = int.parse(timeParts[1]);

          weeklyHours[dayIndex] +=
              hours.toDouble() + (minutes / 60).round().toDouble();
        }
      });
    }
    return weeklyHours;
  }
}
