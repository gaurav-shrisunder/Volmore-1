class UserModel {
   String? uid;
   String? name;
   String? email;
   String? phone;
   String? gradYear;
   String? state;
   String? profileLink;
  dynamic totalHours;

  UserModel({
     this.uid,
     this.name,
     this.email,
     this.phone,
     this.gradYear,
     this.state,
     this.profileLink,
    this.totalHours
  });

  // Factory method to create a UserModel from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      gradYear: data['grad_year'],
      state: data['state'],
      phone: data['number'],
      profileLink: data['profile_link'],
      totalHours: data['total_hours'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    data['name'] = name;
    data['email'] = email;
    data['grad_year'] = gradYear;
    data['state'] = state;
    data['number'] = phone;
    data['profile_link'] = profileLink;
    data['total_hours'] = totalHours;
    return data;
  }
}




