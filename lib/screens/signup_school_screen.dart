import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/email_signin_screen.dart';
import 'package:peeroreum_client/screens/signin_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;

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
                )),
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
                      DropdownButton(
                        value: _siDo,
                        hint: Text(
                          '시･도',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600]),
                        ),
                        elevation: 0,
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]),
                        items: _siDos
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _siDo = value!;
                          });
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      DropdownButton(
                        value: _siGuGun,
                        hint: Text(
                          '시·구·군',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600]),
                        ),
                        elevation: 0,
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]),
                        items: _siDos
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _siGuGun = value!;
                          });
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
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
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        '건너뛰기',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                            color: Colors.grey[500]),
                      )),
                ],
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
              if(_siDo != null && _siGuGun != null && _schoolName != null) {
                member.school = _schoolName;
                var result = await http.post(
                    Uri.parse('http://172.30.1.74:8080/signup'),
                    body: jsonEncode(member),
                    headers: {'Content-Type': 'application/json'}
                );
                if(result.statusCode == 200) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => SignIn(),
                        transitionDuration: const Duration(seconds: 0),
                        reverseTransitionDuration: const Duration(seconds: 0)),
                      (route) => false
                  );
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
                backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
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
