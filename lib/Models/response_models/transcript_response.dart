class TranscriptResponse {
  int? lifeTimeHour;
  List<Transcript>? transcripts;

  TranscriptResponse({this.lifeTimeHour, this.transcripts});

  factory TranscriptResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptResponse(
      lifeTimeHour: json['lifeTimeMinutes'],
      transcripts: json['transcripts'] != null
          ? (json['transcripts'] as List)
              .map((i) => Transcript.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lifeTimeMinutes': lifeTimeHour,
      'transcripts': transcripts?.map((e) => e.toJson()).toList(),
    };
  }
}

class Transcript {
  String? eventCategoryName;
  String? eventColorCode;
  int? totalHours;
  List<Event>? event;

  Transcript(
      {this.eventCategoryName,
      this.eventColorCode,
      this.totalHours,
      this.event});

  factory Transcript.fromJson(Map<String, dynamic> json) {
    return Transcript(
      eventCategoryName: json['eventCategoryName'],
      eventColorCode: json['eventColorCode'],
      totalHours: json['totalMinutes'],
      event: json['event'] != null
          ? (json['event'] as List).map((i) => Event.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventCategoryName': eventCategoryName,
      'eventColorCode': eventColorCode,
      'totalMinutes': totalHours,
      'event': event?.map((e) => e.toJson()).toList(),
    };
  }
}

class Event {
  String? eventTitle;
  String? eventDateTime;
  String? eventLocation;
  int? hour;
  String? hostName;
  String? userDateTime;
  String? userLocation;
  String? verifierInformation;
  String? verifierSignatureHash;
  String? verifierNotes;
  bool? isLoggedAsPast;

  Event({
    this.eventTitle,
    this.eventDateTime,
    this.eventLocation,
    this.hour,
    this.hostName,
    this.userDateTime,
    this.userLocation,
    this.verifierInformation,
    this.verifierSignatureHash,
    this.verifierNotes,
    this.isLoggedAsPast
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventTitle: json['eventTitle'],
      eventDateTime: json['eventDateTime'],
      eventLocation: json['eventLocation'],
      hour: json['minutes'],
      hostName: json['hostName'],
      userDateTime: json['userDateTime'],
      userLocation: json['userLocation'],
      verifierInformation: json['verifierInformation'],
      verifierSignatureHash: json['verifierSignatureHash'],
      verifierNotes: json['verifierNotes'],
      isLoggedAsPast: json['isLoggedAsPast'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventTitle': eventTitle,
      'eventDateTime': eventDateTime,
      'eventLocation': eventLocation,
      'minutes': hour,
      'hostName': hostName,
      'userDateTime': userDateTime,
      'userLocation': userLocation,
      'verifierInformation': verifierInformation,
      'verifierSignatureHash': verifierSignatureHash,
      'verifierNotes': verifierNotes,
      'isLoggedAsPast': isLoggedAsPast,
    };
  }
}
