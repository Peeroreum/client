import 'package:flutter/material.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/signup_subject_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SignUpNickname extends StatefulWidget {
  Member member;
  SignUpNickname(this.member);

  @override
  State<SignUpNickname> createState() => _SignUpNicknameState(member);
}

class _SignUpNicknameState extends State<SignUpNickname> {
  Member member;
  _SignUpNicknameState(this.member);
  final nicknameController = TextEditingController();

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
            // mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: double.maxFinite,
                    child: LinearPercentIndicator(
                      animateFromLastPercent: true,
                      lineHeight: 8.0,
                      percent: 0.25,
                      progressColor: Color.fromARGB(255, 114, 96, 248),
                      backgroundColor: Colors.grey[100],
                      barRadius: Radius.circular(10),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("피어오름에서 사용할 닉네임을\n알려주세요.",
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        SizedBox(
                          height: 10,
                        ),
                        Text("닉네임을 설정하면 30일 이후 변경할 수 있어요.",
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[800])),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 120, 10, 4),
                    child: TextFormField(
                      controller: nicknameController,
                      onChanged: (value) {
                        member.nickname = value;
                      },
                      decoration: InputDecoration(
                        hintText: '닉네임을 입력하세요',
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
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("언더바(_)를 제외한 특수문자와 이모티콘은 사용할 수 없어요.",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600])),
                        Row(
                          children: [
                            Text("12",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600])),
                            Text("/",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[200])),
                            Text("12",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600])),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
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
                Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => SignUpSubject(member),
                      transitionDuration: const Duration(seconds: 0),
                      reverseTransitionDuration: const Duration(seconds: 0)),
                );
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
      ),
    );
  }
}
