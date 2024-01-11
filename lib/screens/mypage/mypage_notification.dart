// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class MyPageNotification extends StatefulWidget {
  const MyPageNotification({super.key});

  @override
  State<MyPageNotification> createState() => _MyPageNotificationState();
}

class _MyPageNotificationState extends State<MyPageNotification> {
  bool _allChecked = false;
  bool _weduChecked = false;
  bool _iduChecked = false;
  bool _rankChecked = false;
  void Check() {
    if (_weduChecked || _iduChecked || _rankChecked) {
      setState(() {
        _allChecked = false;
      });
    }
    if (_weduChecked && _iduChecked && _rankChecked) {
      setState(() {
        _allChecked = true;
      });
    }
  }

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
          Navigator.of(context).pop();
        },
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          color: PeeroreumColor.gray[800],
        ),
      ),
      title: Text(
        "알림 설정",
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: all_noti(),
          ),
          Container(
            height: 8,
            color: PeeroreumColor.gray[50],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                wedu_noti(),
                Container(
                  height: 20,
                ),
                idu_noti(),
                Container(
                  height: 20,
                ),
                rank_noti(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget all_noti() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전체 알림',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 16,
        ),
        SizedBox(
          // width: 26,
          // height: 26,
          child: CupertinoSwitch(
            value: _allChecked,
            activeColor: PeeroreumColor.primaryPuple[400],
            trackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _allChecked = value;
                _weduChecked = value;
                _iduChecked = value;
                _rankChecked = value;
              });
            },
          ),
        )
      ],
    );
  }

  Widget wedu_noti() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '같이해냄 알림',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '챌린지 달성, 독려하기, 칭찬하기 등',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[600],
              ),
            ),
          ],
        ),
        SizedBox(
          width: 16,
        ),
        SizedBox(
          // width: 26,
          // height: 26,
          child: CupertinoSwitch(
            value: _weduChecked,
            activeColor: PeeroreumColor.primaryPuple[400],
            trackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _weduChecked = value;
                Check();
              });
            },
          ),
        )
      ],
    );
  }

  Widget idu_noti() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '내가해냄 알림',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '댓글 등록, 채택 등',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[600],
              ),
            ),
          ],
        ),
        SizedBox(
          width: 16,
        ),
        SizedBox(
          // width: 26,
          // height: 26,
          child: CupertinoSwitch(
            value: _iduChecked,
            activeColor: PeeroreumColor.primaryPuple[400],
            trackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _iduChecked = value;
                Check();
              });
            },
          ),
        )
      ],
    );
  }

  Widget rank_noti() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '랭킹 알림',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '순위 변동, 일간 순위 공지 등',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[600],
              ),
            ),
          ],
        ),
        SizedBox(
          width: 16,
        ),
        SizedBox(
          // width: 26,
          // height: 26,
          child: CupertinoSwitch(
            value: _rankChecked,
            activeColor: PeeroreumColor.primaryPuple[400],
            trackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _rankChecked = value;
                Check();
              });
            },
          ),
        )
      ],
    );
  }
}
