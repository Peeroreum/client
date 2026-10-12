import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCheck{
    static const String _onBoardingCheckKey = "checkNewUser";

    static Future<void> setUserType(bool setTypes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_onBoardingCheckKey, setTypes);
  }

  static Future<bool?> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var setTypes = prefs.getBool(_onBoardingCheckKey);
    return setTypes;
  }
}