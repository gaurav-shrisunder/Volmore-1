class SignUpRequestModel {
  String? userName;
  String? contactNumber;
  String? emailId;
  String? passwordHash;
  int? yearOfStudy;
  String? userRoleId;
  Organization? organization;
  String? university;
  String? school;

  SignUpRequestModel(
      {this.userName,
      this.contactNumber,
      this.emailId,
      this.passwordHash,
      this.yearOfStudy,
      this.userRoleId,
      this.school,
      this.university,
      this.organization});

  SignUpRequestModel.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    contactNumber = json['contactNumber'];
    emailId = json['emailId'];
    passwordHash = json['passwordHash'];
    yearOfStudy = json['yearOfStudy'];
    userRoleId = json['userRoleId'];
    university = json['university'];
    school = json['school'];
    organization = json['organization'] != null
        ? Organization.fromJson(json['organization'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['contactNumber'] = contactNumber;
    data['emailId'] = emailId;
    data['passwordHash'] = passwordHash;
    data['yearOfStudy'] = yearOfStudy;
    data['userRoleId'] = userRoleId;
    data['school'] = school;
    data['university'] = university;
    if (organization != null) {
      data['organization'] = organization!.toJson();
    }
    return data;
  }
}

class Organization {
  dynamic id;
  String? name;

  Organization({this.id, this.name});

  Organization.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
