

/*
* userName
contactNumber
school
university
yearOfStudy
userRoleId
profilePicture
* */
class UpdateProfileRequest {
  String? userId;
  String? school;
  String? university;
  String? contactNumber;
  String? userName;
  int? yearOfStudy;
  String? profilePicture;

  UpdateProfileRequest(
      {this.userId, this.school, this.university, this.contactNumber, this.userName,   this.yearOfStudy,
        this.profilePicture});

  UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    school = json['school'];
    university = json['university'];
    contactNumber = json['contactNumber'];
    userName = json['userName'];
    yearOfStudy = json['yearOfStudy'];
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if(userId != null){
      data['userId'] = userId;
    }

    if(school != null){
      data['school'] = school;
    }
    if(university != null){
      data['university'] = university;
    }
    if(contactNumber != null){
      data['contactNumber'] = contactNumber;
    }
    if(userName != null){
      data['userName'] = userName;
    }
    if(yearOfStudy != null){
      data['yearOfStudy'] = yearOfStudy;
    }
    if(profilePicture != null){
      data['profilePicture'] = profilePicture;
    }
    return data;
  }
}
