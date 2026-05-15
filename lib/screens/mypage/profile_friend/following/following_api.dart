import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/following/following_model.dart';

class FollowingProvider {
  Future<List<FollowingModel>?> getFriends(String nickname) async {
    try {
      final result = await ApiClient().get('/member/friend/$nickname/following');
      if (result.statusCode == 200) {
        return friendFromJson(result.data);
      } else {
        print("에러${result.statusCode}");
        return null;
      }
    } catch (e) {
      print("에러: $e");
      return null;
    }
  }
}
