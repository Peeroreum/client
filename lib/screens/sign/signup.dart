// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/sign/signup_nickname_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  Member member;
  SignUp(this.member);

  @override
  State<SignUp> createState() => _SignUpState(member);
}

class _SignUpState extends State<SignUp> {
  Member member;
  _SignUpState(this.member);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: PeeroreumColor.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/signup_ready.png"),
              SizedBox(height: 80,),
              Text(
                '안녕하세요, 오르미예요!',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black
                ),
              ),
              SizedBox(height: 16,),
              Text(
                '서비스 사용을 위한 설정이 필요해요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: PeeroreumColor.gray[700]
                ),
              )
            ]
        ),
      ),
      bottomSheet: bottomsheetWidget(),
    );
  }

  Widget bottomsheetWidget() {
    return Container(
      color: PeeroreumColor.white,
      padding: MediaQuery.of(context).viewInsets.bottom > 0
          ? EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)
          : EdgeInsets.fromLTRB(20, 8, 20, 28),
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        height: 48,
        child: TextButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return serviceTerms(member);
              },
            );
          },
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(PeeroreumColor.primaryPuple[400]),
              padding:
                  MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                    ? BorderRadius.zero
                    : BorderRadius.circular(8.0),
              ))),
          child: Text(
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

class serviceTerms extends StatefulWidget {
  Member member;
  serviceTerms(this.member);

  @override
  State<serviceTerms> createState() => _serviceTermsState(member);
}

class _serviceTermsState extends State<serviceTerms> {
  Member member;
  _serviceTermsState(this.member);

  bool button = false; //다음 button

  bool _allChecked = false; // 약관 전체 동의
  bool _useChecked = false; // 이용약관 동의
  bool _infoChecked = false; // 개인정보 동의
  bool _eventChecked = false; // 이벤트마케팅동의 (선택)

  void Check() {
    if (_useChecked || _infoChecked || _eventChecked) {
      setState(() {
        _allChecked = false;
      });
    }
    if (_useChecked && _infoChecked && _eventChecked) {
      setState(() {
        _allChecked = true;
        button = true;
      });
    }
    if (_useChecked && _infoChecked) {
      setState(() {
        button = true;
      });
    } else {
      setState(() {
        button = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return serviceTerms();
  }

  Widget serviceTerms() {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
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
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _allChecked,
                      onChanged: (value) {
                        setState(() {
                          _allChecked = value!;
                          _useChecked = value;
                          _infoChecked = value;
                          _eventChecked = value;
                          button = value;
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashRadius: 4,
                      side: BorderSide(
                          width: 2, color: PeeroreumColor.gray[200]!),
                      checkColor: PeeroreumColor.white,
                      activeColor: PeeroreumColor.primaryPuple[400],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    '약관 전체 동의',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _allChecked
                          ? PeeroreumColor.black
                          : PeeroreumColor.gray[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //devider
              margin: EdgeInsets.fromLTRB(10, 0, 20, 10),
              color: PeeroreumColor.gray[200],
              height: 1,
            ),
            Container(
              //이용약관 동의
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _useChecked,
                          onChanged: (value) {
                            setState(() {
                              _useChecked = value!;
                              Check();
                            });
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          splashRadius: 24,
                          side: BorderSide(
                              width: 2, color: PeeroreumColor.gray[200]!),
                          checkColor: PeeroreumColor.white,
                          activeColor: PeeroreumColor.primaryPuple[400],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      SizedBox(
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
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      launchUrl(Uri.parse("https://peeroreum.notion.site/1b5a5f1566fe4b51ba76820fbed005ff"));
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/right.svg",
                      color: PeeroreumColor.gray[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //개인정보 수집 및 이용 동의
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _infoChecked,
                          onChanged: (value) {
                            setState(() {
                              _infoChecked = value!;
                              Check();
                            });
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          splashRadius: 24,
                          side: BorderSide(
                              width: 2, color: PeeroreumColor.gray[200]!),
                          checkColor: PeeroreumColor.white,
                          activeColor: PeeroreumColor.primaryPuple[400],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      SizedBox(
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
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      launchUrl(Uri.parse("https://peeroreum.notion.site/68e35d866d544911ac35ee254e227b6c"));
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/right.svg",
                      color: PeeroreumColor.gray[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //(선택) 이벤트, 마케팅 및 혜택 알림 동의
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _eventChecked,
                          onChanged: (value) {
                            setState(() {
                              _eventChecked = value!;
                              Check();
                            });
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          splashRadius: 24,
                          side: BorderSide(
                              width: 2, color: PeeroreumColor.gray[200]!),
                          checkColor: PeeroreumColor.white,
                          activeColor: PeeroreumColor.primaryPuple[400],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      SizedBox(
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
                  Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/icons/right.svg",
                      color: PeeroreumColor.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: PeeroreumColor.white,
          padding: MediaQuery.of(context).viewInsets.bottom > 0
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom)
              : EdgeInsets.fromLTRB(20, 8, 20, 28),
          width: MediaQuery.of(context).size.width,
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: button
                  ? () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SignUpNickname(member),
                            transitionDuration: const Duration(seconds: 0),
                            reverseTransitionDuration:
                                const Duration(seconds: 0)),
                      );
                    }
                  : null,
              style: ButtonStyle(
                  backgroundColor: button
                      ? MaterialStateProperty.all(
                          PeeroreumColor.primaryPuple[400])
                      : MaterialStateProperty.all(PeeroreumColor.gray[300]),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 12)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                        ? BorderRadius.zero
                        : BorderRadius.circular(8.0),
                  ))),
              child: Text(
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
      ),
    );
  }
}
