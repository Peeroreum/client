import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumButton.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/email_signin_screen.dart';
import 'package:peeroreum_client/screens/signin_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;

import '../api/PeeroreumApi.dart';

class SignUpSchool extends StatefulWidget {
  Member member;
  SignUpSchool(this.member);

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

  bool is_Enabled = false;

  void _checkInput() {
    if (_siDo != null && _siGuGun != null && _schoolName != null) {
      setState(() {
        is_Enabled = true;
      });
    } else {
      setState(() {
        is_Enabled = false;
      });
    }
  }

  void SkipDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "학교 입력을 건너뛰실 건가요?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                  color: PeeroreumColor.black,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "학교를 입력하지 않은 경우, 학교 대항전과 같은\n이벤트 참여에 제한이 생길 수 있어요.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                  color: PeeroreumColor.gray[600],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(PeeroreumColor.gray[300]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (_, __, ___) => SignIn(),
                              transitionDuration: const Duration(seconds: 0),
                              reverseTransitionDuration:
                                  const Duration(seconds: 0)),
                          (route) => false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
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
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          PeeroreumColor.primaryPuple[400]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
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
    return Scaffold(
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: double.maxFinite,
                  child: LinearPercentIndicator(
                    animateFromLastPercent: true,
                    lineHeight: 8.0,
                    percent: 1,
                    progressColor: Color.fromARGB(255, 114, 96, 248),
                    backgroundColor: Colors.grey[100],
                    barRadius: Radius.circular(10),
                  ),
                ),
                Container(
                  height: 122,
                  width: double.maxFinite,
                  padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("현재 다니는 학교를 알려주세요.",
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      SizedBox(
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
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '지역',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      SizedBox(
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
                          SizedBox(
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
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
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
                                  color: Color.fromARGB(255, 234, 235, 236)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextButton(
                onPressed: () {
                  SkipDialog();
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: SizedBox(
          height: 48,
          child: TextButton(
            onPressed: () async {
              if (_siDo != null && _siGuGun != null && _schoolName != null) {
                member.school = _schoolName;
                var result = await http.post(
                    Uri.parse('${API.hostConnect}/signup'),
                    body: jsonEncode(member),
                    headers: {'Content-Type': 'application/json'});
                if (result.statusCode == 200) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => SignIn(),
                          transitionDuration: const Duration(seconds: 0),
                          reverseTransitionDuration:
                              const Duration(seconds: 0)),
                      (route) => false);
                } else {
                  print(result.statusCode);
                }
              }
            },
            child: Text(
              '다음',
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  color: Colors.white),
            ),
            style: ButtonStyle(
                backgroundColor: is_Enabled
                    ? MaterialStateProperty.all(
                        PeeroreumColor.primaryPuple[400])
                    : MaterialStateProperty.all(PeeroreumColor.gray[300]),
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 12)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ))),
          ),
        ),
      ),
    );
  }
}
