import 'dart:convert';


class WeeklyStatsResponseModel {
  List<EventDetail>? eventDetails;
  UserHoursByDay? userHoursByDay;
  int? weekTotalHour;
  int? lifeTimeHours;

  WeeklyStatsResponseModel({
     this.eventDetails,
     this.userHoursByDay,
     this.weekTotalHour,
     this.lifeTimeHours,
  });

  // Method to convert Dart object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'eventDetails': eventDetails?.map((event) => event.toJson()).toList(),
      'userHoursByDay': userHoursByDay?.toJson(),
      'weekTotalHour': weekTotalHour,
      'lifeTimeHours': lifeTimeHours,
    };
  }

  // Factory constructor to create WeeklyStatsResponseModel from JSON
  factory WeeklyStatsResponseModel.fromJson(Map<String, dynamic> json) {
    return WeeklyStatsResponseModel(
      eventDetails: (json['eventDetails'] as List)
          .map((event) => EventDetail.fromJson(event))
          .toList(),
      userHoursByDay: UserHoursByDay.fromJson(json['userHoursByDay']),
      weekTotalHour: json['weekTotalHour'] ?? 0,
      lifeTimeHours: json['lifeTimeHours'] ?? 0,
    );
  }
}

class EventDetail {
  String title;
  String location;
  String date;

  EventDetail({
    required this.title,
    required this.location,
    required this.date,
  });

  // Method to convert EventDetail to JSON format
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'date': date,
    };
  }

  // Factory constructor to create EventDetail from JSON
  factory EventDetail.fromJson(Map<String, dynamic> json) {
    return EventDetail(
      title: json['title'],
      location: json['location'],
      date: json['date'],
    );
  }
}

class UserHoursByDay {
  int sunday;
  int monday;
  int tuesday;
  int wednesday;
  int thursday;
  int friday;
  int saturday;

  UserHoursByDay({
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  // Method to convert UserHoursByDay to JSON format
  Map<String, dynamic> toJson() {
    return {
      'sunday': sunday,
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday,
    };
  }

  // Factory constructor to create UserHoursByDay from JSON
  factory UserHoursByDay.fromJson(Map<String, dynamic> json) {
    return UserHoursByDay(
      sunday: json['sunday'],
      monday: json['monday'],
      tuesday: json['tuesday'],
      wednesday: json['wednesday'],
      thursday: json['thursday'],
      friday: json['friday'],
      saturday: json['saturday'],
    );
  }
}

// Example usage to parse the JSON
