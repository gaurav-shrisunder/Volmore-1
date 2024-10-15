class LogEventRequestModel {
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

  LogEventRequestModel(
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

  LogEventRequestModel.fromJson(Map<String, dynamic> json) {
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
    data['userId'] = this.userId;
    data['eventInstanceId'] = this.eventInstanceId;
    data['userStartDateTime'] = this.userStartDateTime;
    data['userEndDateTime'] = this.userEndDateTime;
    data['userLocationName'] = this.userLocationName;
    data['userNotes'] = this.userNotes;
    data['userHours'] = this.userHours;
    if (this.hostInformation != null) {
      data['hostInformation'] = this.hostInformation!.toJson();
    }
    data['userEarnPoints'] = this.userEarnPoints;
    data['verifierSignatureHash'] = this.verifierSignatureHash;
    data['verifierInformation'] = this.verifierInformation;
    data['verifierNotes'] = this.verifierNotes;
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
    data['eventId'] = this.eventId;
    data['hostId'] = this.hostId;
    data['hours'] = this.hours;
    return data;
  }
}
