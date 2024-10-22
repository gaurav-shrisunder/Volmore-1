
class UpdateProfileResponseModel {
  String? message;
  UpdatedUser? user;

  UpdateProfileResponseModel({this.message, this.user});

  UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    user = json['user'] != null ? new UpdatedUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class UpdatedUser {
  String? userId;
  String? userName;
  String? contactNumber;
  String? emailId;
  int? yearOfStudy;
  String? mailSSOId;
  String? profilePicture;

  UpdatedUser(
      {this.userId,
        this.userName,
        this.contactNumber,
        this.emailId,
        this.yearOfStudy,
        this.mailSSOId,
        this.profilePicture});

  UpdatedUser.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    contactNumber = json['contactNumber'];
    emailId = json['emailId'];
    yearOfStudy = json['yearOfStudy'];
    mailSSOId = json['mailSSOId'];
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['contactNumber'] = this.contactNumber;
    data['emailId'] = this.emailId;
    data['yearOfStudy'] = this.yearOfStudy;
    data['mailSSOId'] = this.mailSSOId;
    data['profilePicture'] = this.profilePicture;
    return data;
  }
}
