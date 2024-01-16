import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCheck{
    static const String _onboardingcheckKey = "checkNewUser";

    static Future<void> setUserType(bool setTypes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_onboardingcheckKey, setTypes);
  }

  static Future<bool?> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var setTypes = prefs.getBool(_onboardingcheckKey);
    return setTypes;
  }
}