

class UserRoleResponseModel {
  List<UserRoleData>? data;
  String? message;

  UserRoleResponseModel({this.data, this.message});

  UserRoleResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <UserRoleData>[];
      json['data'].forEach((v) {
        data!.add(new UserRoleData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class UserRoleData {
  String? roleId;
  String? roleName;

  UserRoleData({this.roleId, this.roleName});

  UserRoleData.fromJson(Map<String, dynamic> json) {
    roleId = json['roleId'];
    roleName = json['roleName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roleId'] = this.roleId;
    data['roleName'] = this.roleName;
    return data;
  }
}
