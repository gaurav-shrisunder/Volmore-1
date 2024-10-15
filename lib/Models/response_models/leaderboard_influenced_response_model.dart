class LeaderboardInfluencedResponseModel {
  String? message;
  LeaderBoardDetails? leaderBoardDetails;

  LeaderboardInfluencedResponseModel({this.message, this.leaderBoardDetails});

  factory LeaderboardInfluencedResponseModel.fromJson(
      Map<String, dynamic> json) {
    return LeaderboardInfluencedResponseModel(
      message: json['message'],
      leaderBoardDetails: json['leaderBoardDetails'] != null
          ? LeaderBoardDetails.fromJson(json['leaderBoardDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'leaderBoardDetails': leaderBoardDetails?.toJson(),
    };
  }
}

class LeaderBoardDetails {
  List<LeaderboardUser>? users;
  Pagination? pagination;

  LeaderBoardDetails({this.users, this.pagination});

  factory LeaderBoardDetails.fromJson(Map<String, dynamic> json) {
    return LeaderBoardDetails(
      users: json['users'] != null
          ? (json['users'] as List)
              .map((user) => LeaderboardUser.fromJson(user))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users?.map((user) => user.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class LeaderboardUser {
  String? userId;
  String? userName;
  int? hostInfluenceHours;
  int? yearOfStudy;
  int? participantHours;

  LeaderboardUser(
      {this.userId, this.userName, this.hostInfluenceHours, this.yearOfStudy,this.participantHours});

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      userId: json['userId'],
      userName: json['userName'],
      hostInfluenceHours: json['hostInfluenceHours'] ?? 0,
      yearOfStudy: json['yearOfStudy'] ?? 0,
      participantHours: json['participantHours'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'hostInfluenceHours': hostInfluenceHours,
      'yearOfStudy': yearOfStudy,
      'participantHours': participantHours
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
