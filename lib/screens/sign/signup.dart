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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/images/signup_ready.png"),
          SizedBox(
            height: 80,
          ),
          Text(
            '안녕하세요, 오르미예요!',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: PeeroreumColor.black),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            '서비스 사용을 위한 설정이 필요해요.',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[700]),
          )
        ]),
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
              backgroundColor: Colors.transparent,
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

  List<bool> isCheckedList = [false, false, false, false];
  // 약관 전체 동의 // 이용약관 동의 // 개인정보 동의 // 이벤트마케팅동의 (선택)

  void Check() {
    if(isCheckedList[1] == isCheckedList[2] &&  isCheckedList[2] == isCheckedList[3]){
      isCheckedList[0] =isCheckedList[1];
    } else{
      isCheckedList[0] = false;
    }
    if(isCheckedList[1] == true && isCheckedList[2] == true){
      button = true;
    } else{
      button = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return serviceTerms();
  }

  Widget serviceTerms() {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 24, 0, 16),
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
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        // 전체 동의 로직
                        setState(() {
                          isCheckedList[0] = !isCheckedList[0];
                          if(isCheckedList[0]){
                            isCheckedList = [true, true, true, true];
                          } else if(isCheckedList[0] == false){
                            isCheckedList = [false, false, false, false];
                          }
                          Check();
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PeeroreumColor.gray[200]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                          color: 
                           isCheckedList[0]
                              ? PeeroreumColor.primaryPuple[400]!
                              : PeeroreumColor.white
                          
                        ),
                        child: isCheckedList[0]
                            ? Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            : null,
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
                      color: button
                          ? PeeroreumColor.black
                          : PeeroreumColor.gray[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //devider
              // margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              color: PeeroreumColor.gray[200],
              height: 1,
            ),
            Container(
              //이용약관 동의
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Row(
                    children: [
                     InkWell(
                      onTap: () {
                        setState(() {
                          isCheckedList[1] = !isCheckedList[1];
                          Check();
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PeeroreumColor.gray[200]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                          color: 
                           isCheckedList[1]
                              ? PeeroreumColor.primaryPuple[400]!
                              : PeeroreumColor.white
                          
                        ),
                        child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
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
                  GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse(
                          "https://peeroreum.notion.site/1b5a5f1566fe4b51ba76820fbed005ff"));
                    },
                    child: SvgPicture.asset(
                      "assets/icons/right.svg",
                      color: PeeroreumColor.gray[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //개인정보 수집 및 이용 동의
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Row(
                    children: [
                      InkWell(
                      onTap: () {
                        setState(() {
                          isCheckedList[2] = !isCheckedList[2];
                          Check();
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PeeroreumColor.gray[200]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                          color: 
                           isCheckedList[2]
                              ? PeeroreumColor.primaryPuple[400]!
                              : PeeroreumColor.white
                          
                        ),
                        child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
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
                  GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse(
                          "https://peeroreum.notion.site/68e35d866d544911ac35ee254e227b6c"));
                    },
                    child: SvgPicture.asset(
                      "assets/icons/right.svg",
                      color: PeeroreumColor.gray[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //(선택) 이벤트, 마케팅 및 혜택 알림 동의
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Row(
                    children: [
                      InkWell(
                      onTap: () {
                        // 전체 동의 로직
                        setState(() {
                          isCheckedList[3] = !isCheckedList[3];
                          Check();
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PeeroreumColor.gray[200]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                          color: 
                           isCheckedList[3]
                              ? PeeroreumColor.primaryPuple[400]!
                              : PeeroreumColor.white
                          
                        ),
                        child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
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
                ],
              ),
            ),
            Container(
              color: PeeroreumColor.white,
              margin: EdgeInsets.fromLTRB(0, 28, 0, 8),
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: button
                      ? () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    SignUpNickname(member),
                                transitionDuration:
                                    const Duration(seconds: 0),
                                reverseTransitionDuration:
                                    const Duration(seconds: 0)),
                          );
                        }
                      : null,
                  style: ButtonStyle(
                      backgroundColor: button
                          ? MaterialStateProperty.all(
                              PeeroreumColor.primaryPuple[400])
                          : MaterialStateProperty.all(
                              PeeroreumColor.gray[300]),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 12)),
                      shape:
                          MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                        borderRadius:
                            MediaQuery.of(context).viewInsets.bottom > 0
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
          ],
        ),
      ),
    );
  }
}
