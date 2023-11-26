// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/signup_nickname_screen.dart';

class EmailSignUp extends StatefulWidget {
  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  final id_controller = TextEditingController();
  final pw_controller = TextEditingController();
  final pw2_controller = TextEditingController();
  bool is_Enabled = false;
  bool pw_visible = true;
  bool pw2_visible = true;

  void _checkInput() {
    if (id_controller.text.length >= 5 &&
        pw_controller.text.length >= 8 &&
        (pw_controller.text == pw2_controller.text)) {
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

  bool id_check = false;
  bool pw_check = false;
  bool pw2_check = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  TextField(
                    controller: id_controller,
                    onChanged: (value) {
                      _checkInput();
                      if (value.length > 0) {
                        id_showClearbutton = true;
                      } else {
                        id_showClearbutton = false;
                      }
                      if (id_controller.text.length > 5) {
                        id_check = true;
                      } else {
                        id_check = false;
                      }
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: PeeroreumColor.gray[200]!)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: id_check
                                  ? PeeroreumColor.primaryPuple[400]!
                                  : PeeroreumColor.black)),
                      hintText: 'peer@mail.com',
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
                            Container(
                                child: id_showClearbutton
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
                            Container(
                              child: id_check
                                  ? SvgPicture.asset(
                                      "assets/icons/check.svg",
                                      color: PeeroreumColor.primaryPuple[400],
                                    )
                                  : SizedBox(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Text(id_check ? '사용 가능한 이메일입니다.' : ''),
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
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: PeeroreumColor.gray[200]!)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: PeeroreumColor.black)),
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
                          borderSide: BorderSide(color: PeeroreumColor.black)),
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: SizedBox(
          height: 48,
          child: TextButton(
            onPressed: is_Enabled
                ? () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => SignUpNickname(),
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
    );
  }
}
