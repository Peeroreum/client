import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/sign/signup.dart';
import 'package:peeroreum_client/api/ApiClient.dart';

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});

  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  Member member = Member();
  final idController = TextEditingController();
  final pw1Controller = TextEditingController();
  final pw2Controller = TextEditingController();
  bool isEnabled = false;
  bool pw1Hide = true;
  bool pw2Hide = true;

  bool idCheck = false;
  bool idDuplicate = false;
  bool pw1Check = false;
  bool pw2Check = false;

  void _checkInput() {
    if (idCheck && pw1Check && pw2Check) {
      setState(() {
        isEnabled = true;
      });
    } else {
      setState(() {
        isEnabled = false;
      });
    }
  }

  bool idShowClearButton = false;
  bool pw1ShowClearButton = false;
  bool pw2ShowClearButton = false;

  bool idFocus = false;
  bool pw1Focus = false;
  bool pw2Focus = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          idShowClearButton = false;
          pw1ShowClearButton = false;
          pw2ShowClearButton = false;
          idFocus = false;
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
          title: const Text(
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
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: PeeroreumColor.gray[800],
            ),
          ),
        ),
        body: Container(
          color: PeeroreumColor.white,
          child: SafeArea(
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * 0.3),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '이메일',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                              controller: idController,
                              onTap: () {
                                if (idController.text.isNotEmpty) {
                                  setState(() {
                                    idShowClearButton = true;
                                  });
                                }
                                setState(() {
                                  pw1ShowClearButton = false;
                                  pw2ShowClearButton = false;
                                  idFocus = true;
                                  pw1Focus = false;
                                  pw2Focus = false;
                                });
                              },
                              onChanged: (value) {
                                validateEmail();
                                _checkInput();
                                setState(() {
                                  if (value.isNotEmpty) {
                                    idShowClearButton = true;
                                  } else {
                                    idShowClearButton = false;
                                  }
                                });
                              },
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                idFocus = false;
                              },
                              decoration: InputDecoration(
                                hintText: 'peer@mail.com',
                                hintStyle: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: PeeroreumColor.gray[600]),
                                errorText:
                                    idDuplicate ? "이미 사용 중인 이메일입니다." : null,
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: PeeroreumColor.error)),
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
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: idShowClearButton
                                            ? GestureDetector(
                                                onTap: () {
                                                  idController.clear();
                                                  setState(() {
                                                    idShowClearButton = false;
                                                    idCheck = false;
                                                    idDuplicate = false;
                                                    _checkInput();
                                                  });
                                                },
                                                child: SvgPicture.asset(
                                                  "assets/icons/x_circle.svg",
                                                  color:
                                                      PeeroreumColor.gray[200],
                                                ))
                                            : null),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Container(
                                      padding: idCheck
                                          ? const EdgeInsets.fromLTRB(
                                              0, 0, 16, 0)
                                          : null,
                                      child: idCheck
                                          ? SvgPicture.asset(
                                              "assets/icons/check.svg",
                                              color: PeeroreumColor
                                                  .primaryPuple[400],
                                            )
                                          : const SizedBox(),
                                    ),
                                    Container(
                                        padding: idDuplicate
                                            ? const EdgeInsets.fromLTRB(
                                                0, 0, 16, 0)
                                            : null,
                                        child: idDuplicate
                                            ? SvgPicture.asset(
                                                "assets/icons/warning_circle.svg",
                                                color: PeeroreumColor.error,
                                              )
                                            : const SizedBox())
                                  ],
                                ),
                                helperText: idFocus ? emailHelperText() : null,
                                helperStyle: emailHelperTextStyle(),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                focusedBorder: idCheck
                                    ? OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: PeeroreumColor
                                                .primaryPuple[400]!),
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
                                      color: idFocus
                                          ? (idCheck
                                              ? PeeroreumColor
                                                  .primaryPuple[400]!
                                              : PeeroreumColor.gray[200]!)
                                          : PeeroreumColor.gray[200]!),
                                ),
                              ),
                              cursorColor: PeeroreumColor.gray[600]),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '비밀번호',
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
                                idShowClearButton = false;
                                pw2ShowClearButton = false;
                                idFocus = false;
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
                                      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,12}$')
                                  .hasMatch(pw1Controller.text)) {
                                setState(() {
                                  pw1Check = true;
                                });
                              } else {
                                setState(() {
                                  pw1Check = false;
                                });
                              }
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
                                                color: PeeroreumColor.gray[200],
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
                                      color: PeeroreumColor.primaryPuple[400])
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
                                              .primaryPuple[400]!),
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
                                            ? PeeroreumColor.primaryPuple[400]!
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
                              idShowClearButton = false;
                              pw1ShowClearButton = false;
                              idFocus = false;
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
                                            ? PeeroreumColor.primaryPuple[400]!
                                            : PeeroreumColor.gray[200]!)
                                        : PeeroreumColor.gray[200]!)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: pw2Check
                                        ? PeeroreumColor.primaryPuple[400]!
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
                                color: PeeroreumColor.primaryPuple[400]),
                            errorText:
                                !pw2Check && pw2Controller.text.length >= 2
                                    ? "비밀번호가 일치하지 않습니다."
                                    : null,
                            errorStyle:
                                !pw2Check && pw2Controller.text.length >= 2
                                    ? const TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: PeeroreumColor.error)
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
                                            color: PeeroreumColor.gray[200],
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
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom))
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: Container(
          color: PeeroreumColor.white,
          padding: MediaQuery.of(context).viewInsets.bottom > 0
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom)
              : const EdgeInsets.fromLTRB(20, 8, 20, 28),
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: (idCheck && pw1Check && pw2Check)
                    ? () {
                        member.username = idController.text;
                        member.password = pw1Controller.text;
                        Get.to(() => SignUp(member),
                            transition: Transition.noTransition);
                      }
                    : null,
                style: ButtonStyle(
                    backgroundColor: ((idCheck && pw1Check && pw2Check))
                        ? MaterialStateProperty.all(
                            PeeroreumColor.primaryPuple[400])
                        : MaterialStateProperty.all(PeeroreumColor.gray[300]),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                          ? BorderRadius.zero
                          : BorderRadius.circular(8.0),
                    ))),
                child: const Text(
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
        ),
      ),
    );
  }

  validateEmail() async {
    idDuplicate = await isDuplicatedEmail();
    setState(() {
      if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
              .hasMatch(idController.text) &&
          !idDuplicate) {
        idCheck = true;
      } else {
        idCheck = false;
      }
    });
  }

  isDuplicatedEmail() async {
    var result = await ApiClient().get('/signup/email/${idController.text}');
    if (result.statusCode == 409) {
      return true;
    } else {
      return false;
    }
  }

  emailHelperText() {
    if (idCheck) {
      return "사용 가능한 이메일입니다.";
    }
    if (idDuplicate) {
      return "이미 사용 중인 이메일입니다.";
    }
    return "";
  }

  emailHelperTextStyle() {
    if (idCheck) {
      return TextStyle(
          fontFamily: "Pretendard",
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: PeeroreumColor.primaryPuple[400]);
    }
    if (idDuplicate) {
      return const TextStyle(
          fontFamily: "Pretendard",
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: PeeroreumColor.error);
    }
    return const TextStyle();
  }

  pw1Suffix() {
    if (pw1Check) {
      return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/check.svg",
            color: PeeroreumColor.primaryPuple[400],
          ));
    }
    if (pw1Controller.text.length >= 2 && !pw1Check) {
      return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/warning_circle.svg",
            color: PeeroreumColor.error,
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
          color: PeeroreumColor.gray[600],
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
            color: PeeroreumColor.primaryPuple[400],
          ));
    }
    if (pw2Controller.text.length >= 2 && !pw2Check) {
      return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SvgPicture.asset(
            "assets/icons/warning_circle.svg",
            color: PeeroreumColor.error,
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
          color: PeeroreumColor.gray[600],
        ),
      ),
    );
  }
}
