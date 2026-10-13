import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchIeduHistory {
  static const int _maxCount = 30;
  static const String _historyKey = 'ieduSearchHistory';

  // 검색 기록 저장
  static Future<void> saveSearchHistory(List<Map<String, String>> history) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyStringList = history.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_historyKey, historyStringList);
  }

  // 검색 기록 불러오기 (최신순으로 저장되어 있음)
  static Future<List<Map<String, String>>> getSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyStringList = prefs.getStringList(_historyKey) ?? [];
    return historyStringList.map((item) {
      final decodedItem = jsonDecode(item) as Map;
      return decodedItem.map((key, value) => MapEntry(key as String, value as String));
    }).toList();
  }

  // 검색 기록에 새 항목 추가
  static Future<void> addSearchItem(String searchItem) async {
    List<Map<String, String>> history = await getSearchHistory();
    final String currentDate = DateFormat('yy.MM.dd').format(DateTime.now());
    Map<String, String> searchEntry = {'keyword': searchItem, 'date': currentDate};

    // 중복 검색 기록 삭제 후 맨 앞(최신)에 추가
    history.removeWhere((item) => item['keyword'] == searchItem);
    history.insert(0, searchEntry);

    // 최대 30개, 넘치면 가장 오래된(맨 뒤) 기록 삭제
    if (history.length > _maxCount) {
      history.removeRange(_maxCount, history.length);
    }

    await saveSearchHistory(history);
  }

  // 검색 기록 삭제
  static Future<void> deleteSearchItem(String searchItem) async {
    List<Map<String, String>> history = await getSearchHistory();
    history.removeWhere((item) => item['keyword'] == searchItem);
    await saveSearchHistory(history);
  }

  static Future<void> deleteAllSearchItem() async {
    List<Map<String, String>> history = await getSearchHistory();
    history.clear();
    await saveSearchHistory(history);
  }
}