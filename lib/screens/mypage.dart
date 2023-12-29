// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/in_wedu.dart';
import 'package:peeroreum_client/screens/mypage_account.dart';
import 'package:peeroreum_client/screens/mypage_notification.dart';
import 'package:peeroreum_client/screens/mypage_profile.dart';
import 'package:peeroreum_client/screens/mypage_version.dart';
import 'package:peeroreum_client/screens/signin_screen.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int selectedIndex = 5;

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
      title: Text(
        "마이페이지",
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
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[100]!),
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: first_col()),
              SizedBox(
                height: 16,
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[100]!),
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: second_col()),
              SizedBox(
                height: 16,
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[100]!),
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: third_col()),
              SizedBox(
                height: 16,
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[100]!),
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: fourth_col()),
            ],
          ),
        ),
      ),
    );
  }

  Widget first_col() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                child: Row(children: [
              Container(
                padding: EdgeInsets.all(3.5),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PeeroreumColor.gray[200]!
                      //color: PeeroreumColor.gradeColor[successList[index]['grade']]!
                      ),
                  image: DecorationImage(
                      image: AssetImage('assets/images/user.jpg')),
                ),
              ),
              Container(width: 11),
              Text(
                'name',
                style: TextStyle(
                  color: PeeroreumColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Pretendard',
                ),
              ),
            ])),
            SvgPicture.asset('assets/icons/right.svg')
          ],
        ),
        SizedBox(
          height: 17,
        ),
        Container(
          height: 1,
          color: PeeroreumColor.gray[100],
        ),
        SizedBox(
          height: 17,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => MyPageProfile(),
              icon: SvgPicture.asset('assets/images/oreum.png'),
            ),
            Container(width: 4),
            Text('+'),
            Container(width: 2),
            Text('NN'),
          ],
        ),
      ],
    );
  }

  Widget second_col() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () => InWedu(),
          child: Text(
            '내 같이방',
            style: TextStyle(
              color: PeeroreumColor.gray[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        TextButton(
          onPressed: () => {},
          child: Text(
            '내 질의응답',
            style: TextStyle(
              color: PeeroreumColor.gray[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        TextButton(
          onPressed: () => {},
          child: Text(
            '스크랩',
            style: TextStyle(
              color: PeeroreumColor.gray[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ],
    );
  }

  Widget third_col() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () => MyPageNotification(),
          child: Text(
            '알림 설정',
            style: TextStyle(
              color: PeeroreumColor.gray[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        TextButton(
          onPressed: () => MyPageAccount(),
          child: Text(
            '계정 관리',
            style: TextStyle(
              color: PeeroreumColor.gray[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        TextButton(
          onPressed: () => {},
          child: Text(
            '멤버십/구독 관리',
            style: TextStyle(
              color: PeeroreumColor.gray[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ],
    );
  }

  Widget fourth_col() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () => MyPageVersion(),
          child: Text(
            '버전 정보',
            style: TextStyle(
              color: PeeroreumColor.gray[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            logout();
          },
          child: Text(
            '로그아웃',
            style: TextStyle(
              color: PeeroreumColor.gray[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ],
    );
  }

  void logout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text("로그아웃", textAlign: TextAlign.center),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
            color: PeeroreumColor.black,
          ),
          titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          content: Text(
            "로그아웃 하시겠습니까?",
            textAlign: TextAlign.center,
          ),
          contentTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Pretendard',
            color: PeeroreumColor.gray[600],
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(PeeroreumColor.gray[300]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.gray[600],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (_, __, ___) => SignIn(),
                              transitionDuration: const Duration(seconds: 0),
                              reverseTransitionDuration:
                                  const Duration(seconds: 0)),
                          (route) => false);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          PeeroreumColor.primaryPuple[400]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
              label: '질의응답'),
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
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        });
  }
}
