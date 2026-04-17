// ignore_for_file: prefer_const_constructors, deprecated_member_use, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/data/Subject.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
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
  List<String> DetailSubjects = [];
  Color _nextColor = PeeroreumColor.gray[500]!;
  String titleCheck = "";
  String contentCheck = "";
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  var token;
  var my_grade;
  int? _grade;
  String? _subject;
  String? _detailSubject;
  int subject = 0;
  int detailSubject = 0;
  late Future initFuture;

  final ImagePicker picker = ImagePicker();
  List<XFile> _images = [];

  FocusNode ContentFocusNode = FocusNode();
  Map<String, Color> focusColor = {
    "grade": PeeroreumColor.gray[200]!,
    "subjet": PeeroreumColor.gray[200]!,
    "detailSubject": PeeroreumColor.gray[200]!
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFuture = fetchStatus();
  }

  Future<void> fetchStatus() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    my_grade = await FlutterSecureStorage().read(key: "grade");
    _grade ??= int.parse(my_grade!) - 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          return await onBackKey();
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

  void check_validation() {
    if (titleCheck != "" && contentCheck != "") {
      setState(() {
        _nextColor = PeeroreumColor.primaryPuple[400]!;
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
      title: Text(
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
          padding: EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {
              if (_nextColor == PeeroreumColor.primaryPuple[400]) {
                postIedu();
              } else {
                return;
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '완료',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
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
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          dropdown_body(),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: TextFormField(
              controller: titleController,
              maxLines: null,
              style: TextStyle(color: Colors.black),
              cursorColor: PeeroreumColor.gray[600],
              decoration: InputDecoration(
                  hintText: '제목을 입력하세요.',
                  hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: PeeroreumColor.gray[600]!),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none),
              onChanged: (value) {
                titleCheck = value;
                check_validation();
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
              FocusScope.of(context).requestFocus(ContentFocusNode);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  TextFormField(
                    controller: contentController,
                    focusNode: ContentFocusNode,
                    maxLines: null,
                    minLines: 6,
                    style: TextStyle(color: Colors.black),
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
                      check_validation();
                    },
                  ),
                  if (contentController.text == "") guidance(),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 16, 0, 40),
                    child: photos(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  dropdown_body() {
    return Row(
      children: [
        // 학년
        GestureDetector(
          onTap: () {
            setState(() {
              focusColor["grade"] = PeeroreumColor.black;
              print(focusColor["grade"]);
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  _grade != null
                      ? grades[_grade!]
                      : my_grade != null
                          ? grades[int.parse(my_grade!)]
                          : "선택",
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      color: PeeroreumColor.black),
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
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    _subject ?? '선택',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        color: PeeroreumColor.black),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset('assets/icons/down.svg'),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
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
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      focusColor["detailSubject"] ?? PeeroreumColor.gray[200]!,
                ),
                color:
                    _grade == 6 ? PeeroreumColor.gray[100] : Colors.transparent,
              ),
              child: Row(
                children: [
                  Text(
                    _detailSubject ?? '선택',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        color: PeeroreumColor.black),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset('assets/icons/down.svg'),
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
      height: MediaQuery.of(context).size.height * 0.63,
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
                '학년',
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          grades[index],
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

  subjectSelect() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.63,
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
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _subject = subjects[index];
                          subject = index;
                          DetailSubjects = ((index != 0 && _grade! < 3)
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          subjects[index],
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

  detailSubjectSelect() {
    return Container(
      width: double.infinity,
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
                itemCount: DetailSubjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _detailSubject = DetailSubjects[index];
                          detailSubject = index;
                          print(
                              '_detailSubject = $_detailSubject, detailSubject = $detailSubject');
                        });
                        Get.back();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(
                          DetailSubjects[index],
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

  Widget guidance() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          B4_14px_R(
            text: '게시판 성격과 맞지 않는 글은 작성할 수 없어요.',
            color: PeeroreumColor.gray[600],
          ),
          Container(
            height: 12,
          ),
          Row(
            children: [
              SizedBox(
                child: SvgPicture.asset(
                  'assets/icons/x_circle.svg',
                  color: PeeroreumColor.gray[600],
                ),
              ),
              SizedBox(
                width: 4,
              ),
              C1_12px_R(
                text: '비방, 욕설을 포함하는 글',
                color: PeeroreumColor.gray[600],
              ),
            ],
          ),
          Container(
            height: 8,
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/x_circle.svg',
                color: PeeroreumColor.gray[600],
              ),
              SizedBox(
                width: 4,
              ),
              C1_12px_R(
                text: '무료 행사를 포함한 홍보 목적의 글',
                color: PeeroreumColor.gray[600],
              ),
            ],
          ),
          Container(
            height: 8,
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/x_circle.svg',
                color: PeeroreumColor.gray[600],
              ),
              SizedBox(
                width: 4,
              ),
              C1_12px_R(
                text: '기타 오프라인 모임 조장 목적의 글',
                color: PeeroreumColor.gray[600],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget photos() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.94 / 1,
        mainAxisSpacing: 8,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _images.length,
      itemBuilder: (BuildContext context, int index) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    width: 1,
                    color: PeeroreumColor.gray[100]!,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(_images[index].path)),
                  )),
            ),
            GestureDetector(
              child: Container(
                width: 24,
                height: 24,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: SvgPicture.asset(
                  'assets/icons/x_circle.svg',
                  color: PeeroreumColor.black.withOpacity(0.4),
                ),
              ),
              onTap: () {
                setState(() {
                  _images.remove(_images[index]);
                });
              },
            ),
          ],
        );
      },
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
            color: PeeroreumColor.gray[50],
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                        color: PeeroreumColor.gray[500],
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      T4_16px(
                        text: '사진 첨부',
                        color: PeeroreumColor.gray[500],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                GestureDetector(
                  onTap: () async {
                    if (_images.length < 5) {
                      final dynamic whiteboardImage =
                          await Get.to(() => WhiteboardIedu());
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
                        color: PeeroreumColor.gray[500],
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      T4_16px(
                        text: '화이트 보드',
                        color: PeeroreumColor.gray[500],
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
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      setState(() {
        if (selectedImages.length + _images.length < 6) {
          _images.addAll(selectedImages);
        } else {
          PeeroreumToast.show(context, '사진 첨부는 5장까지 가능해요.');
        }
      });
    }
  }

  Future<void> postIedu() async {
    var IeduMap = <String, dynamic>{
      'title': titleController.text,
      'content': contentController.text,
      'subject': subject + 1,
      'detailSubject': detailSubject + 1,
      'grade': _grade! + 1,
    };

    var dio1 = dio.Dio();
    var formData = dio.FormData();

    dio1.options.contentType = 'multipart/form-data';
    dio1.options.headers = {'Authorization': 'Bearer $token'};
    formData = dio.FormData.fromMap(IeduMap);

    for (var image in _images) {
      var file = await dio.MultipartFile.fromFile(image.path);
      formData.files.add(MapEntry('files', file));
    }

    var response =
        await dio1.post('${API.hostConnect}/question', data: formData);

    if (response.statusCode == 200) {
      PeeroreumToast.show(context, '질문 작성이 완료되었어요.');
      Get.offAllNamed('/home/iedu');
    } else {
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
    }
  }

  onBackKey() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          contentPadding: EdgeInsets.all(20),
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
                SizedBox(
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
                SizedBox(
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
                          backgroundColor: PeeroreumColor.gray[300], // 배경 색상
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16), // 패딩
                          shape: RoundedRectangleBorder(
                            // 모양
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
                    SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back(result: true);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.primaryPuple[400],
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
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
