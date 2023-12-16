// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/create_wedu_screen.dart';
import 'package:peeroreum_client/screens/search_wedu.dart';
import 'package:peeroreum_client/screens/detail_wedu_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class HomeWedu extends StatefulWidget {
  const HomeWedu({super.key});

  @override
  State<HomeWedu> createState() => _HomeWeduState();
}

class _HomeWeduState extends State<HomeWedu> {
  var token;
  int selectedIndex = 1;
  List<dynamic> datas = [];
  List<dynamic> inroom_datas = [];
  List<dynamic> inviDatas = [];
  List<dynamic> hashTags = [];
  List<Map<String, String>> searchData = [];
  List<String> dropdownGradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> dropdownSubjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
  List<String> dropdownSortTypeList = ['최신순', '추천순', '인기순'];
  String selectedGrade = '전체';
  String selectedSubject = '전체';
  String selectedSortType = '최신순';

  var grade = 0;
  var subject = 0;

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "memberInfo");
    var weduResult = await http.get(
        Uri.parse('${API.hostConnect}/wedu?sort=$selectedSortType&grade=$grade&subject=$subject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (weduResult.statusCode == 200) {
      datas = jsonDecode(utf8.decode(weduResult.bodyBytes))['data'];
    } else {
      print("에러${weduResult.statusCode}");
    }
    var inWeduResult = await http.get(Uri.parse('${API.hostConnect}/wedu/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (inWeduResult.statusCode == 200) {
      inroom_datas = jsonDecode(utf8.decode(inWeduResult.bodyBytes))['data'];
    } else {
      print("에러${weduResult.statusCode}");
    }

    await fetchImage(datas);
  }

  fetchImage(datas) async {
    var inviData;
    for (var data in datas) {
      inviData = await fetchInvitation(data['id']);
      inviDatas.add(inviData);
      hashTags.add(inviData['hashTags']);
    }
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      // systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => searchWedu()));
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: PeeroreumColor.gray[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(37.0))),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/search.svg',
                          color: PeeroreumColor.gray[600],
                        ),
                        SizedBox(width: 8.0),
                        SizedBox(
                          child: Text(
                            '같이방에서 함께 공부해요!',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: PeeroreumColor.gray[600]),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.only(right: 4),
                constraints: BoxConstraints(),
                icon: SvgPicture.asset('assets/icons/plus_square.svg',
                    color: PeeroreumColor.gray[800]),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => CreateWedu(),
                        transitionDuration: const Duration(seconds: 0),
                        reverseTransitionDuration: const Duration(seconds: 0)),
                  );
                },
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: SvgPicture.asset(
                  'assets/icons/bell_none.svg',
                  color: PeeroreumColor.gray[800],
                ),
                onPressed: () {},
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Container(
          child: Column(
        children: [
          room_body(),
          (inroom_datas.length != 0)
              ? SizedBox(
                  height: 193, //180으로 나중에 수정
                  child: in_room_body())
              : SizedBox(
                  height: 0,
                ),
          Container(
            height: 8,
            color: PeeroreumColor.gray[50],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('같이방',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard')),
              ],
            ),
          ),
          dropdown_body(),
          Expanded(child: listview_body())
        ],
      )),
    );
  }

  Widget room_body() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "참여 중인 같이방",
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  '${inroom_datas.length}',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            // TextButton(
            //     onPressed: () {
            //       Navigator.of(context)
            //           .push(MaterialPageRoute(builder: (context) => InWedu()));
            //     },
            //     child: Text('전체 보기',
            //         style: TextStyle(
            //             fontFamily: 'Pretendard',
            //             fontWeight: FontWeight.w600,
            //             fontSize: 14,
            //             color: PeeroreumColor.gray[500])))
          ],
        ),
      ),
    );
  }

  Widget in_room_body() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: inroom_datas.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
            width: 150,
            padding: EdgeInsets.fromLTRB(8, 20, 8, 16),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: (inroom_datas[index]['imagePath'] != null)
                      ? Image.network(inroom_datas[index]['imagePath']!,
                          width: 48, height: 48)
                      : Image.asset('assets/images/example_logo.png',
                          width: 48, height: 48),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: PeeroreumColor.subjectColor[dropdownSubjectList[
                            inroom_datas[index]['subject']]]?[0],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 8),
                        child: Text(
                          dropdownSubjectList[inroom_datas[index]['subject']],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: PeeroreumColor.subjectColor[
                                dropdownSubjectList[inroom_datas[index]
                                    ['subject']]]?[1],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      width: 98,
                      child: Text(
                        inroom_datas[index]["title"]!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PeeroreumColor.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dropdownGradeList[inroom_datas[index]["grade"]],
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Text('⋅'),
                    ),
                    Text('${inroom_datas[index]["attendingPeopleNum"]!}명 참여중',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Text('⋅'),
                    ),
                    Text('D-${inroom_datas[index]["dday"]!}',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '${inroom_datas[index]["progress"]}% 달성', //이후 퍼센티지 수정
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.primaryPuple[400]),
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailWedu(inroom_datas[index]["id"])));
          },
        );
      },
    );
  }

  Widget dropdown_body() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: PeeroreumColor.gray[100]!, width: 1),
                      borderRadius: BorderRadius.circular(8)),
                  child: SizedBox(
                    width: 75,
                    height: 40,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: DropdownButton(
                          icon: Padding(
                            padding: EdgeInsets.only(left: 7.0), //나중에 수정 8.0
                            child: Icon(Icons.expand_more,
                                color: PeeroreumColor.gray[600]),
                          ),
                          iconSize: 18,
                          underline: SizedBox.shrink(),
                          value: selectedGrade,
                          items: dropdownGradeList.map((String item) {
                            return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ));
                          }).toList(),
                          onChanged: (dynamic value) {
                            setState(() {
                              selectedGrade = value;
                              grade = dropdownGradeList.indexOf(selectedGrade);
                            });
                          }),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: PeeroreumColor.gray[200]!, width: 1),
                      borderRadius: BorderRadius.circular(8)),
                  child: SizedBox(
                    width: 75,
                    height: 40,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: DropdownButton(
                          icon: Padding(
                            padding:
                                const EdgeInsets.only(left: 7.0), //나중에 수정 8.0
                            child: Icon(Icons.expand_more,
                                color: PeeroreumColor.gray[600]),
                          ),
                          iconSize: 18,
                          underline: SizedBox.shrink(),
                          value: selectedSubject,
                          items: dropdownSubjectList.map((String item) {
                            return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(fontSize: 14),
                                ));
                          }).toList(),
                          onChanged: (dynamic value) {
                            setState(() {
                              selectedSubject = value;
                              subject = dropdownSubjectList.indexOf(selectedSubject);
                            });
                          }),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(color: PeeroreumColor.gray[200]!, width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: SizedBox(
              width: 87,
              height: 40,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: DropdownButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 6.0), //나중에 수정 8.0
                    child: Icon(
                      Icons.expand_more,
                      color: PeeroreumColor.gray[600],
                    ),
                  ),
                  iconSize: 18,
                  underline: SizedBox.shrink(),
                  value: selectedSortType,
                  items: dropdownSortTypeList.map((String item) {
                    return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 14),
                        ));
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      selectedSortType = value;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listview_body() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: datas.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: (datas[index]["imagePath"] != null)
                      ? Image.network(datas[index]["imagePath"]!,
                          width: 44, height: 44)
                      : Image.asset('assets/images/example_logo.png',
                          width: 44, height: 44),
                ),
                Container(
                  height: 44,
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                color: PeeroreumColor.subjectColor[
                                    dropdownSubjectList[datas[index]
                                        ['subject']]]?[0],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  dropdownSubjectList[datas[index]['subject']],
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: PeeroreumColor.subjectColor[
                                        dropdownSubjectList[datas[index]
                                            ['subject']]]?[1],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              datas[index]["title"]!,
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Text(dropdownGradeList[datas[index]["grade"]],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('${datas[index]["attendingPeopleNum"]!}명 참여중',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('D-${datas[index]["dday"]!}',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                          ],
                        )
                      ]),
                )
              ],
            ),
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              isScrollControlled: true,
              builder: (context) {
                return roominfo(index);
              },
            );
          },
        );
      },
    );
  }

  Widget roominfo(index) {
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.55,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: PeeroreumColor.gray[200]!),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Image.network(datas[index]["imagePath"]!,
                            width: 72, height: 72),
                      ),
                      Container(
                        height: 72,
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                color: PeeroreumColor.subjectColor[
                                    dropdownSubjectList[datas[index]
                                        ['subject']]]?[0],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  dropdownSubjectList[datas[index]["subject"]],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      color: PeeroreumColor.subjectColor[
                                          dropdownSubjectList[datas[index]
                                              ['subject']]]?[1],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              datas[index]["title"]!,
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Text(dropdownGradeList[datas[index]["grade"]],
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: PeeroreumColor.gray[600])),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text('⋅'),
                                ),
                                Text(
                                    '${datas[index]["attendingPeopleNum"]!}명 참여중',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: PeeroreumColor.gray[600])),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text('⋅'),
                                ),
                                Text('D-${datas[index]["dday"]!}',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: PeeroreumColor.gray[600])),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: PeeroreumColor.gray[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/icons/share.svg',
                      ),
                    ),
                  )
                ],
              ),
              roominfo_tag(index),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  inviDatas[index]['challenge'],
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                decoration: BoxDecoration(
                    color: PeeroreumColor.gray[50],
                    borderRadius: BorderRadius.circular(8)),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 162,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(inviDatas[index]['invitationUrl']),
                        fit: BoxFit.cover),
                    color: PeeroreumColor.primaryPuple[400],
                    borderRadius: BorderRadius.circular(8)),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(20),
          width: double.maxFinite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.gray[600],
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(PeeroreumColor.gray[300]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    enrollWedu(index);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '참여하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.white,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        PeeroreumColor.primaryPuple[400]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
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

  Widget roominfo_tag(roomIndex) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 26,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: PeeroreumColor.primaryPuple[400]!),
                    borderRadius: BorderRadius.all(Radius.circular(100.0))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '#',
                      style: TextStyle(
                        color: PeeroreumColor.primaryPuple[200],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      hashTags[roomIndex][index],
                      style: TextStyle(
                        color: PeeroreumColor.primaryPuple[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: 4,
              );
            },
            itemCount: hashTags[roomIndex].length),
      ),
    );
  }

  Widget bottomNavigatorBarWidget() {
    return BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/home_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '홈'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/user_three.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/user_three_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '같이해냄'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/chats_tear_drop.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/chats_tear_drop_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '질의응답'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/medal.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/medal_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '랭킹'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/user.svg',
                color: PeeroreumColor.gray[400],
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/user_fill.svg',
                color: PeeroreumColor.primaryPuple[400],
              ),
              label: '마이페이지'),
        ],
        currentIndex: selectedIndex,
        unselectedItemColor: PeeroreumColor.gray[400],
        unselectedLabelStyle: TextStyle(fontFamily: 'Pretendard', fontSize: 12),
        selectedItemColor: PeeroreumColor.primaryPuple[400],
        selectedLabelStyle: TextStyle(fontFamily: 'Pretendard', fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchDatas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center();
            } else if (snapshot.hasError) {
              // 에러 발생 시
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return bodyWidget();
            }
          }),
      bottomNavigationBar: bottomNavigatorBarWidget(),
    );
  }

  fetchInvitation(id) async {
    var inviResult = await http
        .get(Uri.parse('${API.hostConnect}/wedu/$id/invitation'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (inviResult.statusCode == 200) {
      return await jsonDecode(utf8.decode(inviResult.bodyBytes))['data'];
    } else {
      print("에러${inviResult.statusCode}");
    }
  }

  void enrollWedu(index) async {
    var id = datas[index]['id'];
    var enrollResult = await await http
        .post(Uri.parse('${API.hostConnect}/wedu/$id/enroll'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if(enrollResult.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "같이방 참여 완료!"
      );
    } else if(enrollResult.statusCode == 409) {
      Fluttertoast.showToast(msg: '이미 참여 중인 같이방입니다.');
    } else {
      Fluttertoast.showToast(msg: '잠시 후에 다시 시도해 주세요.');
      print('에러${enrollResult.statusCode}${enrollResult.body}');
    }
  }
}
