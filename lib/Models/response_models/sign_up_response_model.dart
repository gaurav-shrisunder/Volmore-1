class SignUpLoginResponseModel {
  Data? data;
  String? message;

  SignUpLoginResponseModel({this.data, this.message});

  SignUpLoginResponseModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ?  Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  User? user;
  String? accessToken;
  String? refreshToken;

  Data({this.user, this.accessToken, this.refreshToken});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    return data;
  }
}

class User {
  String? userId;
  String? userName;
  String? emailId;
  String? organizationName;
  String? yearOfStudy;

  User({this.userId, this.userName, this.emailId, this.organizationName, this.yearOfStudy});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    emailId = json['emailId'];
    organizationName = json['organizationName'];
    yearOfStudy = json['yearOfStudy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['userId'] = userId;
    data['userName'] = userName;
    data['emailId'] = emailId;
    data['organizationName'] = organizationName;
    data['yearOfStudy'] = yearOfStudy;
    return data;
  }
}
