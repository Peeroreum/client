import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SignUpGrade extends StatefulWidget {
  @override
  State<SignUpGrade> createState() => _SignUpGradeState();
}

class _SignUpGradeState extends State<SignUpGrade> {
  @override
  Widget build(BuildContext context) {
    final _schools = ['중학교', '고등학교'];
    final _grades = ['1학년', '2학년', '3학년'];
    String? _school;
    String? _grade;

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
                  percent: 0.75,
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
                      "학년을 알려주세요.",
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
                      "친구가 있는 같이방과 답변을 기다리는 질문을 추천해 드릴게요.",
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
              padding: EdgeInsets.fromLTRB(10, 167, 10, 312),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton(
                      value: _school,
                      hint: Text(
                        '학교',
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
                      items: _schools
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _school = value!;
                        });
                      },
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600],),
                    ),
                    DropdownButton(
                      value: _grade,
                      hint: Text(
                        '학년',
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
                      items: _grades
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _grade = value!;
                        });
                      },
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600],),
                    ),
                  ]
              )
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: 350.0,
              height: 48.0,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signUp/profile/grade');
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