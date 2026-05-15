import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/data/VisitCount.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/iedu/iedu_in.dart';
import 'package:peeroreum_client/screens/mypage/mypage_inquiry.dart';
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
  List<dynamic> data = [];
  List<dynamic> inroomData = [];
  List<dynamic> inviData = [];
  List<dynamic> hashTags = [];
  List<dynamic> notSuccessList = [];

  fetchStatus() async {
    token = await const FlutterSecureStorage().read(key: "accessToken");
    nickname = await const FlutterSecureStorage().read(key: "nickname");
    profileImage = await const FlutterSecureStorage().read(key: "profileImage");
    grade = await const FlutterSecureStorage().read(key: "grade");
    withPeerDay = await VisitCount.getVisitCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: SafeArea(
        child: Container(
          color: PeeroreumColor.white,
          child: FutureBuilder<void>(
              future: fetchStatus(),
              builder: (context, snapshot) {
                return bodyWidget();
              }),
        ),
      ),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      surfaceTintColor: PeeroreumColor.white,
      shadowColor: PeeroreumColor.white,
      elevation: 0.2,
      title: const Text(
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
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[100]!),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                child: firstCol()),
            const SizedBox(
              height: 16,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[100]!),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                child: secondCol()),
            const SizedBox(
              height: 16,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[100]!),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                child: thirdCol()),
            const SizedBox(
              height: 16,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[100]!),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                child: fourthCol()),
          ],
        ),
      ),
    );
  }

  Widget firstCol() {
    return Column(
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () {
            Get.to(() => MyPageProfile(nickname, true));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2,
                          color: grade != null
                              ? PeeroreumColor.gradeColor[int.parse(grade)]!
                              : const Color.fromARGB(255, 186, 188, 189)),
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
                            : const DecorationImage(
                                image: AssetImage(
                                'assets/images/user.jpg',
                              )),
                      ),
                    ),
                  ),
                  Container(width: 11),
                  Text(
                    '$nickname',
                    style: const TextStyle(
                      color: PeeroreumColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ]),
                SvgPicture.asset(
                  'assets/icons/right.svg',
                  height: 24,
                  color: PeeroreumColor.gray[600],
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 1,
          color: PeeroreumColor.gray[100],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/color_logo.png',
                height: 24,
              ),
              Container(width: 4),
              const Text(
                '+',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(width: 2),
              Text("$withPeerDay",
                  style: const TextStyle(
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

  Widget secondCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {Get.to(const InWedu())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/UsersThree.svg'),
                const SizedBox(
                  width: 12,
                ),
                T4_16px(
                  text: '내 같이방',
                  color: PeeroreumColor.gray[800],
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {Get.to(const InIedu())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/ChatsTeardrop.svg'),
                const SizedBox(
                  width: 12,
                ),
                T4_16px(
                  text: '내 질의응답',
                  color: PeeroreumColor.gray[800],
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {Get.to(const Scrap())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/BookmarkSimple.svg'),
                const SizedBox(
                  width: 12,
                ),
                T4_16px(
                  text: '스크랩',
                  color: PeeroreumColor.gray[800],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget thirdCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {Get.to(const MyPageNotification())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/bell.svg'),
                const SizedBox(
                  width: 12,
                ),
                T4_16px(
                  text: '알림 설정',
                  color: PeeroreumColor.gray[800],
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {Get.to(const MyPageAccount())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/User2.svg',
                ),
                const SizedBox(
                  width: 12,
                ),
                T4_16px(
                  text: '계정 관리',
                  color: PeeroreumColor.gray[800],
                ),
              ],
            ),
          ),
        ),
        // TextButton(
        //   onPressed: () => {PeeroreumToast.show(context, "준비 중입니다.")},
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

  Widget fourthCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {Get.to(const MyPageInquiry())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/Headset.svg'),
                const SizedBox(
                  width: 12,
                ),
                T4_16px(
                  text: '문의하기',
                  color: PeeroreumColor.gray[800],
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () => {Get.to(const MyPageVersion())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/Info.svg'),
                const SizedBox(
                  width: 12,
                ),
                T4_16px(
                  text: '버전 정보',
                  color: PeeroreumColor.gray[800],
                ),
              ],
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: PeeroreumColor.gray[100],
          onTap: () {
            logoutModal();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/SignOut.svg'),
                const SizedBox(
                  width: 12,
                ),
                T4_16px(
                  text: '로그아웃',
                  color: PeeroreumColor.gray[800],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void logoutModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "로그아웃",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                ),
                const SizedBox(height: 8),
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
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await logout();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.primaryPuple[400],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
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

  Future<void> logout() async {
    try {
      await ApiClient().post('/logout');
      print("logout 성공");
    } catch (e) {
      print("logout 예외 발생: $e");
    } finally {
      const FlutterSecureStorage().deleteAll();
      Get.offAllNamed('/signIn/email');
    }
  }
}
