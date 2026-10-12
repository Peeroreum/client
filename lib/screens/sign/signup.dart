import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/model/member.dart';
import 'package:peeroreum_client/screens/sign/signup_nickname_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  final Member member;

  const SignUp(this.member, {super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late Member member;

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PeeroreumColor.white,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: PeeroreumColor.white,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset("assets/images/signup_ready.png"),
              const SizedBox(
                height: 80,
              ),
              const Text(
                '안녕하세요, 오르미예요!',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                '서비스 사용을 위한 설정이 필요해요.',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[700]),
              )
            ]),
          ),
          bottomSheet: bottomsheetWidget(),
        ),
      ),
    );
  }

  Widget bottomsheetWidget() {
    return Container(
      color: PeeroreumColor.white,
      padding: MediaQuery.of(context).viewInsets.bottom > 0
          ? EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)
          : const EdgeInsets.fromLTRB(20, 8, 20, 28),
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        height: 48,
        child: TextButton(
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return ServiceTerms(member);
              },
            );
          },
          style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(PeeroreumColor.primaryPurple[400]),
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
                color: PeeroreumColor.white),
          ),
        ),
      ),
    );
  }
}

class ServiceTerms extends StatefulWidget {
  final Member member;

  const ServiceTerms(this.member, {super.key});

  @override
  State<ServiceTerms> createState() => _ServiceTermsState();
}

class _ServiceTermsState extends State<ServiceTerms> {
  late Member member;

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  bool button = false; //다음 button

  List<bool> isCheckedList = [false, false, false, false, false];

  // 약관 전체 동의 // 만 14세 이상입니다. // 이용약관 동의 // 개인정보 동의 // 이벤트마케팅동의 (선택)

  void check() {
    if (isCheckedList[1] == isCheckedList[2] &&
        isCheckedList[2] == isCheckedList[3] &&
        isCheckedList[3] == isCheckedList[4]) {
      isCheckedList[0] = isCheckedList[1];
    } else {
      isCheckedList[0] = false;
    }
    if (isCheckedList[1] == true &&
        isCheckedList[2] == true &&
        isCheckedList[3] == true) {
      button = true;
    } else {
      button = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return serviceTerms();
  }

  Widget serviceTerms() {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                child: const Text(
                  '피어오름 서비스 약관에 동의해 주세요.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                ),
              ),
              Container(
                //약관 전체 동의
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // 전체 동의 로직
                        setState(() {
                          isCheckedList[0] = !isCheckedList[0];
                          if (isCheckedList[0]) {
                            isCheckedList = [true, true, true, true, true];
                          } else if (isCheckedList[0] == false) {
                            isCheckedList = [false, false, false, false, false];
                          }
                          check();
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: PeeroreumColor.gray[200]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                            color: isCheckedList[0]
                                ? PeeroreumColor.primaryPurple[400]!
                                : PeeroreumColor.white),
                        child: isCheckedList[0]
                            ? const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '약관 전체 동의',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isCheckedList[0]
                            ? PeeroreumColor.black
                            : PeeroreumColor.gray[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: PeeroreumColor.gray[200],
                height: 1,
              ),
              Container(
                //만 14세 이상입니다.
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isCheckedList[1] = !isCheckedList[1];
                              check();
                            });
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: PeeroreumColor.gray[200]!,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                                color: isCheckedList[1]
                                    ? PeeroreumColor.primaryPurple[400]!
                                    : PeeroreumColor.white),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          '(필수) 만 14세 이상입니다.',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://teachlog.notion.site/2e9ac6484ea08073b23bca6e894989ca?pvs=143"));
                      },
                      child: SvgPicture.asset(
                        "assets/icons/right.svg",
                        colorFilter: ColorFilter.mode(
                            PeeroreumColor.gray[600]!, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                //이용약관 동의
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isCheckedList[2] = !isCheckedList[2];
                              check();
                            });
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: PeeroreumColor.gray[200]!,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                                color: isCheckedList[2]
                                    ? PeeroreumColor.primaryPurple[400]!
                                    : PeeroreumColor.white),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          '(필수) 이용약관 동의',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://teachlog.notion.site/1b5a5f1566fe4b51ba76820fbed005ff?pvs=143"));
                      },
                      child: SvgPicture.asset(
                        "assets/icons/right.svg",
                        colorFilter: ColorFilter.mode(
                            PeeroreumColor.gray[600]!, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                //개인정보 수집 및 이용 동의
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isCheckedList[3] = !isCheckedList[3];
                              check();
                            });
                          },
                          child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: PeeroreumColor.gray[200]!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: isCheckedList[3]
                                      ? PeeroreumColor.primaryPurple[400]!
                                      : PeeroreumColor.white),
                              child: const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          '(필수) 개인정보 수집 및 이용 동의',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://teachlog.notion.site/68e35d866d544911ac35ee254e227b6c?pvs=143"));
                      },
                      child: SvgPicture.asset(
                        "assets/icons/right.svg",
                        colorFilter: ColorFilter.mode(
                            PeeroreumColor.gray[600]!, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                //(선택) 이벤트, 마케팅 및 혜택 알림 동의
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // 전체 동의 로직
                            setState(() {
                              isCheckedList[4] = !isCheckedList[4];
                              check();
                            });
                          },
                          child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: PeeroreumColor.gray[200]!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: isCheckedList[4]
                                      ? PeeroreumColor.primaryPurple[400]!
                                      : PeeroreumColor.white),
                              child: const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          '(선택) 이벤트, 마케팅 및 혜택 알림 동의',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Container(
                color: PeeroreumColor.white,
                margin: const EdgeInsets.fromLTRB(0, 28, 0, 8),
                width: MediaQuery.of(context).size.width,
                child: SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: button
                        ? () {
                            Get.to(() => SignUpNickname(member),
                                transition: Transition.noTransition);
                          }
                        : null,
                    style: ButtonStyle(
                        backgroundColor: button
                            ? WidgetStateProperty.all(
                                PeeroreumColor.primaryPurple[400])
                            : WidgetStateProperty.all(PeeroreumColor.gray[300]),
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 12)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius:
                              MediaQuery.of(context).viewInsets.bottom > 0
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
            ],
          ),
        ),
      ),
    );
  }
}
