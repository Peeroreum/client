import 'package:flutter/material.dart';
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

  void changeIndex(int index) {
    selectedIndex(index);
  }

  void fetchRanking() async {
    try {
      isLoading(true);
      final response = await rankingProvider.getRanking();
      if (response != null) {
        ranking.assignAll(response);
        errorMessage('');
      } else {
        errorMessage('No ranking found');
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchRanking();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
