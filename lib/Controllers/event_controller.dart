import 'package:get/get.dart';
import 'package:volunterring/Models/event_data_model.dart';
import 'package:volunterring/Services/logService.dart';

class EventController extends GetxController {
  var isLoading = true.obs;
  var events = <EventDataModel>[].obs;
  final LogServices _logService = LogServices();

  @override
  void onInit() {
    fetchEvents();
    super.onInit();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading(true);
      var fetchedEvents = await _logService.fetchAllEventsWithLogs();
      if (fetchedEvents != null) {
        events.assignAll(fetchedEvents);
      }
    } finally {
      isLoading(false);
    }
  }

  List<EventDataModel> getEventList() {
    return events;
  }
}
