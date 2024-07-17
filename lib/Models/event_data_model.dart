import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventDataModel {
  dynamic date;
  String? description;
  String? group;
  String? groupColor;
  String? id;
  String? location;
  String? occurence;
  String? title;
   String? host;

  EventDataModel(
      {this.date,
      this.description,
      this.group,
      this.groupColor,
      this.id,
      this.location,
      this.occurence,
      this.title,
      this.host
  });

  EventDataModel.fromJson(Map<String, dynamic> json) {
    date = json['date'] != null ? (json['date'] as Timestamp).toDate() : null;
    description = json['description'];
    group = json['group'];
    groupColor = json['group_color'];
    id = json['id'];
    location = json['location'];
    occurence = json['occurence'];
    title = json['title'];
    host = json['host'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['description'] = this.description;
    data['group'] = this.group;
    data['group_color'] = this.groupColor;
    data['id'] = this.id;
    data['location'] = this.location;
    data['occurence'] = this.occurence;
    data['title'] = this.title;
     data['host'] = this.host;
    return data;
  }
}
