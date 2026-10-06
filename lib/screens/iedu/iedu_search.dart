import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/data/i_edu_search_history.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/screens/iedu/iedu_search_result.dart';

class SearchIedu extends StatefulWidget {
  const SearchIedu({super.key});

  @override
  State<SearchIedu> createState() => _SearchIeduState();
}

class _SearchIeduState extends State<SearchIedu> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchHistory = [];

  @override
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

  bool searchClear = false;

  PreferredSizeWidget appbarWidget() {
    return AppBar(
        backgroundColor: PeeroreumColor.white,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            colorFilter:
                ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.fromLTRB(0, 12, 20, 12),
          child: SearchBar(
            controller: _searchController,
            onTap: () {
              if (_searchController.text.isNotEmpty) {
                setState(() {
                  searchClear = true;
                });
              }
            },
            onSubmitted: (value) {
              if (_searchController.text.isNotEmpty) {
                _saveSearchHistory(_searchController.text);
                goToSearchResult(_searchController.text);
              } else {
                PeeroreumToast.show(context, '검색어를 입력하세요.');
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
            backgroundColor: WidgetStateProperty.all(PeeroreumColor.gray[100]),
            elevation: WidgetStateProperty.all(0),
            constraints: const BoxConstraints(minHeight: 40),
            hintText: '모르는 문제를 검색해 보세요!',
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
                        colorFilter: ColorFilter.mode(
                            PeeroreumColor.gray[600]!, BlendMode.srcIn),
                      ))
                  : Container(),
              const SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () {
                  if (_searchController.text.isNotEmpty) {
                    _saveSearchHistory(_searchController.text);
                    goToSearchResult(_searchController.text);
                  } else {
                    PeeroreumToast.show(context, '검색어를 입력하세요.');
                  }
                },
                child: SvgPicture.asset(
                  'assets/icons/search.svg',
                  colorFilter:
                      ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
                ),
              ),
              const SizedBox(
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
        children: [Expanded(child: recentSearch())],
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
              const Text(
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Get.to(() => SearchResultIedu(
                                  _searchHistory[index]['keyword'].toString()));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_searchHistory[index]['keyword']}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Pretendard',
                                      color: PeeroreumColor.gray[600]),
                                ),
                                Text(
                                  '${_searchHistory[index]['date']}',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: PeeroreumColor.gray[400]),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(
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
                                colorFilter: ColorFilter.mode(
                                    PeeroreumColor.gray[800]!, BlendMode.srcIn),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
          searchClear = false;
        });
      },
      child: Scaffold(
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
    var result = await Get.to(() => SearchResultIedu(_searchController.text));

    if (result != null) {
      _loadSearchHistory();
    }
  }
}
