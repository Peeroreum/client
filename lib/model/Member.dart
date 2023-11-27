class Member {
  String? username;
  String? password;
  String? nickname;
  int? grade;
  int? goodSubject;
  int? badSubject;
  String? school;

  Member({
    this.username,
    this.password,
    this.nickname,
    this.grade,
    this.goodSubject,
    this.badSubject,
    this.school
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'nickname': nickname,
    'grade': grade,
    'goodSubject': goodSubject,
    'badSubject': badSubject,
    'school': school
  };
}
