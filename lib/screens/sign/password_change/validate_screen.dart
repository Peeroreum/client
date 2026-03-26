import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import '../../../api/PeeroreumApi.dart';
import './new_password_screen.dart';

class EmailValidate extends StatefulWidget {
  final String email;
  EmailValidate(this.email);

  @override
  State<EmailValidate> createState() => _EmailValidateState();
}

class _EmailValidateState extends State<EmailValidate> {
  final code_controller = TextEditingController();
  bool is_Enabled = false;
  bool is_loading = false;
  bool is_resending = false;
  late Timer _timer;
  int _secondsRemaining = 300;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _secondsRemaining = 300;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  String get timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _checkInput() {
    if (code_controller.text.length == 6) {
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
      },
      child: Scaffold(
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
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '인증번호 전송 완료',
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
                '메일함을 확인해 주세요.',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: PeeroreumColor.black),
              ),
              SizedBox(
                height: 24,
              ),
              TextFormField(
                controller: code_controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  _checkInput();
                },
                decoration: InputDecoration(
                  counterText: "",
                  hintText: '인증번호 6자리',
                  hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: PeeroreumColor.gray[600]),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                cursorColor: PeeroreumColor.gray[600],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!is_resending) {
                        resendEmail();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: is_resending
                                ? PeeroreumColor.gray[400]!
                                : PeeroreumColor.primaryPuple[500]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        '재전송',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: is_resending
                                ? PeeroreumColor.gray[400]
                                : PeeroreumColor.primaryPuple[500]),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${timerText} 남음',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: PeeroreumColor.gray[600]),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              )
            ],
          ),
        ),
        bottomSheet: Container(
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
                      verifyCode();
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
    );
  }

  verifyCode() async {
    setState(() {
      is_loading = true;
    });
    var result = await http.post(
      Uri.parse(
          '${API.hostConnect}/member/password/verify?email=${widget.email}&code=${code_controller.text}'),
    );
    setState(() {
      is_loading = false;
    });
    if (result.statusCode == 200) {
      var data = jsonDecode(utf8.decode(result.bodyBytes));
      if (data['status'] == 'success') {
        String token = data['data'];
        Get.to(() => NewPassword(widget.email, token),
            transition: Transition.noTransition);
      } else {
        Fluttertoast.showToast(msg: "인증번호가 일치하지 않아요");
      }
    } else {
      Fluttertoast.showToast(msg: "인증번호가 일치하지 않아요");
    }
  }

  resendEmail() async {
    setState(() {
      is_resending = true;
    });
    var result = await http.post(
      Uri.parse(
          '${API.hostConnect}/member/password/email?email=${widget.email}'),
    );
    setState(() {
      is_resending = false;
    });
    if (result.statusCode == 200) {
      var data = jsonDecode(utf8.decode(result.bodyBytes));
      if (data['status'] == 'success') {
        _timer.cancel();
        startTimer();
        Fluttertoast.showToast(msg: "인증코드가 재발송되었습니다.");
      } else {
        Fluttertoast.showToast(msg: "재발송 실패");
      }
    } else {
      Fluttertoast.showToast(msg: "오류가 발생했습니다.");
    }
  }
}
