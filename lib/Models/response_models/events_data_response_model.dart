class EventsDataResponseModel {
  String? message;
  EventDetails? eventDetails;

  EventsDataResponseModel({this.message, this.eventDetails});

  EventsDataResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    eventDetails = json['eventDetails'] != null
        ? EventDetails.fromJson(json['eventDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (eventDetails != null) {
      data['eventDetails'] = eventDetails!.toJson();
    }
    return data;
  }
}

class EventDetails {
  List<Events>? events;
  Pagination? pagination;

  EventDetails({this.events, this.pagination});

  EventDetails.fromJson(Map<String, dynamic> json) {
    if (json['events'] != null) {
      events = <Events>[];
      json['events'].forEach((v) {
        events!.add(Events.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (events != null) {
      data['events'] = events!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
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
    event = json['event'] != null ? Event.fromJson(json['event']) : null;
    eventInstance = json['eventInstance'] != null
        ? EventInstance.fromJson(json['eventInstance'])
        : null;
    eventParticipant = json['eventParticipant'] != null
        ? EventParticipant.fromJson(json['eventParticipant'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (event != null) {
      data['event'] = event!.toJson();
    }
    if (eventInstance != null) {
      data['eventInstance'] = eventInstance!.toJson();
    }
    if (eventParticipant != null) {
      data['eventParticipant'] = eventParticipant!.toJson();
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
  String? eventParticipatedDuration;
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
      this.eventParticipatedDuration,
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
    eventParticipatedDuration = json['eventParticipatedDuration'];
    reccurencePattern = json['reccurencePattern'] != null
        ? ReccurencePattern.fromJson(json['reccurencePattern'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventId'] = eventId;
    data['eventTitle'] = eventTitle;
    data['eventDescription'] = eventDescription;
    data['eventLocationName'] = eventLocationName;
    data['hostId'] = hostId;
    data['hostName'] = hostName;
    data['eventCategoryId'] = eventCategoryId;
    data['eventCategoryName'] = eventCategoryName;
    data['eventColorCode'] = eventColorCode;
    data['eventParticipatedDuration'] = eventParticipatedDuration;
    if (reccurencePattern != null) {
      data['reccurencePattern'] = reccurencePattern!.toJson();
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
    eventStartDateTime = json['startDate'];
    eventEndDateTime = json['endDate'];
    recurFrequency = json['recurFrequency'];
    recurInterval = json['recurInterval'];
    weekdays = json['weekdays'];
    dayOfMonth = json['dayOfMonth'];
    monthOfYear = json['monthOfYear'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recurringPatternId'] = recurringPatternId;
    data['startDate'] = eventStartDateTime;
    data['endDate'] = eventEndDateTime;
    data['recurFrequency'] = recurFrequency;
    data['recurInterval'] = recurInterval;
    data['weekdays'] = weekdays;
    data['dayOfMonth'] = dayOfMonth;
    data['monthOfYear'] = monthOfYear;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventInstanceId'] = eventInstanceId;
    data['eventStartDateTime'] = eventStartDateTime;
    data['eventEndDateTime'] = eventEndDateTime;
    return data;
  }
}

class EventParticipant {
  String? userId;
  String? userStartDateTime;
  String? userEndDateTime;
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
    if (json['userStartDateTime'] != null) {
      userStartDateTime = json['userStartDateTime'];
    }

    userEndDateTime = json['userEndDateTime'];
    userLocationName = json['userLocationName'];
    userNotes = json['userNotes'];
    userHours = json['userMinutes'];
    userEarnPoints = json['userEarnPoints'];
    verifierSignatureHash = json['verifierSignatureHash'];
    verifierInformation = json['verifierInformation'];
    verifierNotes = json['verifierNotes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['userStartDateTime'] = userStartDateTime;
    data['userEndDateTime'] = userEndDateTime;
    data['userLocationName'] = userLocationName;
    data['userNotes'] = userNotes;
    data['userHours'] = userHours;
    data['userEarnPoints'] = userEarnPoints;
    data['verifierSignatureHash'] = verifierSignatureHash;
    data['verifierInformation'] = verifierInformation;
    data['verifierNotes'] = verifierNotes;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalCount;

  Pagination({this.currentPage, this.totalPages, this.totalCount});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentPage'] = currentPage;
    data['totalPages'] = totalPages;
    data['totalCount'] = totalCount;
    return data;
  }
}
