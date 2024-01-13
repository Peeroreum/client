// ignore_for_file: prefer_const_constructors, camel_case_types, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/wedu/wedu_search_result_screen.dart';

import '../../data/WeduSearchHistory.dart';

class searchWedu extends StatefulWidget {
  const searchWedu({super.key});

  @override
  State<searchWedu> createState() => _searchWeduState();
}

class _searchWeduState extends State<searchWedu> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchHistory = [];

  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  _loadSearchHistory() async {
    _searchHistory = await SearchHistory.getSearchHistory();
    setState(() {});
  }

  _saveSearchHistory(String value) async {
    await SearchHistory.addSearchItem(value);
    _loadSearchHistory();
  }

  _deleteSearchHistory(String item) async {
    await SearchHistory.deleteSearchItem(item);
    _loadSearchHistory();
  }

  _deleteAllSearchHistory() async {
    await SearchHistory.deleteAllSearchItem();
    _loadSearchHistory();
  }

  bool search_clear = false;

  PreferredSizeWidget appbarWidget() {
    return AppBar(
        backgroundColor: PeeroreumColor.white,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
        title: Container(
          margin: EdgeInsets.fromLTRB(0, 12, 20, 12),
          child: SearchBar(
            controller: _searchController,
            onTap: () {
              if (_searchController.text.length > 0) {
                setState(() {
                  search_clear = true;
                });
              }
            },
            onChanged: (value) {
              if (value.length > 0) {
                setState(() {
                  search_clear = true;
                });
              } else {
                setState(() {
                  search_clear = false;
                });
              }
            },
            backgroundColor:
                MaterialStateProperty.all(PeeroreumColor.gray[100]),
            elevation: MaterialStateProperty.all(0),
            constraints: BoxConstraints(minHeight: 40),
            hintText: '같이방에서 함께 공부해요!',
            hintStyle: MaterialStateProperty.all(TextStyle(
                color: PeeroreumColor.gray[600],
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w400)),
            trailing: [
              search_clear
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          search_clear = false;
                        });
                      },
                      child: SvgPicture.asset(
                        'assets/icons/x_circle.svg',
                        color: PeeroreumColor.gray[600],
                      ))
                  : Container(),
              SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () {
                  if (_searchController.text.isNotEmpty) {
                    _saveSearchHistory(_searchController.text);
                    goToSearchResult(_searchController.text);
                  } else {
                    Fluttertoast.showToast(msg: '검색어를 입력하세요.');
                  }
                },
                child: SvgPicture.asset(
                  'assets/icons/search.svg',
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(
                width: 8,
              )
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
                          '${_searchHistory[index]["search_word"]}',
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
                itemCount: _searchHistory.length),
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
              GestureDetector(
                child: Text(
                  '전체삭제',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.gray[500]),
                ),
                onTap: () {
                  _deleteAllSearchHistory();
                  setState(() {});
                },
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => SearchResultWedu(
                                      _searchHistory[index]['keyword']
                                          .toString()),
                                  transitionDuration:
                                      const Duration(seconds: 0),
                                  reverseTransitionDuration:
                                      const Duration(seconds: 0)),
                            );
                          },
                          child: Text(
                            '${_searchHistory[index]['keyword']}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                                color: PeeroreumColor.gray[600]),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${_searchHistory[index]['date']}',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: PeeroreumColor.gray[400]),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                _deleteSearchHistory(_searchHistory[index]
                                        ['keyword']
                                    .toString());
                                setState(() {});
                              },
                              child: SvgPicture.asset(
                                'assets/icons/x.svg',
                                color: PeeroreumColor.gray[800],
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: PeeroreumColor.gray[100]));
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          search_clear = false;
        });
      },
      child: Scaffold(
        appBar: appbarWidget(),
        body: bodyWidget(),
      ),
    );
  }

  Future<void> goToSearchResult(String text) async {
    var result = await Navigator.push(
      context,
      PageRouteBuilder(
          pageBuilder: (_, __, ___) => SearchResultWedu(_searchController.text),
          transitionDuration: const Duration(seconds: 0),
          reverseTransitionDuration: const Duration(seconds: 0)),
    );

    if (result != null) {
      _loadSearchHistory();
    }
  }
}
