
class LogPastEventRequestModel {
  String? eventTitle;
  String? eventDescription;
  String? eventCategoryId;
  String? eventLocationName;
  String? createdBy;
  List<Dates>? dates;

  LogPastEventRequestModel(
      {this.eventTitle,
        this.eventDescription,
        this.eventCategoryId,
        this.eventLocationName,
        this.createdBy,
        this.dates});

  LogPastEventRequestModel.fromJson(Map<String, dynamic> json) {
    eventTitle = json['eventTitle'];
    eventDescription = json['eventDescription'];
    eventCategoryId = json['eventCategoryId'];
    eventLocationName = json['eventLocationName'];
    createdBy = json['createdBy'];
    if (json['dates'] != null) {
      dates = <Dates>[];
      json['dates'].forEach((v) {
        dates!.add(Dates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventTitle'] = eventTitle;
    data['eventDescription'] = eventDescription;
    data['eventCategoryId'] = eventCategoryId;
    data['eventLocationName'] = eventLocationName;
    data['createdBy'] = createdBy;
    if (dates != null) {
      data['dates'] = dates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dates {
  String? startDateTime;
  String? endDateTime;

  Dates({this.startDateTime, this.endDateTime});

  Dates.fromJson(Map<String, dynamic> json) {
    startDateTime = json['startDateTime'];
    endDateTime = json['endDateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startDateTime'] = startDateTime;
    data['endDateTime'] = endDateTime;
    return data;
  }
}
