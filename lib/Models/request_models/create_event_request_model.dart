class CreateEventRequestModel {
  String? eventTitle;
  String? eventDescription;
  String? eventCategoryId;
  String? eventLocationName;
  String? createdBy;
  Recurrence? recurrence;

  CreateEventRequestModel(
      {this.eventTitle,
        this.eventDescription,
        this.eventCategoryId,
        this.eventLocationName,
        this.createdBy,
        this.recurrence});

  CreateEventRequestModel.fromJson(Map<String, dynamic> json) {
    eventTitle = json['eventTitle'];
    eventDescription = json['eventDescription'];
    eventCategoryId = json['eventCategoryId'];
    eventLocationName = json['eventLocationName'];
    createdBy = json['createdBy'];
    recurrence = json['recurrence'] != null
        ? Recurrence.fromJson(json['recurrence'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventTitle'] = eventTitle;
    data['eventDescription'] = eventDescription;
    data['eventCategoryId'] = eventCategoryId;
    data['eventLocationName'] = eventLocationName;
    data['createdBy'] = createdBy;
    if (recurrence != null) {
      data['recurrence'] = recurrence!.toJson();
    }
    return data;
  }
}

class Recurrence {
  String? eventStartDateTime;
  String? eventEndDateTime;
  String? recurFrequency;
  String? weekdays;
  int? recurInterval;

  Recurrence(
      {this.eventStartDateTime,
        this.eventEndDateTime,
        this.recurFrequency,
        this.weekdays,
        this.recurInterval});

  Recurrence.fromJson(Map<String, dynamic> json) {
    eventStartDateTime = json['eventStartDateTime'];
    eventEndDateTime = json['eventEndDateTime'];
    recurFrequency = json['recurFrequency'];
    weekdays = json['weekdays'];
    recurInterval = json['recurInterval'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventStartDateTime'] = eventStartDateTime;
    data['eventEndDateTime'] = eventEndDateTime;
    data['recurFrequency'] = recurFrequency;
    data['weekdays'] = weekdays;
    data['recurInterval'] = recurInterval;
    return data;
  }
}
