class SignUpRequestModel {
  String? userName;
  String? contactNumber;
  String? emailId;
  String? passwordHash;
  int? yearOfStudy;
  int? userRoleId;
  Organization? organization;

  SignUpRequestModel(
      {this.userName,
        this.contactNumber,
        this.emailId,
        this.passwordHash,
        this.yearOfStudy,
        this.userRoleId,
        this.organization});

  SignUpRequestModel.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    contactNumber = json['contactNumber'];
    emailId = json['emailId'];
    passwordHash = json['passwordHash'];
    yearOfStudy = json['yearOfStudy'];
    userRoleId = json['userRoleId'];
    organization = json['organization'] != null
        ? Organization.fromJson(json['organization'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['userName'] = userName;
    data['contactNumber'] = contactNumber;
    data['emailId'] = emailId;
    data['passwordHash'] = passwordHash;
    data['yearOfStudy'] = yearOfStudy;
    data['userRoleId'] = userRoleId;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
