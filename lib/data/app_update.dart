import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:url_launcher/url_launcher.dart';

/// 서버에 설정된 버전 정보와 설치된 앱 버전
class AppVersionInfo {
  final String current;
  final String minVersion;
  final String latestVersion;
  final String storeUrl;

  const AppVersionInfo({
    required this.current,
    required this.minVersion,
    required this.latestVersion,
    required this.storeUrl,
  });

  bool get needsForceUpdate => AppUpdate.isLower(current, minVersion);
  bool get hasNewVersion => AppUpdate.isLower(current, latestVersion);
}

/// 서버의 최소 지원 버전보다 낮으면 닫을 수 없는 업데이트 안내를 띄움
class AppUpdate {
  static bool _shown = false;

  /// 실패하면 null
  static Future<AppVersionInfo?> fetchInfo() async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final result = await ApiClient().get('/app/version',
          queryParameters: {'platform': platform}, options: ApiClient.silent);
      if (result.statusCode != 200) return null;

      final data = result.data['data'] as Map<String, dynamic>;
      return AppVersionInfo(
        current: (await PackageInfo.fromPlatform()).version,
        minVersion: data['minVersion'] as String? ?? '0.0.0',
        latestVersion: data['latestVersion'] as String? ?? '0.0.0',
        storeUrl: data['storeUrl'] as String? ?? '',
      );
    } catch (e) {
      if (kDebugMode) {
        print('버전 정보 조회 실패 $e');
      }
      return null;
    }
  }

  static Future<void> checkAndPrompt() async {
    if (_shown) return;
    final info = await fetchInfo();
    // 확인에 실패하면 사용을 막지 않음
    if (info == null || !info.needsForceUpdate) return;
    _shown = true;
    _showDialog(info.storeUrl);
  }

  static Future<void> openStore(String storeUrl) async {
    if (storeUrl.isEmpty) return;
    await launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
  }

  /// "1.6.0" 형식 비교, current가 min보다 낮으면 true
  @visibleForTesting
  static bool isLower(String current, String min) {
    List<int> parse(String v) => v
        .split('+')
        .first
        .split('.')
        .map((p) => int.tryParse(p) ?? 0)
        .toList();
    final a = parse(current);
    final b = parse(min);
    for (int i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x < y;
    }
    return false;
  }

  static void _showDialog(String storeUrl) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '업데이트가 필요해요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '더 안정적인 피어오름을 위해\n최신 버전으로 업데이트해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => openStore(storeUrl),
                    style: TextButton.styleFrom(
                      backgroundColor: PeeroreumColor.primaryPurple[400],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '업데이트',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: PeeroreumColor.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
