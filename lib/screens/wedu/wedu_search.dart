// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/screens/wedu/wedu_search_result_screen.dart';

import '../../data/wedu_search_history.dart';

class SearchWedu extends StatefulWidget {
  const SearchWedu({super.key});

  @override
  State<SearchWedu> createState() => _SearchWeduState();
}

class _SearchWeduState extends State<SearchWedu> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Map<String, String>> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  _loadSearchHistory() async {
    _searchHistory = await SearchHistory.getSearchHistory();
    setState(() {});
  }


  _deleteSearchHistory(String item) async {
    await SearchHistory.deleteSearchItem(item);
    _loadSearchHistory();
  }

  _deleteAllSearchHistory() async {
    await SearchHistory.deleteAllSearchItem();
    _loadSearchHistory();
  }

  bool searchClear = false;

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
            colorFilter: ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: Container(
          margin: EdgeInsets.fromLTRB(0, 12, 20, 12),
          child: SearchBar(
            controller: _searchController,
            focusNode: _searchFocus,
            autoFocus: true,
            onTap: () {
              if (_searchController.text.isNotEmpty) {
                setState(() {
                  searchClear = true;
                });
              }
            },
            onSubmitted: (value) {
              if (_searchController.text.isNotEmpty) {
                goToSearchResult(_searchController.text);
              } else {
                PeeroreumToast.show(context, '검색어를 입력하세요.', isError: true);
              }
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  searchClear = true;
                });
              } else {
                setState(() {
                  searchClear = false;
                });
              }
            },
            backgroundColor:
                WidgetStateProperty.all(PeeroreumColor.gray[100]),
            elevation: WidgetStateProperty.all(0),
            constraints: BoxConstraints(minHeight: 40),
            hintText: '같이방에서 함께 공부해요!',
            hintStyle: WidgetStateProperty.all(TextStyle(
                color: PeeroreumColor.gray[600],
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w400)),
            trailing: [
              searchClear
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          searchClear = false;
                        });
                      },
                      child: SvgPicture.asset(
                        'assets/icons/x_circle.svg',
                        colorFilter: ColorFilter.mode(PeeroreumColor.gray[600]!, BlendMode.srcIn),
                      ))
                  : Container(),
              SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () {
                  if (_searchController.text.isNotEmpty) {
                    goToSearchResult(_searchController.text);
                  } else {
                    PeeroreumToast.show(context, '검색어를 입력하세요.', isError: true);
                  }
                },
                child: SvgPicture.asset(
                  'assets/icons/search.svg',
                  colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
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
                            width: 1, color: PeeroreumColor.primaryPurple[400]!),
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '#',
                          style: TextStyle(
                              color: PeeroreumColor.primaryPurple[200]),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${_searchHistory[index]["search_word"]}',
                          style: TextStyle(
                              color: PeeroreumColor.primaryPurple[400]),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색어',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.gray[800]),
              ),
              if (_searchHistory.isNotEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _deleteAllSearchHistory();
                    setState(() {});
                  },
                  child: Text(
                    '전체 삭제',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: PeeroreumColor.gray[400]),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _searchHistory.isEmpty
              ? emptyRecentSearch()
              : ListView.builder(
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    final keyword = _searchHistory[index]['keyword'].toString();
                    return InkWell(
                      onTap: () => goToSearchResult(keyword),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 11, 12, 11),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                keyword,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: PeeroreumColor.gray[800]),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              shortDate(_searchHistory[index]['date']),
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: PeeroreumColor.gray[400]),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _deleteSearchHistory(keyword);
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: SvgPicture.asset(
                                  'assets/icons/x.svg',
                                  width: 14,
                                  height: 14,
                                  colorFilter: ColorFilter.mode(
                                      PeeroreumColor.gray[400]!,
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 저장 형식 yy.MM.dd → 올해면 MM.dd, 지난해 이전이면 yy.MM.dd 그대로
  String shortDate(dynamic date) {
    final value = date?.toString() ?? '';
    final thisYear = (DateTime.now().year % 100).toString().padLeft(2, '0');
    return value.length == 8 && value.startsWith('$thisYear.')
        ? value.substring(3)
        : value;
  }

  Widget emptyRecentSearch() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/search.svg',
            width: 28,
            height: 28,
            colorFilter:
                ColorFilter.mode(PeeroreumColor.gray[300]!, BlendMode.srcIn),
          ),
          const SizedBox(height: 10),
          Text(
            '최근 검색어가 없어요',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          searchClear = false;
        });
      },
      child: Scaffold(
        backgroundColor: PeeroreumColor.white,
        appBar: appbarWidget(),
        body: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            child: bodyWidget(),
          ),
        ),
      ),
    );
  }

  Future<void> goToSearchResult(String text) async {
    // 최근 검색어로 들어가도 맨 위로 올리고, 입력창에도 같은 검색어 유지
    _searchController.text = text;
    setState(() {
      searchClear = text.isNotEmpty;
    });
    _searchFocus.unfocus();
    await SearchHistory.addSearchItem(text);
    final result = await Get.to(() => SearchResultWedu(text));
    if (!mounted) return;
    _loadSearchHistory();

    // 결과 화면 검색창을 눌러 돌아온 경우: 검색어 끝에 커서를 두고 키보드 열기
    if (result == 'edit') {
      _searchController.selection =
          TextSelection.collapsed(offset: _searchController.text.length);
      _searchFocus.requestFocus();
    }
  }
}
