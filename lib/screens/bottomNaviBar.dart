import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/data/VisitCount.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/FirebaseToken.dart';
import 'package:peeroreum_client/screens/iedu/iedu_home.dart';
import 'package:peeroreum_client/screens/mypage/mypage.dart';
import 'package:peeroreum_client/screens/mypage/mypage_account.dart';
import 'package:peeroreum_client/screens/mypage/mypage_notification.dart';
import 'package:peeroreum_client/screens/prepare.dart';
import 'package:peeroreum_client/screens/wedu/wedu_home.dart';
import 'package:http/http.dart' as http;

import '../api/PeeroreumApi.dart';

class bottomNaviBar extends StatefulWidget {
  String firebaseToken;
  var selectedIndex;
  bottomNaviBar(this.firebaseToken, this.selectedIndex, {super.key});

  @override
  State<bottomNaviBar> createState() =>
      _bottomNaviBarState(firebaseToken, selectedIndex);
}

class _bottomNaviBarState extends State<bottomNaviBar> {
  String firebaseToken;
  var selectedIndex;

  List _pages = [
    Prepare(),
    HomeWedu(),
    HomeIedu(),
    Prepare(),
    MyPage(),
  ];

  _bottomNaviBarState(this.firebaseToken, this.selectedIndex);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    postFirebaseToken();
    visitCount();
  }

  void visitCount() async {
    await VisitCount.incrementVisitCount();
  }

  postFirebaseToken() async {
    var token = await const FlutterSecureStorage().read(key: 'accessToken');
    var result = await http.post(
        Uri.parse('${API.hostConnect}/member/firebasetoken'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(FirebaseToken(firebaseToken: firebaseToken)));

    if (result.statusCode == 200) {
      print("firebaseToken post 성공");
    } else {
      print("firebaseToken post 실패 ${result.statusCode}");
    }
  }

  Widget bottomNavigatorBarWidget() {
    return BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/home_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '홈'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/user_three.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/user_three_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '같이해냄'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/chats_tear_drop.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/chats_tear_drop_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '내가해냄'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/medal.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/medal_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '랭킹'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/user.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/user_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '마이페이지'),
        ],
        currentIndex: selectedIndex,
        unselectedItemColor: PeeroreumColor.gray[400],
        unselectedLabelStyle: TextStyle(fontFamily: 'Pretendard', fontSize: 12),
        selectedItemColor: PeeroreumColor.primaryPuple[400],
        selectedLabelStyle: TextStyle(fontFamily: 'Pretendard', fontSize: 12),
        backgroundColor: PeeroreumColor.white,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: bottomNavigatorBarWidget(),
    );
  }
}
