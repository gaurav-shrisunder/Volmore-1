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
  List<String>? instancesToBeVerified;

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
      this.verifierNotes,
      this.instancesToBeVerified
      });

  LogEventRequestModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    eventInstanceId = json['eventInstanceId'];
    userStartDateTime = json['userStartDateTime'];
    userEndDateTime = json['userEndDateTime'];
    userLocationName = json['userLocationName'];
    userNotes = json['userNotes'];
    userHours = json['userHours'];
    hostInformation = json['hostInformation'] != null
        ? HostInformation.fromJson(json['hostInformation'])
        : null;
    userEarnPoints = json['userEarnPoints'];
    verifierSignatureHash = json['verifierSignatureHash'];
    verifierInformation = json['verifierInformation'];
    verifierNotes = json['verifierNotes'];
    instancesToBeVerified = json['instancesToBeVerified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['eventInstanceId'] = eventInstanceId;

    if (userStartDateTime != null) {
      data['userStartDateTime'] = userStartDateTime;
    }
    if (userEndDateTime != null) {
      data['userEndDateTime'] = userEndDateTime;
    }
    if (userLocationName != null) {
      data['userLocationName'] = userLocationName;
    }
    if (userNotes != null) {
      data['userNotes'] = userNotes;
    }
    if (userHours != null) {
      data['userHours'] = userHours;
    }

    if (hostInformation != null) {
      data['hostInformation'] = hostInformation!.toJson();
    }
    if (userEarnPoints != null) {
      data['userEarnPoints'] = userEarnPoints;
    }
    if (verifierSignatureHash != null) {
      data['verifierSignatureHash'] = verifierSignatureHash;
    }
    if (verifierInformation != null) {
      data['verifierInformation'] = verifierInformation;
    }
    if (verifierNotes != null) {
      data['verifierNotes'] = verifierNotes;
    } if (instancesToBeVerified != null) {
      data['instancesToBeVerified'] = instancesToBeVerified;
    }
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventId'] = eventId;
    data['hostId'] = hostId;
    data['hours'] = hours;
    return data;
  }
}
