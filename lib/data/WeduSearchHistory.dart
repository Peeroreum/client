import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistory {
  static const String _historyKey = 'weduSearchHistory';

  // 검색 기록 저장
  static Future<void> saveSearchHistory(List<Map<String, String>> history) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyStringList = history.map((item) => jsonEncode(item)).toList();
    prefs.setStringList(_historyKey, historyStringList);
  }

  // 검색 기록 불러오기
  static Future<List<Map<String, String>>> getSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyStringList = prefs.getStringList(_historyKey) ?? [];
    return historyStringList.map((item) {
      final decodedItem = jsonDecode(item) as Map;
      return decodedItem.map((key, value) => MapEntry(key as String, value as String));
    }).toList().reversed.toList();
  }

  // 검색 기록에 새 항목 추가
  static Future<void> addSearchItem(String searchItem) async {
    List<Map<String, String>> history = await getSearchHistory();
    final String currentDate = DateFormat('yy.MM.dd').format(DateTime.now());
    Map<String, String> searchEntry = {'keyword': searchItem, 'date': currentDate};

    // 중복 검색 기록 삭제
    history.removeWhere((item) => item['keyword'] == searchItem);

    // 10개 초과 시 가장 오래된 기록 삭제
    if (history.length == 10) {
      history.removeAt(0);
    }

    history.add(searchEntry);
    saveSearchHistory(history);
  }

  // 검색 기록 삭제
  static Future<void> deleteSearchItem(String searchItem) async {
    List<Map<String, String>> history = await getSearchHistory();
    history.removeWhere((item) => item['keyword'] == searchItem);
    saveSearchHistory(history);
  }

  static Future<void> deleteAllSearchItem() async {
    List<Map<String, String>> history = await getSearchHistory();
    history.clear();
    saveSearchHistory(history);
  }
}