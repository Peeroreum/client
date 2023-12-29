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
      elevation: 1,
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
            SizedBox(
              height: 8,
            ),
            Text(
              '잠금시 비밀번호를 아는 친구만 함께할 수 있어요.',
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
            value: _allChecked,
            activeColor: PeeroreumColor.primaryPuple[400],
            trackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _allChecked = value;
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
              '잠금시 비밀번호를 아는 친구만 함께할 수 있어요.',
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
              '잠금시 비밀번호를 아는 친구만 함께할 수 있어요.',
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
              '잠금시 비밀번호를 아는 친구만 함께할 수 있어요.',
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
            value: _allChecked,
            activeColor: PeeroreumColor.primaryPuple[400],
            trackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _allChecked = value;
              });
            },
          ),
        )
      ],
    );
  }
}
