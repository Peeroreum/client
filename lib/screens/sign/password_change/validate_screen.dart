import 'dart:async';
import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/api/api_client.dart';
import './new_password_screen.dart';

class EmailValidate extends StatefulWidget {
  final String email;

  const EmailValidate(this.email, {super.key});

  @override
  State<EmailValidate> createState() => _EmailValidateState();
}

class _EmailValidateState extends State<EmailValidate> {
  final codeController = TextEditingController();
  bool isEnabled = false;
  bool isLoading = false;
  bool isResending = false;
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    if (codeController.text.length == 6) {
      setState(() {
        isEnabled = true;
      });
    } else {
      setState(() {
        isEnabled = false;
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
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '인증번호 전송 완료',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: PeeroreumColor.black),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '메일함을 확인해 주세요.',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: PeeroreumColor.black),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: codeController,
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
                                borderSide: const BorderSide(
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (!isResending) {
                                    resendEmail();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isResending
                                            ? PeeroreumColor.gray[400]!
                                            : PeeroreumColor
                                                .primaryPurple[500]!,
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
                                        color: isResending
                                            ? PeeroreumColor.gray[400]
                                            : PeeroreumColor
                                                .primaryPurple[500]),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$timerText 남음',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: PeeroreumColor.gray[600]),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: (isEnabled && !isLoading)
                          ? () {
                              verifyCode();
                            }
                          : null,
                      style: ButtonStyle(
                        backgroundColor: (isEnabled && !isLoading)
                            ? WidgetStateProperty.all(
                                PeeroreumColor.primaryPurple[400])
                            : WidgetStateProperty.all(PeeroreumColor.gray[300]),
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 12)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: PeeroreumColor.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '다음',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: PeeroreumColor.white),
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
      isLoading = true;
    });
    var result = await ApiClient().post(
      '/member/password/verify?email=${Uri.encodeComponent(widget.email)}&code=${Uri.encodeComponent(codeController.text)}',
    );
    if (!mounted) return;
    setState(() {
      isLoading = false;
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
      isResending = true;
    });
    var result = await ApiClient().post(
      '/member/password/email?email=${Uri.encodeComponent(widget.email)}',
    );
    if (!mounted) return;
    setState(() {
      isResending = false;
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
