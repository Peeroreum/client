// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import '../../../api/PeeroreumApi.dart';
import './complete_screen.dart';

class NewPassword extends StatefulWidget {
  final String email;
  final String token;
  NewPassword(this.email, this.token);

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final pw_controller = TextEditingController();
  final pw2_controller = TextEditingController();
  bool is_Enabled = false;
  bool is_loading = false;
  bool pw_hide = true;
  bool pw2_hide = true;

  bool pw_check = false;
  bool pw2_check = false;

  void _checkInput() {
    if (pw_check) {
      setState(() {
        is_Enabled = true;
      });
    } else {
      setState(() {
        is_Enabled = false;
      });
    }
  }

  bool pw_showClearbutton = false;
  bool pw2_showClearbutton = false;

  bool pw_focus = false;
  bool pw2_focus = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          pw_showClearbutton = false;
          pw2_showClearbutton = false;
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
          leading: IconButton(
            onPressed: () {
              Get.back();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '비밀번호 재설정',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: PeeroreumColor.black),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  '새로운 비밀번호를 입력해 주세요.',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: PeeroreumColor.black),
                ),
                SizedBox(
                  height: 24,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '새 비밀번호',
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
                            pw2_showClearbutton = false;
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
                          _checkInput();
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
                          pw_showClearbutton = false;
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
                        _checkInput();
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
                onPressed: (is_Enabled && !is_loading)
                    ? () {
                        if (pw2_check) {
                          resetPassword();
                        } else {
                          Fluttertoast.showToast(msg: "비밀번호가 일치하지 않아요");
                        }
                      }
                    : null,
                child: is_loading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: PeeroreumColor.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '변경하기',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: PeeroreumColor.white),
                      ),
                style: ButtonStyle(
                    backgroundColor: (is_Enabled && !is_loading)
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

  resetPassword() async {
    setState(() {
      is_loading = true;
    });
    var result = await http.put(
        Uri.parse(
            '${API.hostConnect}/member/password/reset?newPassword=${pw_controller.text}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}'
        });
    setState(() {
      is_loading = false;
    });
    if (result.statusCode == 200) {
      var data = jsonDecode(utf8.decode(result.bodyBytes));
      if (data['status'] == 'success') {
        Get.to(() => CompletePassword(), transition: Transition.noTransition);
      } else {
        Fluttertoast.showToast(msg: "비밀번호 변경에 실패했습니다.");
      }
    } else {
      Fluttertoast.showToast(msg: "비밀번호 변경에 실패했습니다.");
    }
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
