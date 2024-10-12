

class LogCurrentEventRequestModel {
  String? userId;
  String? eventInstanceId;
  String? userStartDateTime;
  String? userEndDateTime;
  String? userLocationName;
  String? userNotes;
  int? userHours;
  HostInformation? hostInformation;
  int? userEarnPoints;
  String? verifierSignatureHash;
  String? verifierInformation;
  String? verifierNotes;

  LogCurrentEventRequestModel(
      {this.userId,
        this.eventInstanceId,
        this.userStartDateTime,
        this.userEndDateTime,
        this.userLocationName,
        this.userNotes,
        this.userHours,
        this.hostInformation,
        this.userEarnPoints,
        this.verifierSignatureHash,
        this.verifierInformation,
        this.verifierNotes});

  LogCurrentEventRequestModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    eventInstanceId = json['eventInstanceId'];
    userStartDateTime = json['userStartDateTime'];
    userEndDateTime = json['userEndDateTime'];
    userLocationName = json['userLocationName'];
    userNotes = json['userNotes'];
    userHours = json['userHours'];
    hostInformation = json['hostInformation'] != null
        ? new HostInformation.fromJson(json['hostInformation'])
        : null;
    userEarnPoints = json['userEarnPoints'];
    verifierSignatureHash = json['verifierSignatureHash'];
    verifierInformation = json['verifierInformation'];
    verifierNotes = json['verifierNotes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['eventInstanceId'] = eventInstanceId;
    data['userStartDateTime'] = userStartDateTime;
    data['userEndDateTime'] = userEndDateTime;
    data['userLocationName'] = userLocationName;
    data['userNotes'] = userNotes;
    data['userHours'] = userHours;
    if (hostInformation != null) {
      data['hostInformation'] = hostInformation!.toJson();
    }
    data['userEarnPoints'] = userEarnPoints;
    data['verifierSignatureHash'] = verifierSignatureHash;
    data['verifierInformation'] = verifierInformation;
    data['verifierNotes'] = verifierNotes;
    return data;
  }
}

class HostInformation {
  String? eventId;
  String? hostId;
  int? hours;

  HostInformation({this.eventId, this.hostId, this.hours});

  HostInformation.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    hostId = json['hostId'];
    hours = json['hours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = eventId;
    data['hostId'] = hostId;
    data['hours'] = hours;
    return data;
  }
}
