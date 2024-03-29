// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, non_constant_identifier_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/data/VisitCount.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/iedu/iedu_in.dart';
import 'package:peeroreum_client/screens/mypage/mypage_scrap.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:peeroreum_client/screens/mypage/mypage_account.dart';
import 'package:peeroreum_client/screens/mypage/mypage_notification.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';
import 'package:peeroreum_client/screens/mypage/mypage_version.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  var token;
  var nickname;
  var profileImage;
  var grade;
  var withPeerDay = 0;
  List<dynamic> datas = [];
  List<dynamic> inroom_datas = [];
  List<dynamic> inviDatas = [];
  List<dynamic> hashTags = [];
  List<dynamic> notSuccessList = [];

  fetchStatus() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    nickname = await FlutterSecureStorage().read(key: "nickname");
    profileImage = await FlutterSecureStorage().read(key: "profileImage");
    grade = await FlutterSecureStorage().read(key: "grade");
    withPeerDay = await VisitCount.getVisitCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchStatus(),
          builder: (context, snapshot) {
            return bodyWidget();
          }),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      surfaceTintColor: PeeroreumColor.white,
      shadowColor: PeeroreumColor.white,
      elevation: 0.2,
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                  // padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MyPageProfile(nickname, true)));
          },
          // style: ElevatedButton.styleFrom(
          //   minimumSize: Size.fromHeight(56),
          //   backgroundColor: PeeroreumColor.white,
          //   elevation: 0,
          //   padding: EdgeInsets.all(0),
          // ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: Row(children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2,
                          color: grade != null
                              ? PeeroreumColor.gradeColor[int.parse(grade)]!
                              : Color.fromARGB(255, 186, 188, 189)),
                    ),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                          color: PeeroreumColor.white,
                        ),
                        image: profileImage != null
                            ? DecorationImage(
                                image: NetworkImage(profileImage),
                                fit: BoxFit.cover)
                            : DecorationImage(
                                image: AssetImage(
                                'assets/images/user.jpg',
                              )),
                      ),
                    ),
                  ),
                  Container(width: 11),
                  Text(
                    '$nickname',
                    style: TextStyle(
                      color: PeeroreumColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ])),
                SvgPicture.asset(
                  'assets/icons/right.svg',
                  height: 24,
                  color: PeeroreumColor.gray[600],
                ),
              ],
            ),
          ),
        ),
        // SizedBox(
        //   height: 17,
        // ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          height: 1,
          color: PeeroreumColor.gray[100],
        ),
        // SizedBox(
        //   height: 17,
        // ),
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/color_logo.png',
                height: 24,
              ),
              Container(width: 4),
              Text(
                '+',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(width: 2),
              Text("$withPeerDay",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget second_col() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => InWedu()))
          },
          // style: TextButton.styleFrom(
          //     minimumSize: Size.fromHeight(56),
          //     padding: EdgeInsets.symmetric(horizontal: 20)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '내 같이방',
                  style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => InIedu()))
          },
          // style: TextButton.styleFrom(
          //     minimumSize: Size.fromHeight(56),
          //     padding: EdgeInsets.symmetric(horizontal: 20)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '내 질의응답',
                  style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Scrap()))
          },
          // style: TextButton.styleFrom(
          //     minimumSize: Size.fromHeight(56),
          //     padding: EdgeInsets.symmetric(horizontal: 20)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '스크랩',
                  style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
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
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyPageNotification()))
          },
          // style: TextButton.styleFrom(
          //     minimumSize: Size.fromHeight(56),
          //     padding: EdgeInsets.symmetric(horizontal: 20)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '알림 설정',
                  style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => MyPageAccount()))
          },
          // style: TextButton.styleFrom(
          //     minimumSize: Size.fromHeight(56),
          //     padding: EdgeInsets.symmetric(horizontal: 20)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '계정 관리',
                  style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ),
        // TextButton(
        //   onPressed: () => {Fluttertoast.showToast(msg: "준비 중입니다.")},
        //   style: TextButton.styleFrom(
        //       minimumSize: Size.fromHeight(56),
        //       padding: EdgeInsets.symmetric(horizontal: 20)
        //
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       Text(
        //         '멤버십/구독 관리',
        //         style: TextStyle(
        //           color: PeeroreumColor.gray[800],
        //           fontSize: 16,
        //           fontWeight: FontWeight.w600,
        //           fontFamily: 'Pretendard',
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget fourth_col() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => MyPageVersion()))
          },
          // style: TextButton.styleFrom(
          //     minimumSize: Size.fromHeight(56),
          //     padding: EdgeInsets.symmetric(horizontal: 20)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '버전 정보',
                  style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () {
            logout();
          },
          // style: TextButton.styleFrom(
          //     minimumSize: Size.fromHeight(56),
          //     padding: EdgeInsets.symmetric(horizontal: 20)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '로그아웃',
                  style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
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
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "로그아웃",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  alignment: Alignment.center,
                  height: 48,
                  child: Text(
                    "로그아웃하시겠습니까?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: PeeroreumColor.gray[600],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300], // 배경 색상
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16), // 패딩
                          shape: RoundedRectangleBorder(
                            // 모양
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/signIn/email', (route) => false);
                          FlutterSecureStorage().deleteAll();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.primaryPuple[400],
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '확인',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
