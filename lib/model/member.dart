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
  // 소셜 가입 시 kakao, google, apple
  String? provider;
  // 이메일 인증·소셜 토큰 검증 후 서버가 발급한 가입 토큰
  String? signupToken;

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
    this.school,
    this.provider,
    this.signupToken
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
    'school': school,
    'provider': provider,
    'signupToken': signupToken
  };
}
