import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';

/// 데이터를 불러오지 못했을 때 보여주는 공통 화면
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    super.key,
    required this.onRetry,
    this.message = '정보를 불러오지 못했어요',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PeeroreumColor.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/warning_circle.svg',
            width: 40,
            height: 40,
            colorFilter:
                ColorFilter.mode(PeeroreumColor.gray[400]!, BlendMode.srcIn),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PeeroreumColor.gray[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '네트워크 상태를 확인하고 다시 시도해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: PeeroreumColor.gray[500],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: PeeroreumColor.primaryPurple[400],
              side: BorderSide(color: PeeroreumColor.primaryPurple[400]!),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '다시 시도',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
