import 'package:get/get.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/following/following_api.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/following/following_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FollowingController extends GetxController {
  var followings = <FollowingModel>[].obs;
  var isLoading = false.obs;
  var myNickname = "".obs;

  final FollowingProvider provider;
  FollowingController(this.provider);

  @override
  void onInit() {
    super.onInit();
    fetchMyNickname();
  }

  Future<void> fetchMyNickname() async {
    try {
      myNickname.value =
          await FlutterSecureStorage().read(key: "nickname") ?? "";
    } catch (e) {
      print("Error fetching my nickname: $e");
    }
  }

  Future<void> fetchFriends(String nickname) async {
    isLoading(true);
    try {
      final result = await provider.getFriends(nickname);
      if (result != null) {
        followings.assignAll(result);
        print(result);
        print("팔로잉 성공");
      } else {
        print("팔로잉 $nickname 에러");
      }
    } catch (e) {
      print("Error 팔로잉: $e");
    } finally {
      isLoading(false);
    }
  }
}
