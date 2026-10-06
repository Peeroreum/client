import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/follower/follower_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/follower/follower_model.dart';

class FollowerController extends GetxController {
  var followers = <FollowerModel>[].obs;
  var isLoading = false.obs;
  var myNickname = "".obs;

  final FollowerProvider provider;
  FollowerController(this.provider);

  @override
  void onInit() {
    super.onInit();
    fetchMyNickname();
  }

  Future<void> fetchMyNickname() async {
    try {
      myNickname.value =
          await const FlutterSecureStorage().read(key: "nickname") ?? "";
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching my nickname: $e");
      }
    }
  }

  Future<void> fetchFriends(String nickname) async {
    isLoading(true);
    try {
      final result = await provider.getFriends(nickname);
      if (result != null) {
        followers.assignAll(result);
        if (kDebugMode) {
          print(result);
        }
        if (kDebugMode) {
          print("팔로워 성공");
        }
      } else {
        if (kDebugMode) {
          print("팔로워 $nickname 에러");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error 팔로워: $e");
      }
    } finally {
      isLoading(false);
    }
  }
}
