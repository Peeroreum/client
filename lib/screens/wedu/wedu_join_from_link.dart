import 'package:flutter/material.dart';
import 'package:peeroreum_client/screens/wedu/wedu_room_info_sheet.dart';

/// 딥링크로 진입 시 같이방 참여 바텀시트를 표시하는 진입점.
/// 실제 UI는 WeduRoomInfoSheet 에서 관리됩니다.
class WeduJoinFromLink {
  WeduJoinFromLink._();

  static Future<void> show(BuildContext context, String roomId) =>
      WeduRoomInfoSheet.showFromLink(context, roomId);
}
