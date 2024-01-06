import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/designs/PeeroreumButton.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/data/Subject.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;

import '../../api/PeeroreumApi.dart';

class SignUpSubject extends StatefulWidget {
  Member member;
  SignUpSubject(this.member);

  @override
  State<SignUpSubject> createState() => _SignUpSubjectState(member);
}

class _SignUpSubjectState extends State<SignUpSubject> {
  Member member;
  _SignUpSubjectState(this.member);

  final subjects = Subject.subject;
  final middleSubjects = Subject.middleSubject;
  final highSubjects = Subject.highSubject;

  final _levels = ['상', '중', '하'];
  List<String> goodDetailSubjects = [];
  List<String> badDetailSubjects = [];
  String? _goodSubject;
  String? _selectedDetailGoodSubject;
  String? _badSubject;
  String? _selectedDetailBadSubject;
  String? _goodLevel;
  String? _badLevel;

  bool isEnabled = false;

  void _checkInput() {
    if (_goodSubject != null &&
        _badSubject != null &&
        _selectedDetailGoodSubject != null &&
        _selectedDetailBadSubject != null &&
        _goodLevel != null &&
        _badLevel != null) {
      setState(() {
        isEnabled = true;
      });
    }
    else{
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
                    percent: 1,
                    progressColor: Color.fromARGB(255, 114, 96, 248),
                    backgroundColor: Colors.grey[100],
                    barRadius: Radius.circular(10),
                  )),
              Container(
                // height: 122,
                width: double.maxFinite,
                padding: EdgeInsets.fromLTRB(10, 16, 10, 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("자신 있는 과목과 보완하고 싶은\n과목의 성취 수준을 알려주세요.",
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    SizedBox(
                      height: 10,
                    ),
                    Text("유사한 성취 수준의 친구가 있는 같이방을 추천해 드릴게요.",
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[800])),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '자신 있는 과목',
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          PeeroreumButton<String>(
                            items: Subject.subject,
                            value: _goodSubject,
                            onChanged: (value) {
                              setState(() {
                                _goodSubject = value;
                                goodDetailSubjects = ((member.grade! <= 3)
                                    ? middleSubjects[_goodSubject]
                                    : highSubjects[_goodSubject])!;
                                _selectedDetailGoodSubject=null;
                                _checkInput();
                              });
                            },
                            hintText: '과목',
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: PeeroreumButton<String>(
                                width: double.infinity,
                                items: goodDetailSubjects,
                                value: _selectedDetailGoodSubject,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDetailGoodSubject = value;
                                    _checkInput();
                                  });
                                },
                                hintText: '세부 과목'),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      PeeroreumButton<String>(
                        width: double.infinity,
                        items: _levels,
                        value: _goodLevel,
                        onChanged: (value) {
                          setState(() {
                            _goodLevel = value;
                            _checkInput();
                          });
                        },
                        hintText: '성취 수준을 선택해 주세요',
                      ),
                    ],
                  )),
              SizedBox(
                height: 40,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '보완하고 싶은 과목',
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        PeeroreumButton<String>(
                          items: Subject.subject,
                          value: _badSubject,
                          onChanged: (value) {
                            setState(() {
                              _badSubject = value;
                              badDetailSubjects = ((member.grade! <= 3)
                                  ? middleSubjects[_badSubject]
                                  : highSubjects[_badSubject])!;
                              _selectedDetailBadSubject=null;
                              _checkInput();
                            });
                          },
                          hintText: '과목',
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: PeeroreumButton<String>(
                            width: double.infinity,
                            items: badDetailSubjects,
                            value: _selectedDetailBadSubject,
                            onChanged: (value) {
                              setState(() {
                                _selectedDetailBadSubject = value;
                                _checkInput();
                              });
                            },
                            hintText: '세부 과목',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    PeeroreumButton<String>(
                      width: double.infinity,
                      items: _levels,
                      value: _badLevel,
                      onChanged: (value) {
                        setState(() {
                          _badLevel = value;
                          _checkInput();
                        });
                      },
                      hintText: '성취 수준을 선택해 주세요',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () {
                if (isEnabled) {
                  member.goodSubject = subjects.indexOf(_goodSubject!) + 1;
                  member.goodDetailSubject = goodDetailSubjects.indexOf(_selectedDetailGoodSubject!);
                  member.goodLevel = _levels.indexOf(_goodLevel!);
                  member.badSubject = subjects.indexOf(_badSubject!) + 1;
                  member.badDetailSubject = badDetailSubjects.indexOf(_selectedDetailBadSubject!);
                  member.badLevel = _levels.indexOf(_badLevel!);
                  signUpAPI();
                  // Navigator.push(
                  //   context,
                  //   PageRouteBuilder(
                  //       pageBuilder: (_, __, ___) => SignUpSchool(member),
                  //       transitionDuration: const Duration(seconds: 0),
                  //       reverseTransitionDuration: const Duration(seconds: 0)),
                  // );
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
                  backgroundColor: isEnabled
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

  Future<void> signUpAPI() async {
    var result = await http.post(
        Uri.parse('${API.hostConnect}/signup'),
        body: jsonEncode(member),
        headers: {'Content-Type': 'application/json'});
    if (result.statusCode == 200) {
      var data = jsonDecode(utf8.decode(result.bodyBytes))['data'];
      FlutterSecureStorage secureStorage = FlutterSecureStorage();
      secureStorage.write(key: "accessToken", value: data['accessToken']);
      secureStorage.write(key: "email", value: data['email']);
      secureStorage.write(key: "nickname", value: data['nickname']);
      Navigator.pushNamedAndRemoveUntil(context, 'signUp/Complete', (route) => false);
    } else {
      print(result.statusCode);
    }
  }
}
