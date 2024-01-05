class Member {
  String? username;
  String? password;
  String? nickname;
  int? grade;
  int? goodSubject;
  int? goodDetailSubject;
  int? goodLevel;
  int? badSubject;
  int? badDetailSubject;
  int? badLevel;
  String? school;

  Member({
    this.username,
    this.password,
    this.nickname,
    this.grade,
    this.goodSubject,
    this.goodDetailSubject,
    this.goodLevel,
    this.badSubject,
    this.badDetailSubject,
    this.badLevel,
    this.school
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'nickname': nickname,
    'grade': grade,
    'goodSubject': goodSubject,
    'goodDetailSubject': goodDetailSubject,
    'goodLevel': goodLevel,
    'badSubject': badSubject,
    'badDetailSubject': badDetailSubject,
    'badLevel': badLevel,
    'school': school
  };
}
