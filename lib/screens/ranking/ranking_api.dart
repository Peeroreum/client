import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/screens/ranking/ranking_model.dart';

class RankingProvider extends GetConnect implements GetxService {
  Future<List<RankingModel>?> getRanking() async {
    final response = await ApiClient().get('/rank/weekly');
    if (response.statusCode == 200) {
      return rankingFromJson(response.data);
    } else {
      if (kDebugMode) {
        print("에러${response.statusCode}");
      }
      return null;
    }
  }

}
