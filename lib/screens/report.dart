import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/widgets/block_user.dart';

class Report extends StatefulWidget {
  final dynamic data;

  /// 신고 대상 종류: QUESTION, ANSWER, CHALLENGE_IMAGE, MEMBER
  final String targetType;
  final dynamic targetId;

  /// 신고 대상 회원 닉네임 (있으면 '함께 차단하기' 노출)
  final String? reportedNickname;

  const Report(
      {Key? key,
      required this.data,
      this.targetType = 'MEMBER',
      this.targetId,
      this.reportedNickname})
      : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  late String data;

  @override
  void initState() {
    super.initState();
    data = widget.data.toString();
  }

  String selectedReason = "신고사유를 선택해 주세요";
  String otherReason = "";
  List<bool> reason = [false, false, false, false];
  String detailReason = "";
  bool alsoBlock = false;
  bool isSubmitting = false;

  void updateReason(List<bool> newReason, String newSelectedReason) {
    setState(() {
      reason = newReason;
      selectedReason = newSelectedReason;
    });
  }

  Future<bool> submitReport() async {
    final targetId = widget.targetId == null
        ? null
        : int.tryParse(widget.targetId.toString());
    try {
      final response = await ApiClient().post('/report', data: {
        'targetType': widget.targetType,
        'targetId': targetId,
        'reportedNickname': widget.reportedNickname,
        'reason': reason[3] ? '$selectedReason-$otherReason' : selectedReason,
        'detail': detailReason,
        'context': data,
        'block': alsoBlock,
      });
      if (response.statusCode == 200) return true;
      if (mounted) {
        PeeroreumToast.show(context, ApiClient.errorMessage(response),
            isError: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return false;
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
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/arrow-left.svg',
              colorFilter:
                  ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
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
        body: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            child: bodyWidget(),
          ),
        ),
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
                const SizedBox(
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
                        return ReportReasonBottomSheet(
                          updateReason: updateReason,
                          selectedReason: selectedReason,
                          reason: reason,
                        );
                      },
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: SvgPicture.asset(
                            'assets/icons/down.svg',
                            colorFilter: ColorFilter.mode(
                                PeeroreumColor.gray[600]!, BlendMode.srcIn),
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
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: PeeroreumColor.gray[200]!),
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: TextFormField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(
                                  r'[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣ᆞᆢㆍᄀ-ᄒ%₩=&·*\-+<>@#:;^♡_/()"~.,!?≠≒÷×$￥|\\{}○●□■※♥☆★\[\]←↑↓→↔«»\s]'))
                            ],
                            style: const TextStyle(color: Colors.black),
                            cursorColor: PeeroreumColor.gray[600],
                            decoration: InputDecoration(
                                hintText: '기타 사유를 입력해 주세요.',
                                hintStyle: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: PeeroreumColor.gray[600]!),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none),
                            onChanged: (value) {
                              otherReason = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height -
                      (widget.reportedNickname != null ? 443 : 397),
                  decoration: BoxDecoration(
                      border: Border.all(color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(
                          r'[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣ᆞᆢㆍᄀ-ᄒ%₩=&·*\-+<>@#:;^♡_/()"~.,!?≠≒÷×$￥|\\{}○●□■※♥☆★\[\]←↑↓→↔«»\s]'))
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
          //함께 차단하기
          if (widget.reportedNickname != null)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => alsoBlock = !alsoBlock),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      alsoBlock
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 22,
                      color: alsoBlock
                          ? PeeroreumColor.primaryPurple[400]
                          : PeeroreumColor.gray[400],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.reportedNickname} 님을 함께 차단할게요',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          //신고하기 버튼
          Container(
            color: PeeroreumColor.white,
            margin: const EdgeInsets.fromLTRB(20, 36, 20, 8),
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: (selectedReason != '신고사유를 선택해 주세요' &&
                            detailReason != "" &&
                            selectedReason != '기타' ||
                        selectedReason == '기타' &&
                            otherReason != "" &&
                            detailReason != "")
                    ? () async {
                        if (isSubmitting) return;
                        final confirmed = await showModerationConfirm(
                          context,
                          title: widget.reportedNickname != null
                              ? '${widget.reportedNickname} 님을 신고할까요?'
                              : '신고할까요?',
                          description:
                              '신고 내용은 운영팀에 전달되며,\n검토 후 운영 정책에 따라 조치될 수 있어요.',
                          confirmText: '신고',
                        );
                        if (!confirmed || !mounted) return;
                        setState(() => isSubmitting = true);
                        final success = await submitReport();
                        if (!mounted) return;
                        setState(() => isSubmitting = false);
                        if (!success) return;
                        PeeroreumToast.show(context, "신고가 접수되었어요.");
                        Navigator.pop(context, alsoBlock);
                        Navigator.pop(context, alsoBlock);
                      }
                    : null,
                style: ButtonStyle(
                    backgroundColor: (selectedReason != '신고사유를 선택해 주세요' &&
                                detailReason != "" &&
                                selectedReason != '기타' ||
                            selectedReason == '기타' &&
                                otherReason != "" &&
                                detailReason != "")
                        ? WidgetStateProperty.all(
                            PeeroreumColor.primaryPurple[400])
                        : WidgetStateProperty.all(PeeroreumColor.gray[300]),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                          ? BorderRadius.zero
                          : BorderRadius.circular(8.0),
                    ))),
                child: const Text(
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

class ReportReasonBottomSheet extends StatefulWidget {
  final Function(List<bool>, String) updateReason;
  final String selectedReason;
  final List<bool> reason;

  const ReportReasonBottomSheet({
    super.key,
    required this.updateReason,
    required this.selectedReason,
    required this.reason,
  });

  @override
  State<ReportReasonBottomSheet> createState() =>
      _ReportReasonBottomSheetState();
}

class _ReportReasonBottomSheetState extends State<ReportReasonBottomSheet> {
  List<bool> reason = [false, false, false, false];
  String selectedReason = "신고사유를 선택해 주세요";

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
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
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
                              ? PeeroreumColor.primaryPurple[400]
                              : PeeroreumColor.black,
                        ),
                      ),
                      if (reason[0])
                        SvgPicture.asset(
                          'assets/icons/check2.svg',
                          colorFilter: ColorFilter.mode(
                              PeeroreumColor.primaryPurple[400]!,
                              BlendMode.srcIn),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
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
                              ? PeeroreumColor.primaryPurple[400]
                              : PeeroreumColor.black,
                        ),
                      ),
                      if (reason[1])
                        SvgPicture.asset(
                          'assets/icons/check2.svg',
                          colorFilter: ColorFilter.mode(
                              PeeroreumColor.primaryPurple[400]!,
                              BlendMode.srcIn),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
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
                              ? PeeroreumColor.primaryPurple[400]
                              : PeeroreumColor.black,
                        ),
                      ),
                      if (reason[2])
                        SvgPicture.asset(
                          'assets/icons/check2.svg',
                          colorFilter: ColorFilter.mode(
                              PeeroreumColor.primaryPurple[400]!,
                              BlendMode.srcIn),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
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
                              ? PeeroreumColor.primaryPurple[400]
                              : PeeroreumColor.black,
                        ),
                      ),
                      if (reason[3])
                        SvgPicture.asset(
                          'assets/icons/check2.svg',
                          colorFilter: ColorFilter.mode(
                              PeeroreumColor.primaryPurple[400]!,
                              BlendMode.srcIn),
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
                    backgroundColor: WidgetStateProperty.all(
                        PeeroreumColor.primaryPurple[400]),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
                child: const Text(
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
            const SizedBox(
              height: 21,
            ),
          ],
        ),
      ),
    );
  }
}
