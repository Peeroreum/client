// ignore_for_file: prefer_const_constructors, camel_case_types, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/search_result_wedu_screen.dart';

class searchWedu extends StatefulWidget {
  const searchWedu({super.key});

  @override
  State<searchWedu> createState() => _searchWeduState();
}

class _searchWeduState extends State<searchWedu> {
  final TextEditingController _textEditingController = TextEditingController();
  List<Map<String, String>> searchData = [];

  void initState() {
    super.initState();
    searchData = [
      {"cid": "1", "search_word": "검색어"},
      {"cid": "2", "search_word": "검색어"},
      {"cid": "3", "search_word": "검색어"},
      {"cid": "4", "search_word": "검색어"},
      {"cid": "5", "search_word": "검색어"},
      {"cid": "6", "search_word": "검색어"},
      {"cid": "7", "search_word": "검색어"},
      {"cid": "8", "search_word": "검색어"},
    ];
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leadingWidth: 36,
        leading: IconButton(
          // iconSize: 24,
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            color: PeeroreumColor.gray[800],
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 20, 12),
          child: SearchBar(
            // padding: MaterialStateProperty.all(
            //     EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
            controller: _textEditingController,
            backgroundColor:
                MaterialStateProperty.all(PeeroreumColor.gray[100]),
            elevation: MaterialStateProperty.all(0),
            // shape: MaterialStateProperty.all(ContinuousRectangleBorder(
            //     borderRadius: BorderRadius.all(Radius.circular(37.0)))),
            constraints: BoxConstraints(maxHeight: 40),
            hintText: '같이방에서 함께 공부해요!',
            hintStyle: MaterialStateProperty.all(TextStyle(
                color: PeeroreumColor.gray[600],
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w400)),
            trailing: [
              GestureDetector(
                onTap: () => _textEditingController.clear(),
                child: SvgPicture.asset(
                  'assets/icons/x_circle.svg',
                  color: PeeroreumColor.gray[600],
                )
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => SearchResultWedu(_textEditingController.text),
                        transitionDuration: const Duration(seconds: 0),
                        reverseTransitionDuration: const Duration(seconds: 0)),
                  );
                },
                icon: SvgPicture.asset(
                  'assets/icons/search.svg',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ));
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Column(
        children: [
          // realtimeSearch(),
          // Container(
          //   height: 8,
          //   color: PeeroreumColor.gray[100],
          // ),
          Expanded(child: recentSearch())
        ],
      ),
    );
  }

  Widget realtimeSearch() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 0, 16),
              child: Text(
                '실시간 검색어',
                style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            height: 32,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1, color: PeeroreumColor.primaryPuple[400]!),
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '#',
                          style: TextStyle(
                              color: PeeroreumColor.primaryPuple[200]),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${searchData[index]["search_word"]}',
                          style: TextStyle(
                              color: PeeroreumColor.primaryPuple[400]),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 8,
                  );
                },
                itemCount: searchData.length),
          ),
        )
      ],
    );
  }

  Widget recentSearch() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색어',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              TextButton(
                child: Text(
                  '전체삭제',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.gray[500]),
                ),
                onPressed: () => {},
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchData.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${searchData[index]["search_word"]}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                                color: PeeroreumColor.gray[600]),
                          ),
                          Row(
                            children: [
                              Text(
                                'YY.MM.DD',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[400]),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.close,
                                size: 18,
                                color: PeeroreumColor.gray[800],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(
                        color: PeeroreumColor.gray[100],
                      )
                    ],
                  ),
                );
              }),
        )
      ],
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
