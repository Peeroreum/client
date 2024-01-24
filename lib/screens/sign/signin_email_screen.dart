// ignore_for_file: prefer_const_constructors, sort_child_properties_last, non_constant_identifier_names, prefer_is_empty

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/MemberInfo.dart';
import 'package:peeroreum_client/model/SignIn.dart';
import 'package:peeroreum_client/screens/bottomNaviBar.dart';
import 'package:peeroreum_client/screens/sign/signup.dart';
import 'package:peeroreum_client/screens/sign/signup_email_screen.dart';
import 'package:peeroreum_client/screens/sign/signup_nickname_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../api/PeeroreumApi.dart';
import '../../model/Member.dart';

class EmailSignIn extends StatefulWidget {
  const EmailSignIn({super.key});

  @override
  State<EmailSignIn> createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  static final secureStorage = FlutterSecureStorage();
  var socialAccount = "";

  MemberInfo memberInfo = MemberInfo();
  SignIn signIn = SignIn();

  final id_controller = TextEditingController();
  final pw_controller = TextEditingController();
  var is_checked = false;
  bool is_Enabled = false;
  bool pw_visible = true;

  void _checkInput() {
    if (id_controller.text.length >= 5 && pw_controller.text.length >= 5) {
      setState(() {
        is_Enabled = true;
      });
    } else {
      setState(() {
        is_Enabled = false;
      });
    }
  }

  bool id_showClearbutton = false;

  bool pw_showClearbutton = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          id_showClearbutton = false;
          pw_showClearbutton = false;
        });
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: PeeroreumColor.white,
        appBar: AppBar(
          backgroundColor: PeeroreumColor.white,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
          automaticallyImplyLeading: false,
        ),
        body: ListView(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 60),
                Image.asset(
                  'assets/images/splash_logo.png',
                  height: 236.0,
                  width: 170.0,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Column(
                  children: [
                    TextFormField(
                      controller: id_controller,
                      onTap: () {
                        if (id_controller.text.length > 0) {
                          setState(() {
                            id_showClearbutton = true;
                          });
                        }
                        setState(() {
                          pw_showClearbutton = false;
                        });
                      },
                      onChanged: (value) {
                        _checkInput();
                        if (value.length > 0) {
                          id_showClearbutton = true;
                        } else {
                          id_showClearbutton = false;
                        }
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (term) {
                        FocusScope.of(context).nextFocus();
                      },
                      style:
                          TextStyle(fontSize: 14, color: PeeroreumColor.black),
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: PeeroreumColor.gray[200]!)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: PeeroreumColor.black)),
                          hintText: '이메일을 입력하세요.',
                          hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.gray[600]),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: id_showClearbutton
                              ? IconButton(
                                  onPressed: () {
                                    id_controller.clear();
                                    setState(() {
                                      id_showClearbutton = false;
                                      _checkInput();
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    "assets/icons/x_circle.svg",
                                    color: PeeroreumColor.gray[200],
                                  ))
                              : null),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      controller: pw_controller,
                      onTap: () {
                        if (pw_controller.text.length > 0) {
                          setState(() {
                            pw_showClearbutton = true;
                          });
                        }
                        setState(() {
                          id_showClearbutton = false;
                        });
                      },
                      onChanged: (value) {
                        _checkInput();
                        if (value.length > 0) {
                          pw_showClearbutton = true;
                        } else {
                          pw_showClearbutton = false;
                        }
                      },
                      textInputAction: TextInputAction.done,
                      obscureText: pw_visible,
                      obscuringCharacter: '●',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: PeeroreumColor.gray[200]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: PeeroreumColor.black)),
                        hintText: '비밀번호를 입력하세요.',
                        hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600]),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              pw_showClearbutton
                                  ? GestureDetector(
                                      onTap: () {
                                        pw_controller.clear();
                                        setState(() {
                                          pw_showClearbutton = false;
                                          _checkInput();
                                        });
                                      },
                                      child: SvgPicture.asset(
                                        "assets/icons/x_circle.svg",
                                        color: PeeroreumColor.gray[200],
                                      ),
                                    )
                                  : SizedBox(
                                      width: 0,
                                    ),
                              SizedBox(
                                width: 12,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pw_visible = !pw_visible;
                                  });
                                },
                                child: SvgPicture.asset(
                                  !pw_visible
                                      ? "assets/icons/eye_on.svg"
                                      : "assets/icons/eye_off.svg",
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // suffixIconConstraints: BoxConstraints(maxHeight: 18)
                      ),
                    ),
                    SizedBox(
                      height: 20.0, //40.0
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48.0,
                      child: TextButton(
                        onPressed: is_Enabled
                            ? () async {
                                signIn.email = id_controller.text;
                                signIn.password = pw_controller.text;
                                var result = await http.post(
                                    Uri.parse('${API.hostConnect}/login'),
                                    body: jsonEncode(signIn),
                                    headers: {
                                      'Content-Type': 'application/json'
                                    });
                                if (result.statusCode == 200) {
                                  var data = jsonDecode(
                                      utf8.decode(result.bodyBytes))['data'];
                                  secureStorage.write(
                                      key: "accessToken",
                                      value: data['accessToken']);
                                  secureStorage.write(
                                      key: "email", value: data['email']);
                                  secureStorage.write(
                                      key: "nickname", value: data['nickname']);
                                  secureStorage.write(
                                      key: "profileImage",
                                      value: data['profileImage']);
                                  secureStorage.write(
                                      key: "grade",
                                      value: data['grade'].toString());
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/home', (route) => false);
                                } else if (result.statusCode == 404 ||
                                    result.statusCode == 401) {
                                  Fluttertoast.showToast(
                                      msg: "이메일 혹은 비밀번호가 일치하지 않습니다.");
                                } else {
                                  Fluttertoast.showToast(
                                      msg: '잠시 후에 다시 시도해 주세요.');
                                }
                              }
                            : null,
                        child: Text(
                          '로그인',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: PeeroreumColor.white),
                        ),
                        style: ButtonStyle(
                            padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12)),
                            backgroundColor: is_Enabled
                                ? MaterialStateProperty.all(
                                    PeeroreumColor.primaryPuple[400])
                                : MaterialStateProperty.all(
                                    PeeroreumColor.gray[300]),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ))),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TextButton(
                        //     onPressed: () {},
                        //     child: Text(
                        //       '이메일 찾기',
                        //       style: TextStyle(
                        //           fontFamily: 'Pretendard',
                        //           fontWeight: FontWeight.w600,
                        //           fontSize: 14.0,
                        //           color: Colors.grey[600]),
                        //     )
                        // ),
                        // Text(
                        //   '|',
                        //   style: TextStyle(color: Colors.grey[200]),
                        // ),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              '비밀번호 재설정',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                  color: Colors.grey[600]),
                            )),
                        Text(
                          '|',
                          style: TextStyle(color: Colors.grey[200]),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => EmailSignUp(),
                                    transitionDuration:
                                        const Duration(seconds: 0),
                                    reverseTransitionDuration:
                                        const Duration(seconds: 0)),
                              );
                            },
                            child: Text(
                              '회원가입',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                  color: Colors.grey[600]),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                          color: PeeroreumColor.gray[100],
                          thickness: 1,
                        )),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'SNS 계정으로 로그인',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: PeeroreumColor.gray[400]),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                          color: PeeroreumColor.gray[100],
                          thickness: 1,
                        )),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PeeroreumColor.gray[100],
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/kakao_logo.png'),
                                  fit: BoxFit.fill)),
                        ),
                        onTap: () {
                          kakaoSignIn();
                        },
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                        child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: PeeroreumColor.gray[200]!),
                                shape: BoxShape.circle,
                                color: PeeroreumColor.white,
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/google_logo.png'),
                                ))),
                        onTap: () {
                          googleSignIn();
                        },
                      ),
                      // SizedBox(
                      //   width: 16,
                      // ),
                      // GestureDetector(
                      //   child: Container(
                      //       height: 48,
                      //       width: 48,
                      //       decoration: BoxDecoration(
                      //           border: Border.all(
                      //               color: PeeroreumColor.gray[200]!),
                      //           shape: BoxShape.circle,
                      //           color: PeeroreumColor.white,
                      //           image: DecorationImage(
                      //             image: AssetImage(
                      //                 'assets/images/apple_logo.png'),
                      //           ))),
                      //   onTap: () {
                      //     appleSignIn();
                      //   },
                      // )
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
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
          return;
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
        return;
      }
    }

    User user = await UserApi.instance.me();
    socialAccount = user.kakaoAccount!.email!;
    fetchSocialLogin(socialAccount);
  }

  void googleSignIn() async {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    if (googleSignInAccount != null) {
      socialAccount = googleSignInAccount.email;
      fetchSocialLogin(socialAccount);
    } else {
      print("구글계정으로 로그인 실패");
      return;
    }
  }

  Future<void> fetchSocialLogin(String socialAccount) async {
    var result = await http.get(
        Uri.parse('${API.hostConnect}/socialLogin?email=${socialAccount}'),
        headers: {'Content-Type': 'application/json'});

    if (result.statusCode == 200) {
      var data = jsonDecode(utf8.decode(result.bodyBytes))['data'];
      secureStorage.write(key: "accessToken", value: data['accessToken']);
      secureStorage.write(key: "email", value: data['email']);
      secureStorage.write(key: "nickname", value: data['nickname']);
      secureStorage.write(key: "profileImage", value: data['profileImage']);
      secureStorage.write(key: "grade", value: data['grade'].toString());
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (result.statusCode == 404) {
      Member member = Member();
      member.username = socialAccount;
      Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => SignUp(member),
            transitionDuration: const Duration(seconds: 0),
            reverseTransitionDuration: const Duration(seconds: 0)),
      );
    } else {
      print("소셜 로그인 실패");
    }
  }

  // void appleSignIn() async {
  //   final credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]
  //   );
  //
  //   if(credential != null) {
  //     fetchSocialLogin(credential.userIdentifier!);
  //   }
  //   else {
  //     print("애플 로그인 실패");
  //   }
  // }
}
