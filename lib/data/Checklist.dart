import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CheckComplimentList{
  static const String _checklistKey = "compliement_checkSend";
  
  static Future<void> setComplimentCheck(List<Map<String, String>> memberList) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> memberStringList = memberList.map((item) => jsonEncode(item)).toList();
    prefs.setStringList(_checklistKey, memberStringList);
  }

  static Future<List<Map<String, String>>?> getComplimentCheck() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> memberStringList = prefs.getStringList(_checklistKey) ?? [];
    return memberStringList.map((item){
      final decodedItem = jsonDecode(item) as Map;
      return decodedItem.map((key, value) => MapEntry(key as String, value as String));
    }).toList();
  }
}

class CheckEncouragementList{
  static const String _checklistKey = "encouragement_checkSend";
  
  static Future<void> setEncouragementCheck(List<Map<String, String>> memberList) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> memberStringList = memberList.map((item) => jsonEncode(item)).toList();
    prefs.setStringList(_checklistKey, memberStringList);
  }

  static Future<List<Map<String, String>>?> getEncouragementCheck() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> memberStringList = prefs.getStringList(_checklistKey) ?? [];
    return memberStringList.map((item){
      final decodedItem = jsonDecode(item) as Map;
      return decodedItem.map((key, value) => MapEntry(key as String, value as String));
    }).toList();
  }
}