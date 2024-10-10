class EventsDataResponseModel {
  String? message;
  List<Events>? events;

  EventsDataResponseModel({this.message, this.events});

  EventsDataResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['events'] != null) {
      events = <Events>[];
      json['events'].forEach((v) {
        events!.add(new Events.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.events != null) {
      data['events'] = this.events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Events {
  Event? event;
  EventInstance? eventInstance;
  EventParticipant? eventParticipant;

  Events({this.event, this.eventInstance, this.eventParticipant});

  Events.fromJson(Map<String, dynamic> json) {
    event = json['event'] != null ? new Event.fromJson(json['event']) : null;
    eventInstance = json['eventInstance'] != null
        ? new EventInstance.fromJson(json['eventInstance'])
        : null;
    eventParticipant = json['eventParticipant'] != null
        ? new EventParticipant.fromJson(json['eventParticipant'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.event != null) {
      data['event'] = this.event!.toJson();
    }
    if (this.eventInstance != null) {
      data['eventInstance'] = this.eventInstance!.toJson();
    }
    if (this.eventParticipant != null) {
      data['eventParticipant'] = this.eventParticipant!.toJson();
    }
    return data;
  }
}

class Event {
  String? eventId;
  String? eventTitle;
  String? eventDescription;
  String? eventLocationName;
  String? hostId;
  String? hostName;
  String? eventCategoryId;
  String? eventCategoryName;
  String? eventColorCode;
  ReccurencePattern? reccurencePattern;

  Event(
      {this.eventId,
        this.eventTitle,
        this.eventDescription,
        this.eventLocationName,
        this.hostId,
        this.hostName,
        this.eventCategoryId,
        this.eventCategoryName,
        this.eventColorCode,
        this.reccurencePattern});

  Event.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    eventTitle = json['eventTitle'];
    eventDescription = json['eventDescription'];
    eventLocationName = json['eventLocationName'];
    hostId = json['hostId'];
    hostName = json['hostName'];
    eventCategoryId = json['eventCategoryId'];
    eventCategoryName = json['eventCategoryName'];
    eventColorCode = json['eventColorCode'];
    reccurencePattern = json['reccurencePattern'] != null
        ? new ReccurencePattern.fromJson(json['reccurencePattern'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['eventTitle'] = this.eventTitle;
    data['eventDescription'] = this.eventDescription;
    data['eventLocationName'] = this.eventLocationName;
    data['hostId'] = this.hostId;
    data['hostName'] = this.hostName;
    data['eventCategoryId'] = this.eventCategoryId;
    data['eventCategoryName'] = this.eventCategoryName;
    data['eventColorCode'] = this.eventColorCode;
    if (this.reccurencePattern != null) {
      data['reccurencePattern'] = this.reccurencePattern!.toJson();
    }
    return data;
  }
}

class ReccurencePattern {
  String? recurringPatternId;
  String? eventStartDateTime;
  String? eventEndDateTime;
  String? recurFrequency;
  int? recurInterval;
  String? weekdays;
  String? dayOfMonth;
  String? monthOfYear;

  ReccurencePattern(
      {this.recurringPatternId,
        this.eventStartDateTime,
        this.eventEndDateTime,
        this.recurFrequency,
        this.recurInterval,
        this.weekdays,
        this.dayOfMonth,
        this.monthOfYear});

  ReccurencePattern.fromJson(Map<String, dynamic> json) {
    recurringPatternId = json['recurringPatternId'];
    eventStartDateTime = json['eventStartDateTime'];
    eventEndDateTime = json['eventEndDateTime'];
    recurFrequency = json['recurFrequency'];
    recurInterval = json['recurInterval'];
    weekdays = json['weekdays'];
    dayOfMonth = json['dayOfMonth'];
    monthOfYear = json['monthOfYear'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['recurringPatternId'] = this.recurringPatternId;
    data['eventStartDateTime'] = this.eventStartDateTime;
    data['eventEndDateTime'] = this.eventEndDateTime;
    data['recurFrequency'] = this.recurFrequency;
    data['recurInterval'] = this.recurInterval;
    data['weekdays'] = this.weekdays;
    data['dayOfMonth'] = this.dayOfMonth;
    data['monthOfYear'] = this.monthOfYear;
    return data;
  }
}

class EventInstance {
  String? eventInstanceId;
  String? eventStartDateTime;
  String? eventEndDateTime;

  EventInstance(
      {this.eventInstanceId, this.eventStartDateTime, this.eventEndDateTime});

  EventInstance.fromJson(Map<String, dynamic> json) {
    eventInstanceId = json['eventInstanceId'];
    eventStartDateTime = json['eventStartDateTime'];
    eventEndDateTime = json['eventEndDateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventInstanceId'] = this.eventInstanceId;
    data['eventStartDateTime'] = this.eventStartDateTime;
    data['eventEndDateTime'] = this.eventEndDateTime;
    return data;
  }
}

class EventParticipant {
  String? userId;
  Null? userStartDateTime;
  Null? userEndDateTime;
  String? userLocationName;
  String? userNotes;
  int? userHours;
  int? userEarnPoints;
  String? verifierSignatureHash;
  String? verifierInformation;
  String? verifierNotes;

  EventParticipant(
      {this.userId,
        this.userStartDateTime,
        this.userEndDateTime,
        this.userLocationName,
        this.userNotes,
        this.userHours,
        this.userEarnPoints,
        this.verifierSignatureHash,
        this.verifierInformation,
        this.verifierNotes});

  EventParticipant.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userStartDateTime = json['userStartDateTime'];
    userEndDateTime = json['userEndDateTime'];
    userLocationName = json['userLocationName'];
    userNotes = json['userNotes'];
    userHours = json['userHours'];
    userEarnPoints = json['userEarnPoints'];
    verifierSignatureHash = json['verifierSignatureHash'];
    verifierInformation = json['verifierInformation'];
    verifierNotes = json['verifierNotes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userStartDateTime'] = this.userStartDateTime;
    data['userEndDateTime'] = this.userEndDateTime;
    data['userLocationName'] = this.userLocationName;
    data['userNotes'] = this.userNotes;
    data['userHours'] = this.userHours;
    data['userEarnPoints'] = this.userEarnPoints;
    data['verifierSignatureHash'] = this.verifierSignatureHash;
    data['verifierInformation'] = this.verifierInformation;
    data['verifierNotes'] = this.verifierNotes;
    return data;
  }
}
