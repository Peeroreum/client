import 'package:shared_preferences/shared_preferences.dart';

class NotificationSetting {
  static const String _notificationKey = "notificationSetting";

  static Future<void> setNotificationType(List<String> setTypes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_notificationKey, setTypes);
  }

  static Future<List<String>?> getNotificationType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var setTypes = prefs.getStringList(_notificationKey);
    return setTypes;
  }
}