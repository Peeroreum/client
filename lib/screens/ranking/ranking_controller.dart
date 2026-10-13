import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/screens/ranking/ranking_api.dart';
import 'package:peeroreum_client/screens/ranking/ranking_model.dart';

class RankingController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final ScrollController scrollController = ScrollController();
  final RankingProvider rankingProvider = RankingProvider();
  final RxList<RankingModel> ranking = <RankingModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString mynickname = ''.obs;
  final RxString myprofileImage = ''.obs;

  void changeIndex(int index) {
    selectedIndex(index);
  }

  /// [showLoading]이 false면 기존 목록을 보여준 채로 갱신
  Future<void> fetchRanking({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading(true);
      final response = await rankingProvider.getRanking();
      if (response != null && response.isNotEmpty) {
        ranking.assignAll(response);
        errorMessage('');
      } else {
        // 주가 바뀌어 랭킹이 비면 지난 주 목록이 남지 않도록 비움
        ranking.clear();
        errorMessage('No ranking found');
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMy() async {
    const storage = FlutterSecureStorage();
    final loadedNickname = await storage.read(key: "nickname");
    final loadedProfileImage = await storage.read(key: "profileImage");
    mynickname.value = loadedNickname ?? '';
    myprofileImage.value = loadedProfileImage ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    fetchRanking();
    loadMy();
  }


  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
