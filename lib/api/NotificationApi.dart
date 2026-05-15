import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/model/NotificationRequest.dart';

class NotificationApi {
  static sendCompliment(
      String sender, String receiver, String title, String data) {
    NotificationRequest notificationRequest = NotificationRequest(
        nickname: receiver,
        title: title,
        body: "$sender 님이 칭찬을 보냈어요!",
        type: 0,
        data: data);
    postApi(notificationRequest);
  }

  static sendEncouragement(
      String sender, String receiver, String title, String data) {
    NotificationRequest notificationRequest = NotificationRequest(
        nickname: receiver,
        title: title,
        body: "$sender 님이 챌린지 인증을 기다려요!",
        type: 0,
        data: data);
    postApi(notificationRequest);
  }

  static postApi(NotificationRequest notificationRequest) async {
    try {
      var result = await ApiClient().post('/member/notification',
          data: notificationRequest.toJson());
      if (result.statusCode == 200) {
        print("push 알림 성공");
      } else {
        print("push 알림 실패 ${result.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }
}
