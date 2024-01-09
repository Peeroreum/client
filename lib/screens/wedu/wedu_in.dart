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
  List<dynamic> ing_group = [];
  List<dynamic> complete_group = [];

  var token;
  dynamic datas = '';
  List<String> gradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> subjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    var result = await http.get(
        Uri.parse('${API.hostConnect}/wedu/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (result.statusCode == 200) {
      datas = await jsonDecode(utf8.decode(result.bodyBytes))['data'];
      ing_group = datas["ingWedus"];
      complete_group = datas['endWedus'];
    } else {
      print("에러${result.statusCode}");
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
                  Tab(text: '참여 중인 같이방',),
                  Tab(text: '완료된 같이방',)
                ]),
            Expanded(
                child: TabBarView(
                    children: [
                      ing_group.isNotEmpty? ing_room() : Center(child: Text('참여 중인 같이방이 없습니다.', style: TextStyle(fontFamily: "Pretendard", fontWeight: FontWeight.w600, fontSize: 16, color: PeeroreumColor.gray[600]),)),
                      complete_group.isNotEmpty? complete_room() : Center(child: Text('완료된 같이방이 없습니다.', style: TextStyle(fontFamily: "Pretendard", fontWeight: FontWeight.w600, fontSize: 16, color: PeeroreumColor.gray[600]),))
                ])
            ),
          ],
        ),
      ),
    );
  }

  Widget complete_room() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: complete_group.length,
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
                  margin: EdgeInsets.only(right: 16),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      image: complete_group[index]["imagePath"] != null
                          ? DecorationImage(image: NetworkImage(complete_group[index]["imagePath"]), fit: BoxFit.cover)
                          : DecorationImage(image: AssetImage('assets/images/example_logo.png'))
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(4)),
                              color: PeeroreumColor.subjectColor[
                              subjectList[complete_group[index]
                              ['subject']]]?[0],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                subjectList[complete_group[index]['subject']],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: PeeroreumColor.subjectColor[
                                    subjectList[complete_group[index]
                                    ['subject']]]?[1],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            child: Text(
                              complete_group[index]["title"]!,
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black,
                                  overflow: TextOverflow.ellipsis
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   width: 4,
                          // ),
                          // complete_group[index]['locked'].toString() == "true"
                          //     ? SvgPicture.asset('assets/icons/lock.svg',
                          //     color: PeeroreumColor.gray[400], width: 12)
                          //     : Container()
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                gradeList[complete_group[index]["grade"]],
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
                                '${complete_group[index]["attendingPeopleNum"]!}명 참여중',
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
                                'D-${complete_group[index]["dday"]!}',
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
                            "${complete_group[index]["progress"]}% 달성",
                            style: TextStyle(
                                color: PeeroreumColor.primaryPuple[400],
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      LinearPercentIndicator(
                        padding: EdgeInsets.all(0),
                        lineHeight: 8,
                        percent: double.parse(complete_group[index]["progress"].toString()) / 100,
                        backgroundColor: PeeroreumColor.gray[200],
                        linearGradient: LinearGradient(colors: [
                          PeeroreumColor.primaryPuple[400]!,
                          PeeroreumColor.primaryPuple[200]!
                        ]),
                        barRadius: Radius.circular(8),
                      )
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

  Widget ing_room() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: ing_group.length,
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
                  margin: EdgeInsets.only(right: 16),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      image: ing_group[index]["imagePath"] != null
                          ? DecorationImage(image: NetworkImage(ing_group[index]["imagePath"]), fit: BoxFit.cover)
                          : DecorationImage(image: AssetImage('assets/images/example_logo.png'))
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              color: PeeroreumColor.subjectColor[
                                  subjectList[ing_group[index]
                                      ['subject']]]?[0],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                subjectList[ing_group[index]['subject']],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: PeeroreumColor.subjectColor[
                                        subjectList[ing_group[index]
                                            ['subject']]]?[1],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            child: Text(
                              ing_group[index]["title"]!,
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black,
                                overflow: TextOverflow.ellipsis
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   width: 4,
                          // ),
                          // ing_group[index]['locked'].toString() == "true"
                          //     ? SvgPicture.asset('assets/icons/lock.svg',
                          //         color: PeeroreumColor.gray[400], width: 12)
                          //     : Container()
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                gradeList[ing_group[index]["grade"]],
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
                                '${ing_group[index]["attendingPeopleNum"]!}명 참여중',
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
                                'D-${ing_group[index]["dday"]!}',
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
                            "${ing_group[index]["progress"]}% 달성",
                            style: TextStyle(
                                color: PeeroreumColor.primaryPuple[400],
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      LinearPercentIndicator(
                        padding: EdgeInsets.all(0),
                        lineHeight: 8,
                        percent: double.parse(ing_group[index]["progress"].toString()) / 100,
                        backgroundColor: PeeroreumColor.gray[200],
                        linearGradient: LinearGradient(colors: [
                          PeeroreumColor.primaryPuple[400]!,
                          PeeroreumColor.primaryPuple[200]!
                        ]),
                        barRadius: Radius.circular(8),
                      )
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
