class SignUpLoginResponseModel {
  String? message;
  UserDetails? userDetails;

  SignUpLoginResponseModel({this.message, this.userDetails});

  SignUpLoginResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    userDetails = json['userDetails'] != null
        ? UserDetails.fromJson(json['userDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (userDetails != null) {
      data['userDetails'] = userDetails!.toJson();
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
    user = json['user'] != null ? User.fromJson(json['user']) : null;
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
  String? school;
  String? university;
  int? yearOfStudy;
  String? profilePicture;

  User(
      {this.userId,
        this.userName,
        this.emailId,
        this.school,
        this.university,
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['userName'] = userName;
    data['emailId'] = emailId;
    data['organizationName'] = school;
    data['university'] = university;
    data['yearOfStudy'] = yearOfStudy;
    data['profilePicture'] = profilePicture;
    return data;
  }
}