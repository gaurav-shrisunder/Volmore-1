
class NonVerifiedEventsResponseModel {
  String? message;
  List<NonVerifiedEvents>? nonVerifiedEvents;

  NonVerifiedEventsResponseModel({this.message, this.nonVerifiedEvents});

  NonVerifiedEventsResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['nonVerifiedEvents'] != null) {
      nonVerifiedEvents = <NonVerifiedEvents>[];
      json['nonVerifiedEvents'].forEach((v) {
        nonVerifiedEvents!.add(new NonVerifiedEvents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.nonVerifiedEvents != null) {
      data['nonVerifiedEvents'] =
          this.nonVerifiedEvents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NonVerifiedEvents {
  String? eventInstanceId;
  String? eventTitle;
  String? eventStartDate;
  String? eventEndDate;
  String? userLocation;
  String? verifierInformation;
  String? verifierSignatureHash;
  String? verifierNotes;

  NonVerifiedEvents(
      {this.eventInstanceId,
        this.eventTitle,
        this.eventStartDate,
        this.eventEndDate,
        this.userLocation,
        this.verifierInformation,
        this.verifierSignatureHash,
        this.verifierNotes});

  NonVerifiedEvents.fromJson(Map<String, dynamic> json) {
    eventInstanceId = json['eventInstanceId'];
    eventTitle = json['eventTitle'];
    eventStartDate = json['eventStartDate'];
    eventEndDate = json['eventEndDate'];
    userLocation = json['userLocation'];
    verifierInformation = json['verifierInformation'];
    verifierSignatureHash = json['verifierSignatureHash'];
    verifierNotes = json['verifierNotes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventInstanceId'] = this.eventInstanceId;
    data['eventTitle'] = this.eventTitle;
    data['eventStartDate'] = this.eventStartDate;
    data['eventEndDate'] = this.eventEndDate;
    data['userLocation'] = this.userLocation;
    data['verifierInformation'] = this.verifierInformation;
    data['verifierSignatureHash'] = this.verifierSignatureHash;
    data['verifierNotes'] = this.verifierNotes;
    return data;
  }
}
