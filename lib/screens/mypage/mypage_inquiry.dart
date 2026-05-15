import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class MyPageInquiry extends StatefulWidget {
  const MyPageInquiry({super.key});

  @override
  State<MyPageInquiry> createState() => _MyPageInquiryState();
}

class _MyPageInquiryState extends State<MyPageInquiry> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  var email, nickname;
  List<String> inquireType = ["앱 작동에 이상", "데이터에 이상", "수정 혹은 삭제 요청", "기타"];
  String selectedType = "문의 유형을 선택해주세요.";
  String otherType = "";
  String detailInquiry = "";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    email = await storage.read(key: "email");
    nickname = await storage.read(key: "nickname");
  }

  void sendMail() async {
    String username = 'peeroreum.help@gmail.com';
    String password = dotenv.env['GMAIL_PASSWORD'] ?? '';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add('peeroreum.help@gmail.com')
      ..subject = selectedType != "기타"
          ? "[문의] $selectedType"
          : "[문의] $selectedType - $otherType"
      ..text = '문의자 : $nickname \n문의자 이메일 : $email \n문의 사항: $detailInquiry';

    try {
      await send(message, smtpServer);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: PeeroreumColor.white,
        appBar: AppBar(
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: PeeroreumColor.white,
          shadowColor: PeeroreumColor.white,
          elevation: 0.2,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: SvgPicture.asset(
              'assets/icons/arrow-left.svg',
              color: PeeroreumColor.gray[800],
            ),
          ),
          title: Text(
            "문의하기",
            style: TextStyle(
                color: PeeroreumColor.black,
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        height: 24,
                        child: Text(
                          "문의 유형",
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.black,
                          ),
                        )),
                    SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return inquireReasonBottomSheet();
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: PeeroreumColor.gray[200]!),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedType,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                color: PeeroreumColor.gray[600],
                              ),
                            ),
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: SvgPicture.asset(
                                'assets/icons/down.svg',
                                color: PeeroreumColor.gray[600],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: selectedType == "기타",
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: PeeroreumColor.gray[200]!),
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: TextFormField(
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ㆍ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ|%₩=&·*-+<>@#:;^♡_/()\"~.,!?≠≒÷×\$￥|\\{}○●□■※♥☆★\[\]←↑↓→↔«»\s]'))
                                ],
                                style: TextStyle(color: Colors.black),
                                cursorColor: PeeroreumColor.gray[600],
                                decoration: InputDecoration(
                                    hintText: '기타 유형을 입력해 주세요.',
                                    hintStyle: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: PeeroreumColor.gray[600]!),
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none),
                                onChanged: (value) {
                                  setState(() {
                                    otherType = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                      height: 24,
                      child: const Text(
                        '상세 내용',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                          border: Border.all(color: PeeroreumColor.gray[200]!),
                          borderRadius: BorderRadius.circular(8)),
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(
                              r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ㆍ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ|%₩=&·*-+<>@#:;^♡_/()\"~.,!?≠≒÷×\$￥|\\{}○●□■※♥☆★\[\]←↑↓→↔«»\s]'))
                        ],
                        maxLines: null,
                        cursorColor: PeeroreumColor.gray[600],
                        decoration: const InputDecoration(
                          hintText: '내용을 입력해 주세요.',
                          hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              color: Color(0xFFADB5BD)),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          setState(() {
                            detailInquiry = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewPadding.bottom > 20 ? MediaQuery.of(context).viewPadding.bottom : 20.0),
                width: MediaQuery.of(context).size.width,
                child: SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: (selectedType != '문의 유형을 선택해주세요.' &&
                                detailInquiry != "" &&
                                selectedType != '기타' ||
                            selectedType == '기타' &&
                                otherType != "" &&
                                detailInquiry != "")
                        ? () {
                            sendMail();
                            PeeroreumToast.show(context, "문의가 접수되었어요.");
                            Get.back();
                          }
                        : null,
                    style: ButtonStyle(
                        backgroundColor: (selectedType != '문의 유형을 선택해주세요.' &&
                                    detailInquiry != "" &&
                                    selectedType != '기타' ||
                                selectedType == '기타' &&
                                    otherType != "" &&
                                    detailInquiry != "")
                            ? MaterialStateProperty.all(
                                PeeroreumColor.primaryPuple[400])
                            : MaterialStateProperty.all(
                                PeeroreumColor.gray[300]),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 12)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ))),
                    child: Text(
                      '문의하기',
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
      ),
    );
  }

  Widget inquireReasonBottomSheet() {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
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
                  "문의 유형을 선택해주세요.",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                )),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: inquireType.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          selectedType = inquireType[index];
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Text(
                            inquireType[index],
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.black,
                            ),
                          )));
                }),
          ),
        ],
      ),
    );
  }
}
