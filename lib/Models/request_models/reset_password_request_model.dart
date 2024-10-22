class ResetPasswordRequestModel {
  String? emailId;
  String? password;
  String? token;

  ResetPasswordRequestModel({this.emailId, this.password, this.token});

  ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) {
    emailId = json['emailId'];
    password = json['password'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emailId'] = this.emailId;
    data['password'] = this.password;
    data['token'] = this.token;
    return data;
  }
}
