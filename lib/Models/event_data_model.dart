import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/*
address
"1600 Amphitheatre Pkwy Building 43, Mountain View, 94043, United States"
(string)

date
August 12, 2024 at 10:04:36 PM UTC+5:30
(timestamp)

elapsedTime(hh:mm:ss)
"0:0:5"
(string)

endTime
August 12, 2024 at 10:06:13 PM UTC+5:30
(timestamp)

id
"1d7c0960-ec6e-4fd7-a523-beb66a3b4628"
(string)

isLocationVerified
true
(boolean)

isSignatureVerified
true
(boolean)

isTimeVerified
true
(boolean)

location
[37.4219983° N, 122.084° W]
(geopoint)

phoneNumber
"983274987"
(string)

signature
"iVBORw0KGgoAAAANSUhEUgAAAJoAAAAuCAYAAADQpAB0AAAAAXNSR0IArs4c6QAAAARzQklUCAgICHwIZIgAAApHSURBVHic7Zx/SBNvHMc/00ydiYXMLS37qaLLfmxLk7K0L0JaQpRKjmI1ofIPjWhCRakIkWWRFSRIZWJNIQoyW1K4TanUMAvTaVmUP1DStMxKzfLz/SNcnnf76W3ncC94cHvu+fH+3L3vubt5z8NCRAQ7diyMA9MC7MwMZjEtYDrT0dEBKpUKXF1dQaPRmFzf3d0dBgcHp6xjzpw5wOfzYcWKFbBgwYIpt8cELPul8x8DAwOgUqlApVKBUqmExsZG4HA4EBERAbdv3za5vXXr1kFNTc2UNLFYLIiMjASlUgkAAJ6enlrTTfzr6ek5pX4szYwe0RBRayyVSgVPnz4llent7YX+/n4G1P2jsbFR+7mvrw+qqqqgqqqKUGbhwoWUBnR1dbW2XEoYNVp3dzd8+/bNrLoODg4wNjZmcj2NRgPV1dVQW1sLNTU18OvXL4N1ent7zZFIGz09PQbLdHR0QEdHB5SXlxPyAwICgM/na83n4+MD69evt5RUnVjt0tnf3w91dXWEFBUVBQUFBWCOhLCwMKiurja5npubG/z48cOkOo6OjvDnzx+T+6Lr0knnIdq4cSPU19eDSCQCkUgEQqEQRCIRLF++nLY+qLDIiDYyMkIyVUtLC6lcXV2dJbrXi5OTk8l1dJnM3d0dUlNTob+/H7hcLuX2LVu2mNzfRGpra4HL5UJTUxM0NTXBz58/p9Sek5MTfP/+HdRqNajVam2+l5eX1nzjaf78+VPqayK0GO3ly5cEU9XX1xtVr6GhAVgsFh0SjGZ0dNTosgKBQG8sXC4XuFwu5ObmwvXr1yEhIYEOiXp5+/YtNDU1QWNjI+Gvseh6Cu7p6QGFQgEKhUKbt3jxYpL5PDw8zBOOU6CoqAjj4uJw27ZtCABmJRaLZVa9sLAws/s0NgUGBpqkITMzcyq702xGR0fx5cuXePPmTTx69CjGxsbikiVLKDXzeDyz90dlZSVmZ2ebpdGse7T79+9DdnY2PHv2DAAAJBIJFBYWmtoMsFgs4HA4MG/ePJPrBgYGQnNzs/Z7e3s7uLi4wNjYGAwMDOitO3v2bPDw8AA2mw0uLi46y/3+/Rvev3+vczvV72QJCQlQUFAAbDbbyEgsx7dv3wij3vgtTF9fn8ltBQUFAY/HA6VSCeHh4ZCTkwOhoaHGN2CKK6uqqjAmJobk9NWrVxt1RvD5fJRIJHj58mWsrq7G0dFRs86OyUilUoNa1qxZgzk5OdjZ2WlS2yMjI/jq1SssLi7G9PR0jIuLQz6fr3ckDg4Oxrq6OlpiswRv3rzBW7du4eHDhzE8PBxdXV0NHjuhUEjKS09PN7pPo4zW0NCAYrHYpGF2yZIlGB8fj2fOnMGKigr8+vWr2TtGH+fOnSP17ejoiACAHA4HU1NTsbq6mvZ+BwcHcevWrTrjnzVrFubm5tLer6Wor6/H/Px8PHDgAKWpdJ1YQqEQlUqlwfb1Gq2trQ2Tk5ONMpaXlxemp6djaWkpdnV10bYD9KFQKHTqOXXqlFU0ZGRkUPbv7++PAoEAL1y4YBUddDM8PIxPnjzB3NxcDAoKMnj8ZTKZ3vYojaZUKlEikWBAQIDBDsLDw1GhUFgkWH18+PABuVwupaarV69aVUtJSQmy2Wydl5qsrCyr6rEEKpUKRSKRXi8cP34cP378SFmfZLQ1a9ZoKzo7O+tsdOXKlSiXyy0eoC4iIyMpdR05coQRPQ0NDVpzTdyH4yktLY0RXXSTnp5Oud9XrVqFmZmZuGHDBsp6JKNlZ2cTGti8eTPhu6+vL+bl5Vk8IH0kJSVRBhsdHc2ortHRUb2XmYMHDzKqjy5qa2tx48aNhNgmnlzHjh0j1SEZrauri9SAs7Mzenh44OnTp60SiD5CQkIoD+KiRYuwu7ubaXmIiHjw4EGdZtu9ezfT8mhjfFAaf/iamCbfTlHeoyUmJmorcDgclEqlFntqNIW+vj6dB7CiooJpeQTS0tJIGiMjIzEmJgYzMjKYlkcbhYWFlMdj6dKlODg4qC1HabTy8nL877//sKioyGqCjeHhw4eUQV2+fJlpaZRkZWVpNQYGBqKnp6fOM96WOXXqFOVxkUgk2jJT+hcUE7i4uBCC4XA4TEvSy4ULF9DLy4t0EHx9ffHz589My6ON6OhoQnwXL14kbLc5oz148AC9vb3R2dkZ165dy7Qcozh06BDlGR8fH8+0NNqor68nxBYeHo4nT57Enp4eRLRBo9kqk8/48ZSTk8O0NFq4e/cuKbaAgADtdvssKCuRl5dH+V5/Wloa6bVsW2Tiu23jREZGaj/bjWYlFi1aBHl5eaR8d3d3UKlUDCiiF6oYIiIi/n1hcLSdkchkMsJvlOP/4bhx4wbT0syms7OT8rbg06dP2jJ2ozFAUFAQ+vr6Eg6KUChkWpbZHDlyBOfOnUuIRyAQEMrYL50McPToUWhvbyfkvXjxAu7cucOQoqnx5csX+Pr1K/D5fIiIiAChUAibNm0iFmLoJJjxREVFkS41mzZtYlqWWVC9Nl5WVkYoYx/RGCIlJYWUV1lZCY8ePWJAjfm0tLTAhw8fSPkTnzgB7E+djBEbGwthYWGk/D179kBHRwcDisxD19Pm5DkTdqMxyORRzd3dHXp6ekAoFNrM/dq9e/dIeZNHMwCwnXu0nz9/YktLC9MyaGfFihUok8kopyxO95clCwoKKOcSVFZWksrahNHy8/Nx9uzZCPD3zd7m5mamJdFGf38/5QQbmPCAoNFomJZJYvJcktDQUGSz2ejm5kZZftob7cePH+jk5EQIaseOHUzLopWysjJcuHChTrO5urrivn37mJaJiH/frhUIBCSNy5Ytw4GBAVSr1ZT1pr3RNBoNKSg+n8+0LNrp7e3FnTt36nyJEODvnNXi4mLGNF66dEnnyQAAKBaLddad9kZDROTz+YSADE3tsmXOnj1LiNXBwQG9vb1Jr+BM/p3KksjlcoNT7vbu3YtDQ0M627AJozU2NuL27dsxMDCQsVlO1kStVmvX/YiLi9N5cEUiEZ44cQKfP3+OX758oVVDe3s7ZmRkEC7p/v7+lDquXLlisD370qLTlKGhIUhOToaysjKj18rg8Xjg5+cHfn5+4O/vr/3s5+end42RiVRUVMC1a9eguLiYcntwcDC8fv0aAABCQkIgLy8PBAKBwXbtRpvmqNVqOHPmDGklRwAAPp9v9JJVPB4POByO3jLv3r2DoaEhvWX2798P+fn5kJKSApcuXTKqbwCwnd/RZjqlpaW4YcMGwiVr8nd9ycfHx+iy+pJAIMCSkhKT9duNZmPI5XJctWoVymQyXLx4sdEGMbScgaG0a9cufPz4sdm6Z/Sq3LZIYmIiJCYmQldXF4yNjUFrayu0trbC27dv9S4ebewyoWKxGORyOQD8XelbKpWCVCoFX1/fKem2G81G8fb2hvPnzxPyxg030Xytra3Q1tYG3t7eRrWblJQEnz59AqlUCmKxmDa99oeBGcDw8DBoNBqjFooODg62iAa70exYhf8BaBQCEuNMYr8AAAAASUVORK5CYII="
(string)

startTime
August 12, 2024 at 10:06:07 PM UTC+5:30

*/

class LogModel {
  String? logId;
  String? elapsedTime;
  String? address;
  dynamic startTime;
  dynamic endTime;
  Timestamp date;
  bool? isLocationVerified;
  bool? isSignatureVerified;
  bool? isTimeVerified;
  String? signature;

  @override
  String toString() {
    return 'LogModel{logId: $logId, elapsedTime: $elapsedTime, startTime: $startTime, endTime: $endTime, date: $date, isLocationVerified: $isLocationVerified, isSignatureVerified: $isSignatureVerified, isTimeVerified: $isTimeVerified}';
  }

  LogModel(
      {required this.logId,
      this.elapsedTime,
      this.startTime,
      this.endTime,
      this.address,
      required this.date,
      this.isLocationVerified,
      this.isSignatureVerified,
      this.isTimeVerified,
      this.signature});

  factory LogModel.fromMap(Map<String, dynamic> data, String id) {
    return LogModel(
      logId: data['id'],
      elapsedTime: data['elapsedTime(hh:mm:ss)'],
      startTime: data['startTime'],
      address: data['address'],
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
  String? hostId;
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
      this.hostId,
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
    hostId = json['host_id'];
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
      hostId: data['host_id'],
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
    data['host_id'] = hostId;
    return data;
  }

  @override
  String toString() {
    return 'EventDataModel{date: $date, description: $description, group: $group, groupColor: $groupColor, id: $id, location: $location, address: $address, occurence: $occurence, title: $title, host: $host, time: $time, duration: $duration, startTime: $startTime, endTime: $endTime, endDate: $endDate, dates: $dates';
  }
}
