class LeaderboardInfluencedResponseModel {
  String? message;
  List<LeaderboardUser>? leaderBoardDetails;

  LeaderboardInfluencedResponseModel({this.message, this.leaderBoardDetails});

  factory LeaderboardInfluencedResponseModel.fromJson(
      Map<String, dynamic> json) {
    return LeaderboardInfluencedResponseModel(
      message: json['message'],
      leaderBoardDetails: json['leaderBoardDetails'] != null
    ? (json['leaderBoardDetails'] as List)
        .map((user) => LeaderboardUser.fromJson(user))
        .toList()
        : []
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'leaderBoardDetails': leaderBoardDetails?.map((user) => user.toJson()).toList(),
    };
  }
}



class LeaderboardUser {
  String? userId;
  String? userName;
  String? locationState;
  String? profilePicture;
  int? hostInfluenceHours;
  int? yearOfStudy;
  int? participantHours;

  LeaderboardUser(
      {this.userId, this.userName, this.hostInfluenceHours, this.yearOfStudy,this.participantHours, this.locationState, this.profilePicture});

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      userId: json['userId'],
      userName: json['userName'],
        locationState: json['locationState'],
        // profilePicture: json['profilePicture'],
      hostInfluenceHours: json['hostInfluenceMinutes'] ?? 0,
      yearOfStudy: json['yearOfStudy'] ?? 0,
      participantHours: json['participantMinutes'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'locationState': locationState,
      'hostInfluenceMinutes': hostInfluenceHours,
      'yearOfStudy': yearOfStudy,
      // 'profilePicture': profilePicture,
      'participantMinutes': participantHours
    };
  }
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalCount;

  Pagination({this.currentPage, this.totalPages, this.totalCount});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalCount: json['totalCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalCount': totalCount,
    };
  }
}
