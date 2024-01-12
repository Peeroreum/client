import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/model/NotificationRequest.dart';
import 'package:http/http.dart' as http;

import 'PeeroreumApi.dart';

class NotificationApi {

  static sendFriendAdd(String sender, String receiver) {
    NotificationRequest notificationRequest = NotificationRequest(
        nickname: receiver,
        title: "마이페이지",
        body: "$sender 님이 $receiver 님을 친구로 추가했어요!"
    );

    postApi(notificationRequest);
  }

  static sendCompliment(String sender, String receiver) {
    NotificationRequest notificationRequest = NotificationRequest(
      nickname: receiver,
      title: "같이해냄",
      body: "$sender 님이 칭찬을 보냈어요!"
    );

    postApi(notificationRequest);
  }

  static sendEncouragement(String sender, String receiver) {
    NotificationRequest notificationRequest = NotificationRequest(
        nickname: receiver,
        title: "같이해냄",
        body: "$sender 님이 챌린지 인증을 기다려요!"
    );

    postApi(notificationRequest);
  }

  static postApi(NotificationRequest notificationRequest) async {
    var token = await FlutterSecureStorage().read(key: "accessToken");
    var result = await http.post(Uri.parse('${API.hostConnect}/member/notification'),
        body: jsonEncode(notificationRequest),
        headers: {
      'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
    });

    if(result.statusCode == 200) {
      print("push 알림 성공");
    } else {
      print("push 알림 실패 ${result.statusCode}");
    }
  }
}