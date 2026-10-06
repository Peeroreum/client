import 'package:flutter/foundation.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/model/notification_request.dart';

class NotificationApi {
  static void sendCompliment(
      String sender, String receiver, String title, String data) {
    NotificationRequest notificationRequest = NotificationRequest(
        nickname: receiver,
        title: title,
        body: "$sender 님이 칭찬을 보냈어요!",
        type: 0,
        data: data);
    postApi(notificationRequest);
  }

  static void sendEncouragement(
      String sender, String receiver, String title, String data) {
    NotificationRequest notificationRequest = NotificationRequest(
        nickname: receiver,
        title: title,
        body: "$sender 님이 챌린지 인증을 기다려요!",
        type: 0,
        data: data);
    postApi(notificationRequest);
  }

  static Future<void> postApi(NotificationRequest notificationRequest) async {
    try {
      var result = await ApiClient().post('/member/notification',
          data: notificationRequest.toJson());
      if (result.statusCode == 200) {
        if (kDebugMode) {
          print("push 알림 성공");
        }
      } else {
        if (kDebugMode) {
          print("push 알림 실패 ${result.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
    }
  }
}
