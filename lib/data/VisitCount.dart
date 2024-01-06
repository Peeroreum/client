import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitCount {
  static const String _visitCountKey = 'visitCount';

  static Future<void> incrementVisitCount() async {
    int visitCount = 0;
    final prefs = await SharedPreferences.getInstance();
    final lastVisitDateStr = prefs.getString('lastVisitDate');
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastVisitDateStr != todayStr) {
      visitCount = prefs.getInt(_visitCountKey) ?? 0;
      visitCount++;
      await prefs.setInt(_visitCountKey, visitCount);
      await prefs.setString('lastVisitDate', todayStr);
    } else {
      visitCount = prefs.getInt(_visitCountKey) ?? 0;
    }
  }

  static getVisitCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var visitCount = prefs.getInt(_visitCountKey);
    return visitCount;
  }
}