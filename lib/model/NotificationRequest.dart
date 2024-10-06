class NotificationRequest {
  String nickname;
  String title;
  String body;
  int type;
  String data;

  NotificationRequest({
    required this.nickname,
    required this.title,
    required this.body,
    required this.type,
    required this.data
  });


  Map<String, dynamic> toJson() => {
    "nickname" : nickname,
    "title" : title,
    "body" : body,
    "type" : type,
    "data" : data
  };

}