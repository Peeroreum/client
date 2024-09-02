import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/follower/follower_model.dart';

class FollowerProvider extends GetConnect {
  var token;
  Future<List<FollowerModel>?> getFriends(String nickname) async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    final String url = '${API.hostConnect}/member/friend/$nickname';
    final Response response = await get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (response.statusCode == 200) {
      return friendFromJson(response.body);
    } else {
      print("에러${response.statusCode}");
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}
