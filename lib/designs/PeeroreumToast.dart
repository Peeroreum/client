import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class PeeroreumToast {
  static OverlayEntry? _currentOverlay;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    int duration = 2,
    bool isError = false,
  }) {
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
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(191),
                    borderRadius: BorderRadius.circular(1000),
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
                              ? Color.fromARGB(255, 251, 232, 232)
                              : Color.fromARGB(255, 222, 245, 226),
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          letterSpacing: -0.35,
                          color: PeeroreumColor.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
