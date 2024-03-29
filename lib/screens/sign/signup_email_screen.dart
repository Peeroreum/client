// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/sign/signup.dart';
import 'package:peeroreum_client/screens/sign/signup_nickname_screen.dart';

import '../../api/PeeroreumApi.dart';

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
  bool pw_hide = true;
  bool pw2_hide = true;

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

  bool id_focus = false;
  bool pw_focus = false;
  bool pw2_focus = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          id_showClearbutton = false;
          pw_showClearbutton = false;
          pw2_showClearbutton = false;
          id_focus = false;
          pw_focus = false;
          pw2_focus = false;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
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
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.3),
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
                          onTap: () {
                            if (id_controller.text.length > 0) {
                              setState(() {
                                id_showClearbutton = true;
                              });
                            }
                            setState(() {
                              pw_showClearbutton = false;
                              pw2_showClearbutton = false;
                              id_focus = true;
                              pw_focus = false;
                              pw2_focus = false;
                            });
                          },
                          onChanged: (value) {
                            validateEmail();
                            _checkInput();
                            setState(() {
                              if (value.isNotEmpty) {
                                id_showClearbutton = true;
                              } else {
                                id_showClearbutton = false;
                              }
                            });
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) {
                            id_focus = false;
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
                                borderSide:
                                    BorderSide(color: PeeroreumColor.error)),
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
                                        ? GestureDetector(
                                            onTap: () {
                                              id_controller.clear();
                                              setState(() {
                                                id_showClearbutton = false;
                                                id_check = false;
                                                id_duplicate = false;
                                                _checkInput();
                                              });
                                            },
                                            child: SvgPicture.asset(
                                              "assets/icons/x_circle.svg",
                                              color: PeeroreumColor.gray[200],
                                            ))
                                        : null),
                                SizedBox(
                                  width: 12,
                                ),
                                Container(
                                  padding: id_check
                                      ? EdgeInsets.fromLTRB(0, 0, 16, 0)
                                      : null,
                                  child: id_check
                                      ? SvgPicture.asset(
                                          "assets/icons/check.svg",
                                          color:
                                              PeeroreumColor.primaryPuple[400],
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
                            helperText: id_focus ? emailHelperText() : null,
                            helperStyle: emailHelperTextStyle(),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            focusedBorder: id_check
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            PeeroreumColor.primaryPuple[400]!),
                                  )
                                : OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: PeeroreumColor.black,
                                    ),
                                  ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: id_focus
                                      ? (id_check
                                          ? PeeroreumColor.primaryPuple[400]!
                                          : PeeroreumColor.gray[200]!)
                                      : PeeroreumColor.gray[200]!),
                            ),
                          ),
                          cursorColor: PeeroreumColor.gray[600]),
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
                        onTap: () {
                          if (pw_controller.text.length > 0) {
                            setState(() {
                              pw_showClearbutton = true;
                            });
                          }
                          setState(() {
                            id_showClearbutton = false;
                            pw2_showClearbutton = false;
                            id_focus = false;
                            pw_focus = true;
                            pw2_focus = false;
                          });
                        },
                        onChanged: (value) {
                          _checkInput();
                          if (value.isNotEmpty) {
                            pw_showClearbutton = true;
                            if (pw_controller.text == pw2_controller.text) {
                              setState(() {
                                pw2_check = true;
                              });
                            } else {
                              setState(() {
                                pw2_check = false;
                              });
                            }
                          } else {
                            pw_showClearbutton = false;
                          }
                          if (RegExp(
                                  r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,12}$')
                              .hasMatch(pw_controller.text)) {
                            setState(() {
                              pw_check = true;
                            });
                          } else {
                            setState(() {
                              pw_check = false;
                            });
                          }
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          pw_focus = false;
                        },
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력하세요',
                          hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: PeeroreumColor.gray[600]),
                          errorText: pw_controller.text.length >= 2 && !pw_check
                              ? "영문, 숫자, 특수문자 포함 8자~12자"
                              : null,
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
                                  child: pw_showClearbutton
                                      ? GestureDetector(
                                          onTap: () {
                                            pw_controller.clear();
                                            setState(() {
                                              pw_showClearbutton = false;
                                              pw_check = false;
                                            });
                                            _checkInput();
                                          },
                                          child: SvgPicture.asset(
                                            "assets/icons/x_circle.svg",
                                            color: PeeroreumColor.gray[200],
                                          ))
                                      : null),
                              SizedBox(
                                width: 12,
                              ),
                              pw_suffix()
                            ],
                          ),
                          helperText: pw_check
                              ? (pw_focus ? "사용 가능한 비밀번호입니다." : null)
                              : "영문, 숫자, 특수문자 포함 8자~12자",
                          helperStyle: pw_check
                              ? TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: PeeroreumColor.primaryPuple[400])
                              : TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: PeeroreumColor.gray[600]),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: pw_check
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
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: pw_focus
                                    ? (pw_check
                                        ? PeeroreumColor.primaryPuple[400]!
                                        : PeeroreumColor.gray[200]!)
                                    : PeeroreumColor.gray[200]!),
                          ),
                        ),
                        showCursor: false,
                        obscureText: pw_hide,
                        obscuringCharacter: '●',
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
                    TextFormField(
                      controller: pw2_controller,
                      scrollPadding: EdgeInsets.only(bottom: 140),
                      onTap: () {
                        if (pw2_controller.text.length > 0) {
                          setState(() {
                            pw2_showClearbutton = true;
                          });
                        }
                        setState(() {
                          id_showClearbutton = false;
                          pw_showClearbutton = false;
                          id_focus = false;
                          pw_focus = false;
                          pw2_focus = true;
                        });
                      },
                      onChanged: (value) {
                        _checkInput();
                        if (value.isNotEmpty) {
                          pw2_showClearbutton = true;
                        } else {
                          pw2_showClearbutton = false;
                        }
                        if (pw_controller.text == pw2_controller.text) {
                          setState(() {
                            pw2_check = true;
                          });
                        } else {
                          setState(() {
                            pw2_check = false;
                          });
                        }
                      },
                      onFieldSubmitted: (value) {
                        pw2_focus = false;
                      },
                      obscureText: pw2_hide,
                      obscuringCharacter: '●',
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: pw2_focus
                                    ? (pw2_check
                                        ? PeeroreumColor.primaryPuple[400]!
                                        : PeeroreumColor.gray[200]!)
                                    : PeeroreumColor.gray[200]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: pw2_check
                                    ? PeeroreumColor.primaryPuple[400]!
                                    : PeeroreumColor.black)),
                        hintText: '비밀번호를 재입력하세요',
                        hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600]),
                        helperText: pw2_focus
                            ? (pw2_check ? "비밀번호가 일치합니다." : "")
                            : null,
                        helperStyle: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: PeeroreumColor.primaryPuple[400]),
                        errorText: !pw2_check && pw2_controller.text.length >= 2
                            ? "비밀번호가 일치하지 않습니다."
                            : null,
                        errorStyle:
                            !pw2_check && pw2_controller.text.length >= 2
                                ? TextStyle(
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: PeeroreumColor.error)
                                : null,
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: PeeroreumColor.error)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: PeeroreumColor.error)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              pw2_showClearbutton
                                  ? GestureDetector(
                                      onTap: () {
                                        pw2_controller.clear();
                                        setState(() {
                                          pw2_showClearbutton = false;
                                          pw2_check = false;
                                        });
                                        _checkInput();
                                      },
                                      child: SvgPicture.asset(
                                        "assets/icons/x_circle.svg",
                                        color: PeeroreumColor.gray[200],
                                      ),
                                    )
                                  : SizedBox(),
                              SizedBox(
                                width: 12,
                              ),
                              pw2_suffix()
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
        bottomSheet: Container(
          child: Container(
            color: PeeroreumColor.white,
            padding: MediaQuery.of(context).viewInsets.bottom > 0
                ? EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom)
                : EdgeInsets.fromLTRB(20, 8, 20, 28),
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: (id_check && pw_check && pw2_check)
                    ? () {
                        member.username = id_controller.text;
                        member.password = pw_controller.text;
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (_, __, ___) => SignUp(member),
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
                    backgroundColor: ((id_check && pw_check && pw2_check))
                        ? MaterialStateProperty.all(
                            PeeroreumColor.primaryPuple[400])
                        : MaterialStateProperty.all(PeeroreumColor.gray[300]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                          ? BorderRadius.zero
                          : BorderRadius.circular(8.0),
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
    setState(() {
      if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
              .hasMatch(id_controller.text) &&
          !id_duplicate) {
        id_check = true;
      } else {
        id_check = false;
      }
    });
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

  pw_suffix() {
    if (pw_check) {
      return Container(
          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/check.svg",
            color: PeeroreumColor.primaryPuple[400],
          ));
    }
    if (pw_controller.text.length >= 2 && !pw_check) {
      return Container(
          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/warning_circle.svg",
            color: PeeroreumColor.error,
          ));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          pw_hide = !pw_hide;
        });
      },
      child: Container(
        padding: EdgeInsets.only(right: 16),
        child: SvgPicture.asset(
          pw_hide ? "assets/icons/eye_off.svg" : "assets/icons/eye_on.svg",
          color: PeeroreumColor.gray[600],
        ),
      ),
    );
  }

  pw2_suffix() {
    if (pw2_check) {
      return Container(
          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/check.svg",
            color: PeeroreumColor.primaryPuple[400],
          ));
    }
    if (pw2_controller.text.length >= 2 && !pw2_check) {
      return Container(
          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/warning_circle.svg",
            color: PeeroreumColor.error,
          ));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          pw2_hide = !pw2_hide;
        });
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 0, 16, 0),
        child: SvgPicture.asset(
          pw2_hide ? "assets/icons/eye_off.svg" : "assets/icons/eye_on.svg",
          color: PeeroreumColor.gray[600],
        ),
      ),
    );
  }
}
