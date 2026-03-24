import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import '../../../api/PeeroreumApi.dart';
import './validate_screen.dart';

class EmailSearch extends StatefulWidget {
  @override
  State<EmailSearch> createState() => _EmailSearchState();
}

class _EmailSearchState extends State<EmailSearch> {
  final email_controller = TextEditingController();
  bool is_Enabled = false;
  bool email_showClearbutton = false;
  bool email_focus = false;
  bool is_loading = false;

  void _checkInput() {
    if (RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email_controller.text)) {
      setState(() {
        is_Enabled = true;
      });
    } else {
      setState(() {
        is_Enabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          email_showClearbutton = false;
          email_focus = false;
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
                  '이메일을 입력해 주세요.',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: PeeroreumColor.black),
                ),
                SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                      controller: email_controller,
                      onTap: () {
                        if (email_controller.text.length > 0) {
                          setState(() {
                            email_showClearbutton = true;
                          });
                        }
                        setState(() {
                          email_focus = true;
                        });
                      },
                      onChanged: (value) {
                        _checkInput();
                        setState(() {
                          if (value.isNotEmpty) {
                            email_showClearbutton = true;
                          } else {
                            email_showClearbutton = false;
                          }
                        });
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        email_focus = false;
                      },
                      decoration: InputDecoration(
                        hintText: 'peer@mail.com',
                        hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: PeeroreumColor.gray[600]),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: PeeroreumColor.error)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: PeeroreumColor.error,
                            )),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        suffixIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                padding: EdgeInsets.only(left: 12),
                                child: email_showClearbutton
                                    ? GestureDetector(
                                        onTap: () {
                                          email_controller.clear();
                                          setState(() {
                                            email_showClearbutton = false;
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
                            )
                          ],
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: PeeroreumColor.black,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: PeeroreumColor.gray[200]!,
                          ),
                        ),
                      ),
                      cursorColor: PeeroreumColor.gray[600]),
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
                    ? () async {
                        if (await isExistingEmail()) {
                          sendEmail();
                        } else {
                          Fluttertoast.showToast(msg: "해당 이메일로 가입된 계정이 없어요");
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
                        '다음',
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

  isExistingEmail() async {
    var result = await http.get(
        Uri.parse('${API.hostConnect}/signup/email/${email_controller.text}'),
        headers: {'Content-Type': 'application/json'});
    if (result.statusCode == 409) {
      return true;
    } else {
      return false;
    }
  }

  sendEmail() async {
    setState(() {
      is_loading = true;
    });
    var result = await http.post(
      Uri.parse(
          '${API.hostConnect}/member/password/email?email=${email_controller.text}'),
    );
    setState(() {
      is_loading = false;
    });
    if (result.statusCode == 200) {
      var data = jsonDecode(utf8.decode(result.bodyBytes));
      if (data['status'] == 'success') {
        Get.to(() => EmailValidate(email_controller.text),
            transition: Transition.noTransition);
      } else {
        Fluttertoast.showToast(msg: "메일 전송에 실패했습니다.");
      }
    } else {
      Fluttertoast.showToast(msg: "메일을 전송할 수 없습니다. 다시 시도해 주세요.");
    }
  }
}
