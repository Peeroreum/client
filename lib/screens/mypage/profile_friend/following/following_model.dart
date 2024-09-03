List<FollowingModel> friendFromJson(dynamic str) => List<FollowingModel>.from(
    (str['data'] ?? []).map((x) => FollowingModel.fromJson(x)));

class FollowingModel {
  String? nickname;
  String? profileImage;
  int? grade;

  FollowingModel({this.nickname, this.profileImage, this.grade});

  factory FollowingModel.fromJson(Map<String, dynamic> json) => FollowingModel(
        nickname: json['nickname'],
        profileImage: json['profileImage'],
        grade: json['grade'],
      );

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'profileImage': profileImage,
        'grade': grade,
      };
}
