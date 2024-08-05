import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    endDate = json['end_date'] != null
        ? (json['end_date'] as Timestamp).toDate()
        : null;
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
    return data;
  }
}
