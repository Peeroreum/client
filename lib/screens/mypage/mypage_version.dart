import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class MyPageVersion extends StatefulWidget {
  const MyPageVersion({super.key});

  @override
  State<MyPageVersion> createState() => _MyPageVersionState();
}

class _MyPageVersionState extends State<MyPageVersion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: bodyWidget(),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
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
        "버전정보",
        style: TextStyle(
            color: PeeroreumColor.black,
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  Widget bodyWidget() {
    return Container(
      color: PeeroreumColor.white,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                width: 1,
                color: PeeroreumColor.gray[200]!,
              ),
            ),
            child: peer_version(),
          ),
        ],
      ),
    );
  }

  Widget peer_version() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.4),
                  image: DecorationImage(
                      image: AssetImage('assets/images/peeroreum_logo.png'))),
            ),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '피어오름',
                  style: TextStyle(
                    color: PeeroreumColor.black,
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  '1.5.0',
                  style: TextStyle(
                      color: PeeroreumColor.gray[600],
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          width: 16,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: PeeroreumColor.primaryPuple[400]!,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
            child: Text(
              '최신버전',
              style: TextStyle(
                color: PeeroreumColor.primaryPuple[400],
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
