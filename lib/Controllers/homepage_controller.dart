

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Services/events_services.dart';

class HomeController extends GetxController {
  var events = [].obs;


  void fetchEvents() async {
    // Fetch the updated list of events
    // events.value = await EventsServices().getEvents();
  }
}