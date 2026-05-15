import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumButton.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/sign/signin_email_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:peeroreum_client/api/ApiClient.dart';

class SignUpSchool extends StatefulWidget {
  Member member;

  SignUpSchool(this.member, {super.key});

  @override
  State<SignUpSchool> createState() => _SignUpSchoolState(member);
}

class _SignUpSchoolState extends State<SignUpSchool> {
  Member member;

  _SignUpSchoolState(this.member);

  final schoolController = TextEditingController();
  final _siDos = ['서울특별시', '경기도', '강원도', '광주광역시', '울산광역시'];
  String? _siDo;
  String? _siGuGun;
  String? _schoolName;

  bool isEnabled = false;

  void _checkInput() {
    if (_siDo != null && _siGuGun != null && schoolController.text.isNotEmpty) {
      setState(() {
        isEnabled = true;
      });
    } else {
      setState(() {
        isEnabled = false;
      });
    }
  }

  void skipDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          title: const Text("학교 입력을 건너뛰실 건가요?", textAlign: TextAlign.center),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
            color: PeeroreumColor.black,
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          content: const Text(
            "학교를 입력하지 않은 경우, 학교 대항전과 같은 이벤트 참여에 제한이 생길 수 있어요.",
            textAlign: TextAlign.center,
          ),
          contentTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Pretendard',
            color: PeeroreumColor.gray[600],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(PeeroreumColor.gray[300]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.gray[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      signUpAPI();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          PeeroreumColor.primaryPuple[400]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        '건너뛰기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey[800],
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                      width: double.maxFinite,
                      child: LinearPercentIndicator(
                        animateFromLastPercent: true,
                        lineHeight: 8.0,
                        percent: 1,
                        progressColor: const Color.fromARGB(255, 114, 96, 248),
                        backgroundColor: Colors.grey[100],
                        barRadius: const Radius.circular(10),
                      ),
                    ),
                    Container(
                      height: 122,
                      width: double.maxFinite,
                      padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("현재 다니는 학교를 알려주세요.",
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("학교 정보는 추후 학교 대항전 등 이벤트에 활용될 수 있어요.",
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[800])),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '지역',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: PeeroreumButton<String>(
                                  width: double.infinity,
                                  items: _siDos,
                                  value: _siDo,
                                  onChanged: (value) {
                                    setState(() {
                                      _siDo = value;
                                      _checkInput();
                                    });
                                  },
                                  hintText: '시･도',
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: PeeroreumButton<String>(
                                  width: double.infinity,
                                  items: _siDos,
                                  value: _siGuGun,
                                  onChanged: (value) {
                                    setState(() {
                                      _siGuGun = value;
                                      _checkInput();
                                    });
                                  },
                                  hintText: '시･구･군',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: TextFormField(
                              controller: schoolController,
                              onChanged: (value) {
                                _schoolName = value;
                                _checkInput();
                              },
                              decoration: InputDecoration(
                                hintText: '학교명',
                                hintStyle: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600]),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: PeeroreumColor.gray[200]!),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: PeeroreumColor.gray[200]!),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                              ),
                              cursorColor: PeeroreumColor.gray[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextButton(
                    onPressed: () {
                      skipDialog();
                    },
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          color: Colors.grey[500]),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () async {
                  if (_siDo != null &&
                      _siGuGun != null &&
                      _schoolName != null) {
                    member.school = _schoolName;
                    signUpAPI();
                  }
                },
                style: ButtonStyle(
                    backgroundColor: isEnabled
                        ? MaterialStateProperty.all(
                            PeeroreumColor.primaryPuple[400])
                        : MaterialStateProperty.all(PeeroreumColor.gray[300]),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
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

  Future<void> signUpAPI() async {
    var result = await ApiClient().post('/signup', data: member);
    if (result.statusCode == 200) {
      Get.to(() => const EmailSignIn(), transition: Transition.noTransition);
    } else {
      print(result.statusCode);
    }
  }
}
