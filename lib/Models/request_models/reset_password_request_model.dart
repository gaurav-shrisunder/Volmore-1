class ResetPasswordRequestModel {
  String? emailId;
  String? password;


  ResetPasswordRequestModel({this.emailId, this.password});

  ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) {
    emailId = json['emailId'];
    password = json['password'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emailId'] = this.emailId;
    data['password'] = this.password;
    return data;
  }
}
