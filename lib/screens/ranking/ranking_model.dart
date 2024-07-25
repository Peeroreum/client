List<RankingModel> rankingFromJson(dynamic str) => List<RankingModel>.from(
    (str['data'] ?? []).map((x) => RankingModel.fromJson(x)));

class RankingModel {
  String? nickname;
  String? profileImage;
  String? points;
  String? rank;

  RankingModel({this.nickname, this.profileImage, this.points, this.rank});

  factory RankingModel.fromJson(Map<String, dynamic> json) => RankingModel(
        nickname: json['nickname'],
        profileImage: json['profileImage'],
        points: json['points'],
        rank: json['rank'],
      );

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'profileImage': profileImage,
        'points': points,
        'rank': rank,
      };
}
