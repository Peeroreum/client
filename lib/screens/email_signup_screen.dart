// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/signup_nickname_screen.dart';

import '../api/PeeroreumApi.dart';

class EmailSignUp extends StatefulWidget {
  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  Member member = Member();
  final id_controller = TextEditingController();
  final pw_controller = TextEditingController();
  final pw2_controller = TextEditingController();
  bool is_Enabled = false;
  bool pw_visible = true;
  bool pw2_visible = true;

  bool id_check = false;
  bool id_duplicate = false;
  bool pw_check = false;
  bool pw2_check = false;

  void _checkInput() {
    if (id_check && pw_check && pw2_check) {
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
  bool pw2_showClearbutton = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(
            '회원가입',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: PeeroreumColor.gray[800],
            ),
          ),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이메일',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        controller: id_controller,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            id_showClearbutton = true;
                          } else {
                            id_showClearbutton = false;
                          }
                          _checkInput();
                          validateEmail();
                        },
                        decoration: InputDecoration(
                          hintText: 'peer@mail.com',
                          hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: PeeroreumColor.gray[600]),
                          errorText: id_duplicate ? "이미 사용 중인 이메일입니다." : null,
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: PeeroreumColor.error,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: PeeroreumColor.error,
                              )),
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(left: 12),
                                  child: id_showClearbutton
                                      ? IconButton(
                                          onPressed: () {
                                            id_controller.clear();
                                            setState(() {
                                              id_showClearbutton = false;
                                              id_check = false;
                                              id_duplicate = false;
                                              _checkInput();
                                            });
                                          },
                                          icon: SvgPicture.asset(
                                            "assets/icons/x_circle.svg",
                                            color: PeeroreumColor.gray[200],
                                          ))
                                      : null),
                              Container(
                                padding: id_check
                                    ? EdgeInsets.fromLTRB(0, 0, 16, 0)
                                    : null,
                                child: id_check
                                    ? SvgPicture.asset(
                                        "assets/icons/check.svg",
                                        color: PeeroreumColor.primaryPuple[400],
                                      )
                                    : SizedBox(),
                              ),
                              Container(
                                  padding: id_duplicate
                                      ? EdgeInsets.fromLTRB(0, 0, 16, 0)
                                      : null,
                                  child: id_duplicate
                                      ? SvgPicture.asset(
                                          "assets/icons/warning_circle.svg",
                                          color: PeeroreumColor.error,
                                        )
                                      : SizedBox())
                            ],
                          ),
                          helperText: emailHelperText(),
                          helperStyle: emailHelperTextStyle(),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: id_check
                              ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: PeeroreumColor.primaryPuple[400]!),
                                )
                              : OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: PeeroreumColor.black,
                                  ),
                                ),
                          enabledBorder: id_check
                              ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: PeeroreumColor.primaryPuple[400]!),
                                )
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: PeeroreumColor.gray[200]!,
                                  )),
                        ),
                        showCursor: false,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '비밀번호',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
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
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: PeeroreumColor.gray[200]!)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: PeeroreumColor.black)),
                          hintText: '비밀번호를 입력하세요',
                          hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.gray[600]),
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
                                    : SizedBox(),
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
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                      child: Text(
                        '영문, 숫자, 특수문자 포함 8자~12자',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '비밀번호 확인',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    TextField(
                      controller: pw2_controller,
                      onChanged: (value) {
                        _checkInput();
                        if (value.length > 0) {
                          pw2_showClearbutton = true;
                        } else {
                          pw2_showClearbutton = false;
                        }
                      },
                      obscureText: pw2_visible,
                      obscuringCharacter: '●',
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: PeeroreumColor.gray[200]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: PeeroreumColor.black)),
                        hintText: '비밀번호를 재입력하세요',
                        hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600]),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Padding(
                          padding: EdgeInsets.fromLTRB(12, 0, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              pw2_showClearbutton
                                  ? IconButton(
                                      onPressed: () {
                                        pw2_controller.clear();
                                        setState(() {
                                          pw2_showClearbutton = false;
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
                                  : SizedBox(),
                              SizedBox(
                                width: 12,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pw2_visible = !pw2_visible;
                                  });
                                },
                                child: SvgPicture.asset(
                                  pw_visible
                                      ? "assets/icons/eye_on.svg"
                                      : "assets/icons/eye_off.svg",
                                  color: PeeroreumColor.gray[600],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            ),
          ),
        ),
        bottomSheet: Container (
          child: Container(
            color: PeeroreumColor.white,
            padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: is_Enabled
                    ? () {
                  member.username = id_controller.text;
                  member.password = pw_controller.text;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => SignUpNickname(member),
                        transitionDuration: const Duration(seconds: 0),
                        reverseTransitionDuration:
                        const Duration(seconds: 0)),
                  );
                }
                    : null,
                child: Text(
                  '다음',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      color: PeeroreumColor.white),
                ),
                style: ButtonStyle(
                    backgroundColor: is_Enabled
                        ? MaterialStateProperty.all(
                        PeeroreumColor.primaryPuple[400])
                        : MaterialStateProperty.all(PeeroreumColor.gray[300]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ))),
              ),
            ),
          ),
        ),
      ),
    );
  }

  validateEmail() async {
    id_duplicate = await isDuplicatedEmail();
    if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
            .hasMatch(id_controller.text) &&
        !id_duplicate) {
      id_check = true;
    } else {
      id_check = false;
    }
  }

  isDuplicatedEmail() async {
    var result = await http.get(
        Uri.parse('${API.hostConnect}/signup/email/${id_controller.text}'),
        headers: {'Content-Type': 'application/json'});
    if (result.statusCode == 409) {
      return true;
    } else {
      return false;
    }
  }

  emailHelperText() {
    if (id_check) {
      return "사용 가능한 이메일입니다.";
    }
    if (id_duplicate) {
      return "이미 사용 중인 이메일입니다.";
    }
    return "";
  }

  emailHelperTextStyle() {
    if (id_check) {
      return TextStyle(
          fontFamily: "Pretendard",
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: PeeroreumColor.primaryPuple[400]);
    }
    if (id_duplicate) {
      return TextStyle(
          fontFamily: "Pretendard",
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: PeeroreumColor.error);
    }
    return TextStyle();
  }
}
