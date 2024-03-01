import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/data/IeduSearchHistory.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/iedu/iedu_search_result.dart';

class SearchIedu extends StatefulWidget {
  const SearchIedu({super.key});

  @override
  State<SearchIedu> createState() => _SearchIeduState();
}

class _SearchIeduState extends State<SearchIedu> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchHistory = [];

  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  _loadSearchHistory() async {
    _searchHistory = await SearchIeduHistory.getSearchHistory();
    setState(() {});
  }

  _saveSearchHistory(String value) async {
    await SearchIeduHistory.addSearchItem(value);
    _loadSearchHistory();
  }

  _deleteSearchHistory(String item) async {
    await SearchIeduHistory.deleteSearchItem(item);
    _loadSearchHistory();
  }

  _deleteAllSearchHistory() async {
    await SearchIeduHistory.deleteAllSearchItem();
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
            onSubmitted: (value) {
              if (_searchController.text.isNotEmpty) {
                _saveSearchHistory(_searchController.text);
                goToSearchResult(_searchController.text);
              } else {
                Fluttertoast.showToast(msg: '검색어를 입력하세요.');
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
            hintText: '모르는 문제를 검색해 보세요!',
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
                                  pageBuilder: (_, __, ___) => SearchResultIedu(
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
          pageBuilder: (_, __, ___) => SearchResultIedu(_searchController.text),
          transitionDuration: const Duration(seconds: 0),
          reverseTransitionDuration: const Duration(seconds: 0)),
    );

    if (result != null) {
      _loadSearchHistory();
    }
  }
}