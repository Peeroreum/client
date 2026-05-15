import 'dart:async';
import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
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
      child: Container(
        color: PeeroreumColor.white,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: PeeroreumColor.white,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: PeeroreumColor.white,
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
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
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
                          SizedBox(height: 4),
                          Text(
                            '메일함을 확인해 주세요.',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: PeeroreumColor.black),
                          ),
                          SizedBox(height: 24),
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
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
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
                          SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(width: 8),
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
                                '$timerText 남음',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: PeeroreumColor.gray[600]),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 버튼을 body 하단에 배치 (bottomSheet 대신)
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
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
                            : MaterialStateProperty.all(
                                PeeroreumColor.gray[300]),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 12)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
    var result = await ApiClient().post(
      '/member/password/verify?email=${Uri.encodeComponent(widget.email)}&code=${Uri.encodeComponent(code_controller.text)}',
    );
    setState(() {
      is_loading = false;
    });
    if (result.statusCode == 200) {
      var data = result.data;
      if (data['status'] == 'success') {
        String token = data['data'];
        Get.to(() => NewPassword(widget.email, token),
            transition: Transition.noTransition);
      } else {
        PeeroreumToast.show(
          context,
          "인증번호가 일치하지 않아요",
          isError: true,
        );
      }
    } else {
      PeeroreumToast.show(
        context,
        "인증번호가 일치하지 않아요",
        isError: true,
      );
    }
  }

  resendEmail() async {
    setState(() {
      is_resending = true;
    });
    var result = await ApiClient().post(
      '/member/password/email?email=${Uri.encodeComponent(widget.email)}',
    );
    setState(() {
      is_resending = false;
    });
    if (result.statusCode == 200) {
      var data = result.data;
      if (data['status'] == 'success') {
        _timer.cancel();
        startTimer();
        PeeroreumToast.show(context, "인증코드가 재발송되었어요.");
      } else {
        PeeroreumToast.show(
          context,
          "재발송 실패",
          isError: true,
        );
      }
    } else {
      PeeroreumToast.show(
        context,
        "오류가 발생했습니다.",
        isError: true,
      );
    }
  }
}
