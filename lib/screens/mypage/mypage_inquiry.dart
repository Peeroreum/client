import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/inquire.dart';

class MyPageInquiry extends StatelessWidget {
  const MyPageInquiry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: AppBar(
        backgroundColor: PeeroreumColor.white,
        surfaceTintColor: PeeroreumColor.white,
        shadowColor: PeeroreumColor.white,
        elevation: 0.2,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            color: PeeroreumColor.gray[800],
          ),
        ),
        title: Text(
          "문의하기",
          style: TextStyle(
              color: PeeroreumColor.black,
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTap: () {
            Get.to(() => Inquire());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: PeeroreumColor.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                width: 1,
                color: PeeroreumColor.gray[200]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '문의하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.gray[800],
                  ),
                ),
                Text(
                  'peeroreum.help@gmail.com',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
