import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/designs/peeroreum_typo.dart';

class PeeroreumToast {
  static OverlayEntry? _currentOverlay;
  static Timer? _timer;
  static DateTime? _lastErrorAt;

  static void show(
    BuildContext context,
    String message, {
    int duration = 2,
    bool isError = false,
  }) {
    // 공통 네트워크 오류 토스트와 화면별 실패 토스트가 겹치지 않도록 짧은 시간 내 에러 토스트는 한 번만 표시
    if (isError) {
      final now = DateTime.now();
      if (_lastErrorAt != null &&
          now.difference(_lastErrorAt!) < const Duration(milliseconds: 1500)) {
        return;
      }
      _lastErrorAt = now;
    }
    final overlay = Overlay.of(context);

    // Cancel existing timer and remove existing toast
    _timer?.cancel();
    if (_currentOverlay != null && _currentOverlay!.mounted) {
      _currentOverlay!.remove();
    }

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          // 긴 문구도 화면 밖으로 넘치지 않도록 좌우 여백 확보
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: ClipRRect(
              // 한 줄일 때는 알약 모양, 두 줄이면 둥근 사각형
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(191),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        isError
                            ? 'assets/icons/warning_circle.svg'
                            : 'assets/icons/check_circle_fill.svg',
                        colorFilter: ColorFilter.mode(
                          isError
                              ? const Color.fromARGB(255, 251, 232, 232)
                              : const Color.fromARGB(255, 222, 245, 226),
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: B4m(
                          text: message,
                          color: PeeroreumColor.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
        ),
      ),
    );

    overlay.insert(_currentOverlay!);

    _timer = Timer(Duration(seconds: duration), () {
      if (_currentOverlay != null && _currentOverlay!.mounted) {
        _currentOverlay!.remove();
        _currentOverlay = null;
      }
    });
  }
}
