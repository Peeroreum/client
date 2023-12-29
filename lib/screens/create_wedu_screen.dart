import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:peeroreum_client/model/Wedu.dart';


DateTime date = DateTime.now().add(const Duration(days:66));
const List<String> subject = <String>['전체', '국어', '영어', '수학', '사회', '과학','한국사', '기타'];
const List<String> grade = <String>['중1', '중2', '중3', '고1', '고2', '고3'];
const List<int> headcount = <int>[10, 30, 50, 70, 100];
//const List<String> gender = <String>['전체', '여자', '남자'];
List<String> challenge = <String>['문제 30개 풀기', '공부 2시간' ,'기타'];
List<String> _tag = [];

class CreateWedu extends StatefulWidget {
  CreateWedu({super.key});

  @override
  State<CreateWedu> createState() => _CreateWeduState();
}

class _CreateWeduState extends State<CreateWedu> {
  Wedu wedu = Wedu();
  String dropdownSubject = subject.first;
  String dropdownGrade = grade.first;
  int dropdownHeadcount = headcount.first;
  //String dropdownGender = gender.first;
  String? dropdownChallenge;

  bool _isLocked = false;

  final int maxName = 16;
  final int maxPassword = 6;
  String nameValue = "";
  String passwordValue = "";

  String personalChallenge="";

  late TextfieldTagsController _controller;

  Color _nextColor = PeeroreumColor.gray[500]!;

  void check_validation(){
     if (nameValue != "" &&
      ((dropdownChallenge != null && dropdownChallenge !=challenge.last) || (dropdownChallenge == challenge.last && personalChallenge != "")) && 
      (_isLocked == false || (_isLocked == true && passwordValue !=""))) {
                setState(() {
                  _nextColor=PeeroreumColor.primaryPuple[400]!;
                });
              }
  
      else{
        setState(() {
          _nextColor = PeeroreumColor.gray[500]!;
        });
      }
  }

  void check_subject(value){
    switch(value){
        case '국어': challenge.insert(2, '지문 분석');
          break;
        case '영어': challenge.insert(2, '단어 암기');
          break;
        case '수학': challenge.insert(2, '오답 노트');
          break;
        case '사회':
        case '과학':
        case '한국사':
        case '기타': challenge.insert(2, '개념 공부(노트 필기)');
          break;
        default:
        break;
      }
  }

  void change_challenge(value){
    if (challenge.length==3){
      check_subject(value);
    }
    else if(challenge.length==4){
      challenge.removeAt(2);
      check_subject(value);
    }
  }

  XFile? _image; //이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장        
      });
    }
  }
  

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController();
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
          elevation: 0.7,
          backgroundColor: PeeroreumColor.white,
          leading: IconButton(
            color: PeeroreumColor.black,
            icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '같이방 만들기',
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
                if (nameValue != "" && (dropdownChallenge != null)) {
                  fetchWedu();
                } else {
                  return;
                }
              },
              child: Text(
                '다음',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: _nextColor,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(
                  maxHeight: 120,
                  maxWidth: 120,
                ),
                decoration: _image != null
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PeeroreumColor.gray[50]!,
                          width: 1,
                        ),
                        image: DecorationImage(
                          image: FileImage(File(_image!.path)),
                          fit: BoxFit.cover,
                        ),
                      )
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: PeeroreumColor.gray[50],
                        border: Border.all(
                          color: PeeroreumColor.gray[100]!,
                          width: 1,
                        ),
                      ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    getImage(ImageSource.gallery);
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
                      child:  SvgPicture.asset('assets/icons/camera.svg')
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment(0.0, 0.0),
                margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Column(
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
                            width: 350,
                            child: TextFormField(
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
                                  hintText: '같이방 이름을 입력하세요',
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
                                    color: PeeroreumColor.gray[600]!,
                                  ),
                                  counterText: '${nameValue.length} / $maxName',
                                  counterStyle: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: PeeroreumColor.gray[600]!)),
                              maxLength: maxName,
                              onChanged: (value) {
                                setState(() {
                                  nameValue = value;
                                  check_validation();
                                });
                              },
                            ),
                          ),
                        ],
                      )),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Column(
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
                                  border: Border.all(
                                      color: PeeroreumColor.gray[200]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  width: 146,
                                  child: DropdownButton(
                                    isExpanded: true,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    underline: SizedBox.shrink(),
                                    value: dropdownSubject,
                                    iconSize: 18,
                                    icon: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: SvgPicture.asset('assets/icons/down.svg'),
                                    ),
                                    items: subject.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color: PeeroreumColor.black,
                                            fontFamily: 'Pretendard',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        dropdownSubject = value!;
                                        change_challenge(value);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Column(
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
                                SizedBox(
                                  width: 152,
                                  height: 40,
                                  child: InkWell(
                                    onTap: () async {
                                      final selectedDate = await showDatePicker(
                                        context:
                                            context, // 팝업으로 띄우기 때문에 context 전달
                                        initialDate: DateTime.now().add(Duration(
                                            days:
                                                66)), // 달력을 띄웠을 때 선택된 날짜. 위에서 date 변수에 오늘 날짜를 넣었으므로 오늘 날짜가 선택돼서 나옴
                                        firstDate: DateTime.now().add(Duration(
                                            days:
                                                66)), // 시작 년도
                                        lastDate: DateTime.now()
                                            .add(Duration(days: 3 * 365)),
                                      );
                                      if (selectedDate != null) {
                                        setState(() {
                                          date = selectedDate;// 선택한 날짜는 date 변수에 저장
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: PeeroreumColor.gray[200]!,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset('assets/icons/calendar.svg'),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                '$date'.substring(0, 10),
                                                style: const TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: PeeroreumColor.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // const SizedBox(width: 8.0),
                                          SvgPicture.asset('assets/icons/down.svg'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Column(
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
                                  border: Border.all(
                                      color: PeeroreumColor.gray[200]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  width: 80,
                                  child: DropdownButton(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    underline: SizedBox.shrink(),
                                    value: dropdownGrade,
                                    iconSize: 18,
                                    icon: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: SvgPicture.asset('assets/icons/down.svg'),
                                    ),
                                    items: grade.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color: PeeroreumColor.black,
                                            fontFamily: 'Pretendard',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        dropdownGrade = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Column(
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
                                  border: Border.all(
                                      color: PeeroreumColor.gray[200]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  width: 80,
                                  child: DropdownButton(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    underline: SizedBox.shrink(),
                                    value: dropdownHeadcount,
                                    iconSize: 18,
                                    icon: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: SvgPicture.asset('assets/icons/down.svg'),
                                    ),
                                    items: headcount.map<DropdownMenuItem<int>>(
                                        (int value) {
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
                                      setState(() {
                                        dropdownHeadcount = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              ],
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('챌린지 설정',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              )),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: PeeroreumColor.gray[200]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        hint: Text('챌린지를 설정하세요',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 12),
                                        underline: SizedBox.shrink(),
                                        value: dropdownChallenge,
                                        iconSize: 18,
                                        icon: Container(
                                          child: SvgPicture.asset('assets/icons/down.svg'),
                                        ),
                                        items: challenge.map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                color: PeeroreumColor.black,
                                                fontFamily: 'Pretendard',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            dropdownChallenge = value!;
                                            check_validation();
                                          });

                                        },
                                      ),


                                ),
                          ),

                          Container(
                            child: Visibility(
                              maintainState: true,
                              maintainAnimation: true,
                              visible: dropdownChallenge == challenge.last,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextFormField(
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
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color:
                                                      PeeroreumColor.gray[200]!,
                                                )),
                                            hintText: '챌린지 내용을 입력해 주세요.',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,

                                            )),
                                            onChanged: (value) {
                                setState(() {
                                  personalChallenge = value;
                                  check_validation();
                                });

                              },
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: Column(
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
                                  width: 350,
                                  child: TextFieldTags(
                                    textfieldTagsController: _controller,
                                    initialTags: null,
                                    textSeparators: [' '],
                                    validator: (String tag) {
                                      if (_controller.getTags!.contains(tag))
                                        return 'you already entered that';
                                      else {
                                        _tag.add(tag);
                                        return null;
                                      }
                                    },
                                    inputfieldBuilder: (context, tec, fn, error,
                                        onChanged, onSubmitted) {
                                      return ((context, sc, tags, onTagDelete) {
                                        return TextField(
                                          controller: tec,
                                          focusNode: fn,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: PeeroreumColor.gray[200]!,
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: PeeroreumColor.black,
                                                width: 1.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: PeeroreumColor.error,
                                              ),
                                            ),
                                            helperText:
                                                '띄어쓰기로 각 키워드를 구분해 주세요.',
                                            helperStyle: const TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            hintText: _controller.hasTags
                                                ? "#피어오름"
                                                : "#피어오름 #오르미",
                                            hintStyle: TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                            //errorText: error,
                                            prefixIconConstraints: BoxConstraints(
                                                maxWidth: 350 * 0.8),
                                            prefixIcon: tags.isNotEmpty
                                                ? SingleChildScrollView(
                                                    controller: sc,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                        children: tags
                                                            .map((String tag) {
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: PeeroreumColor
                                                                      .primaryPuple[
                                                                  400]!),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(20.0),
                                                          ),
                                                          color:
                                                              Colors.transparent,
                                                        ),
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 5.0),
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            InkWell(
                                                              child: Text(
                                                                '# $tag',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Pretendard',
                                                                    fontSize: 12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: PeeroreumColor
                                                                            .primaryPuple[
                                                                        400]),
                                                              ),
                                                              onTap: () {
                                                                print(
                                                                    "$tag selected");
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                width: 4.0),
                                                            InkWell(
                                                              child: Icon(
                                                                Icons.cancel,
                                                                size: 16.0,
                                                                color:
                                                                    PeeroreumColor
                                                                            .gray[
                                                                        200]!,
                                                              ),
                                                              onTap: () {
                                                                onTagDelete(tag);
                                                                _tag.remove(tag);
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
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('같이방 잠금 여부'),
                                    const Text(
                                      '잠금시 비밀번호를 아는 친구만 함께 할 수 있어요.',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                                CupertinoSwitch(
                                    activeColor: Color(0xff7260f8),
                                    value: _isLocked,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _isLocked = value;
                                        check_validation();
                                      });

                                    }),
                              ],
                            ),
                          ),
                          Container(
                            child: Visibility(
                                maintainState: true,
                                maintainAnimation: true,
                                visible: _isLocked,
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
                                          inputFormatters: [
                                            FilteringTextInputFormatter(
                                              RegExp('[a-z A-Z 0-9]'),
                                              allow: true,
                                            )
                                          ],
                                          decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: PeeroreumColor.black,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color:
                                                        PeeroreumColor.gray[200]!,
                                                  )),
                                              hintText: '비밀번호를 입력하세요',
                                              helperText:
                                                  '비밀번호는 영문 또는 숫자만 설정 가능해요.',
                                              counterText:
                                                  "${passwordValue.length} / $maxPassword",
                                              hintStyle: TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
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
                                              passwordValue = value;
                                              check_validation();
                                            });

                                          }),
                                    )
                                  ],
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchWedu() async {
    var weduMap = <String, dynamic> {
      'title': nameValue,
      'subject': subject.indexOf(dropdownSubject),
      'targetDate': '$date'.substring(0, 10),
      'grade': grade.indexOf(dropdownGrade),
      'maximumPeople':dropdownHeadcount,
      'challenge': dropdownChallenge,
      'isLocked': _isLocked? 1 : 0,
      'password': passwordValue,
      'hashTags': _tag
    };
    if(_image != null) {
      weduMap.addAll({
        'file': MultipartFile.fromFile(_image!.path)
      });
    }
    Navigator.pushNamed(context, '/wedu/create_invitaion', arguments: weduMap);
  }
}
