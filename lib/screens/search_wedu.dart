// ignore_for_file: prefer_const_constructors, camel_case_types, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

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
    ];
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 24,
      leading: IconButton(
        iconSize: 24,
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        color: PeeroreumColor.gray[800],
      ),
      titleSpacing: 0,
      title: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 20, 12),
          child: SizedBox(
            width: 234,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PeeroreumColor.gray[100],
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: PeeroreumColor.gray[100]!),
                      borderRadius: BorderRadius.circular(37)),
                  hintText: '어떤 문제가 궁금하세요?',
                  hintStyle: TextStyle(
                      color: PeeroreumColor.gray[600],
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: GestureDetector(
                          child: Icon(
                            Icons.cancel,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          onTap: () => _textEditingController.clear(),
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: GestureDetector(
                          child: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      body: Column(
        children: [
          realtimeSearch(),
          Container(
            height: 8,
            color: PeeroreumColor.gray[100],
          ),
          recentSearch()
        ],
      ),
    );
  }

  Widget realtimeSearch() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 274, 16),
          child: Text(
            '실시간 검색어',
            style: TextStyle(
                color: PeeroreumColor.gray[800],
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
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
                    child: Text(
                      '# ${searchData[index]["search_word"]!}',
                      style: TextStyle(color: PeeroreumColor.primaryPuple[400]),
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
              Text(
                '전체삭제',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.gray[500]),
              )
            ],
          ),
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
