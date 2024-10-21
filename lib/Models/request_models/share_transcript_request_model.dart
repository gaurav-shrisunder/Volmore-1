class ShareResponseRequestModel {
  final String userId;
  final String emailId;

  ShareResponseRequestModel({
    required this.userId,
    required this.emailId,
  });

  // Factory constructor to create a new instance from a map (JSON)
  factory ShareResponseRequestModel.fromJson(Map<String, dynamic> json) {
    return ShareResponseRequestModel(
      userId: json['userId'],
      emailId: json['emailId'],
    );
  }

  // Method to convert an instance of ShareResponseRequestModel to a map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emailId': emailId,
    };
  }
}
