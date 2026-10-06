import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/model/member.dart';
import 'package:peeroreum_client/screens/sign/signup_grade_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../designs/peeroreum_color.dart';
import 'package:peeroreum_client/api/api_client.dart';

class SignUpNickname extends StatefulWidget {
  final Member member;

  const SignUpNickname(this.member, {super.key});

  @override
  State<SignUpNickname> createState() => _SignUpNicknameState();
}

class _SignUpNicknameState extends State<SignUpNickname> {
  late Member member;

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  final nicknameController = TextEditingController();
  bool isDuplicateNickname = false;
  bool checkNickname = false;
  bool showNicknameClearButton = false;

  bool nicknameFocus = false;

  checkDuplicateNickname(String value) async {
    var result = await ApiClient().get('/signup/nickname/$value');
    if (result.statusCode == 409) {
      setState(() {
        isDuplicateNickname = true;
      });
    } else {
      setState(() {
        isDuplicateNickname = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          nicknameFocus = false;
          showNicknameClearButton = false;
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
            icon: SvgPicture.asset('assets/icons/arrow-left.svg',
                colorFilter: ColorFilter.mode(
                    PeeroreumColor.gray[800]!, BlendMode.srcIn)),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * 1.3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 40,
                          width: double.maxFinite,
                          child: LinearPercentIndicator(
                            animateFromLastPercent: true,
                            lineHeight: 8.0,
                            percent: 0.33,
                            progressColor:
                                const Color.fromARGB(255, 114, 96, 248),
                            backgroundColor: Colors.grey[100],
                            barRadius: const Radius.circular(10),
                          ),
                        ),
                        Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("피어오름에서 사용할 닉네임을\n알려주세요.",
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                              const SizedBox(
                                height: 10,
                              ),
                              Text("닉네임을 설정하면 30일 이후 변경할 수 있어요.",
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[800])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                          controller: nicknameController,
                          scrollPadding: const EdgeInsets.only(bottom: 400),
                          onTap: () {
                            setState(() {
                              nicknameFocus = true;
                            });
                            if (nicknameController.text.isNotEmpty) {
                              setState(() {
                                showNicknameClearButton = true;
                              });
                            }
                          },
                          onChanged: (value) {
                            if (nicknameController.text.isNotEmpty) {
                              setState(() {
                                showNicknameClearButton = true;
                                if (nicknameController.text.length >= 2 &&
                                    nicknameController.text.length <= 12) {
                                  checkNickname = true;
                                } else {
                                  checkNickname = false;
                                }
                              });
                            } else {
                              setState(() {
                                showNicknameClearButton = false;
                                checkNickname = false;
                                isDuplicateNickname = false;
                              });
                            }
                            checkDuplicateNickname(value);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9_ㄱ-ㅎㅏ-ㅣ가-힣ᆞᆢㆍᄀ-ᄒ]'))
                          ],
                          decoration: InputDecoration(
                              hintText: '닉네임을 입력하세요',
                              hintStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: PeeroreumColor.gray[600]),
                              helperText: checkNickname && !isDuplicateNickname
                                  ? (nicknameFocus ? "사용 가능한 닉네임입니다." : null)
                                  : "언더바(_)를 제외한 특수문자는 사용할 수 없어요.",
                              helperStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: checkNickname && !isDuplicateNickname
                                      ? PeeroreumColor.primaryPurple[400]
                                      : PeeroreumColor.gray[600]),
                              errorText: checkError(),
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
                              counterText:
                                  '${nicknameController.text.length} / 12',
                              counterStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: PeeroreumColor.gray[600]!),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              focusedBorder: checkNickname &&
                                      !isDuplicateNickname
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
                              enabledBorder: checkNickname &&
                                      !isDuplicateNickname
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: (nicknameFocus
                                              ? PeeroreumColor
                                                  .primaryPurple[400]!
                                              : PeeroreumColor.gray[200]!)),
                                    )
                                  : OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: PeeroreumColor.gray[200]!,
                                      )),
                              suffixIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: showNicknameClearButton
                                          ? IconButton(
                                              onPressed: () {
                                                nicknameController.clear();
                                                setState(() {
                                                  checkNickname = false;
                                                  isDuplicateNickname = false;
                                                  showNicknameClearButton =
                                                      false;
                                                });
                                              },
                                              icon: SvgPicture.asset(
                                                "assets/icons/x_circle.svg",
                                                colorFilter: ColorFilter.mode(
                                                    PeeroreumColor.gray[200]!,
                                                    BlendMode.srcIn),
                                              ))
                                          : null),
                                  Container(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: checkNickname &&
                                              !isDuplicateNickname
                                          ? SvgPicture.asset(
                                              "assets/icons/check.svg",
                                              colorFilter: ColorFilter.mode(
                                                  PeeroreumColor
                                                      .primaryPurple[400]!,
                                                  BlendMode.srcIn),
                                            )
                                          : nicknameController.text.isNotEmpty
                                              ? SvgPicture.asset(
                                                  "assets/icons/warning_circle.svg",
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                          PeeroreumColor.error,
                                                          BlendMode.srcIn),
                                                )
                                              : null),
                                ],
                              )),
                          cursorColor: PeeroreumColor.gray[600]),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: Container(
          color: PeeroreumColor.white,
          width: MediaQuery.of(context).size.width,
          padding: MediaQuery.of(context).viewInsets.bottom > 0
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom)
              : const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: SafeArea(
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: checkNickname && !isDuplicateNickname
                    ? () {
                        member.nickname = nicknameController.text;
                        Get.to(() => SignUpGrade(member),
                            transition: Transition.noTransition);
                      }
                    : null,
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        checkNickname && !isDuplicateNickname
                            ? PeeroreumColor.primaryPurple[400]
                            : PeeroreumColor.gray[300]),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  checkError() {
    if (!checkNickname && nicknameController.text.isNotEmpty) {
      return "한글 2자, 영문/숫자 4자 이상 적어주세요.";
    }
    if (isDuplicateNickname) {
      return "이미 사용 중인 닉네임입니다.";
    }
    return null;
  }
}
