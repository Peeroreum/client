import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api/PeeroreumApi.dart';

class VisitCount {
  static const String _visitCountKey = 'visitCount';

  static Future<void> incrementVisitCount() async {
    int visitCount = 0;
    final prefs = await SharedPreferences.getInstance();
    final lastVisitDateStr = prefs.getString('lastVisitDate');
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastVisitDateStr != todayStr) {
      visitCount = await updateVisitCount();
      await prefs.setString('lastVisitDate', todayStr);
    } else {
      visitCount = await fetchVisitCount();
    }
    await prefs.setInt(_visitCountKey, visitCount);
  }

  static getVisitCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var visitCount = prefs.getInt(_visitCountKey);
    return visitCount;
  }

  static updateVisitCount() async {
    var token = await const FlutterSecureStorage().read(key: "accessToken");

    var inviResult = await http
        .put(Uri.parse('${API.hostConnect}/member/activeDays'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (inviResult.statusCode == 200) {
      return await jsonDecode(utf8.decode(inviResult.bodyBytes))['data'];
    } else {
      print("에러${inviResult.statusCode}");
    }
  }

  static fetchVisitCount() async {
    var token = await const FlutterSecureStorage().read(key: "accessToken");
    var nickname = await const FlutterSecureStorage().read(key: "nickname");

    var profileinfo = await http.get(
        Uri.parse('${API.hostConnect}/member/profile?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (profileinfo.statusCode == 200) {
      var data = jsonDecode(utf8.decode(profileinfo.bodyBytes))['data'];
      return data['activeDaysCount'];
    }
  }
}