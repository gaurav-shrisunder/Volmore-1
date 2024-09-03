class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileLink;
  final int totalMinutes;
  final int minutesInfluenced;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileLink,
    this.totalMinutes = 0, // Default value is 0
    this.minutesInfluenced = 0, // Default value is 0
  });

  // Factory method to create a UserModel from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      phone: data['number'],
      profileLink: data['profile_link'],
      totalMinutes: data['total_minutes'] ?? 0, // Default to 0 if not present
      minutesInfluenced: data['minutes_influenced'] ?? 0, 
    );
  }
}
