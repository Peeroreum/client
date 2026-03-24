// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/sign/signin_email_screen.dart';
import '../signin_screen.dart';

class CompletePassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/check_circle_fill.svg'),
            SizedBox(
              height: 12,
            ),
            Text(
              '비밀번호 재설정이\n완료되었어요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: PeeroreumColor.black,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '이제 새로운 비밀번호를 사용하실 수 있어요.\n다시 로그인 후 서비스를 이용해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: PeeroreumColor.gray[500]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
        width: double.maxFinite,
        height: 48,
        child: TextButton(
          onPressed: () {
            Get.offAll(() => EmailSignIn(),
                transition: Transition.noTransition);
          },
          child: Text(
            '로그인하기',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PeeroreumColor.white,
            ),
          ),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(PeeroreumColor.primaryPuple[400]),
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
