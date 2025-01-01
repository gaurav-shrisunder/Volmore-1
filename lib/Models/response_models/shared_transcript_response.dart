class SharedTranscriptResponse {
  List<SharedInfo>? sharedInfo;

  SharedTranscriptResponse({this.sharedInfo});

  SharedTranscriptResponse.fromJson(Map<String, dynamic> json) {
    if (json['sharedInfo'] != null) {
      sharedInfo = <SharedInfo>[];
      json['sharedInfo'].forEach((v) {
        sharedInfo!.add(new SharedInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sharedInfo != null) {
      data['sharedInfo'] = this.sharedInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SharedInfo {
  String? emailId;
  String? sharedDate;

  SharedInfo({this.emailId, this.sharedDate});

  SharedInfo.fromJson(Map<String, dynamic> json) {
    emailId = json['emailId'];
    sharedDate = json['sharedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emailId'] = this.emailId;
    data['sharedDate'] = this.sharedDate;
    return data;
  }
}
