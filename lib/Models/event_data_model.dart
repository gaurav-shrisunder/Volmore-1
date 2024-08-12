import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LogModel {
  final String logId;
  String? elapsedTime;
  dynamic startTime;
  dynamic endTime;
  dynamic date;
  dynamic isLocationVerified;
  dynamic isSignatureVerified;
  dynamic isTimeVerified;

  LogModel({
    required this.logId,
    this.elapsedTime,
    this.startTime,
    this.endTime,
    this.date,
    this.isLocationVerified,
    this.isSignatureVerified,
    this.isTimeVerified,
  });

  factory LogModel.fromMap(Map<String, dynamic> data, String id) {
    return LogModel(
      logId: data['id'],
      elapsedTime: data['elapsedTime(hh:mm:ss)'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      date: data['date'],
      isLocationVerified: data['isLocationVerified'],
      isSignatureVerified: data['isSignatureVerified'],
      isTimeVerified: data['isTimeVerified'],
    );
  }
}

class EventListDataModel {
  EventDataModel? event;
  dynamic date;

  EventListDataModel({this.event, this.date});

  EventListDataModel.fromJson(Map<String, dynamic> json) {
    event =
        json['event'] != null ? EventDataModel.fromJson(json['event']) : null;
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (event != null) {
      data['event'] = event!.toJson();
    }
    data['date'] = date;
    return data;
  }
}

class EventDataModel {
  dynamic date;
  String? description;
  String? group;
  String? groupColor;
  String? id;
  String? location;
  String? address;
  String? occurence;
  String? title;
  String? host;
  String? time;
  String? duration;
  dynamic startTime;
  dynamic endTime;
  dynamic endDate;
  List<dynamic>? dates;
  List<LogModel>? logs;

  EventDataModel(
      {this.date,
      this.description,
      this.group,
      this.groupColor,
      this.id,
      this.location,
      this.address,
      this.occurence,
      this.title,
      this.time,
      this.duration,
      this.startTime,
      this.endTime,
      this.endDate,
      this.dates,
      this.logs,
      this.host});

  EventDataModel.fromJson(Map<String, dynamic> json) {
    date = json['date'] != null ? (json['date'] as Timestamp).toDate() : null;
    description = json['description'];
    group = json['group'];
    groupColor = json['group_color'];
    id = json['id'];
    location = json['location'];
    address = json['address'];
    occurence = json['occurrence'];
    title = json['title'];
    host = json['host'];
    time = json['time'];
    duration = json['duration'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    dates = json['dates'];
    logs = json['logs'];
    endDate = json['end_date'] != null
        ? (json['end_date'] as Timestamp).toDate()
        : null;
  }

  factory EventDataModel.fromMap(
      Map<String, dynamic> data, String id, List<LogModel> logs) {
    return EventDataModel(
      id: id,
      title: data['title'],
      description: data['description'],
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
      location: data['location'] ?? '',
      occurence: data['occurrence'] ?? "No occurrence",
      group: data['group'] ?? "General",
      host: data['host'] ?? "You",
      duration: data['duration'],
      startTime: data['startTime'],
      groupColor: data['group_color'],
      time: data['time'],
      address: data['address'],
      endTime: data['endTime'],
      dates: data['dates'],
      endDate: data['end_date'] != null
          ? (data['end_date'] as Timestamp).toDate()
          : null,
      logs: logs,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['dates'] = dates;
    data['description'] = description;
    data['group'] = group;
    data['group_color'] = groupColor;
    data['id'] = id;
    data['location'] = location;
    data['address'] = address;
    data['occurrence'] = occurence;
    data['title'] = title;
    data['host'] = host;
    data['time'] = time;
    data['duration'] = duration;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['end_date'] = endDate;
    data['logs'] = logs;
    return data;
  }

  @override
  String toString() {
    return 'EventDataModel{date: $date, description: $description, group: $group, groupColor: $groupColor, id: $id, location: $location, address: $address, occurence: $occurence, title: $title, host: $host, time: $time, duration: $duration, startTime: $startTime, endTime: $endTime, endDate: $endDate, dates: $dates}';
  }
}
