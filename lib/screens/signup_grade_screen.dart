import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumButton.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/signup_school_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SignUpGrade extends StatefulWidget {
  Member member;
  SignUpGrade(this.member);

  @override
  State<SignUpGrade> createState() => _SignUpGradeState(member);
}

class _SignUpGradeState extends State<SignUpGrade> {
  Member member;
  _SignUpGradeState(this.member);
  final _schools = ['중학교', '고등학교'];
  final _grades = ['1학년', '2학년', '3학년'];
  String? _school;
  String? _grade;

  bool is_Enabled = false;

  void _checkInput() {
    if (_school != null && _grade != null) {
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
                    percent: 0.75,
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
                    Text("친구가 있는 같이방과 답변을 기다리는 질문을 추천해 드릴게요.",
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
                        Expanded(
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
                      ])),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () {
                if (_school != null && _grade != null) {
                  member.grade = _school == "중학교"
                      ? _grades.indexOf(_grade!) + 1
                      : _grades.indexOf(_grade!) + 4;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => SignUpSchool(member),
                        transitionDuration: const Duration(seconds: 0),
                        reverseTransitionDuration: const Duration(seconds: 0)),
                  );
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
    );
  }
}
