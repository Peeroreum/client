import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/widgets/error_retry_view.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/data/i_edu_read.dart';
import 'package:peeroreum_client/data/i_edu_search_history.dart';
import 'package:peeroreum_client/data/subject.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/designs/peeroreum_typo.dart';
import 'package:peeroreum_client/screens/iedu/iedu_create.dart';
import 'package:peeroreum_client/screens/iedu/iedu_detail.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';

class SearchResultIedu extends StatefulWidget {
  final String keyword;

  const SearchResultIedu(this.keyword, {super.key});

  @override
  State<SearchResultIedu> createState() => _SearchResultIeduState();
}

class _SearchResultIeduState extends State<SearchResultIedu> {
  late Future initFuture;
  late String keyword;

  _SearchResultIeduState();

  List<Map<String, String>> _searchHistory = [];
  dynamic data;

  List<String> isReadList = [];

  int _grade = 0;
  String? _subject;
  String? _detailSubject;
  int subject = 0;
  int detailSubject = 0;

  final grades = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  final subjects = Subject.subject;
  final middleSubjects = Subject.middleSubject;
  final highSubjects = Subject.highSubject;
  List<String> subjectList = ['전체'];
  Map<String, List<String>> detailMiddleSubjects = {
    "전체": ["전체"]
  };
  Map<String, List<String>> detailHighSubjects = {
    "전체": ["전체"]
  };

  List<String> detailSubjects = [];

  int currentPage = 0;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  Map<String, Color> focusColor = {
    "grade": PeeroreumColor.gray[200]!,
    "subject": PeeroreumColor.gray[200]!,
    "detailSubject": PeeroreumColor.gray[200]!
  };

  @override
  void initState() {
    super.initState();
    keyword = widget.keyword;
    initFuture = fetchData();
    subjectList.addAll(subjects);
    detailMiddleSubjects.addAll(middleSubjects);
    detailHighSubjects.addAll(highSubjects);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        loadMoreData();
      }
    });
    currentPage = 0;
  }

  Future<void> fetchData() async {
    if (kDebugMode) {
      print(
          'fetch~~/question/search/$keyword?grade=$_grade&subject=$subject&detailSubject=$detailSubject&page=$currentPage');
    }
    var weduResult =
        await ApiClient().get('/question/search', queryParameters: {
      'keyword': keyword,
      'grade': _grade,
      'subject': subject,
      'detailSubject': detailSubject,
      'page': currentPage,
    });
    if (weduResult.statusCode == 200) {
      data = weduResult.data['data'];
      if (kDebugMode) {
        print(data.length);
        print(data);
      }
    } else {
      if (kDebugMode) {
        print("에러${weduResult.statusCode}");
      }
    }
    await getReadListData();
    setState(() {});
  }

  _loadSearchHistory() async {
    _searchHistory = await SearchIeduHistory.getSearchHistory();
    setState(() {});
  }

  _saveSearchHistory(String value) async {
    await SearchIeduHistory.addSearchItem(value);
    _loadSearchHistory();
  }

  bool searchClear = false;

  getReadListData() async {
    List<String>? data = await Read.getRead();
    isReadList = data!;
  }

  bool upCheck(String createdAt) {
    DateTime createdTime = DateTime.parse(createdAt);
    DateTime now = DateTime.now();

    Duration difference = now.difference(createdTime);
    if (difference.inHours >= 1) {
      return false;
    } else {
      return true;
    }
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

  // 현재 학년(중등/고등)과 과목 기준으로 세부과목 목록 구성
  void _updateDetailSubjects() {
    detailSubjects = ['전체'];
    if (_subject == null || _subject == '전체') return;
    final source = _grade <= 3 ? detailMiddleSubjects : detailHighSubjects;
    detailSubjects.addAll(source[_subject] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = keyword;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          searchClear = false;
        });
      },
      child: Scaffold(
          backgroundColor: PeeroreumColor.white,
          appBar: AppBar(
              backgroundColor: PeeroreumColor.white,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  colorFilter: ColorFilter.mode(
                      PeeroreumColor.gray[800]!, BlendMode.srcIn),
                ),
                onPressed: () {
                  Get.back(result: _searchHistory);
                },
              ),
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 20, 12),
                child: SearchBar(
                  controller: textEditingController,
                  onTap: () {
                    Get.back(result: _searchHistory);
                  },
                  backgroundColor:
                      WidgetStateProperty.all(PeeroreumColor.gray[100]),
                  elevation: WidgetStateProperty.all(0),
                  constraints: const BoxConstraints(minHeight: 40),
                  hintText: '모르는 문제를 검색해 보세요!!',
                  hintStyle: WidgetStateProperty.all(TextStyle(
                      color: PeeroreumColor.gray[600],
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
                  trailing: [
                    searchClear
                        ? GestureDetector(
                            onTap: () {
                              textEditingController.clear();
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
                        if ((textEditingController.text.isNotEmpty)) {
                          setState(() {
                            keyword = textEditingController.text;
                            fetchData();
                            _saveSearchHistory(keyword);
                          });
                        }
                      },
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        colorFilter: ColorFilter.mode(
                            Colors.grey[600]!, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              )),
          body: SafeArea(
            child: Container(
              color: PeeroreumColor.white,
              child: FutureBuilder<void>(
                future: initFuture,
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return ErrorRetryView(
                      onRetry: () => setState(() {
                        initFuture = fetchData();
                      }),
                    );
                  } else {
                    return data.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        '검색된 질문',
                                        style: TextStyle(
                                            color: PeeroreumColor.gray[800],
                                            fontFamily: 'Pretendard',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        '${data.length}',
                                        style: TextStyle(
                                            color: PeeroreumColor.gray[600],
                                            fontFamily: 'Pretendard',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: dropdownBody(),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/no_wedu_oreum.png',
                                        width: 150,
                                      ),
                                      const Text(
                                        '검색된 질문이 없어요',
                                        style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: PeeroreumColor.black),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Text(
                                        '질문을 작성해 보세요!',
                                        style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            color: PeeroreumColor.gray[700]),
                                      ),
                                      const SizedBox(
                                        height: 32,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => const CreateIedu());
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          height: 48,
                                          width: 208,
                                          decoration: BoxDecoration(
                                            color: PeeroreumColor
                                                .primaryPurple[400],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/pencil_with_line.svg',
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        PeeroreumColor.white,
                                                        BlendMode.srcIn),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              const T4(
                                                text: '내가해냄 질문하러 가기',
                                                color: PeeroreumColor.white,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 56,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    children: [
                                      Text(
                                        '검색된 내가해냄',
                                        style: TextStyle(
                                            color: PeeroreumColor.gray[800],
                                            fontFamily: 'Pretendard',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        '${data.length}',
                                        style: TextStyle(
                                            color: PeeroreumColor.gray[600],
                                            fontFamily: 'Pretendard',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ),
                                dropdownBody(),
                                const SizedBox(
                                  height: 16,
                                ),
                                Expanded(child: asks())
                              ],
                            ),
                          );
                  }
                },
              ),
            ),
          )),
    );
  }

  dropdownBody() {
    return Row(
      children: [
        // 학년
        GestureDetector(
          onTap: () {
            setState(() {
              focusColor["grade"] = PeeroreumColor.black;
              if (kDebugMode) {
                print(focusColor["grade"]);
              }
            });
            showModalBottomSheet(
                context: context,
                isScrollControlled: false,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return gradeSelect();
                }).then((value) {
              setState(() {
                focusColor["grade"] = PeeroreumColor.gray[200]!;
              });
            });
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: focusColor["grade"] ?? PeeroreumColor.gray[200]!,
              ),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Text(
                  grades[_grade],
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      color: _grade != 0
                          ? PeeroreumColor.black
                          : PeeroreumColor.gray[600]),
                ),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset('assets/icons/down.svg'),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        // 과목
        GestureDetector(
          onTap: () {
            setState(() {
              focusColor["subject"] = PeeroreumColor.black;
            });
            showModalBottomSheet(
                context: context,
                isScrollControlled: false,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return subjectSelect();
                }).then((value) {
              setState(() {
                focusColor["subject"] = PeeroreumColor.gray[200]!;
              });
            });
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: focusColor["subject"] ?? PeeroreumColor.gray[200]!,
              ),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Text(
                  _subject ?? '전체',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      color: _subject != null
                          ? PeeroreumColor.black
                          : PeeroreumColor.gray[600]),
                ),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset('assets/icons/down.svg'),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        // 상세 과목
        GestureDetector(
          onTap: () {
            if (_subject != null && subject != 0 && _grade != 0) {
              setState(() {
                focusColor["detailSubject"] = PeeroreumColor.black;
              });
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return detailSubjectSelect();
                  }).then((value) {
                setState(() {
                  focusColor["detailSubject"] = PeeroreumColor.gray[200]!;
                });
              });
            } else {
              PeeroreumToast.show(context, "학년과 과목을 모두 선택해 주세요.",
                  isError: true);
            }
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: focusColor["detailSubject"] ?? PeeroreumColor.gray[200]!,
              ),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Text(
                  _detailSubject ?? '전체',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      color: _detailSubject != null
                          ? PeeroreumColor.black
                          : PeeroreumColor.gray[600]),
                ),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset('assets/icons/down.svg'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  asks() {
    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: data.length + (_isLoading ? 1 : 0),
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        if (index < data.length) {
          return GestureDetector(
            onTap: () async {
              setState(() {
                if (!isReadList.contains(data[index]['id'].toString())) {
                  isReadList.add(data[index]['id'].toString());
                  Read.saveRead(isReadList);
                }
              });
              await Get.to(
                  () => DetailIedu(data[index]['id'], data[index]['selected']));
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                  color: isReadList.contains(data[index]['id'].toString())
                      ? PeeroreumColor.gray[100]
                      : PeeroreumColor.white,
                  border:
                      Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: data[index]['selected']
                            ? MediaQuery.of(context).size.width - 142
                            : MediaQuery.of(context).size.width - 133,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            upCheck(data[index]["createdTime"])
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEA),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const SizedBox(
                                      height: 16,
                                      child: Center(
                                        child: C2sb(
                                          text: 'UP',
                                          color: Color(0xFFF03A2E),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            upCheck(data[index]["createdTime"])
                                ? const SizedBox(
                                    width: 8,
                                  )
                                : Container(),
                            Flexible(
                                child: T4(
                              text: data[index]['title'],
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      data[index]['selected']
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                color: PeeroreumColor.primaryPurple[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const SizedBox(
                                height: 16,
                                child: Center(
                                  child: C2sb(
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
                                color: isReadList
                                        .contains(data[index]['id'].toString())
                                    ? PeeroreumColor.gray[300]
                                    : PeeroreumColor.gray[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SizedBox(
                                height: 16,
                                child: Center(
                                  child: C2sb(
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
                                color: data[index]["memberProfileDto"]
                                            ["grade"] !=
                                        null
                                    ? PeeroreumColor.gradeColor[data[index]
                                        ["memberProfileDto"]["grade"]]!
                                    : const Color.fromARGB(255, 186, 188, 189)),
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
                              image: data[index]["memberProfileDto"]
                                          ["profileImage"] !=
                                      null
                                  ? DecorationImage(
                                      image: NetworkImage(data[index]
                                          ["memberProfileDto"]["profileImage"]),
                                      fit: BoxFit.cover)
                                  : const DecorationImage(
                                      image:
                                          AssetImage('assets/images/user.jpg')),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: B4m(
                            text: data[index]["memberProfileDto"]["nickname"],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        C1m(
                          text: '${timeCheck(data[index]["createdTime"])} 전',
                          color: PeeroreumColor.gray[400],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: SvgPicture.asset(
                            'assets/icons/dot.svg',
                            colorFilter: ColorFilter.mode(
                                PeeroreumColor.gray[600]!, BlendMode.srcIn),
                          ),
                        ),
                        C1m(
                          text: '좋아요 ${data[index]["likes"]}개',
                          color: PeeroreumColor.gray[400],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: SvgPicture.asset(
                            'assets/icons/dot.svg',
                            colorFilter: ColorFilter.mode(
                                PeeroreumColor.gray[600]!, BlendMode.srcIn),
                          ),
                        ),
                        C1m(
                          text: '댓글 ${data[index]["comments"]}개',
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
        return null;
      },
    );
  }

  detailSubjectSelect() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                '세부 과목',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: detailSubjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _detailSubject = detailSubjects[index];
                          detailSubject = index;
                          currentPage = 0;
                        });
                        Get.back();
                        fetchData();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Text(
                          detailSubjects[index],
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  gradeSelect() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                '학년',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: grades.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          var checkGrade = index;
                          if ((1 <= _grade &&
                                  _grade <= 3 &&
                                  1 <= checkGrade &&
                                  checkGrade <= 3) ||
                              (4 <= _grade &&
                                  _grade <= 6 &&
                                  4 <= checkGrade &&
                                  checkGrade <= 6)) {
                            _grade = checkGrade;
                          } else {
                            _grade = index;
                            _detailSubject = null;
                          }
                          // 학년이 바뀌면 중등/고등 세부과목 목록이 달라지므로 다시 구성
                          _updateDetailSubjects();
                          currentPage = 0;
                          focusColor["grade"] = PeeroreumColor.gray[200]!;
                        });
                        Get.back();
                        fetchData();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Text(
                          grades[index],
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  subjectSelect() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                '과목',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: subjectList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _subject = subjectList[index];
                          subject = index;
                          _updateDetailSubjects();
                          _detailSubject = null;
                          currentPage = 0;
                          focusColor['subject'] = PeeroreumColor.gray[200]!;
                        });
                        Get.back();
                        fetchData();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Text(
                          subjectList[index],
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  loadMoreData() async {
    setState(() {
      _isLoading = true;
    });
    List<dynamic> addedData = [];
    currentPage++;
    var ieduResult =
        await ApiClient().get('/question/search', queryParameters: {
      'keyword': keyword,
      'grade': _grade,
      'subject': subject,
      'detailSubject': detailSubject,
      'page': currentPage,
    });
    if (ieduResult.statusCode == 200) {
      addedData = ieduResult.data['data'];
      setState(() {
        data.addAll(addedData);
        _isLoading = false;
      });
      if (kDebugMode) {
        print("성공 loadMoreData ${ieduResult.statusCode}");
      }
    } else {
      if (kDebugMode) {
        print("에러 loadMoreData ${ieduResult.statusCode}");
      }
    }
  }
}
