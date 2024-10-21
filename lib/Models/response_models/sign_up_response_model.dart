class SignUpLoginResponseModel {
  String? message;
  UserDetails? userDetails;

  SignUpLoginResponseModel({this.message, this.userDetails});

  SignUpLoginResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    userDetails = json['userDetails'] != null
        ? new UserDetails.fromJson(json['userDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.userDetails != null) {
      data['userDetails'] = this.userDetails!.toJson();
    }
    return data;
  }
}

class UserDetails {
  User? user;
  String? accessToken;
  String? refreshToken;

  UserDetails({this.user, this.accessToken, this.refreshToken});

  UserDetails.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    return data;
  }
}

class User {
  String? userId;
  String? userName;
  String? emailId;
  String? school;
  String? university;
  int? yearOfStudy;
  String? profilePicture;

  User(
      {this.userId,
        this.userName,
        this.emailId,
        this.school,
        this.yearOfStudy,
        this.profilePicture});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    emailId = json['emailId'];
    school = json['school'];
    university = json['university'];
    yearOfStudy = json['yearOfStudy'];
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['emailId'] = this.emailId;
    data['school'] = this.school;
    data['university'] = this.university;
    data['yearOfStudy'] = this.yearOfStudy;
    data['profilePicture'] = this.profilePicture;
    return data;
  }
}