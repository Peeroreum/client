import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/sign/signup_nickname_screen.dart';

import 'package:peeroreum_client/data/pending_deep_link.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  static const storage = FlutterSecureStorage();
  var socialAccount = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: PeeroreumColor.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/splash_logo.png',
                height: 236.0,
                width: 170.0,
              ),
              const SizedBox(height: 112),
              Container(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    SizedBox(
                      width: 350.0,
                      height: 48.0,
                      child: TextButton(
                        onPressed: () {
                          kakaoSignIn();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 254, 229, 0)),
                        ),
                        child: const Text(
                          '카카오 로그인',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: Colors.black87),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    SizedBox(
                      width: 350.0,
                      height: 48.0,
                      child: TextButton(
                        onPressed: () {
                          googleSignIn();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey[200]),
                        ),
                        child: const Text(
                          '구글 로그인',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: Colors.black87),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    Container(
                      width: 350.0,
                      height: 48.0,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed('/signIn/email');
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey[200]),
                        ),
                        child: const Text(
                          '이메일 로그인',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void kakaoSignIn() async {
    OAuthToken? kakaoToken;
    if (await isKakaoTalkInstalled()) {
      try {
        kakaoToken = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          kakaoToken = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
          return;
        }
      }
    } else {
      try {
        kakaoToken = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
        return;
      }
    }

    if (kakaoToken == null) return;
    final User user = await UserApi.instance.me();
    fetchSocialLogin('kakao', kakaoToken.accessToken, user.kakaoAccount!.email!);
  }

  Future<void> fetchSocialLogin(String provider, String token, String emailForSignup) async {
    try {
      var result = await ApiClient().post(
        '/socialLogin',
        data: {'provider': provider, 'token': token},
      );

      if (result.statusCode == 200) {
        var data = result.data['data'];
        storage.write(key: "accessToken", value: data['accessToken']);
        storage.write(key: "refreshToken", value: data['refreshToken']);
        storage.write(key: "email", value: data['email']);
        storage.write(key: "nickname", value: data['nickname']);
        storage.write(key: "profileImage", value: data['profileImage']);
        storage.write(key: "grade", value: data['grade']?.toString());
        PendingDeepLink.handleAfterLogin();
        Get.offAllNamed('/wedu');
      } else if (result.statusCode == 404) {
        Member member = Member();
        member.username = emailForSignup;
        Get.to(() => SignUpNickname(member),
            transition: Transition.noTransition);
      } else {
        print("소셜 로그인 실패");
      }
    } catch (e) {
      print("소셜 로그인 에러: $e");
    }
  }

  void googleSignIn() async {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    if (googleSignInAccount == null) {
      print("구글계정으로 로그인 실패");
      return;
    }
    final auth = await googleSignInAccount.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) {
      print("구글 액세스 토큰 없음");
      return;
    }
    fetchSocialLogin('google', accessToken, googleSignInAccount.email);
  }
}
