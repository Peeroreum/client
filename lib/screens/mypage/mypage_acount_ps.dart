import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';

class MyPageAccountPS extends StatefulWidget {
  const MyPageAccountPS({super.key});

  @override
  State<MyPageAccountPS> createState() => _MyPageAccountPSState();
}

class _MyPageAccountPSState extends State<MyPageAccountPS> {
  Member member = Member();
  final pw1Controller = TextEditingController();
  final pw2Controller = TextEditingController();
  bool isEnabled = false;
  bool pw1Hide = true;
  bool pw2Hide = true;

  bool pw1Check = false;
  bool pw2Check = false;

  bool pw1ShowClearbutton = false;
  bool pw2ShowClearbutton = false;

  bool pw1Focus = false;
  bool pw2Focus = false;

  void _checkInput() {
    if (pw1Check && pw2Check) {
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
        pw1ShowClearbutton = false;
        pw2ShowClearbutton = false;
        pw1Focus = false;
        pw2Focus = false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: appbarWidget(),
        body: bodyWidget(),
        bottomSheet: bottomSheetWidget(),
      ),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      surfaceTintColor: PeeroreumColor.white,
      shadowColor: PeeroreumColor.white,
      elevation: 0.2,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          color: PeeroreumColor.gray[800],
        ),
      ),
      title: const Text(
        "비밀번호 변경",
        style: TextStyle(
            color: PeeroreumColor.black,
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            pwWidget(),
            const SizedBox(
              height: 16,
            ),
            pwCheckWidget(),
          ],
        ),
      ),
    );
  }

  Widget pwWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "새 비밀번호",
          style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 4,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TextFormField(
            controller: pw1Controller,
            onTap: () {
              setState(() {
                pw1Focus = true;
                pw2ShowClearbutton = false;
                pw2Focus = false;
              });
              if (pw1Controller.text.isNotEmpty) {
                setState(() {
                  pw1ShowClearbutton = true;
                });
              }
            },
            onChanged: (value) {
              _checkInput();
              setState(() {
                if (value.isNotEmpty) {
                  pw1ShowClearbutton = true;
                  if (pw1Controller.text == pw2Controller.text) {
                    pw2Check = true;
                  } else {
                    pw2Check = false;
                  }
                } else {
                  pw1ShowClearbutton = false;
                }
                if (RegExp(
                        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,12}$')
                    .hasMatch(pw1Controller.text)) {
                  pw1Check = true;
                } else {
                  pw1Check = false;
                }
              });
            },
            decoration: InputDecoration(
              hintText: '비밀번호를 입력하세요',
              hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: PeeroreumColor.gray[600]),
              errorText: pw1Controller.text.length >= 2 && !pw1Check
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
                      child: pw1ShowClearbutton
                          ? GestureDetector(
                              onTap: () {
                                pw1Controller.clear();
                                setState(() {
                                  pw1ShowClearbutton = false;
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
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              focusedBorder: pw1Check
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: PeeroreumColor.primaryPuple[400]!),
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
                    color: (pw1Focus
                        ? (pw1Check
                            ? PeeroreumColor.primaryPuple[400]!
                            : PeeroreumColor.gray[200]!)
                        : PeeroreumColor.gray[200]!)),
              ),
            ),
            showCursor: false,
            obscureText: pw1Hide,
            obscuringCharacter: '●',
          ),
        ),
      ],
    );
  }

  Widget pwCheckWidget() {
    return Column(
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
        TextField(
          controller: pw2Controller,
          onTap: () {
            setState(() {
              pw2Focus = true;
              pw1Focus = false;
              pw1ShowClearbutton = false;
            });
            if (pw2Controller.text.isNotEmpty) {
              setState(() {
                pw2ShowClearbutton = true;
              });
            }
          },
          onChanged: (value) {
            _checkInput();
            setState(() {
              if (value.isNotEmpty) {
                pw2ShowClearbutton = true;
              } else {
                pw2ShowClearbutton = false;
              }
              if (pw1Controller.text == pw2Controller.text) {
                pw2Check = true;
              } else {
                pw2Check = false;
              }
            });
          },
          obscureText: pw2Hide,
          obscuringCharacter: '●',
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: pw2Check
                        ? (pw2Focus
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
            helperText: pw2Focus ? (pw2Check ? "비밀번호가 일치합니다." : null) : null,
            helperStyle: TextStyle(
                fontFamily: "Pretendard",
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: PeeroreumColor.primaryPuple[400]),
            errorText: !pw2Check && pw2Controller.text.length >= 2
                ? "비밀번호가 일치하지 않습니다."
                : null,
            errorStyle: !pw2Check && pw2Controller.text.length >= 2
                ? const TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: PeeroreumColor.error)
                : null,
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: PeeroreumColor.error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: PeeroreumColor.error)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                pw2ShowClearbutton
                    ? GestureDetector(
                        onTap: () {
                          pw2Controller.clear();
                          setState(() {
                            pw2ShowClearbutton = false;
                            pw2Check = false;
                            _checkInput();
                          });
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
      ],
    );
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

  Widget bottomSheetWidget() {
    return Container(
      color: PeeroreumColor.white,
      child: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).viewInsets.bottom > 0
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom)
              : const EdgeInsets.fromLTRB(20, 8, 20, 28),
          width: MediaQuery.of(context).size.width,
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: (pw1Check && pw2Check)
                  ? () async {
                      member.password = pw1Controller.text;
                      psChangeAPI();
                    }
                  : null,
              style: ButtonStyle(
                  backgroundColor: (pw1Check && pw2Check)
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
    );
  }

  Future<void> psChangeAPI() async {
    var result = await ApiClient().put(
        '/member/change/pw?password=${pw2Controller.text}',
        data: member);
    if (result.statusCode == 200) {
      PeeroreumToast.show(context, "비밀번호가 변경되었어요.");
      Get.back();
    } else {
      print(result.statusCode);
      PeeroreumToast.show(context, "비밀번호 변경에 실패했어요.");
    }
  }
}
