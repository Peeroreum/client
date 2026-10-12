import 'package:flutter/foundation.dart';

/// 하단 탭 선택 상태
/// 탭 화면을 유지(IndexedStack)하므로, 다시 열린 탭이 필요한 데이터만 갱신하는 데 사용
class MainTab {
  static const int wedu = 0;
  static const int iedu = 1;
  static const int ranking = 2;
  static const int mypage = 3;

  static final ValueNotifier<int> selected = ValueNotifier<int>(wedu);
}
