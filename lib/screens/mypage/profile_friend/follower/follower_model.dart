List<FollowerModel> friendFromJson(dynamic str) => List<FollowerModel>.from(
    (str['data'] ?? []).map((x) => FollowerModel.fromJson(x)));

class FollowerModel {
  String? nickname;
  String? profileImage;
  int? grade;

  FollowerModel({this.nickname, this.profileImage, this.grade});

  factory FollowerModel.fromJson(Map<String, dynamic> json) => FollowerModel(
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
