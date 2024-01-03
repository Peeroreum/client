import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/home_wedu.dart';
import 'package:peeroreum_client/screens/mypage.dart';
import 'package:peeroreum_client/screens/mypage_account.dart';
import 'package:peeroreum_client/screens/mypage_notification.dart';
import 'package:peeroreum_client/screens/mypage_version.dart';

class bottomNaviBar extends StatefulWidget {
  const bottomNaviBar({super.key});

  @override
  State<bottomNaviBar> createState() => _bottomNaviBarState();
}

class _bottomNaviBarState extends State<bottomNaviBar> {
  var selectedIndex = 4;

  List _pages = [
    HomeWedu(),
    MyPageAccount(),
    MyPageNotification(),
    MyPageVersion(),
    MyPage(),
  ];

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
