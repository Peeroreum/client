import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/data/VisitCount.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/FirebaseToken.dart';
import 'package:peeroreum_client/screens/iedu/iedu_home.dart';
import 'package:peeroreum_client/screens/mypage/mypage.dart';
import 'package:peeroreum_client/screens/wedu/wedu_home.dart';
import 'package:peeroreum_client/screens/ranking/ranking.dart';

import 'package:get/get.dart';
import 'package:peeroreum_client/data/pending_deep_link.dart';
import 'package:peeroreum_client/screens/wedu/wedu_join_from_link.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';

class BottomNaviBar extends StatefulWidget {
  String firebaseToken;
  var selectedIndex;

  BottomNaviBar(this.firebaseToken, this.selectedIndex, {super.key});

  @override
  State<BottomNaviBar> createState() =>
      _BottomNaviBarState(firebaseToken, selectedIndex);
}

class _BottomNaviBarState extends State<BottomNaviBar> {
  String firebaseToken;
  var selectedIndex;

  final List _pages = [
    const HomeWedu(),
    const HomeIedu(),
    const Ranking(),
    const MyPage(),
  ];

  _BottomNaviBarState(this.firebaseToken, this.selectedIndex);

  @override
  void initState() {
    super.initState();
    postFirebaseToken();
    visitCount();
    _handlePendingDeepLink();
  }

  void _handlePendingDeepLink() {
    final roomId = PendingDeepLink.roomId;
    final profileNickname = PendingDeepLink.profileNickname;
    print(
        '[DeepLink] _handlePendingDeepLink roomId=$roomId profileNickname=$profileNickname');

    if (roomId != null) {
      PendingDeepLink.roomId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // GetX Navigator 초기화 완료 후 호출해야 GlobalKey 충돌 방지
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) WeduJoinFromLink.show(context, roomId);
      });
    }

    if (profileNickname != null) {
      PendingDeepLink.profileNickname = null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Get.to()는 Navigator가 완전히 준비된 후 호출해야 GlobalKey 충돌 방지
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) Get.to(() => MyPageProfile(profileNickname, false));
      });
    }
  }

  void visitCount() async {
    await VisitCount.incrementVisitCount();
  }

  postFirebaseToken() async {
    try {
      var result = await ApiClient().post('/member/firebasetoken',
          data: FirebaseToken(firebaseToken: firebaseToken).toJson());
      if (result.statusCode == 200) {
        print("firebaseToken post 성공");
      } else {
        print("firebaseToken post 실패 ${result.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Widget bottomNavigatorBarWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: PeeroreumColor.gray[100]!,
            width: 1,
          ),
        ),
      ),
      child: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              // BottomNavigationBarItem(
              //     icon: SvgPicture.asset(
              //       'assets/icons/home.svg',
              //       color: PeeroreumColor.gray[400],
              //     ),
              //     activeIcon: SvgPicture.asset(
              //       'assets/icons/home_fill.svg',
              //       color: PeeroreumColor.primaryPuple[400],
              //     ),
              //     label: '홈'),
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
            unselectedLabelStyle:
                const TextStyle(fontFamily: 'Pretendard', fontSize: 12),
            selectedItemColor: PeeroreumColor.primaryPuple[400],
            selectedLabelStyle:
                const TextStyle(fontFamily: 'Pretendard', fontSize: 12),
            backgroundColor: PeeroreumColor.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              setState(() {
                selectedIndex = index;
              });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: bottomNavigatorBarWidget(),
    );
  }
}
