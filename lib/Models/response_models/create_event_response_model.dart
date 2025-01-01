class CreateEventResponse {
  String? message;
  EventDetails? eventDetails;

  CreateEventResponse({this.message, this.eventDetails});

  CreateEventResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    eventDetails = json['eventDetails'] != null
        ? new EventDetails.fromJson(json['eventDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.eventDetails != null) {
      data['eventDetails'] = this.eventDetails!.toJson();
    }
    return data;
  }
}

class EventDetails {
  int? eventId;
  int? eventIntanceId;

  EventDetails({this.eventId, this.eventIntanceId});

  EventDetails.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    eventIntanceId = json['eventIntanceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['eventIntanceId'] = this.eventIntanceId;
    return data;
  }
}
