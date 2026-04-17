import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumButton.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/sign/signup_subject_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;
import '../../api/PeeroreumApi.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SignUpGrade extends StatefulWidget {
  Member member;
  SignUpGrade(this.member);

  @override
  State<SignUpGrade> createState() => _SignUpGradeState(member);
}

class _SignUpGradeState extends State<SignUpGrade> {
  Member member;
  _SignUpGradeState(this.member);
  final _schools = ['중학교', '고등학교', '대학교'];
  final _grades = ['1학년', '2학년', '3학년'];
  String? _school;
  String? _grade;

  bool is_Enabled = false;

  void _checkInput() {
    if ((_school != null && _grade != null) || _school == '대학교') {
      setState(() {
        is_Enabled = true;
      });
    }
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
            icon: SvgPicture.asset('assets/icons/arrow-left.svg',
                color: PeeroreumColor.gray[800]),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
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
                      percent: _school == '대학교' ? 1.0 : 0.66,
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
                      Text("학년을 알려주세요.",
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          "학년은 매년 3월 1일에 자동으로 올라가요.\n예비 학년이 아닌, 현재(2월까지) 학년을 선택해주세요!",
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[800])),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: PeeroreumButton<String>(
                            width: double.infinity,
                            items: _schools,
                            value: _school,
                            onChanged: (value) {
                              setState(() {
                                _school = value;
                                _checkInput();
                              });
                            },
                            hintText: '학교',
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Visibility(
                          visible: _school != '대학교',
                          child: Expanded(
                            child: PeeroreumButton<String>(
                              width: double.infinity,
                              items: _grades,
                              value: _grade,
                              onChanged: (value) {
                                setState(() {
                                  _grade = value;
                                  _checkInput();
                                });
                              },
                              hintText: '학년',
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () {
                  if (_school == "대학교") {
                    member.grade = 7;
                    signUpAPI();
                  } else if (_school != null && _grade != null) {
                    member.grade = (_school == "중학교")
                        ? _grades.indexOf(_grade!) + 1
                        : _grades.indexOf(_grade!) + 4;
                    Get.to(() => SignUpSubject(member),
                        transition: Transition.noTransition);
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
        ),
      ),
    );
  }

  Future<void> signUpAPI() async {
    var result = await http.post(Uri.parse('${API.hostConnect}/signup'),
        body: jsonEncode(member),
        headers: {'Content-Type': 'application/json'});
    if (result.statusCode == 200) {
      var data = jsonDecode(utf8.decode(result.bodyBytes))['data'];
      FlutterSecureStorage secureStorage = FlutterSecureStorage();
      secureStorage.write(key: "accessToken", value: data['accessToken']);
      secureStorage.write(key: "email", value: data['email']);
      secureStorage.write(key: "nickname", value: data['nickname']);
      secureStorage.write(key: "profileImage", value: data['profileImage']);
      secureStorage.write(key: "grade", value: data['grade'].toString());
      Get.offAllNamed('signUp/Complete');
    } else {
      print(result.statusCode);
    }
  }
}
