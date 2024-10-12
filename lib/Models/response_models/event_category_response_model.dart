class EventCategoryResponseModel {
  String? message;
  List<EventCategories>? eventCategories;

  EventCategoryResponseModel({this.message, this.eventCategories});

  EventCategoryResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['eventCategories'] != null) {
      eventCategories = <EventCategories>[];
      json['eventCategories'].forEach((v) {
        eventCategories!.add(new EventCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.eventCategories != null) {
      data['eventCategories'] =
          this.eventCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventCategories {
  String? eventCategoryId;
  String? eventCategoryName;
  String? eventColorCode;

  EventCategories(
      {this.eventCategoryId, this.eventCategoryName, this.eventColorCode});

  EventCategories.fromJson(Map<String, dynamic> json) {
    eventCategoryId = json['eventCategoryId'];
    eventCategoryName = json['eventCategoryName'];
    eventColorCode = json['eventColorCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventCategoryId'] = this.eventCategoryId;
    data['eventCategoryName'] = this.eventCategoryName;
    data['eventColorCode'] = this.eventColorCode;
    return data;
  }
}
