import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peeroreum_client/api/api_client.dart';

class VisitCount {
  static const String _visitCountKey = 'visitCount';

  static Future<void> incrementVisitCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVisitDateStr = prefs.getString('lastVisitDate');
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 실패 시 기존 값을 유지하고, 오늘 갱신도 다음 실행 때 다시 시도
    try {
      if (lastVisitDateStr != todayStr) {
        final int? visitCount = await updateVisitCount();
        if (visitCount == null) return;
        await prefs.setString('lastVisitDate', todayStr);
        await prefs.setInt(_visitCountKey, visitCount);
      } else {
        final int? visitCount = await fetchVisitCount();
        if (visitCount == null) return;
        await prefs.setInt(_visitCountKey, visitCount);
      }
    } catch (e) {
      if (kDebugMode) {
        print('접속일 갱신 실패 $e');
      }
    }
  }

  static Future<int> getVisitCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_visitCountKey) ?? 0;
  }

  /// 로그아웃·탈퇴 시 이전 계정의 접속일 캐시 삭제
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_visitCountKey);
    await prefs.remove('lastVisitDate');
  }

  static Future<int?> updateVisitCount() async {
    var result = await ApiClient().put('/member/activeDays', options: ApiClient.silent);
    if (result.statusCode == 200) {
      return result.data['data'];
    } else {
      if (kDebugMode) {
        print("에러${result.statusCode}");
      }
      return null;
    }
  }

  static Future<int?> fetchVisitCount() async {
    var nickname = await const FlutterSecureStorage().read(key: "nickname");

    var profileInfo = await ApiClient().get('/member/profile',
        queryParameters: {'nickname': nickname}, options: ApiClient.silent);
    if (profileInfo.statusCode == 200) {
      var data = profileInfo.data['data'];
      return data['activeDaysCount'];
    }
    return null;
  }
}
