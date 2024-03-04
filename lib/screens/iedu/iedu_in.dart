// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/iedu/iedu_detail.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InIedu extends StatefulWidget {
  const InIedu({super.key});

  @override
  State<InIedu> createState() => _InIeduState();
}

class _InIeduState extends State<InIedu> {
  var token;
  List<String> gradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> subjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
  bool aaa = true;

  int currentPage = 0;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late Future initFuture;

  dynamic data_q = '';
  dynamic question = '';
  dynamic data_a = '';
  dynamic answer = '';

  @override
  void initState() {
    super.initState();
    initFuture = fetchDatas();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        loadMoreData();
      }
    });
    currentPage = 0;
    fetchDatas();
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    currentPage = 0;

    var IeduQuestion = await http.get(
        Uri.parse('${API.hostConnect}/question/my?page=$currentPage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (IeduQuestion.statusCode == 200) {
      print("성공 IeduQuestion ${IeduQuestion.statusCode}");
      data_q = jsonDecode(utf8.decode(IeduQuestion.bodyBytes))["data"];
      question = data_q["questionListReadDtos"];
    } else {
      print("에러 IeduQuestion ${IeduQuestion.statusCode}");
    }

    var IeduAnswer = await http.get(Uri.parse('${API.hostConnect}/answer/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (IeduAnswer.statusCode == 200) {
      print("성공 IeduAnswer ${IeduAnswer.statusCode}");
      data_a = jsonDecode(utf8.decode(IeduAnswer.bodyBytes))['data'];
      answer = data_a["questionListReadDtos"];
    } else {
      print("에러 IeduAnswer ${IeduAnswer.statusCode}");
    }
  }

  loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> addedDatas = [];
    currentPage++;
    var IeduQuestion = await http.get(
        Uri.parse('${API.hostConnect}/question/my?page=$currentPage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (IeduQuestion.statusCode == 200) {
      print("성공 IeduQuestion ${IeduQuestion.statusCode}");
      addedDatas = jsonDecode(utf8.decode(IeduQuestion.bodyBytes))["data"];
      setState(() {
        data_q.addAll(addedDatas);
        question = data_q["questionListReadDtos"];
        _isLoading = false;
      });
    } else {
      print("에러 IeduQuestion ${IeduQuestion.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: initFuture,
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
        "내 질의응답",
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
                    text: '질문',
                  ),
                  Tab(
                    text: '답변',
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
                          child: questions(),
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
                          child: answers(),
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

  Widget questions() {
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
              text: '${data_q["total"]}',
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
            itemCount: question.length + (_isLoading ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                height: 8,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              if (index < question.length) {
                return GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DetailIedu(question[index]['id'],
                            question[index]['selected'])));
                  },
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
                              width: question[index]['selected']
                                  ? MediaQuery.of(context).size.width - 142
                                  : MediaQuery.of(context).size.width - 133,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: T4_16px(
                                      text: '${question[index]['title']}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            question[index]['selected']
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: PeeroreumColor.primaryPuple[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: SizedBox(
                                      height: 16,
                                      child: Center(
                                        child: C2_10px_Sb(
                                          text: '채택완료',
                                          color: PeeroreumColor.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
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
                              C1_12px_M(
                                text:
                                    '${timeCheck(question[index]["createdTime"])} 전',
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
                                text: '좋아요 ${question[index]["likes"]}개',
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
                                text: '댓글 ${question[index]["comments"]}개',
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
            },
          ),
        ),
      ],
    );
  }

  Widget answers() {
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
              text: '${data_a["total"]}',
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
              itemCount: answer.length + (_isLoading ? 1 : 0),
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 8,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DetailIedu(
                            answer[index]['id'], answer[index]['selected'])));
                  },
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
                              width: answer[index]['selected']
                                  ? MediaQuery.of(context).size.width - 142
                                  : MediaQuery.of(context).size.width - 133,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: T4_16px(
                                      text: '${answer[index]['title']}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            answer[index]['selected']
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: PeeroreumColor.primaryPuple[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: SizedBox(
                                      height: 16,
                                      child: Center(
                                        child: C2_10px_Sb(
                                          text: '채택완료',
                                          color: PeeroreumColor.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
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
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            B4_14px_R(
                              text: '${answer[index]["content"]}',
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
                              C1_12px_M(
                                text:
                                    '${timeCheck(answer[index]["createdTime"])} 전',
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
                                text: '좋아요 ${answer[index]["likes"]}개',
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
                                text: '댓글 ${answer[index]["comments"]}개',
                                color: PeeroreumColor.gray[400],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
