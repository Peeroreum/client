// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';

class InWedu extends StatefulWidget {
  const InWedu({super.key});

  @override
  State<InWedu> createState() => _InWeduState();
}

class _InWeduState extends State<InWedu> {
  List<Map<String, String>> ing_group = [];
  List<Map<String, String>> complete_group = [];

  @override
  void initState() {
    super.initState();
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

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
        color: PeeroreumColor.gray[800],
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
    return DefaultTabController(
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
                // decorationColor: PeeroreumColor.gray[800]
              ),
              tabs: [
                Tab(
                  text: '참여 중인 같이방',
                ),
                Tab(
                  text: '완료된 같이방',
                )
              ]),
          Expanded(child: TabBarView(children: [ing_room(), complete_room()])),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemCount: ing_group.length,
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
                child: Image.asset(ing_group[index]["group_profile"]!,
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
                                          ing_group[index]["subject"]!,
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
                                      ing_group[index]["name"]!,
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
                                    Text(ing_group[index]["grade"]!,
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
                                    Text('${ing_group[index]["number"]!}명 참여중',
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
                                    Text('D-${ing_group[index]["day"]!}',
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
                          percent: 0.6,
                          backgroundColor: PeeroreumColor.gray[200],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: bodyWidget(),
    );
  }
}
