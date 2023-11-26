import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Member.dart';

class RememberUser {
  static Future<void> saveRememberUserInfo(Member member) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData = jsonEncode(member.toJson());
    await preferences.setString("currentUser", userJsonData);
  }
}
