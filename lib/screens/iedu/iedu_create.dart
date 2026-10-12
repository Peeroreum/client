import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peeroreum_client/widgets/custom_image_picker.dart';
import 'package:peeroreum_client/data/subject.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/designs/peeroreum_typo.dart';
import 'package:peeroreum_client/screens/detail_image.dart';
import 'package:peeroreum_client/screens/iedu/iedu_whiteboard.dart';

class CreateIedu extends StatefulWidget {
  const CreateIedu({super.key});

  @override
  State<CreateIedu> createState() => _CreateIeduState();
}

class _CreateIeduState extends State<CreateIedu> {
  final grades = ['중1', '중2', '중3', '고1', '고2', '고3', '대학'];
  final subjects = Subject.subject;
  final middleSubjects = Subject.middleSubject;
  final highSubjects = Subject.highSubject;
  List<String> detailSubjects = [];
  Color _nextColor = PeeroreumColor.gray[500]!;
  String titleCheck = "";
  String contentCheck = "";
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  String? myGrade;
  int? _grade;
  String? _subject;
  String? _detailSubject;
  int subject = 0;
  int detailSubject = 0;
  late Future initFuture;

  final List<XFile> _images = [];

  FocusNode contentFocusNode = FocusNode();
  Map<String, Color> focusColor = {
    "grade": PeeroreumColor.gray[200]!,
    "subject": PeeroreumColor.gray[200]!,
    "detailSubject": PeeroreumColor.gray[200]!
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFuture = fetchStatus();
  }

  Future<void> fetchStatus() async {
    myGrade = await const FlutterSecureStorage().read(key: "grade");
    // 저장된 학년이 없거나 형식이 다르면 기본값 없이 '선택' 상태로 둠
    final parsed = int.tryParse(myGrade ?? '');
    if (parsed != null && parsed >= 1 && parsed <= grades.length) {
      _grade ??= parsed - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await onBackKey();
          if (shouldPop == true && mounted) Get.back();
        },
        child: Container(
          color: PeeroreumColor.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: PeeroreumColor.white,
              appBar: appbarWidget(),
              body: FutureBuilder<void>(
                  future: initFuture,
                  builder: (context, snapshot) {
                    return bodyWidget();
                  }),
              bottomSheet: bottomWidget(),
            ),
          ),
        ),
      ),
    );
  }

  void checkValidation() {
    if (titleCheck != "" && contentCheck != "") {
      setState(() {
        _nextColor = PeeroreumColor.primaryPurple[400]!;
      });
    } else {
      setState(() {
        _nextColor = PeeroreumColor.gray[500]!;
      });
    }
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      shape: Border(
        bottom: BorderSide(
          color: PeeroreumColor.gray[100]!,
          width: 1,
        ),
      ),
      backgroundColor: PeeroreumColor.white,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        color: PeeroreumColor.black,
        icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        onPressed: () async {
          if (await onBackKey()) {
            Get.back();
          }
        },
      ),
      title: const Text(
        '질문하기',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          color: PeeroreumColor.black,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {
              if (_nextColor == PeeroreumColor.primaryPurple[400]) {
                postIedu();
              } else {
                return;
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '완료',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: _nextColor == PeeroreumColor.primaryPurple[400]
                      ? FontWeight.w600
                      : FontWeight.w400,
                  fontSize: 14,
                  color: _nextColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      child: Column(
        children: [
          dropdownBody(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextFormField(
              controller: titleController,
              maxLines: null,
              style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PeeroreumColor.black),
              cursorColor: PeeroreumColor.gray[600],
              decoration: InputDecoration(
                  hintText: '제목을 입력하세요.',
                  hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.gray[600]!),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none),
              onChanged: (value) {
                titleCheck = value;
                checkValidation();
              },
            ),
          ),
          Container(
            height: 1,
            color: PeeroreumColor.gray[200],
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).requestFocus(contentFocusNode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  TextFormField(
                    controller: contentController,
                    focusNode: contentFocusNode,
                    maxLines: null,
                    minLines: 6,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: PeeroreumColor.gray[600],
                    decoration: InputDecoration(
                        hintText: '궁금했던 학습 질문을 동료에게 물어보세요.',
                        hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600]!),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none),
                    onChanged: (value) {
                      contentCheck = value;
                      checkValidation();
                    },
                  ),
                  if (_images.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: photos(),
                    ),
                  const SizedBox(height: 16),
                  guidance(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  dropdownBody() {
    return Row(
      children: [
        // 학년
        GestureDetector(
          onTap: () {
            setState(() {
              focusColor["grade"] = PeeroreumColor.black;
              if (kDebugMode) {
                print(focusColor["grade"]);
              }
            });
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return gradeSelect();
                }).then((value) {
              setState(() {
                focusColor["grade"] = PeeroreumColor.gray[200]!;
              });
            });
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: focusColor["grade"] ?? PeeroreumColor.gray[200]!,
              ),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Text(
                  _grade != null ? grades[_grade!] : "선택",
                  style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      color: PeeroreumColor.black),
                ),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset('assets/icons/down.svg'),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        // 과목
        AbsorbPointer(
          absorbing: _grade == 6,
          child: GestureDetector(
            onTap: () {
              setState(() {
                focusColor["subject"] = PeeroreumColor.black;
              });
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return subjectSelect();
                  }).then((value) {
                setState(() {
                  focusColor["subject"] = PeeroreumColor.gray[200]!;
                });
              });
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: focusColor["subject"] ?? PeeroreumColor.gray[200]!,
                ),
                color:
                    _grade == 6 ? PeeroreumColor.gray[100] : Colors.transparent,
              ),
              child: Row(
                children: [
                  Text(
                    _subject ?? '과목',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        color: _subject == null
                            ? PeeroreumColor.gray[500]
                            : PeeroreumColor.black),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset(
                    'assets/icons/down.svg',
                    colorFilter: _subject == null
                        ? ColorFilter.mode(
                            PeeroreumColor.gray[500]!, BlendMode.srcIn)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        // 상세 과목
        AbsorbPointer(
          absorbing: _grade == 6,
          child: GestureDetector(
            onTap: () {
              if (_subject != null) {
                setState(() {
                  focusColor["detailSubject"] = PeeroreumColor.black;
                });
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return detailSubjectSelect();
                    }).then((value) {
                  setState(() {
                    focusColor["detailSubject"] = PeeroreumColor.gray[200]!;
                  });
                });
              }
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      focusColor["detailSubject"] ?? PeeroreumColor.gray[200]!,
                ),
                color: (_grade == 6 || _subject == null)
                    ? PeeroreumColor.gray[100]
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Text(
                    _detailSubject ?? '세부 과목',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        color: _subject == null
                            ? PeeroreumColor.gray[400]
                            : _detailSubject == null
                                ? PeeroreumColor.gray[500]
                                : PeeroreumColor.black),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset(
                    'assets/icons/down.svg',
                    colorFilter: _detailSubject == null
                        ? ColorFilter.mode(
                            _subject == null
                                ? PeeroreumColor.gray[400]!
                                : PeeroreumColor.gray[500]!,
                            BlendMode.srcIn)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  gradeSelect() {
    return Container(
      width: double.infinity,
      // 항목 수만큼만 높이를 차지하고, 많으면 최대 높이 안에서 스크롤
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.63,
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
          const SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                '학년',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: grades.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _grade = index;
                          _subject = null;
                          subject = 0;
                          _detailSubject = null;
                          detailSubject = 0;
                          focusColor["grade"] = PeeroreumColor.gray[200]!;
                        });
                        Get.back();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Text(
                          grades[index],
                          style: const TextStyle(
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

  subjectSelect() {
    return Container(
      width: double.infinity,
      // 항목 수만큼만 높이를 차지하고, 많으면 최대 높이 안에서 스크롤
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.63,
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
          const SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                '과목',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _subject = subjects[index];
                          subject = index;
                          detailSubjects = ((index != 0 && _grade! < 3)
                              ? middleSubjects[_subject]
                              : highSubjects[_subject])!;
                          _detailSubject = null;
                          detailSubject = 0;
                          focusColor['subject'] = PeeroreumColor.gray[200]!;
                        });
                        Get.back();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Text(
                          subjects[index],
                          style: const TextStyle(
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

  detailSubjectSelect() {
    return Container(
      width: double.infinity,
      // 항목 수만큼만 높이를 차지하고, 많으면 최대 높이 안에서 스크롤
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.63,
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
          const SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                '세부 과목',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: detailSubjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _detailSubject = detailSubjects[index];
                          detailSubject = index;
                          if (kDebugMode) {
                            print(
                                '_detailSubject = $_detailSubject, detailSubject = $detailSubject');
                          }
                        });
                        Get.back();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Text(
                          detailSubjects[index],
                          style: const TextStyle(
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

  Widget guidance() {
    const items = [
      '비방, 욕설을 포함하는 글',
      '무료 행사를 포함한 홍보 목적의 글',
      '기타 오프라인 모임 조장 목적의 글',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: PeeroreumColor.gray[50],
        border: Border.all(color: PeeroreumColor.gray[100]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '게시판 성격과 맞지 않는 글은 작성할 수 없어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: PeeroreumColor.gray[700],
            ),
          ),
          for (final item in items) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/x_circle.svg',
                  colorFilter: ColorFilter.mode(
                      PeeroreumColor.gray[600]!, BlendMode.srcIn),
                ),
                const SizedBox(width: 4),
                C1r(text: item, color: PeeroreumColor.gray[600]),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget photos() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => ImageDetail(
                        imageList: _images,
                        initialPage: index,
                      ));
                },
                child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    width: 1,
                    color: PeeroreumColor.gray[100]!,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(_images[index].path)),
                  ),
                ),
              ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _images.removeAt(index);
                    });
                  },
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      'assets/icons/x_circle.svg',
                      colorFilter: ColorFilter.mode(
                          PeeroreumColor.black.withValues(alpha: 0.45),
                          BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget bottomWidget() {
    return SizedBox(
      height: 57,
      child: Column(
        children: [
          Container(
            color: PeeroreumColor.gray[100],
            height: 1,
          ),
          Container(
            color: PeeroreumColor.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_images.length < 5) {
                      takeFromGallery();
                    } else {
                      PeeroreumToast.show(context, '사진 첨부는 5장까지 가능해요.',
                          isError: true);
                    }
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/camera.svg',
                        colorFilter: ColorFilter.mode(
                            PeeroreumColor.gray[700]!, BlendMode.srcIn),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      T4(
                        text: '사진 첨부',
                        color: PeeroreumColor.gray[700],
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${_images.length}',
                              style: TextStyle(
                                color: _images.isNotEmpty
                                    ? PeeroreumColor.primaryPurple[400]
                                    : PeeroreumColor.gray[500],
                                fontWeight: _images.isNotEmpty
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: '/5',
                              style: TextStyle(
                                color: PeeroreumColor.gray[500],
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                GestureDetector(
                  onTap: () async {
                    if (_images.length < 5) {
                      final dynamic whiteboardImage =
                          await Get.to(() => const WhiteboardIedu());
                      setState(() {
                        if (whiteboardImage != null) {
                          _images.add(whiteboardImage);
                        }
                      });
                    } else {
                      PeeroreumToast.show(
                          context, '화이트보드는 첨부한 사진이 5장 미만이어야 쓸 수 있어요.',
                          isError: true);
                    }
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/notepad.svg',
                        colorFilter: ColorFilter.mode(
                            PeeroreumColor.gray[700]!, BlendMode.srcIn),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      T4(
                        text: '화이트보드',
                        color: PeeroreumColor.gray[700],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void takeFromGallery() async {
    final selected = await showCustomImagePicker(
      context,
      multiple: true,
      maxCount: 5 - _images.length,
    );
    if (selected == null || selected.isEmpty) return;
    setState(() {
      if (selected.length + _images.length <= 5) {
        _images.addAll(selected);
      } else {
        PeeroreumToast.show(context, '사진 첨부는 5장까지 가능해요.');
      }
    });
  }

  Future<void> postIedu() async {
    if (_grade == null) {
      PeeroreumToast.show(context, '학년을 선택해 주세요.', isError: true);
      return;
    }
    var ieduMap = <String, dynamic>{
      'title': titleController.text,
      'content': contentController.text,
      'subject': subject + 1,
      'detailSubject': detailSubject + 1,
      'grade': _grade! + 1,
    };

    var formData = dio.FormData.fromMap(ieduMap);

    for (var image in _images) {
      var file = await dio.MultipartFile.fromFile(image.path);
      formData.files.add(MapEntry('files', file));
    }

    try {
      var response = await ApiClient().postForm('/question', formData);

      if (!mounted) return;
      if (response.statusCode == 200) {
        PeeroreumToast.show(context, '질문 작성이 완료되었어요.');
        Get.offAllNamed('/home/iedu');
      } else {
        PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print('Dio error!');
          print('STATUS: ${e.response?.statusCode}');
          print('DATA: ${e.response?.data}');
          print('HEADERS: ${e.response?.headers}');
        }
      } else {
        if (kDebugMode) {
          print('Error sending request!');
          print(e.message);
        }
      }
      if (!mounted) return;
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      if (!mounted) return;
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
    }
  }

  onBackKey() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "글쓰기를 종료하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "작성하신 내용이 삭제됩니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back(result: true);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.primaryPurple[400],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
