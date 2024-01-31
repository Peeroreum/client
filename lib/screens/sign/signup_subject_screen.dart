// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
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
  // State<SignUpSubject> createState() => _SignUpSubjectState();
}

class _SignUpSubjectState extends State<SignUpSubject> {
  Member member;
  _SignUpSubjectState(this.member);
  // Member member = Member();

  final subjects = Subject.subject;
  final middleSubjects = Subject.middleSubject;
  final highSubjects = Subject.highSubject;

  final _levels = [
    '처음 보는 문제여도 어려움 없이 풀 수 있어요.',
    '활용 문제를 풀 수 있지만 시간이 필요해요.',
    '기본 문제는 풀 수 있지만, 활용 문제는 어려워요.',
    '기본 문제를 풀 수 있어요.',
    '기본 개념을 이해하지 못했어요.'
  ];
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
    } else {
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
            icon: SvgPicture.asset('assets/icons/arrow-left.svg',
                color: PeeroreumColor.gray[800]),
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
                          // PeeroreumButton<String>(
                          //   items: Subject.subject,
                          //   value: _goodSubject,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _goodSubject = value;
                          //       goodDetailSubjects = ((member.grade! <= 3)
                          //           ? middleSubjects[_goodSubject]
                          //           : highSubjects[_goodSubject])!;
                          //       _selectedDetailGoodSubject = null;
                          //       _checkInput();
                          //     });
                          //   },
                          //   hintText: '과목',
                          // ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: false,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return goodSubject();
                                  });
                            },
                            child: Container(
                              height: 40,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: PeeroreumColor.gray[200]!,
                                ),
                                color: Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _goodSubject ?? '과목',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        color: _goodSubject != null
                                            ? PeeroreumColor.black
                                            : PeeroreumColor.gray[600]),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  SvgPicture.asset('assets/icons/down.svg'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          // Expanded(
                          //   child: PeeroreumButton<String>(
                          //       width: double.infinity,
                          //       items: goodDetailSubjects,
                          //       value: _selectedDetailGoodSubject,
                          //       onChanged: (value) {
                          //         setState(() {
                          //           _selectedDetailGoodSubject = value;
                          //           _checkInput();
                          //         });
                          //       },
                          //       hintText: '세부 과목'),
                          // ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _goodSubject != null
                                    ? showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: false,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          return goodDetail();
                                        })
                                    : Fluttertoast.showToast(
                                        msg: '과목을 먼저 선택해주세요.');
                              },
                              child: Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: PeeroreumColor.gray[200]!,
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedDetailGoodSubject ?? '세부 과목',
                                      style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          color:
                                              _selectedDetailGoodSubject != null
                                                  ? PeeroreumColor.black
                                                  : PeeroreumColor.gray[600]),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Spacer(),
                                    SvgPicture.asset('assets/icons/down.svg'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // PeeroreumButton<String>(
                      //   width: double.infinity,
                      //   items: _levels,
                      //   value: _goodLevel,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _goodLevel = value;
                      //       _checkInput();
                      //     });
                      //   },
                      //   hintText: '성취 수준을 선택해 주세요',
                      // ),
                      GestureDetector(
                        onTap: () {
                          _selectedDetailGoodSubject != null
                              ? showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: false,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return goodLevel();
                                  })
                              : Fluttertoast.showToast(
                                  msg: '세부 과목을 먼저 선택해주세요.');
                        },
                        child: Container(
                          height: 40,
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: PeeroreumColor.gray[200]!,
                            ),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Text(
                                _goodLevel ?? '성취 수준을 선택해 주세요',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    color: _goodLevel != null
                                        ? PeeroreumColor.black
                                        : PeeroreumColor.gray[600]),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Spacer(),
                              SvgPicture.asset('assets/icons/down.svg'),
                            ],
                          ),
                        ),
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
                        // PeeroreumButton<String>(
                        //   items: Subject.subject,
                        //   value: _badSubject,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       _badSubject = value;
                        //       badDetailSubjects = ((member.grade! <= 3)
                        //           ? middleSubjects[_badSubject]
                        //           : highSubjects[_badSubject])!;
                        //       _selectedDetailBadSubject = null;
                        //       _checkInput();
                        //     });
                        //   },
                        //   hintText: '과목',
                        // ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: false,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return badSubject();
                                });
                          },
                          child: Container(
                            height: 40,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: PeeroreumColor.gray[200]!,
                              ),
                              color: Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _badSubject ?? '과목',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                      color: _badSubject != null
                                          ? PeeroreumColor.black
                                          : PeeroreumColor.gray[600]),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                SvgPicture.asset('assets/icons/down.svg'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        // Expanded(
                        //   child: PeeroreumButton<String>(
                        //     width: double.infinity,
                        //     items: badDetailSubjects,
                        //     value: _selectedDetailBadSubject,
                        //     onChanged: (value) {
                        //       setState(() {
                        //         _selectedDetailBadSubject = value;
                        //         _checkInput();
                        //       });
                        //     },
                        //     hintText: '세부 과목',
                        //   ),
                        // ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _badSubject != null
                                  ? showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: false,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return badDetail();
                                      })
                                  : Fluttertoast.showToast(
                                      msg: '과목을 먼저 선택해주세요.');
                            },
                            child: Container(
                              height: 40,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: PeeroreumColor.gray[200]!,
                                ),
                                color: Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedDetailBadSubject ?? '세부 과목',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        color: _selectedDetailBadSubject != null
                                            ? PeeroreumColor.black
                                            : PeeroreumColor.gray[600]),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Spacer(),
                                  SvgPicture.asset('assets/icons/down.svg'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // PeeroreumButton<String>(
                    //   width: double.infinity,
                    //   items: _levels,
                    //   value: _badLevel,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _badLevel = value;
                    //       _checkInput();
                    //     });
                    //   },
                    //   hintText: '성취 수준을 선택해 주세요',
                    // ),
                    GestureDetector(
                      onTap: () {
                        _selectedDetailBadSubject != null
                            ? showModalBottomSheet(
                                context: context,
                                isScrollControlled: false,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return badLevel();
                                })
                            : Fluttertoast.showToast(msg: '세부 과목을 먼저 선택해주세요.');
                      },
                      child: Container(
                        height: 40,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: PeeroreumColor.gray[200]!,
                          ),
                          color: Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Text(
                              _badLevel ?? '성취 수준을 선택해 주세요',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  color: _badLevel != null
                                      ? PeeroreumColor.black
                                      : PeeroreumColor.gray[600]),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Spacer(),
                            SvgPicture.asset('assets/icons/down.svg'),
                          ],
                        ),
                      ),
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
                  member.goodDetailSubject =
                      goodDetailSubjects.indexOf(_selectedDetailGoodSubject!);
                  member.goodLevel = _levels.indexOf(_goodLevel!);
                  member.badSubject = subjects.indexOf(_badSubject!) + 1;
                  member.badDetailSubject =
                      badDetailSubjects.indexOf(_selectedDetailBadSubject!);
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

  goodSubject() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '과목',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: Subject.subject.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _goodSubject = Subject.subject[index];
                          goodDetailSubjects = ((member.grade! <= 3)
                              ? middleSubjects[_goodSubject]
                              : highSubjects[_goodSubject])!;
                          _selectedDetailGoodSubject = null;
                          _goodLevel = null;
                          _checkInput();
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          Subject.subject[index],
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  goodDetail() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '세부 과목',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: goodDetailSubjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _selectedDetailGoodSubject =
                              goodDetailSubjects[index];
                          _goodLevel = null;
                          _checkInput();
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          goodDetailSubjects[index],
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  goodLevel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '성취 수준을 선택해 주세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _goodLevel = _levels[index];
                          _checkInput();
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          _levels[index],
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16, //원래는 18인데 너무 큰거같아요
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  badSubject() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '과목',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: Subject.subject.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _badSubject = Subject.subject[index];
                          badDetailSubjects = ((member.grade! <= 3)
                              ? middleSubjects[_badSubject]
                              : highSubjects[_badSubject])!;
                          _selectedDetailBadSubject = null;
                          _badLevel = null;
                          _checkInput();
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          Subject.subject[index],
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  badDetail() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '세부 과목',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: badDetailSubjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _selectedDetailBadSubject = badDetailSubjects[index];
                          _badLevel = null;
                          _checkInput();
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          badDetailSubjects[index],
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  badLevel() {
    return Container(
      //width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '성취 수준을 선택해 주세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _badLevel = _levels[index];
                          _checkInput();
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          _levels[index],
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16, //18인데 넘커보임..
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
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
      Navigator.pushNamedAndRemoveUntil(
          context, 'signUp/Complete', (route) => false);
    } else {
      print(result.statusCode);
    }
  }
}
