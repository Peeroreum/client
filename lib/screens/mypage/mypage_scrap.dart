// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Scrap extends StatefulWidget {
  const Scrap({super.key});

  @override
  State<Scrap> createState() => _ScrapState();
}

class _ScrapState extends State<Scrap> {
  var token;
  dynamic datas = '';
  List<String> gradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> subjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
  bool aaa = true;
  int currentPage = 0;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> QnA = [];
  List<dynamic> contents = [];

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    currentPage = 0;
    var myScrap = await http.get(
        Uri.parse('${API.hostConnect}/bookmark/question/my?page=$currentPage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (myScrap.statusCode == 200) {
      print("성공 myScrap ${myScrap.statusCode}");
      datas = jsonDecode(utf8.decode(myScrap.bodyBytes))['data'];
      QnA = datas[""];
      contents = datas[""];
    } else {
      print("에러 myScrap ${myScrap.statusCode}");
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
        "스크랩",
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
                unselectedLabelStyle: TextStyle(
                  color: PeeroreumColor.gray[800],
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                labelStyle: TextStyle(
                  color: PeeroreumColor.primaryPuple[400],
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(
                    text: '질의응답',
                  ),
                  Tab(
                    text: '컨텐츠',
                  )
                ]),
            Container(
              height: 1,
              color: PeeroreumColor.gray[100],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  aaa
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: QAndA(),
                        )
                      : Center(
                          child: Text(
                          '작성한 질문이 없습니다.',
                          style: TextStyle(
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        )),
                  aaa
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Content(),
                        )
                      : Center(
                          child: Text(
                            '작성한 답변이 없습니다.',
                            style: TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: PeeroreumColor.gray[600]),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String timeCheck(String createdAt) {
    DateTime createdTime = DateTime.parse(createdAt);
    DateTime now = DateTime.now();

    Duration difference = now.difference(createdTime);

    if (difference.inDays > 0) {
      if (difference.inDays <= 7) {
        return '${difference.inDays}일';
      } else if (difference.inDays <= 30) {
        int weeks = (difference.inDays / 7).floor();
        return '${weeks}주';
      } else if (difference.inDays >= 365) {
        int years = difference.inDays ~/ 365;
        return '$years년';
      } else if (difference.inDays >= 30) {
        int months = difference.inDays ~/ 30;
        return '$months달';
      } else {
        return '${difference.inDays}일';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분';
    } else {
      return '${difference.inSeconds}초';
    }
  }

  Widget QAndA() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            B4_14px_M(
              text: '전체',
              color: PeeroreumColor.gray[500],
            ),
            SizedBox(
              width: 4,
            ),
            B4_14px_M(
              text: 'NN',
              color: PeeroreumColor.gray[500],
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
          child: ListView.separated(
              shrinkWrap: true,
              itemCount: 8, //datas.length + (_isLoading ? 1 : 0),
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 8,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                //if (index < datas.length) {
                return GestureDetector(
                  // onTap: () async {
                  //   await Navigator.of(context).push(MaterialPageRoute(
                  //       builder: (context) => DetailIedu(
                  //           datas[index]['id'], datas[index]['selected'])));
                  // },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                        color: PeeroreumColor.white,
                        border: Border.all(
                            width: 1, color: PeeroreumColor.gray[200]!),
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              // width: datas[index]['selected']
                              //     ? MediaQuery.of(context).size.width - 142
                              //     : MediaQuery.of(context).size.width - 133,
                              width: MediaQuery.of(context).size.width - 133,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: T4_16px(
                                      // text: datas[index]['title'],
                                      text: 'Title',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            // datas[index]['selected']
                            //     ? Container(
                            //         padding: EdgeInsets.symmetric(
                            //             vertical: 2, horizontal: 8),
                            //         decoration: BoxDecoration(
                            //           color: PeeroreumColor.primaryPuple[200],
                            //           borderRadius: BorderRadius.circular(4),
                            //         ),
                            //         child: SizedBox(
                            //           height: 16,
                            //           child: Center(
                            //             child: C2_10px_Sb(
                            //               text: '채택완료',
                            //               color: PeeroreumColor.white,
                            //             ),
                            //           ),
                            //         ),
                            //       ):
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                color: PeeroreumColor.gray[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SizedBox(
                                height: 16,
                                child: Center(
                                  child: C2_10px_Sb(
                                    text: '미채택',
                                    color: PeeroreumColor.gray[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 42,
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1,
                                    // color: datas[index]["memberProfileDto"]
                                    //             ["grade"] !=
                                    //         null
                                    //     ? PeeroreumColor.gradeColor[datas[index]
                                    //         ["memberProfileDto"]["grade"]]!
                                    //     : Color.fromARGB(255, 186, 188, 189),
                                  ),
                                ),
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: PeeroreumColor.white,
                                    ),
                                    // image: datas[index]["memberProfileDto"]
                                    //             ["profileImage"] !=
                                    //         null
                                    //     ? DecorationImage(
                                    //         image: NetworkImage(datas[index]
                                    //             ["memberProfileDto"]["profileImage"]),
                                    //         fit: BoxFit.cover)
                                    //     : DecorationImage(
                                    //         image:
                                    //             AssetImage('assets/images/user.jpg')),
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/user.jpg')),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Flexible(
                                child: B4_14px_M(
                                  // text: datas[index]["memberProfileDto"]
                                  //     ["nickname"]
                                  text: 'nickname',
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              C1_12px_M(
                                // text: '${timeCheck(datas[index]["createdTime"])} 전',
                                text: 'NN 전',
                                color: PeeroreumColor.gray[400],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[400],
                                ),
                              ),
                              C1_12px_M(
                                // text: '좋아요 ${datas[index]["likes"]}개',
                                text: '좋아요 NN개',
                                color: PeeroreumColor.gray[400],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[400],
                                ),
                              ),
                              C1_12px_M(
                                // text: '댓글 ${datas[index]["comments"]}개',
                                text: '댓글 NN개',
                                color: PeeroreumColor.gray[400],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              //},
              ),
        ),
      ],
    );
  }

  Widget Content() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            B4_14px_M(
              text: '전체',
              color: PeeroreumColor.gray[500],
            ),
            SizedBox(
              width: 4,
            ),
            B4_14px_M(
              text: 'NN',
              color: PeeroreumColor.gray[500],
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
          child: ListView.separated(
              shrinkWrap: true,
              itemCount: 8, //datas.length + (_isLoading ? 1 : 0),
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 8,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                //if (index < datas.length) {
                return GestureDetector(
                  // onTap: () async {
                  //   await Navigator.of(context).push(MaterialPageRoute(
                  //       builder: (context) => DetailIedu(
                  //           datas[index]['id'], datas[index]['selected'])));
                  // },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                        color: PeeroreumColor.white,
                        border: Border.all(
                            width: 1, color: PeeroreumColor.gray[200]!),
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: PeeroreumColor.gray[50],
                            border: Border.all(
                                width: 1, color: PeeroreumColor.gray[100]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            T4_16px(
                              // text: datas[index]['title'],
                              text: 'Title',
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            B4_14px_R(
                              text: 'content',
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                C1_12px_M(
                                  // text: '${timeCheck(datas[index]["createdTime"])} 전',
                                  text: 'NN 전',
                                  color: PeeroreumColor.gray[400],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/dot.svg',
                                    color: PeeroreumColor.gray[400],
                                  ),
                                ),
                                C1_12px_M(
                                  // text: '좋아요 ${datas[index]["likes"]}개',
                                  text: '좋아요 NN개',
                                  color: PeeroreumColor.gray[400],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/dot.svg',
                                    color: PeeroreumColor.gray[400],
                                  ),
                                ),
                                C1_12px_M(
                                  // text: '댓글 ${datas[index]["comments"]}개',
                                  text: '댓글 NN개',
                                  color: PeeroreumColor.gray[400],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              //},
              ),
        ),
      ],
    );
  }
}
