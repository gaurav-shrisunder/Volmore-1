class UserModel {
  String? uid;
  String? name;
  String? email;
  String? phone;
  String? gradYear;
  String? state;
  String? profileLink;

   int totalMinutes;
   int minutesInfluenced;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.gradYear,
    this.state,
    this.profileLink,
    this.totalMinutes = 0, // Default value is 0
    this.minutesInfluenced = 0, // Default value is 0
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
      totalMinutes: data['total_minutes'] ?? 0, // Default to 0 if not present
      minutesInfluenced: data['minutes_influenced'] ?? 0,
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
    data['total_minutes'] = totalMinutes;
    data['minutes_influenced'] = minutesInfluenced;
    return data;
  }
}
