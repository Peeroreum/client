// ignore_for_file: prefer_const_constructors, sort_child_properties_last, non_constant_identifier_names, prefer_is_empty

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/MemberInfo.dart';
import 'package:peeroreum_client/model/SignIn.dart';
import 'package:peeroreum_client/screens/email_signup_screen.dart';
import 'package:peeroreum_client/screens/home_wedu.dart';

import '../api/PeeroreumApi.dart';

class EmailSignIn extends StatefulWidget {
  const EmailSignIn({super.key});

  @override
  State<EmailSignIn> createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  static final storage = FlutterSecureStorage();

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
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey[800],
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            Container(
              alignment: Alignment(0.0, 0.0),
              child: Column(
                children: [
                  SizedBox(
                      // height: MediaQuery.of(context).size.height * 0.1
                    height: 60,
                  ),
                  Image.asset(
                    'assets/images/splash_logo.png',
                    height: 236.0,
                    width: 170.0,
                  ),
                  SizedBox(
                      height: 60
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: id_controller,
                          onChanged: (value) {
                            _checkInput();
                            if (value.length > 0) {
                              id_showClearbutton = true;
                            } else {
                              id_showClearbutton = false;
                            }
                          },
                          style:
                              TextStyle(fontSize: 14, color: PeeroreumColor.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: PeeroreumColor.gray[200]!)),
                              focusedBorder: OutlineInputBorder(
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
                          onChanged: (value) {
                            _checkInput();
                            if (value.length > 0) {
                              pw_showClearbutton = true;
                            } else {
                              pw_showClearbutton = false;
                            }
                          },
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
                                      ? IconButton(
                                          onPressed: () {
                                            pw_controller.clear();
                                            setState(() {
                                              pw_showClearbutton = false;
                                              _checkInput();
                                            });
                                          },
                                          icon: SvgPicture.asset(
                                            "assets/icons/x_circle.svg",
                                            color: PeeroreumColor.gray[200],
                                          ),
                                          constraints: BoxConstraints(),
                                          padding: EdgeInsets.zero,
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
                                      pw_visible
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
                          height: 16.0,
                        ),
                        // Row(
                        //   children: [
                        //     SizedBox(
                        //       width: 24,
                        //       height: 24,
                        //       child: Checkbox(
                        //         value: is_checked,
                        //         materialTapTargetSize:
                        //             MaterialTapTargetSize.shrinkWrap,
                        //         splashRadius: 24,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             is_checked = value!;
                        //           });
                        //           activate();
                        //         },
                        //         side: BorderSide(
                        //             width: 2, color: PeeroreumColor.gray[200]!),
                        //         checkColor: PeeroreumColor.white,
                        //         activeColor: PeeroreumColor.primaryPuple[400],
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(4)),
                        //       ),
                        //     ),
                        //     SizedBox(
                        //       width: 8,
                        //     ),
                        //     Text(
                        //       '로그인 상태 유지',
                        //       style: TextStyle(
                        //           fontFamily: 'Pretendard',
                        //           fontSize: 14,
                        //           fontWeight: FontWeight.w400,
                        //           color: PeeroreumColor.gray[600]),
                        //     )
                        //   ],
                        // ),
                        SizedBox(
                          height: 20.0, //40.0
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 48.0,
                          child: TextButton(
                            onPressed: is_Enabled ? () async {
                              signIn.email = id_controller.text;
                              signIn.password = pw_controller.text;
                              var result = await http.post(
                                  Uri.parse('${API.hostConnect}/login'),
                                  body: jsonEncode(signIn),
                                  headers: {'Content-Type': 'application/json'}
                              );
                              if(result.statusCode == 200) {
                                var data = jsonDecode(result.body)['data'];
                                storage.write(key: "memberInfo", value: data['accessToken']);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => HomeWedu(),
                                      transitionDuration:
                                      const Duration(seconds: 0),
                                      reverseTransitionDuration:
                                      const Duration(seconds: 0)),
                                    (route) => false
                                );
                              } else if(result.statusCode == 404 || result.statusCode == 401) {
                                Fluttertoast.showToast(
                                    msg: "이메일 혹은 비밀번호가 일치하지 않습니다."
                                );
                              } else {
                                Fluttertoast.showToast(msg: '잠시 후에 다시 시도해 주세요.');
                              }
                            } : null,
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
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  )
                              )
                            ),
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
                        )
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}
