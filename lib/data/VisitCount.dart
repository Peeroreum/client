import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peeroreum_client/api/ApiClient.dart';

class VisitCount {
  static const String _visitCountKey = 'visitCount';

  static Future<void> incrementVisitCount() async {
    int? visitCount = 0;
    final prefs = await SharedPreferences.getInstance();
    final lastVisitDateStr = prefs.getString('lastVisitDate');
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastVisitDateStr != todayStr) {
      visitCount = await updateVisitCount();
      await prefs.setString('lastVisitDate', todayStr);
    } else {
      visitCount = await fetchVisitCount();
    }
    await prefs.setInt(_visitCountKey, visitCount ?? 0);
  }

  static getVisitCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var visitCount = prefs.getInt(_visitCountKey);
    return visitCount;
  }

  static updateVisitCount() async {
    var inviResult = await ApiClient().put('/member/activeDays');
    if (inviResult.statusCode == 200) {
      return inviResult.data['data'];
    } else {
      print("에러${inviResult.statusCode}");
    }
  }

  static fetchVisitCount() async {
    var nickname = await const FlutterSecureStorage().read(key: "nickname");

    var profileinfo = await ApiClient().get('/member/profile', queryParameters: {'nickname': nickname});
    if (profileinfo.statusCode == 200) {
      var data = profileinfo.data['data'];
      return data['activeDaysCount'];
    }
  }
}
