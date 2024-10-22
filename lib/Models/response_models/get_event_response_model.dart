class GetEventResponseModel {
  final String message;
  final List<EventData> events;

  GetEventResponseModel({
    required this.message,
    required this.events,
  });

  factory GetEventResponseModel.fromJson(Map<String, dynamic> json) {
    return GetEventResponseModel(
      message: json['message'],
      events: List<EventData>.from(
        json['events'].map((event) => EventData.fromJson(event)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'events': events.map((event) => event.toJson()).toList(),
    };
  }
}

class EventData {
  final Event event;
  final EventInstance eventInstance;

  EventData({
    required this.event,
    required this.eventInstance,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      event: Event.fromJson(json['event']),
      eventInstance: EventInstance.fromJson(json['eventInstance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event.toJson(),
      'eventInstance': eventInstance.toJson(),
    };
  }
}

class Event {
  final String eventId;
  final String eventTitle;
  final String eventDescription;
  final String eventLocationName;
  final String hostId;
  final String hostName;
  final String eventCategoryId;
  final String eventCategoryName;
  final String eventColorCode;
  final RecurrencePattern recurrencePattern;

  Event({
    required this.eventId,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventLocationName,
    required this.hostId,
    required this.hostName,
    required this.eventCategoryId,
    required this.eventCategoryName,
    required this.eventColorCode,
    required this.recurrencePattern,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      eventDescription: json['eventDescription'],
      eventLocationName: json['eventLocationName'],
      hostId: json['hostId'],
      hostName: json['hostName'],
      eventCategoryId: json['eventCategoryId'],
      eventCategoryName: json['eventCategoryName'],
      eventColorCode: json['eventColorCode'],
      recurrencePattern: RecurrencePattern.fromJson(json['reccurencePattern']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDescription': eventDescription,
      'eventLocationName': eventLocationName,
      'hostId': hostId,
      'hostName': hostName,
      'eventCategoryId': eventCategoryId,
      'eventCategoryName': eventCategoryName,
      'eventColorCode': eventColorCode,
      'reccurencePattern': recurrencePattern.toJson(),
    };
  }
}

class RecurrencePattern {
  final String recurringPatternId;
  final String eventStartDateTime;
  final String eventEndDateTime;
  final String recurFrequency;
  final int recurInterval;
  final String weekdays;
  final String dayOfMonth;
  final String monthOfYear;

  RecurrencePattern({
    required this.recurringPatternId,
    required this.eventStartDateTime,
    required this.eventEndDateTime,
    required this.recurFrequency,
    required this.recurInterval,
    required this.weekdays,
    required this.dayOfMonth,
    required this.monthOfYear,
  });

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      recurringPatternId: json['recurringPatternId'],
      eventStartDateTime: json['eventStartDateTime'],
      eventEndDateTime: json['eventEndDateTime'],
      recurFrequency: json['recurFrequency'],
      recurInterval: json['recurInterval'],
      weekdays: json['weekdays'] ?? "",
      dayOfMonth: json['dayOfMonth'] ?? "",
      monthOfYear: json['monthOfYear'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recurringPatternId': recurringPatternId,
      'eventStartDateTime': eventStartDateTime,
      'eventEndDateTime': eventEndDateTime,
      'recurFrequency': recurFrequency,
      'recurInterval': recurInterval,
      'weekdays': weekdays,
      'dayOfMonth': dayOfMonth,
      'monthOfYear': monthOfYear,
    };
  }
}

class EventInstance {
  final String eventInstanceId;
  final String eventStartDateTime;
  final String eventEndDateTime;

  EventInstance({
    required this.eventInstanceId,
    required this.eventStartDateTime,
    required this.eventEndDateTime,
  });

  factory EventInstance.fromJson(Map<String, dynamic> json) {
    return EventInstance(
      eventInstanceId: json['eventInstanceId'],
      eventStartDateTime: json['eventStartDateTime'],
      eventEndDateTime: json['eventEndDateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventInstanceId': eventInstanceId,
      'eventStartDateTime': eventStartDateTime,
      'eventEndDateTime': eventEndDateTime,
    };
  }
}
