import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import './complete_screen.dart';

class NewPassword extends StatefulWidget {
  final String email;
  final String token;

  const NewPassword(this.email, this.token, {super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final pw1Controller = TextEditingController();
  final pw2Controller = TextEditingController();
  bool isEnabled = false;
  bool isLoading = false;
  bool pw1Hide = true;
  bool pw2Hide = true;

  bool pw1Check = false;
  bool pw2Check = false;

  void _checkInput() {
    if (pw1Check) {
      setState(() {
        isEnabled = true;
      });
    } else {
      setState(() {
        isEnabled = false;
      });
    }
  }

  bool pw1ShowClearButton = false;
  bool pw2ShowClearButton = false;

  bool pw1Focus = false;
  bool pw2Focus = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          pw1ShowClearButton = false;
          pw2ShowClearButton = false;
          pw1Focus = false;
          pw2Focus = false;
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
        body: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * 0.3),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: PeeroreumColor.black),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Text(
                      '새로운 비밀번호를 입력해 주세요.',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: PeeroreumColor.black),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '새 비밀번호',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: pw1Controller,
                            onTap: () {
                              if (pw1Controller.text.isNotEmpty) {
                                setState(() {
                                  pw1ShowClearButton = true;
                                });
                              }
                              setState(() {
                                pw2ShowClearButton = false;
                                pw1Focus = true;
                                pw2Focus = false;
                              });
                            },
                            onChanged: (value) {
                              _checkInput();
                              if (value.isNotEmpty) {
                                pw1ShowClearButton = true;
                                if (pw1Controller.text == pw2Controller.text) {
                                  setState(() {
                                    pw2Check = true;
                                  });
                                } else {
                                  setState(() {
                                    pw2Check = false;
                                  });
                                }
                              } else {
                                pw1ShowClearButton = false;
                              }
                              if (RegExp(
                                      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!%*#?~^<>,.&+=@$])[A-Za-z\d!%*#?~^<>,.&+=@$]{8,12}$')
                                  .hasMatch(pw1Controller.text)) {
                                setState(() {
                                  pw1Check = true;
                                });
                              } else {
                                setState(() {
                                  pw1Check = false;
                                });
                              }
                              _checkInput();
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) {
                              pw1Focus = false;
                            },
                            decoration: InputDecoration(
                              hintText: '비밀번호를 입력하세요',
                              hintStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: PeeroreumColor.gray[600]),
                              errorText:
                                  pw1Controller.text.length >= 2 && !pw1Check
                                      ? "영문, 숫자, 특수문자 포함 8자~12자"
                                      : null,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: PeeroreumColor.error,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: PeeroreumColor.error,
                                  )),
                              suffixIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: pw1ShowClearButton
                                          ? GestureDetector(
                                              onTap: () {
                                                pw1Controller.clear();
                                                setState(() {
                                                  pw1ShowClearButton = false;
                                                  pw1Check = false;
                                                });
                                                _checkInput();
                                              },
                                              child: SvgPicture.asset(
                                                "assets/icons/x_circle.svg",
                                                colorFilter: ColorFilter.mode(
                                                    PeeroreumColor.gray[200]!,
                                                    BlendMode.srcIn),
                                              ))
                                          : null),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  pw1Suffix()
                                ],
                              ),
                              helperText: pw1Check
                                  ? (pw1Focus ? "사용 가능한 비밀번호입니다." : null)
                                  : "영문, 숫자, 특수문자 포함 8자~12자",
                              helperStyle: pw1Check
                                  ? TextStyle(
                                      fontFamily: "Pretendard",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: PeeroreumColor.primaryPurple[400])
                                  : TextStyle(
                                      fontFamily: "Pretendard",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: PeeroreumColor.gray[600]),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              focusedBorder: pw1Check
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: PeeroreumColor
                                              .primaryPurple[400]!),
                                    )
                                  : OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: PeeroreumColor.black,
                                      ),
                                    ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: pw1Focus
                                        ? (pw1Check
                                            ? PeeroreumColor.primaryPurple[400]!
                                            : PeeroreumColor.gray[200]!)
                                        : PeeroreumColor.gray[200]!),
                              ),
                            ),
                            showCursor: false,
                            obscureText: pw1Hide,
                            obscuringCharacter: '●',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '비밀번호 확인',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        TextFormField(
                          controller: pw2Controller,
                          scrollPadding: const EdgeInsets.only(bottom: 140),
                          onTap: () {
                            if (pw2Controller.text.isNotEmpty) {
                              setState(() {
                                pw2ShowClearButton = true;
                              });
                            }
                            setState(() {
                              pw1ShowClearButton = false;
                              pw1Focus = false;
                              pw2Focus = true;
                            });
                          },
                          onChanged: (value) {
                            _checkInput();
                            if (value.isNotEmpty) {
                              pw2ShowClearButton = true;
                            } else {
                              pw2ShowClearButton = false;
                            }
                            if (pw1Controller.text == pw2Controller.text) {
                              setState(() {
                                pw2Check = true;
                              });
                            } else {
                              setState(() {
                                pw2Check = false;
                              });
                            }
                            _checkInput();
                          },
                          onFieldSubmitted: (value) {
                            pw2Focus = false;
                          },
                          obscureText: pw2Hide,
                          obscuringCharacter: '●',
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: pw2Focus
                                        ? (pw2Check
                                            ? PeeroreumColor.primaryPurple[400]!
                                            : PeeroreumColor.gray[200]!)
                                        : PeeroreumColor.gray[200]!)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: pw2Check
                                        ? PeeroreumColor.primaryPurple[400]!
                                        : PeeroreumColor.black)),
                            hintText: '비밀번호를 재입력하세요',
                            hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: PeeroreumColor.gray[600]),
                            helperText: pw2Focus
                                ? (pw2Check ? "비밀번호가 일치합니다." : "")
                                : null,
                            helperStyle: TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: PeeroreumColor.primaryPurple[400]),
                            errorText:
                                !pw2Check && pw2Controller.text.length >= 2
                                    ? "비밀번호가 일치하지 않습니다."
                                    : null,
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: PeeroreumColor.error)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: PeeroreumColor.error)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  pw2ShowClearButton
                                      ? GestureDetector(
                                          onTap: () {
                                            pw2Controller.clear();
                                            setState(() {
                                              pw2ShowClearButton = false;
                                              pw2Check = false;
                                            });
                                            _checkInput();
                                          },
                                          child: SvgPicture.asset(
                                            "assets/icons/x_circle.svg",
                                            colorFilter: ColorFilter.mode(
                                                PeeroreumColor.gray[200]!,
                                                BlendMode.srcIn),
                                          ),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  pw2Suffix()
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
          ),
        ),
        bottomSheet: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            padding: MediaQuery.of(context).viewInsets.bottom > 0
                ? EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom)
                : const EdgeInsets.fromLTRB(20, 8, 20, 28),
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: (isEnabled && !isLoading)
                    ? () {
                        if (pw2Check) {
                          resetPassword();
                        } else {
                          PeeroreumToast.show(context, "비밀번호가 일치하지 않아요",
                              isError: true);
                        }
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
                      borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                          ? BorderRadius.zero
                          : BorderRadius.circular(8.0),
                    ))),
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
                        '변경하기',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: PeeroreumColor.white),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  resetPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      final result = await ApiClient().put(
        '/member/password/reset?newPassword=${Uri.encodeComponent(pw1Controller.text)}',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );
      setState(() {
        isLoading = false;
      });
      if (result.statusCode == 200) {
        final data = result.data;
        if (data['status'] == 'success') {
          Get.to(() => const CompletePassword(), transition: Transition.noTransition);
        } else {
          if (!mounted) return;
          PeeroreumToast.show(context, "비밀번호 변경에 실패했어요.", isError: true);
        }
      } else {
        if (!mounted) return;
        PeeroreumToast.show(context, "비밀번호 변경에 실패했어요.", isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      PeeroreumToast.show(context, "비밀번호 변경에 실패했어요.", isError: true);
    }
  }

  pw1Suffix() {
    if (pw1Check) {
      return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/check.svg",
            colorFilter: ColorFilter.mode(
                PeeroreumColor.primaryPurple[400]!, BlendMode.srcIn),
          ));
    }
    if (pw1Controller.text.length >= 2 && !pw1Check) {
      return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/warning_circle.svg",
            colorFilter:
                const ColorFilter.mode(PeeroreumColor.error, BlendMode.srcIn),
          ));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          pw1Hide = !pw1Hide;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(right: 16),
        child: SvgPicture.asset(
          pw1Hide ? "assets/icons/eye_off.svg" : "assets/icons/eye_on.svg",
          colorFilter:
              ColorFilter.mode(PeeroreumColor.gray[600]!, BlendMode.srcIn),
        ),
      ),
    );
  }

  pw2Suffix() {
    if (pw2Check) {
      return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/check.svg",
            colorFilter: ColorFilter.mode(
                PeeroreumColor.primaryPurple[400]!, BlendMode.srcIn),
          ));
    }
    if (pw2Controller.text.length >= 2 && !pw2Check) {
      return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/warning_circle.svg",
            colorFilter:
                const ColorFilter.mode(PeeroreumColor.error, BlendMode.srcIn),
          ));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          pw2Hide = !pw2Hide;
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
        child: SvgPicture.asset(
          pw2Hide ? "assets/icons/eye_off.svg" : "assets/icons/eye_on.svg",
          colorFilter:
              ColorFilter.mode(PeeroreumColor.gray[600]!, BlendMode.srcIn),
        ),
      ),
    );
  }
}
