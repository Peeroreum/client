import 'package:flutter/material.dart';
import 'package:peeroreum_client/screens/signup_grade_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SignUpSubject extends StatefulWidget {
  @override
  State<SignUpSubject> createState() => _SignUpSubjectState();
}

class _SignUpSubjectState extends State<SignUpSubject> {
  final _subjects = ['국어', '영어', '수학', '사회', '과학', '기타'];
  final _levels = ['상', '중', '하'];
  String? _goodSubject;
  String? _selectedDetailGoodSubject;
  String? _badSubject;
  String? _selectedDetailBadSubject;
  String? _goodLevel;
  String? _badLevel;

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
                  percent: 0.5,
                  progressColor: Color.fromARGB(255, 114, 96, 248),
                  backgroundColor: Colors.grey[100],
                  barRadius: Radius.circular(10),
                )
            ),
            Container(
              height: 122,
              width: double.maxFinite,
              padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "자신 있는 과목과 보완하고 싶은\n과목의 성취 수준을 알려주세요.",
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "유사한 성취 수준의 친구가 있는 같이방을 추천해 드릴게요.",
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[800]
                      )
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 56, 10, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '자신 있는 과목',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton(
                        value: _goodSubject,
                        hint: Text(
                          '과목',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]
                          ),
                        ),
                        elevation: 0,
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]
                        ),
                        items: _subjects
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _goodSubject = value!;
                          });
                        },
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600],),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      DropdownButton(
                        value: _selectedDetailGoodSubject,
                        hint: Text(
                          '세부과목',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600]
                          ),
                        ),
                        elevation: 0,
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]
                        ),
                        items: _subjects
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDetailGoodSubject = value!;
                          });
                        },
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600],),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  DropdownButton(
                    value: _goodLevel,
                    hint: Text(
                      '성취 수준을 선택해 주세요',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600]
                      ),
                    ),
                    elevation: 0,
                    dropdownColor: Colors.white,
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600]
                    ),
                    items: _levels
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _goodLevel = value!;
                      });
                    },
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600],),
                  ),
                ],
              )
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 143),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '보완하고 싶은 과목',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton(
                        value: _badSubject,
                        hint: Text(
                          '과목',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600]
                          ),
                        ),
                        elevation: 0,
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]
                        ),
                        items: _subjects
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _badSubject = value!;
                          });
                        },
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600],),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      DropdownButton(
                        value: _selectedDetailBadSubject,
                        hint: Text(
                          '세부과목',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600]
                          ),
                        ),
                        elevation: 0,
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]
                        ),
                        items: _subjects
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDetailBadSubject = value!;
                          });
                        },
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600],),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  DropdownButton(
                    value: _badLevel,
                    hint: Text(
                      '성취 수준을 선택해 주세요',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600]
                      ),
                    ),
                    elevation: 0,
                    dropdownColor: Colors.white,
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600]
                    ),
                    items: _levels
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _badLevel = value!;
                      });
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: 350.0,
              height: 48.0,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => SignUpGrade(),
                        transitionDuration: const Duration(seconds: 0),
                        reverseTransitionDuration: const Duration(seconds: 0)
                    ),
                  );
                },
                child: Text(
                  '다음',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      color: Colors.white
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}