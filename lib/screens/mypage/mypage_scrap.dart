import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:flutter/material.dart';
import 'package:peeroreum_client/screens/iedu/iedu_detail.dart';

class Scrap extends StatefulWidget {
  const Scrap({super.key});

  @override
  State<Scrap> createState() => _ScrapState();
}

class _ScrapState extends State<Scrap> {
  int currentPage = 0;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late Future initFuture;

  dynamic dataQnA = '';
  dynamic totalQnA = 0;
  dynamic questionList = '';
  dynamic contents = '';

  @override
  void initState() {
    super.initState();
    initFuture = fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        loadMoreData();
      }
    });
    currentPage = 0;
    fetchData();
  }

  Future<void> fetchData() async {
    currentPage = 0;
    var myScrap = await ApiClient().get('/bookmark/question/my', queryParameters: {'page': currentPage});
    if (myScrap.statusCode == 200) {
      print("성공 myScrap ${myScrap.statusCode}");
      dataQnA = myScrap.data['data'];
      totalQnA = dataQnA['total'];
      questionList = dataQnA["questionListReadDtos"];
    } else {
      print("에러 myScrap ${myScrap.statusCode}");
    }
  }

  loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> addedData = [];
    currentPage++;
    var myScrap = await ApiClient().get('/question/my', queryParameters: {'page': currentPage});
    if (myScrap.statusCode == 200) {
      print("성공 IeduQuestion ${myScrap.statusCode}");
      addedData = myScrap.data["data"];
      setState(() {
        dataQnA.addAll(addedData);
        questionList = dataQnA["questionListReadDtos"];
        _isLoading = false;
      });
    } else {
      print("에러 IeduQuestion ${myScrap.statusCode}");
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
          Get.back();
        },
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          color: PeeroreumColor.gray[800],
        ),
      ),
      title: const Text(
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
        length: 1,
        child: Column(
          children: [
            TabBar(
                indicatorColor: PeeroreumColor.primaryPuple[400],
                indicatorSize: TabBarIndicatorSize.tab,
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
                tabs: const [
                  Tab(
                    text: '내가해냄',
                  ),
                  //Tab(
                  //  text: '컨텐츠',
                  //)
                ]),
            Container(
              height: 1,
              color: PeeroreumColor.gray[100],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  dataQnA.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: questionListWidget(),
                        )
                      : Center(
                          child: Text(
                          '스크랩한 질문이 없습니다.',
                          style: TextStyle(
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        )),
                  /*Content.length
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
                        ),*/
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
        return '$weeks주';
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

  Widget questionListWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            B4_14px_M(
              text: '전체',
              color: PeeroreumColor.gray[500],
            ),
            const SizedBox(
              width: 4,
            ),
            B4_14px_M(
              text: '$totalQnA',
              color: PeeroreumColor.gray[500],
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: questionList.length + (_isLoading ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                height: 8,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              if (index < questionList.length) {
                return GestureDetector(
                  onTap: () async {
                    await Get.to(() =>
                        DetailIedu(questionList[index]['id'], questionList[index]['selected']));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                        color: PeeroreumColor.white,
                        border: Border.all(
                            width: 1, color: PeeroreumColor.gray[200]!),
                        borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: questionList[index]['selected']
                                  ? MediaQuery.of(context).size.width - 142
                                  : MediaQuery.of(context).size.width - 133,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: T4_16px(
                                      text: '${questionList[index]['title']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            questionList[index]['selected']
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: PeeroreumColor.primaryPuple[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const SizedBox(
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
                                    padding: const EdgeInsets.symmetric(
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
                        const SizedBox(
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
                                    color: questionList[index]["memberProfileDto"]
                                                ["grade"] !=
                                            null
                                        ? PeeroreumColor.gradeColor[questionList[index]
                                            ["memberProfileDto"]["grade"]]!
                                        : const Color.fromARGB(255, 186, 188, 189),
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
                                    image: questionList[index]["memberProfileDto"]
                                                ["profileImage"] !=
                                            null
                                        ? DecorationImage(
                                            image: NetworkImage(questionList[index]
                                                    ["memberProfileDto"]
                                                ["profileImage"]),
                                            fit: BoxFit.cover)
                                        : const DecorationImage(
                                            image: AssetImage(
                                                'assets/images/user.jpg')),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Flexible(
                                child: B4_14px_M(
                                  text:
                                      '${questionList[index]["memberProfileDto"]["nickname"]}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              C1_12px_M(
                                text:
                                    '${timeCheck(questionList[index]["createdTime"])} 전',
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
                                text: '좋아요 ${questionList[index]["likes"]}개',
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
                                text: '댓글 ${questionList[index]["comments"]}개',
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

  Widget content() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            B4_14px_M(
              text: '전체',
              color: PeeroreumColor.gray[500],
            ),
            const SizedBox(
              width: 4,
            ),
            B4_14px_M(
              text: 'NN',
              color: PeeroreumColor.gray[500],
            ),
          ],
        ),
        const SizedBox(
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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                        color: PeeroreumColor.white,
                        border: Border.all(
                            width: 1, color: PeeroreumColor.gray[200]!),
                        borderRadius: const BorderRadius.all(Radius.circular(8.0))),
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
                        const SizedBox(
                          width: 16,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const T4_16px(
                              // text: datas[index]['title'],
                              text: 'Title',
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            const B4_14px_R(
                              text: 'content',
                            ),
                            const SizedBox(
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
