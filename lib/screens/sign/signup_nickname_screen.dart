import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/sign/signup_grade_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../api/PeeroreumApi.dart';
import '../../designs/PeeroreumColor.dart';

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
  bool isDuplicateNickname = false;
  bool checkNickname = false;
  bool showNicknameClearButton = false;

  checkDuplicateNickname(String value) async {
    var result = await http.get(
        Uri.parse('${API.hostConnect}/signup/nickname/$value'),
        headers: {'Content-Type': 'application/json'});
    if (result.statusCode == 409) {
      setState(() {
        isDuplicateNickname = true;
      });
    } else {
      isDuplicateNickname = false;
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
                      percent: 0.33,
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
              Container(
                padding: EdgeInsets.fromLTRB(10, 136, 10, 0),
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  controller: nicknameController,
                  onChanged: (value) {
                    if(nicknameController.text.isNotEmpty) {
                      setState(() {
                        showNicknameClearButton = true;
                        if(nicknameController.text.length >= 2 && nicknameController.text.length <= 12) {
                          checkNickname = true;
                        } else {
                          checkNickname = false;
                        }
                      });
                    } else {
                      setState(() {
                        showNicknameClearButton = false;
                        checkNickname = false;
                        isDuplicateNickname = false;
                      });
                    }
                    checkDuplicateNickname(value);

                  },
                  decoration: InputDecoration(
                    hintText: '닉네임을 입력하세요',
                    hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: PeeroreumColor.gray[600]),
                    helperText: checkNickname && !isDuplicateNickname? "사용 가능한 닉네임입니다." : "언더바(_)를 제외한 특수문자는 사용할 수 없어요.",
                    helperStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: checkNickname && !isDuplicateNickname? PeeroreumColor.primaryPuple[400] : PeeroreumColor.gray[600]),
                    errorText: checkError(),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: PeeroreumColor.error,
                      ),
                    ),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: PeeroreumColor.error,
                          )
                      ),
                      counterText: '${nicknameController.text.length} / 12',
                      counterStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: PeeroreumColor.gray[600]!
                      ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    focusedBorder: checkNickname && !isDuplicateNickname
                        ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: PeeroreumColor.primaryPuple[400]!),
                    )
                        : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: PeeroreumColor.black,
                      ),
                    ),
                    enabledBorder: checkNickname && !isDuplicateNickname
                        ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: PeeroreumColor.primaryPuple[400]!),
                    )
                        : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: PeeroreumColor.gray[200]!,
                        )
                    ),
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 12),
                            child:  showNicknameClearButton
                                ? IconButton(
                                onPressed: () {
                                  nicknameController.clear();
                                  setState(() {
                                    checkNickname = false;
                                    isDuplicateNickname = false;
                                    showNicknameClearButton = false;
                                  });
                                },
                                icon: SvgPicture.asset(
                                  "assets/icons/x_circle.svg",
                                  color: PeeroreumColor.gray[200],
                                ))
                                : null),
                        Container(
                            padding: EdgeInsets.only(right: 16),
                            child: checkNickname && !isDuplicateNickname
                                ? SvgPicture.asset(
                              "assets/icons/check.svg",
                              color: PeeroreumColor.primaryPuple[400],
                            )
                                : nicknameController.text.isNotEmpty? SvgPicture.asset(
                              "assets/icons/warning_circle.svg",
                              color: PeeroreumColor.error,
                            ) : null
                        ),
                      ],
                    )
                  ),
                    cursorColor: PeeroreumColor.gray[600]
                ),
              )
            ],
          ),
        ),
        bottomSheet: Container(
          color: PeeroreumColor.white,
          width: MediaQuery.of(context).size.width,
          padding: MediaQuery.of(context).viewInsets.bottom > 0? EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom) : EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: checkNickname && !isDuplicateNickname ? () {
                member.nickname = nicknameController.text;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => SignUpGrade(member),
                      transitionDuration: const Duration(seconds: 0),
                      reverseTransitionDuration: const Duration(seconds: 0)),
                );
              } : null,
              child: Text(
                '다음',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(checkNickname && !isDuplicateNickname? PeeroreumColor.primaryPuple[400] : PeeroreumColor.gray[300]),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: MediaQuery.of(context).viewInsets.bottom > 0? BorderRadius.zero : BorderRadius.circular(8.0),
                  ))),
            ),
          ),
        ),
      ),
    );
  }

  checkError() {
    if(!checkNickname && nicknameController.text.length > 0) {
      return "한글 2자, 영문/숫자 4자 이상 적어주세요.";
    }
    if(isDuplicateNickname) {
      return "이미 사용 중인 닉네임입니다.";
    }
    return null;
  }
}
