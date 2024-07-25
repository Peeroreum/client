import 'package:get/get.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/screens/ranking/ranking_model.dart';

//model에서 호출
class RankingProvider extends GetConnect implements GetxService {
  var token;
  Future<List<RankingModel>?> getRanking() async {
    final String url = '${API.hostConnect}/rank/daily';
    final Response response = await get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (response.statusCode == 200) {
      return rankingFromJson(response.body);
    } else {
      print("에러${response.statusCode}");
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}
