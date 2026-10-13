import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:get/get.dart';

import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/data/visit_count.dart';
import 'package:peeroreum_client/screens/mypage/mypage_acount_ps.dart';

class MyPageAccount extends StatefulWidget {
  const MyPageAccount({super.key});

  @override
  State<MyPageAccount> createState() => _MyPageAccountState();
}

class _MyPageAccountState extends State<MyPageAccount> {
  String? email;

  /// 가입 방식: email, kakao, google, apple, social(알 수 없는 기존 소셜 가입자)
  String? provider;

  Future<void> fetchStatus() async {
    email = await const FlutterSecureStorage().read(key: "email");
    try {
      final result = await ApiClient().get('/member/account');
      if (result.statusCode == 200) {
        final data = result.data['data'];
        email = data['email'] ?? email;
        provider = data['provider'];
      }
    } catch (e) {
      if (kDebugMode) {
        print("계정 정보 조회 실패 $e");
      }
    }
  }

  bool get isEmailAccount => provider == 'email';

  String get providerLabel {
    switch (provider) {
      case 'email':
        return '이메일';
      case 'kakao':
        return '카카오';
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      default:
        return '소셜';
    }
  }

  String? get providerLogo {
    switch (provider) {
      case 'kakao':
        return 'assets/images/kakao_logo.png';
      case 'google':
        return 'assets/images/google_logo.png';
      case 'apple':
        return 'assets/images/apple_logo.png';
      default:
        return null;
    }
  }

  Future<int> deleteAllMember() async {
    final dynamic result;
    try {
      result = await ApiClient().delete('/member');
    } catch (e) {
      return 500;
    }

    if (result.statusCode == 200) {
      if (kDebugMode) {
        print("회원 탈퇴 성공");
      }
    } else {
      if (kDebugMode) {
        print("회원 탈퇴 실패 ${result.statusCode}");
      }
    }

    return result.statusCode ?? 500;
  }

  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: _initFuture,
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
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          colorFilter:
              ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
        ),
      ),
      title: const Text(
        "계정관리",
        style: TextStyle(
            color: PeeroreumColor.black,
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  /// 이메일 오른쪽 가입 방식 표시 (로고 + 이름)
  Widget providerBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (providerLogo != null) ...[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage(providerLogo!), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          providerLabel,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: PeeroreumColor.gray[500],
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Container(
      color: PeeroreumColor.white,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                width: 1,
                color: PeeroreumColor.gray[200]!,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '이메일',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PeeroreumColor.gray[800],
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  email ?? 'error@mail.com',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: PeeroreumColor.gray[600],
                                  ),
                                  // 긴 이메일은 두 줄까지 표시
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // 소셜 가입자만 가입 방식 표시
                              if (provider != null && !isEmailAccount) ...[
                                const SizedBox(width: 8),
                                providerBadge(),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                // 비밀번호 변경은 이메일 가입자만
                if (isEmailAccount)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '비밀번호',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.gray[800],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(const MyPageAccountPS());
                        },
                        // style: TextButton.styleFrom(minimumSize: Size(24, 24)),
                        child: Text(
                          '변경',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: PeeroreumColor.primaryPurple[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                showWithdrawDialog();
              },
              child: Text(
                '탈퇴하기',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                    color: PeeroreumColor.gray[500]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showWithdrawDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "탈퇴하기",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "정말 탈퇴하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "현재까지의 모든 활동 데이터가 삭제됩니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
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
                          int statusCode = await deleteAllMember();
                          if (!mounted) return;
                          if (statusCode != 200) {
                            PeeroreumToast.show(context, "잠시 후에 다시 시도해 주세요.",
                                isError: true);
                            return;
                          }
                          await const FlutterSecureStorage().deleteAll();
                          await VisitCount.clear();
                          Get.offAllNamed('/signIn/email');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '탈퇴하기',
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
