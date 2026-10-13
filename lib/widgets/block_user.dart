import 'package:flutter/material.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';

/// 바텀시트 메뉴 한 줄 (신고하기·차단하기 등)
class ModerationSheetItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const ModerationSheetItem({
    super.key,
    required this.text,
    required this.onTap,
    this.color = PeeroreumColor.error,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Text(text,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: color,
            )),
      ),
    );
  }
}

/// 바텀시트 하단 안전 영역 여백
double sheetBottomInset(BuildContext context) {
  final bottom = MediaQuery.of(context).viewPadding.bottom;
  return bottom > 20 ? bottom : 20.0;
}

/// 신고·차단 확인 다이얼로그. 확인 시 true
Future<bool> showModerationConfirm(
  BuildContext context, {
  required String title,
  required String description,
  required String confirmText,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _ConfirmDialog(
      title: title,
      description: description,
      confirmText: confirmText,
    ),
  );
  return confirmed == true;
}

/// 차단 확인 후 서버에 차단 요청. 성공 시 true
Future<bool> confirmAndBlockUser(BuildContext context, String nickname) async {
  final confirmed = await showModerationConfirm(
    context,
    title: '$nickname 님을 차단할까요?',
    description: '차단하면 서로의 팔로우가 해제되고,\n상대방의 활동 내역이 더 이상 표시되지 않아요.',
    confirmText: '차단',
  );
  if (!confirmed) return false;

  try {
    final response = await ApiClient().post(
        '/member/block?nickname=${Uri.encodeQueryComponent(nickname)}');
    if (response.statusCode == 200) {
      if (context.mounted) {
        PeeroreumToast.show(context, '$nickname 님을 차단했어요.');
      }
      return true;
    }
    if (context.mounted) {
      PeeroreumToast.show(context, ApiClient.errorMessage(response),
          isError: true);
    }
  } catch (_) {
    if (context.mounted) {
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
    }
  }
  return false;
}

/// 차단 해제. 성공 시 true
Future<bool> unblockUser(BuildContext context, String nickname) async {
  try {
    final response = await ApiClient().delete('/member/block',
        queryParameters: {'nickname': nickname});
    if (response.statusCode == 200) {
      if (context.mounted) {
        PeeroreumToast.show(context, '$nickname 님의 차단을 해제했어요.');
      }
      return true;
    }
    if (context.mounted) {
      PeeroreumToast.show(context, ApiClient.errorMessage(response),
          isError: true);
    }
  } catch (_) {
    if (context.mounted) {
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
    }
  }
  return false;
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;

  const _ConfirmDialog({
    required this.title,
    required this.description,
    required this.confirmText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      contentPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: PeeroreumColor.white,
      surfaceTintColor: Colors.transparent,
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PeeroreumColor.gray[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[600],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: PeeroreumColor.gray[300],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('취소',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: PeeroreumColor.gray[600])),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      backgroundColor: PeeroreumColor.error,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(confirmText,
                        style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: PeeroreumColor.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
