// ignore_for_file: prefer_const_constructors, no_logic_in_create_state, must_be_immutable, avoid_init_to_null, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:peeroreum_client/model/Wedu.dart';
import 'package:http/http.dart' as http;

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
  dynamic weduImage = null;
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
const List<String> subject = <String>['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
const List<String> grade = <String>['전체', '중1', '중2', '중3', '고1', '고2', '고3'];

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

  var token;
  late DateTime date = DateTime.now().add(Duration(days: weduDday));

  Wedu wedu = Wedu();
  late int dropdownHeadcount;

  final int maxName = 16;
  final int maxPassword = 6;

  late TextfieldTagsController _controller;
  late TextEditingController pw_controller;

  Color _nextColor = PeeroreumColor.gray[500]!;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    pw_controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController();
    pw_controller = TextEditingController(text: weduPassword);
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

  void check_validation() {
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
  final ImagePicker picker = ImagePicker();
  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
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
        body: bodyWidget(),
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
          Navigator.pop(context);
        },
      ),
      title: Text(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            imageWidget(),
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment(0.0, 0.0),
              margin: EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget(),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      subjectWidget(),
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          child: DdayWidget()),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      gradeWidget(),
                      Container(
                          margin: EdgeInsets.only(left: 20),
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
      padding: EdgeInsets.all(4),
      constraints: BoxConstraints(
        maxHeight: 120,
        maxWidth: 120,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: PeeroreumColor.gray[50]!,
            width: 1,
          ),
          image: weduImage != null
              ? _image != null
                  ? DecorationImage(
                      image: FileImage(File(_image!.path)),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: NetworkImage(weduImage),
                      fit: BoxFit.cover,
                    )
              : _image != null
                  ? DecorationImage(
                      image: FileImage(File(_image!.path)),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage(
                        'assets/images/wedu_default_image.png',
                      ),
                      fit: BoxFit.cover,
                    )),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          getImage(ImageSource.gallery);
          check_validation();
        },
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PeeroreumColor.gray[200],
                border: Border.all(
                  color: PeeroreumColor.gray[100]!,
                  width: 1,
                ),
              ),
              child: SvgPicture.asset('assets/icons/camera.svg')),
        ),
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
        SizedBox(
          height: 8,
        ),
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                hintStyle: TextStyle(
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
        SizedBox(
          height: 8,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: PeeroreumColor.gray[100],
            border: Border.all(color: PeeroreumColor.gray[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            height: 40,
            width: 146,
            child: Row(
              children: [
                Text(
                  subject[weduSubject ?? 0],
                  style: TextStyle(
                      color: PeeroreumColor.black,
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                Spacer(),
                SvgPicture.asset('assets/icons/down.svg'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget DdayWidget() {
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
        SizedBox(
          height: 8,
        ),
        Container(
          width: 152,
          height: 40,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                style: TextStyle(
                    color: PeeroreumColor.black,
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
              Spacer(),
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
        Text(
          '학년',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
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
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Text(
                  grade[weduGrade],
                  style: TextStyle(
                    color: PeeroreumColor.black,
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Spacer(),
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
              menuItemStyleData: MenuItemStyleData(
                height: 44,
              ),
              underline: SizedBox.shrink(),
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
                    style: TextStyle(
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
                  Fluttertoast.showToast(msg: '참여중인 인원보다 적은 인원은 선택할 수 없습니다.');
                } else {
                  setState(() {
                    dropdownHeadcount = value!;
                    check_validation();
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
                Fluttertoast.showToast(msg: '해시태그는 최대 5개까지 적을 수 있어요.');
                return '태그 5개 제한';
              } else {
                weduHashTags.add(tag);
                return null;
              }
            },
            inputfieldBuilder:
                (context, tec, fn, error, onChanged, onSubmitted) {
              return ((context, sc, tags, onTagDelete) {
                return TextField(
                  //scrollPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  controller: tec,
                  focusNode: fn,
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
                      borderSide: BorderSide(
                        color: PeeroreumColor.black,
                        width: 1.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: PeeroreumColor.error,
                      ),
                    ),
                    helperText: '띄어쓰기로 각 키워드를 구분해 주세요.',
                    helperStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    hintText: _controller.hasTags ? "#피어오름" : "#피어오름 #오르미",
                    hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                    prefixIconConstraints: BoxConstraints(maxWidth: 350 * 0.8),
                    prefixIcon: tags.isNotEmpty
                        ? SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            controller: sc,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: tags.map((String tag) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: PeeroreumColor.primaryPuple[400]!),
                                  borderRadius: BorderRadius.all(
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
                                        onTagDelete(tag);
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
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                );
              });
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
                SizedBox(
                  height: 8,
                ),
                Text(
                  '잠금시 비밀번호를 아는 친구만 함께 할 수 있어요.',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: PeeroreumColor.gray[600]),
                )
              ],
            ),
            CupertinoSwitch(
                activeColor: Color(0xff7260f8),
                value: weduLocked,
                onChanged: (bool value) {
                  setState(() {
                    weduLocked = value;
                    check_validation();
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
                SizedBox(
                  height: 20,
                ),
                Text('비밀번호'),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                      controller: pw_controller,
                      inputFormatters: [
                        FilteringTextInputFormatter(
                          RegExp('[a-z A-Z 0-9]'),
                          allow: true,
                        )
                      ],
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: OutlineInputBorder(
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
                          check_validation();
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
      file = await MultipartFile.fromFile(_image!.path);
      weduMap.addAll({"image": file});
    }
    modifyAPI(weduMap);
  }

  modifyAPI(weduMap) async {
    var dio = Dio();
    final token = await const FlutterSecureStorage().read(key: "accessToken");
    FormData formData = FormData.fromMap(weduMap);
    dio.options.contentType = 'multipart/form-data';
    dio.options.headers = {'Authorization': 'Bearer $token'};
    var weduModify =
        await dio.put('${API.hostConnect}/wedu/$id', data: formData);
    if (weduModify.statusCode == 200) {
      Fluttertoast.showToast(msg: '같이방 수정을 완료했어요.');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DetailWedu(id)));
    } else {
      print("에러${weduModify.statusCode}");
      Fluttertoast.showToast(msg: '같이방 수정 실패');
    }
  }
}
