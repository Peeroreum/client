import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';

class InWedu extends StatefulWidget {
  const InWedu({super.key});

  @override
  State<InWedu> createState() => _InWeduState();
}

class _InWeduState extends State<InWedu> {
  List<dynamic> ingGroup = [];
  List<dynamic> completeGroup = [];

  dynamic data = '';
  List<String> gradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3', '대학'];
  List<String> subjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타', '대학'];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var result = await ApiClient().get('/wedu/my');
    if (result.statusCode == 200) {
      data = result.data['data'];
      ingGroup = data["ingWedus"];
      completeGroup = data['endWedus'];
    } else {
      print("에러${result.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchData(),
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
                    text: '참여 중인 같이방',
                  ),
                  Tab(
                    text: '완료된 같이방',
                  )
                ]),
            Container(
              height: 1,
              color: PeeroreumColor.gray[100],
            ),
            Expanded(
                child: TabBarView(children: [
              ingGroup.isNotEmpty
                  ? ingRoom()
                  : Center(
                      child: Text(
                      '참여 중인 같이방이 없습니다.',
                      style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: PeeroreumColor.gray[600]),
                    )),
              completeGroup.isNotEmpty
                  ? completeRoom()
                  : Center(
                      child: Text(
                      '완료된 같이방이 없습니다.',
                      style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: PeeroreumColor.gray[600]),
                    ))
            ])),
          ],
        ),
      ),
    );
  }

  Widget completeRoom() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: completeGroup.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          // onTap: () {
          //   Get.to(() => DetailWedu(complete_group[index]["id"]));
          // },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PeeroreumColor.gray[50],
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: completeGroup[index]["imagePath"] != null
                        ? Image.network(
                            completeGroup[index]["imagePath"],
                            fit: BoxFit.cover,
                          )
                        : SvgPicture.asset(
                            'assets/images/default.svg',
                            fit: BoxFit.cover,
                          ),
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
                                  const BorderRadius.all(Radius.circular(4)),
                              color: PeeroreumColor.subjectColor[subjectList[
                                  completeGroup[index]['subject']]]?[0],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                subjectList[completeGroup[index]['subject']],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: PeeroreumColor.subjectColor[
                                        subjectList[completeGroup[index]
                                            ['subject']]]?[1],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            child: Text(
                              completeGroup[index]["title"]!,
                              style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black,
                                  overflow: TextOverflow.ellipsis),
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                gradeList[completeGroup[index]["grade"]],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                              Text(
                                '${completeGroup[index]["attendingPeopleNum"]!}명',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                              Text(
                                '${completeGroup[index]["dday"].toString().substring(1)}일 전',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget ingRoom() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: ingGroup.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Get.to(() => DetailWedu(ingGroup[index]["id"]));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PeeroreumColor.gray[50],
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: ingGroup[index]["imagePath"] != null
                        ? Image.network(
                            ingGroup[index]["imagePath"],
                            fit: BoxFit.cover,
                          )
                        : SvgPicture.asset(
                            'assets/images/default.svg',
                            fit: BoxFit.cover,
                          ),
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
                                  const BorderRadius.all(Radius.circular(4)),
                              color: PeeroreumColor.subjectColor[
                                  subjectList[ingGroup[index]['subject']]]?[0],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                subjectList[ingGroup[index]['subject']],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: PeeroreumColor.subjectColor[
                                        subjectList[ingGroup[index]
                                            ['subject']]]?[1],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            child: Text(
                              ingGroup[index]["title"]!,
                              style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black,
                                  overflow: TextOverflow.ellipsis),
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
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                gradeList[ingGroup[index]["grade"]],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                              Text(
                                '${ingGroup[index]["attendingPeopleNum"]!}명 참여중',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                              Text(
                                'D-${ingGroup[index]["dday"]!}',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            "${ingGroup[index]["progress"]}% 달성",
                            style: TextStyle(
                                color: PeeroreumColor.primaryPuple[400],
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      LinearPercentIndicator(
                        padding: const EdgeInsets.all(0),
                        lineHeight: 8,
                        percent: double.parse(
                                ingGroup[index]["progress"].toString()) /
                            100,
                        backgroundColor: PeeroreumColor.gray[200],
                        linearGradient: LinearGradient(colors: [
                          PeeroreumColor.primaryPuple[400]!,
                          PeeroreumColor.primaryPuple[200]!
                        ]),
                        barRadius: const Radius.circular(8),
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
