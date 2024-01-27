import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class Report extends StatefulWidget {
  //const Report({super.key});
  const Report({Key? key}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}



class _ReportState extends State<Report> {
  String selectedReason = "신고사유를 선택해주세요";
  String otherReason = "";
  List<bool> reason = [false, false, false, false];
  String detailReason = "";

  void updateReason(List<bool> newReason, String newSelectedReason) {
    setState(() {
      reason = newReason;
      selectedReason = newSelectedReason;
    });
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
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/arrow-left.svg',
              color: PeeroreumColor.gray[800],
            ),
          ),
          title: Text(
            '신고',
            style: TextStyle(
                color: PeeroreumColor.gray[800],
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500),
          ),
        ),
        body: bodyWidget(),
      ),
    );
  }

  bodyWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: PeeroreumColor.gray[200],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  height: 24,
                  child: const Text(
                    '신고 사유',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 8,),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return reportReasonBottomSheet(
                          updateReason: updateReason,
                          selectedReason: selectedReason,
                          reason: reason,
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        border: Border.all(color: PeeroreumColor.gray[200]!),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedReason,
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.gray[600]),
                        ),
                        Container(
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
                  //기타 입력란
                  visible: reason[3],
                  child: Column(
                    children: [
                      const SizedBox(height: 8,),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                            border: Border.all(color: PeeroreumColor.gray[200]!),
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: TextFormField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(
                                      r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ㆍ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ]'))
                            ],
                            style: TextStyle(color: Colors.black),
                            cursorColor: PeeroreumColor.gray[600],
                            decoration: InputDecoration(
                              hintText: '기타 사유를 입력해 주세요.',
                              hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: PeeroreumColor.gray[600]!
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none
                            ),
                            onChanged: (value) {
                              otherReason = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40,),
                Container(
                  alignment: Alignment.centerLeft,
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
                const SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  width: double.infinity,
                  height: 427,
                  decoration: BoxDecoration(
                      border: Border.all(color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(
                              r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ㆍ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ]'))
                    ],
                    maxLines: null,
                    cursorColor: PeeroreumColor.gray[600],
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      detailReason = value;
                    },
                  ),
                ),
              ],
            ),
          ),
          //신고하기 버튼
          Container(
              color: PeeroreumColor.white,
              margin: EdgeInsets.fromLTRB(20, 66, 20, 8),
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: (selectedReason != '신고사유를 선택해주세요' && detailReason != "" && selectedReason != '기타' 
                  || selectedReason == '기타' && otherReason != "" && detailReason != "")
                      ? () {
                        Navigator.pop(context);
                        // 이메일 보내기 처리
                          // Navigator.push(
                          //   context,
                          //   PageRouteBuilder(
                          //       pageBuilder: (_, __, ___) =>
                          //           SignUpNickname(member),
                          //       transitionDuration:
                          //           const Duration(seconds: 0),
                          //       reverseTransitionDuration:
                          //           const Duration(seconds: 0)),
                          // );
                        }
                      : null,
                  style: ButtonStyle(
                      backgroundColor: (selectedReason != '신고사유를 선택해주세요' && detailReason != "" && selectedReason != '기타' 
                      || selectedReason == '기타' && otherReason != "" && detailReason != "")
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
                    '신고하기',
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
    );
  }
}

class reportReasonBottomSheet extends StatefulWidget {
  //const reportReasonBottomSheet({super.key});

  final Function(List<bool>, String) updateReason;
  final String selectedReason;
  final List<bool> reason;

  reportReasonBottomSheet({
    required this.updateReason,
    required this.selectedReason,
    required this.reason,
  });

  @override
  State<reportReasonBottomSheet> createState() => _reportReasonBottomSheetState();
}

class _reportReasonBottomSheetState extends State<reportReasonBottomSheet> {

  List<bool> reason = [false, false, false, false];
  String selectedReason = "신고사유를 선택해주세요";

  void updateReason(List<bool> newReason, String newSelectedReason) {
    setState(() {
      reason = newReason;
      selectedReason = newSelectedReason;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectReason();
  }
  selectReason() {
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
          const SizedBox(height: 16,),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
                height: 24,
                alignment: Alignment.centerLeft,
                child: const Text(
                  '신고사유',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                )),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              //욕설 및 비방
              setState(() {
                reason = [true, false, false, false];
                selectedReason = '욕설 및 비방';
              });

            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '욕설 및 비방',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: reason[0]
                            ? PeeroreumColor.primaryPuple[400]
                            : PeeroreumColor.black,
                      ),
                    ),
                    if (reason[0])
                      SvgPicture.asset(
                        'assets/icons/check2.svg',
                        color: PeeroreumColor.primaryPuple[400],
                      )
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              //음란물 및 불건전한 대화
              setState(() {
                reason = [false, true, false, false];
                selectedReason = '음란물 및 불건전한 대화';
              });

            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '음란물 및 불건전한 대화',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: reason[1]
                            ? PeeroreumColor.primaryPuple[400]
                            : PeeroreumColor.black,
                      ),
                    ),
                    if (reason[1])
                      SvgPicture.asset(
                        'assets/icons/check2.svg',
                        color: PeeroreumColor.primaryPuple[400],
                      )
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              //상업적 광고 및 판매
              setState(() {
                reason = [false, false, true, false];
                selectedReason = '상업적 광고 및 판매';
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '상업적 광고 및 판매',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: (reason[2])
                            ? PeeroreumColor.primaryPuple[400]
                            : PeeroreumColor.black,
                      ),
                    ),
                    if (reason[2])
                      SvgPicture.asset(
                        'assets/icons/check2.svg',
                        color: PeeroreumColor.primaryPuple[400],
                      )
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              //기타
              setState(() {
                reason = [false, false, false, true];
                selectedReason = '기타';
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '기타',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: reason[3]
                            ? PeeroreumColor.primaryPuple[400]
                            : PeeroreumColor.black,
                      ),
                    ),
                    if (reason[3])
                      SvgPicture.asset(
                        'assets/icons/check2.svg',
                        color: PeeroreumColor.primaryPuple[400],
                      )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 20,
            ),
            width: double.maxFinite,
            child: TextButton(
              onPressed: () {
                widget.updateReason(reason, selectedReason);
                Navigator.pop(context);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      PeeroreumColor.primaryPuple[400]),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 12)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ))),
              child: Text(
                '선택완료',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PeeroreumColor.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 21,),
        ],
      ),
    );
  }
}