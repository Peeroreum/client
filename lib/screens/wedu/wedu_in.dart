// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InWedu extends StatefulWidget {
  const InWedu({super.key});

  @override
  State<InWedu> createState() => _InWeduState();
}

class _InWeduState extends State<InWedu> {
  List<Map<String, String>> ing_group = [];
  List<Map<String, String>> complete_group = [];

  var token;
  List<dynamic> datas = [];
  List<dynamic> inroom_datas = [];
  List<dynamic> inviDatas = [];
  List<dynamic> hashTags = [];
  String selectedSortType = '최신순';
  List<String> dropdownGradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> dropdownSubjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
  List<String> dropdownSortTypeList = ['최신순', '추천순', '인기순'];

  var grade = 0;
  var subject = 0;

  @override
  void initState() {
    super.initState();
    fetchDatas();
    ing_group = [
      {
        "cid": "1",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "국어",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "2",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "수학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "3",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "영어",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "4",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "과학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "5",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "수학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "6",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "수학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "7",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "수학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
    ];
    complete_group = [
      {
        "cid": "1",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "코딩",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "2",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "코딩",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "3",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "코딩",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "4",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "코딩",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
    ];
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    var ingWedu = await http.get(
        Uri.parse(
            '${API.hostConnect}/wedu/my?sort=$selectedSortType&grade=$grade&subject=$subject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (ingWedu.statusCode == 200) {
      datas = jsonDecode(utf8.decode(ingWedu.bodyBytes))['data'];
    } else {
      print("에러${ingWedu.statusCode}");
    }
    var completeWedu = await http.get(Uri.parse('${API.hostConnect}/wedu/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (completeWedu.statusCode == 200) {
      inroom_datas = jsonDecode(utf8.decode(completeWedu.bodyBytes))['data'];
    } else {
      print("에러${completeWedu.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchDatas(),
          builder: (context, snapshot) {
            return bodyWidget();
          }),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          color: PeeroreumColor.gray[800],
        ),
      ),
      title: Text(
        "내 같이방",
        style: TextStyle(
            color: PeeroreumColor.black,
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  Widget bodyWidget() {
    return Container(
      color: PeeroreumColor.white,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
                indicatorColor: PeeroreumColor.primaryPuple[400],
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: PeeroreumColor.primaryPuple[400],
                unselectedLabelColor: PeeroreumColor.gray[800],
                labelStyle: TextStyle(
                  color: PeeroreumColor.primaryPuple[400],
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(
                    text: '참여 중인 같이방',
                  ),
                  Tab(
                    text: '완료된 같이방',
                  )
                ]),
            Expanded(
                child: TabBarView(children: [ing_room(), complete_room()])),
          ],
        ),
      ),
    );
  }

  Widget complete_room() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemCount: complete_group.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 94,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Image.asset(complete_group[index]["group_profile"]!,
                    width: 48, height: 48),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                          color: Color(0xFFFFE9E9)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 8),
                                        child: Text(
                                          complete_group[index]["subject"]!,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              color: Color(0xFFF86060),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      complete_group[index]["name"]!,
                                      style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: PeeroreumColor.black),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Icon(Icons.lock_outline,
                                        size: 18,
                                        color: PeeroreumColor.gray[400])
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    Text(complete_group[index]["grade"]!,
                                        style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: PeeroreumColor.gray[600])),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 2),
                                      child: Text('⋅'),
                                    ),
                                    Text(
                                        '${complete_group[index]["number"]!}명 참여중',
                                        style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: PeeroreumColor.gray[600])),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 2),
                                      child: Text('⋅'),
                                    ),
                                    Text('D-${complete_group[index]["day"]!}',
                                        style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: PeeroreumColor.gray[600])),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 28,
                                ),
                                Text(
                                  "NN% 달성",
                                  style: TextStyle(
                                      color: PeeroreumColor.primaryPuple[400],
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        LinearPercentIndicator(
                          padding: EdgeInsets.all(0),
                          lineHeight: 8,
                          percent: 1.0,
                          backgroundColor: Color(0xffeaebec),
                          linearGradient: LinearGradient(colors: [
                            PeeroreumColor.primaryPuple[400]!,
                            PeeroreumColor.primaryPuple[200]!
                          ]),
                          barRadius: Radius.circular(8),
                        )
                      ]),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget ing_room() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  //height: 60,
                  margin: EdgeInsets.only(left: 16),
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
                                    color: PeeroreumColor.subjectColor[
                                        dropdownSubjectList[datas[index]
                                            ['subject']]]?[1],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
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
                          SizedBox(
                            width: 4,
                          ),
                          datas[index]['locked'].toString() == "true"
                              ? SvgPicture.asset('assets/icons/lock.svg',
                                  color: PeeroreumColor.gray[400], width: 12)
                              : Container()
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                dropdownGradeList[datas[index]["grade"]],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Text('⋅'),
                              ),
                              Text(
                                '${datas[index]["attendingPeopleNum"]!}명 참여중',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Text('⋅'),
                              ),
                              Text(
                                'D-${datas[index]["dday"]!}',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${datas[index]["progress"]}% 달성",
                            style: TextStyle(
                                color: PeeroreumColor.primaryPuple[400],
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: 8,
                      // ),
                      // LinearPercentIndicator(
                      //   padding: EdgeInsets.all(0),
                      //   lineHeight: 8,
                      //   percent: datas[index]["progress"] / 100 ?? 1,
                      //   backgroundColor: PeeroreumColor.gray[200],
                      //   linearGradient: LinearGradient(colors: [
                      //     PeeroreumColor.primaryPuple[400]!,
                      //     PeeroreumColor.primaryPuple[200]!
                      //   ]),
                      //   barRadius: Radius.circular(8),
                      // )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
