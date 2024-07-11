class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileLink;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileLink,
  });

  // Factory method to create a UserModel from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      phone: data['number'],
      profileLink: data['profile_link'],
    );
  }
}
