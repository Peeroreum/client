import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/screens/ranking/ranking_model.dart';

//model에서 호출
class RankingProvider extends GetConnect implements GetxService {
  var token;
  Future<List<RankingModel>?> getRanking() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    final String url = '${API.hostConnect}/rank/daily';
    final Response response = await get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (response.statusCode == 200) {
      return rankingFromJson(response.body);
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
