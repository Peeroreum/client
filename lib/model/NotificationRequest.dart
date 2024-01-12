class NotificationRequest {
  String nickname;
  String title;
  String body;

  NotificationRequest({
    required this.nickname,
    required this.title,
    required this.body
  });


  Map<String, dynamic> toJson() => {
    "nickname" : nickname,
    "title" : title,
    "body" : body
  };

}