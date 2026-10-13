import 'package:shared_preferences/shared_preferences.dart';

class Read {
  // 읽은 기록 저장
  static Future<void> saveRead(List<String> readList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String readKey = 'ieduRead';
    List<String> readStringList = readList;
    prefs.setStringList(readKey, readStringList);
  }

  // 읽은 기록 불러오기
  static Future<List<String>?> getRead() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String readKey = "ieduRead";
    List<String> readStringList = prefs.getStringList(readKey) ?? [];
    return readStringList;
  }
}
