import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CheckComplimentList{
  static Future<void> setComplimentCheck(int id, List<Map<String, String>> memberList) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String _checklistKey = "room_$id";
    List<String> memberStringList = memberList.map((item) => jsonEncode(item)).toList();
    prefs.setStringList(_checklistKey, memberStringList);
  }

  static Future<List<Map<String, String>>?> getComplimentCheck(int id) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String _checklistKey = "room_$id";
    List<String> memberStringList = prefs.getStringList(_checklistKey) ?? [];
    return memberStringList.map((item){
      final decodedItem = jsonDecode(item) as Map;
      return decodedItem.map((key, value) => MapEntry(key as String, value as String));
    }).toList();
  }
}

class CheckEncouragementList{
  static Future<void> setEncouragementCheck(int id, List<Map<String, String>> memberList) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String _checklistKey = "room_$id";
    List<String> memberStringList = memberList.map((item) => jsonEncode(item)).toList();
    prefs.setStringList(_checklistKey, memberStringList);
  }

  static Future<List<Map<String, String>>?> getEncouragementCheck(int id) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String _checklistKey = "room_$id";
    List<String> memberStringList = prefs.getStringList(_checklistKey) ?? [];
    return memberStringList.map((item){
      final decodedItem = jsonDecode(item) as Map;
      return decodedItem.map((key, value) => MapEntry(key as String, value as String));
    }).toList();
  }
}