import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/signup_nickname_screen.dart';

import '../api/PeeroreumApi.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  static final storage = FlutterSecureStorage();
  var socialAccount = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/splash_logo.png',
              height: 236.0,
              width: 170.0,
            ),
            SizedBox(height: 112),
            Container(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Container(
                    width: 350.0,
                    height: 48.0,
                    child: TextButton(
                      onPressed: () {
                        kakaoSignIn();
                      },
                      child: Text(
                        '카카오 로그인',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Colors.black87),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color.fromARGB(255, 254, 229, 0)),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 8.0)),
                  Container(
                    width: 350.0,
                    height: 48.0,
                    child: TextButton(
                      onPressed: () {
                        googleSignIn();
                      },
                      child: Text(
                        '구글 로그인',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Colors.black87),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[200]),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 8.0)),
                  Container(
                    width: 350.0,
                    height: 48.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signIn/email');
                      },
                      child: Text(
                        '이메일 로그인',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Colors.black87),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[200]),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void kakaoSignIn() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }

    User user = await UserApi.instance.me();
    socialAccount = user.kakaoAccount!.email!;
    fetchSocialLogin(socialAccount);
  }

  Future<void> fetchSocialLogin(String socialAccount) async {
    var result = await http.get(
        Uri.parse('${API.hostConnect}/socialLogin?email=${socialAccount}'),
        headers: {'Content-Type': 'application/json'}
    );

    if(result.statusCode == 200) {
      var accessToken = jsonDecode(result.body)['data'];
      storage.write(key: "memberInfo", value: accessToken);
      Navigator.pushNamedAndRemoveUntil(context, '/wedu', (route) => false);
    } else if(result.statusCode == 404) {
      Member member = Member();
      member.username = socialAccount;
      Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => SignUpNickname(member),
            transitionDuration: const Duration(seconds: 0),
            reverseTransitionDuration:
            const Duration(seconds: 0)),
      );
    } else {
      print("소셜 로그인 실패");
    }
  }

  void googleSignIn() async {
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
    var socialAccount = "";
    if(googleSignInAccount != null) {
      socialAccount = googleSignInAccount.email;
      fetchSocialLogin(socialAccount);
    } else {
      print("구글계정으로 로그인 실패");
    }
  }
}
