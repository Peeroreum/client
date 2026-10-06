import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';

class Prepare extends StatelessWidget {
  const Prepare({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 320,
              height: 320,
              child: Image.asset('assets/images/prepare_oreum.png'),
            ),
            const SizedBox(height: 108),
            const Text(
              '준비 중입니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: PeeroreumColor.black
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '조금만 기다려 주세요!',
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: PeeroreumColor.gray[700]
              ),
            ),
            const SizedBox(height: 80,)
          ],
        ),
      ),
    );
  }
}
