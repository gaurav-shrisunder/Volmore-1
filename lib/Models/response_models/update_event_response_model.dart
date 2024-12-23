

import 'events_data_response_model.dart';

class UpdateEventResponseModel {
  String? message;
  Event? event;

  UpdateEventResponseModel({this.message, this.event});

  UpdateEventResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    event = json['event'] != null ? Event.fromJson(json['event']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = this.message;
    if (event != null) {
      data['event'] = event!.toJson();
    }
    return data;
  }
}