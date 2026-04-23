import 'package:dio/dio.dart' as dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/model/NotificationRequest.dart';

import 'PeeroreumApi.dart';

class NotificationApi {
  // static sendFriendAdd(String sender, String receiver) {
  //   NotificationRequest notificationRequest = NotificationRequest(
  //       nickname: receiver,
  //       title: "마이페이지",
  //       body: "$sender 님이 $receiver 님을 친구로 추가했어요!"
  //   );
  //
  //   postApi(notificationRequest);
  // }

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
    var token = await const FlutterSecureStorage().read(key: "accessToken");
    var dio1 = dio.Dio();
    try {
      var result = await dio1.post('${API.hostConnect}/member/notification',
          data: notificationRequest.toJson(),
          options: dio.Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }));

      if (result.statusCode == 200) {
        print("push 알림 성공");
      } else {
        print("push 알림 실패 ${result.statusCode}");
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }
}
