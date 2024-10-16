
class RefreshTokenResponseModel {
  String? message;
  Token? token;

  RefreshTokenResponseModel({this.message, this.token});

  RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    token = json['token'] != null ? Token.fromJson(json['token']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (token != null) {
      data['token'] = token!.toJson();
    }
    return data;
  }
}

class Token {
  String? accessToken;

  Token({this.accessToken});

  Token.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    return data;
  }
}

