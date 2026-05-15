/// 딥링크로 진입했으나 로그인이 필요한 경우 임시 보관
class PendingDeepLink {
  /// 같이방 딥링크 roomId
  static String? roomId;

  /// 프로필 딥링크 nickname
  static String? profileNickname;

  /// 로그인 성공 직후 호출.
  /// 값은 여기서 소비하지 않고 bottomNaviBar._handlePendingDeepLink() 에서 처리.
  static void handleAfterLogin() {
    // no-op: bottomNaviBar 가 initState 에서 PendingDeepLink 를 읽어 처리함
  }
}
