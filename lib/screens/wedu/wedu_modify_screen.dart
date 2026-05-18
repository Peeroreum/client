import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peeroreum_client/widgets/custom_image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:peeroreum_client/model/Wedu.dart';

class ModifyWedu extends StatefulWidget {
  ModifyWedu(
      this.id,
      this.weduTitle,
      this.weduImage,
      this.weduDday,
      this.weduSubject,
      this.weduGrade,
      this.weduAttendingPeopleNum,
      this.weduMaxPeopleNum,
      this.weduHashTags,
      this.weduLocked,
      this.weduPassword,
      {super.key});

  int id;
  dynamic weduTitle = '';
  dynamic weduImage;
  dynamic weduDday = '';
  dynamic weduSubject = '';
  dynamic weduGrade = '';
  dynamic weduAttendingPeopleNum = '';
  dynamic weduMaxPeopleNum = '';
  List<dynamic> weduHashTags = [];
  dynamic weduLocked = false;
  dynamic weduPassword = '';

  @override
  State<ModifyWedu> createState() => _ModifyWeduState(
      id,
      weduTitle,
      weduImage,
      weduDday,
      weduSubject,
      weduGrade,
      weduAttendingPeopleNum,
      weduMaxPeopleNum,
      weduHashTags,
      weduLocked,
      weduPassword);
}

List<int> headcount = <int>[10, 30, 50, 70, 100];
const List<String> subject = <String>[
  '전체',
  '국어',
  '영어',
  '수학',
  '사회',
  '과학',
  '기타',
  '대학'
];
const List<String> grade = <String>[
  '전체',
  '중1',
  '중2',
  '중3',
  '고1',
  '고2',
  '고3',
  '대학'
];

class _ModifyWeduState extends State<ModifyWedu> {
  _ModifyWeduState(
      this.id,
      this.weduTitle,
      this.weduImage,
      this.weduDday,
      this.weduSubject,
      this.weduGrade,
      this.weduAttendingPeopleNum,
      this.weduMaxPeopleNum,
      this.weduHashTags,
      this.weduLocked,
      this.weduPassword);

  int id;
  dynamic weduTitle;
  dynamic weduImage;
  dynamic weduDday;
  dynamic weduSubject;
  dynamic weduGrade;
  dynamic weduAttendingPeopleNum;
  dynamic weduMaxPeopleNum;
  List<dynamic> weduHashTags;
  dynamic weduLocked;
  dynamic weduPassword;

  late DateTime date = DateTime.now().add(Duration(days: weduDday));

  Wedu wedu = Wedu();
  late int dropdownHeadcount;

  final int maxName = 16;
  final int maxPassword = 6;

  late TextfieldTagsController<String> _controller;
  late TextEditingController pwController;

  Color _nextColor = PeeroreumColor.gray[500]!;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    pwController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController<String>();
    pwController = TextEditingController(text: weduPassword);
    weduPassword ??= '';
    checkLocked();
    for (int i = 0; i < headcount.length; i++) {
      if (weduMaxPeopleNum == headcount[i]) {
        dropdownHeadcount = headcount[i];
      }
    }
  }

  void checkLocked() {
    if (weduPassword != "") {
      weduLocked = true;
    }
    if (weduPassword == "") {
      weduLocked = false;
    }
  }

  void checkValidation() {
    if ((weduImage != _image ||
            weduMaxPeopleNum != dropdownHeadcount ||
            weduHashTags != "") &&
        (weduLocked == false || (weduLocked == true && weduPassword != ""))) {
      setState(() {
        _nextColor = PeeroreumColor.primaryPuple[400]!;
      });
    } else {
      setState(() {
        _nextColor = PeeroreumColor.gray[500]!;
      });
    }
  }

  XFile? _image;

  Future getImage() async {
    final selected = await showCustomImagePicker(context, multiple: false);
    if (selected == null || selected.isEmpty) return;
    final cropped = await cropImage(context, selected.first);
    if (cropped != null) {
      setState(() {
        _image = cropped;
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
        backgroundColor: PeeroreumColor.white,
        appBar: appbarWidget(),
        body: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            child: bodyWidget(),
          ),
        ),
      ),
    );
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
        onPressed: () {
          Get.back();
        },
      ),
      title: const Text(
        '같이방 설정',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          color: PeeroreumColor.black,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {
            if (_nextColor == PeeroreumColor.primaryPuple[400]) {
              fetchWedu();
            } else {
              return;
            }
          },
          child: Text(
            '저장',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: _nextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            imageWidget(),
            const SizedBox(
              height: 20,
            ),
            Container(
              alignment: const Alignment(0.0, 0.0),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget(),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      subjectWidget(),
                      Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: dDayWidget()),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      gradeWidget(),
                      Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: maxPeopleWidget()),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hashTagWidget(),
                      const SizedBox(
                        height: 20,
                      ),
                      passwordWidget(),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageWidget() {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 120,
        maxWidth: 120,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: PeeroreumColor.gray[100]!,
          width: 2,
        ),
        color: PeeroreumColor.gray[50],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _image != null
                  ? Image.file(
                      File(_image!.path),
                      fit: BoxFit.cover,
                    )
                  : weduImage != null
                      ? Image.network(
                          weduImage,
                          fit: BoxFit.cover,
                        )
                      : SvgPicture.asset(
                          'assets/images/default.svg',
                          fit: BoxFit.cover,
                        ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                getImage();
                checkValidation();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PeeroreumColor.gray[200],
                  border: Border.all(
                    color: PeeroreumColor.gray[100]!,
                    width: 1,
                  ),
                ),
                child: SvgPicture.asset('assets/icons/camera.svg'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget titleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '같이방 이름',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                fillColor: PeeroreumColor.gray[100],
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: PeeroreumColor.gray[200]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: PeeroreumColor.gray[200]!,
                    )),
                hintText: weduTitle,
                helperText: '같이방 이름은 만든 후에 변경할 수 없어요.',
                helperStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  color: PeeroreumColor.black,
                ),
                counterText: '${weduTitle.length} / $maxName',
                counterStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600]!)),
          ),
        ),
      ],
    );
  }

  Widget subjectWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '목표 과목',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: PeeroreumColor.black,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: PeeroreumColor.gray[100],
            border: Border.all(color: PeeroreumColor.gray[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            height: 40,
            width: 146,
            child: Row(
              children: [
                Text(
                  subject[weduSubject ?? 0],
                  style: const TextStyle(
                      color: PeeroreumColor.black,
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                SvgPicture.asset('assets/icons/down.svg'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget dDayWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '목표 종료일',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          width: 152,
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: PeeroreumColor.gray[100],
            border: Border.all(color: PeeroreumColor.gray[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/calendar.svg'),
              const SizedBox(width: 8.0),
              Text(
                '$date'.substring(0, 10),
                style: const TextStyle(
                    color: PeeroreumColor.black,
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              SvgPicture.asset('assets/icons/down.svg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget gradeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '학년',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
              border: Border.all(color: PeeroreumColor.gray[200]!),
              borderRadius: BorderRadius.circular(8),
              color: PeeroreumColor.gray[100]),
          child: Container(
            height: 40,
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Text(
                  grade[weduGrade],
                  style: const TextStyle(
                    color: PeeroreumColor.black,
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                SvgPicture.asset('assets/icons/down.svg'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget maxPeopleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '인원',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: PeeroreumColor.gray[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 40,
            width: 80,
            child: DropdownButton2(
              dropdownStyleData: DropdownStyleData(
                elevation: 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PeeroreumColor.gray[200]!),
                  color: PeeroreumColor.white,
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 44,
              ),
              underline: const SizedBox.shrink(),
              value: dropdownHeadcount,
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                height: 40,
                width: 80,
              ),
              iconStyleData: IconStyleData(
                icon: SvgPicture.asset('assets/icons/down.svg'),
              ),
              items: headcount.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    "$value",
                    style: const TextStyle(
                      color: PeeroreumColor.black,
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? value) {
                if (weduAttendingPeopleNum > value) {
                  PeeroreumToast.show(context, '참여중인 인원보다 적은 인원은 선택할 수 없어요.',
                      isError: true);
                } else {
                  setState(() {
                    dropdownHeadcount = value!;
                    checkValidation();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget hashTagWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('같이방 해시태그',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          height: 70,
          width: double.infinity,
          child: TextFieldTags(
            textfieldTagsController: _controller,
            initialTags: weduHashTags.cast<String>(),
            textSeparators: const [' '],
            validator: (String tag) {
              if (_controller.getTags!.contains(tag)) {
                return 'you already entered that';
              } else if (_controller.getTags!.length >= 5) {
                PeeroreumToast.show(context, '해시태그는 최대 5개까지 적을 수 있어요.',
                    isError: true);
                return '태그 5개 제한';
              } else {
                weduHashTags.add(tag);
                return null;
              }
            },
            inputFieldBuilder: (context, inputFieldValues) {
              return TextField(
                controller: inputFieldValues.textEditingController,
                focusNode: inputFieldValues.focusNode,
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: PeeroreumColor.gray[200]!,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: PeeroreumColor.black,
                      width: 1.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: PeeroreumColor.error,
                    ),
                  ),
                  helperText: '띄어쓰기로 각 키워드를 구분해 주세요.',
                  helperStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: (inputFieldValues.tags.isNotEmpty)
                      ? "#피어오름"
                      : "#피어오름 #오르미",
                  hintStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  prefixIconConstraints:
                      const BoxConstraints(maxWidth: 350 * 0.8),
                  prefixIcon: inputFieldValues.tags.isNotEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          controller: inputFieldValues.tagScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: inputFieldValues.tags.map((String tag) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: PeeroreumColor.primaryPuple[400]!),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: Colors.transparent,
                              ),
                              margin: const EdgeInsets.only(right: 5.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0, vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '#',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: PeeroreumColor
                                                  .primaryPuple[200],
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' $tag',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: PeeroreumColor
                                                  .primaryPuple[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {},
                                  ),
                                  const SizedBox(width: 4.0),
                                  InkWell(
                                    child: Icon(
                                      Icons.cancel,
                                      size: 16.0,
                                      color: PeeroreumColor.gray[200]!,
                                    ),
                                    onTap: () {
                                      inputFieldValues.onTagDelete(tag);
                                      weduHashTags.remove(tag);
                                    },
                                  )
                                ],
                              ),
                            );
                          }).toList()),
                        )
                      : null,
                ),
                onChanged: inputFieldValues.onChanged,
                onSubmitted: inputFieldValues.onSubmitted,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget passwordWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '같이방 잠금 여부',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: PeeroreumColor.black),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  '잠금 시 비밀번호를 아는 친구만 함께 할 수 있어요.',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: PeeroreumColor.gray[600]),
                )
              ],
            ),
            CupertinoSwitch(
                activeColor: const Color(0xff7260f8),
                value: weduLocked,
                onChanged: (bool value) {
                  setState(() {
                    weduLocked = value;
                    checkValidation();
                  });
                }),
          ],
        ),
        Visibility(
            maintainState: true,
            maintainAnimation: true,
            visible: weduLocked,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text('비밀번호'),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                      controller: pwController,
                      inputFormatters: [
                        FilteringTextInputFormatter(
                          RegExp('[a-z A-Z 0-9]'),
                          allow: true,
                        )
                      ],
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: PeeroreumColor.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: PeeroreumColor.gray[200]!,
                              )),
                          hintText: '비밀번호를 입력하세요',
                          helperText: '비밀번호는 영문 또는 숫자만 설정 가능해요.',
                          counterText: "${weduPassword.length} / $maxPassword",
                          hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.gray[600]),
                          helperStyle: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          counterStyle: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          )),
                      maxLength: maxPassword,
                      onChanged: (value) {
                        setState(() {
                          weduPassword = value;
                          checkValidation();
                        });
                      }),
                )
              ],
            )),
      ],
    );
  }

  void fetchWedu() async {
    var file;
    var weduMap = <String, dynamic>{
      'maximumPeople': dropdownHeadcount,
      'hashTags': weduHashTags,
      'isLocked': weduLocked ? 1 : 0,
      'password': weduPassword,
    };
    if (_image != null) {
      file = await dio.MultipartFile.fromFile(_image!.path);
      weduMap.addAll({"image": file});
    }
    modifyAPI(weduMap);
  }

  modifyAPI(weduMap) async {
    dio.FormData formData = dio.FormData.fromMap(weduMap);
    var weduModify = await ApiClient().putForm('/wedu/$id', formData);
    if (weduModify.statusCode == 200) {
      PeeroreumToast.show(context, '같이방 수정을 완료했어요.');
      Get.back();
      Get.back();
      Get.back();
      Get.to(() => DetailWedu(id));
    } else {
      print("에러${weduModify.statusCode}");
      PeeroreumToast.show(context, '같이방 수정을 실패했어요.', isError: true);
    }
  }
}
