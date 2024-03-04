import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/data/IeduRead.dart';
import 'package:peeroreum_client/data/IeduSearchHistory.dart';
import 'package:peeroreum_client/data/Subject.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/iedu/iedu_detail.dart';

class SearchResultIedu extends StatefulWidget {
  final String keyword;
  SearchResultIedu(this.keyword);

  @override
  State<SearchResultIedu> createState() => _SearchResultIeduState(keyword);
}

class _SearchResultIeduState extends State<SearchResultIedu> {
  var token;

  String keyword;
  _SearchResultIeduState(this.keyword);

  List<Map<String, String>> _searchHistory = [];
  List<dynamic> datas = [];

  List<String> isReadList = [];

  int? _grade;
  String? _subject;
  String? _detailSubject;
  int subject = 0;
  int detailSubject = 0;

  final grades = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  final subjects = Subject.subject;
  final middleSubjects = Subject.middleSubject;
  final highSubjects = Subject.highSubject;
  List<String> Subjects = ['전체'];
  Map<String, List<String>> DetailMiddleSubjects = {
    "전체": ["전체"]
  };
  Map<String, List<String>> DetailHighSubjects = {
    "전체": ["전체"]
  };

  List<String> DetailSubjects = [];

  int currentPage = 0;
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Subjects.addAll(subjects);
    DetailMiddleSubjects.addAll(middleSubjects);
    DetailHighSubjects.addAll(highSubjects);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        loadMoreData();
      }
    });
    currentPage = 0;
    fetchDatas();
    
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    var weduResult = await http
        .get(Uri.parse('${API.hostConnect}/question/search/${keyword}'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (weduResult.statusCode == 200) {
      datas = jsonDecode(utf8.decode(weduResult.bodyBytes))['data'];
      print("데이터 fetch 완료 \n $datas");
    } else {
      print("에러${weduResult.statusCode}");
    }
    await getReadlistData();
  }

  _loadSearchHistory() async {
    _searchHistory = await SearchIeduHistory.getSearchHistory();
    setState(() {});
  }

  _saveSearchHistory(String value) async {
    await SearchIeduHistory.addSearchItem(value);
    _loadSearchHistory();
  }

  bool search_clear = false;

  getReadlistData() async {
    List<String>? data = await Read.getRead();
    isReadList = data!;
  }

  bool UpCheck(String createdAt) {
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
        return '${weeks}주';
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

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = keyword;
    //keyword = textEditingController.text;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          search_clear = false;
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
                  color: PeeroreumColor.gray[800],
                ),
                onPressed: () {
                  Navigator.of(context).pop(_searchHistory);
                },
              ),
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.fromLTRB(0, 12, 20, 12),
                child: SearchBar(
                  controller: textEditingController,
                  onTap: () {
                    Navigator.of(context).pop(_searchHistory);
                  },
                  backgroundColor:
                      MaterialStateProperty.all(PeeroreumColor.gray[100]),
                  elevation: MaterialStateProperty.all(0),
                  constraints: BoxConstraints(minHeight: 40),
                  hintText: '모르는 문제를 검색해 보세요!!',
                  hintStyle: MaterialStateProperty.all(TextStyle(
                      color: PeeroreumColor.gray[600],
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
                  trailing: [
                    search_clear
                        ? GestureDetector(
                            onTap: () {
                              textEditingController.clear();
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
                        if ((textEditingController.text.isNotEmpty)) {
                          setState(() {
                            keyword = textEditingController.text;
                            fetchDatas();
                            _saveSearchHistory(keyword);
                          });
                        }
                      },
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              )),
          body: FutureBuilder<void>(
            future: fetchDatas(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return datas.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 69,
                            ),
                            Image.asset('assets/images/no_wedu_oreum.png'),
                            Text(
                              '찾으시는 질문이 없어요 🥲',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              '다른 검색어를 입력해 보세요!',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: PeeroreumColor.gray[700]),
                            ),
                          ],
                        ),
                      )
                    : Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
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
                                  SizedBox(width: 4,),
                                  Text(
                                    '${datas.length}',
                                    style: TextStyle(
                                        color: PeeroreumColor.gray[600],
                                        fontFamily: 'Pretendard',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                            dropdown_body(),
                            SizedBox(height: 16,),
                            Expanded(child: asks())
                          ],
                        ),
                    );
              }
            },
          )),
    );
  }

  dropdown_body() {
    return Container(
      child: Row(
        children: [
          // 학년
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return gradeSelect();
                  });
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PeeroreumColor.gray[200]!,
                ),
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Text(
                    grades[0],
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        color: _grade != null
                            ? PeeroreumColor.black
                            : PeeroreumColor.gray[600]),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset('assets/icons/down.svg'),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          // 과목
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return subjectSelect();
                  });
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PeeroreumColor.gray[200]!,
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
                  SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset('assets/icons/down.svg'),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          // 상세 과목
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return detailSubjectSelect();
                  });
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PeeroreumColor.gray[200]!,
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
                  SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset('assets/icons/down.svg'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  asks() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: datas.length + (_isLoading ? 1 : 0),
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () async {
            setState(() {
              if (!isReadList.contains(datas[index]['id'].toString())) {
                isReadList.add(datas[index]['id'].toString());
                Read.saveRead(isReadList);
              }
            });
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailIedu(
                    datas[index]['id'], datas[index]['selected'])));
            setState(() {
              
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width - 40,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
                color: isReadList.contains(datas[index]['id'].toString())
                    ? PeeroreumColor.gray[100]
                    : PeeroreumColor.white,
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: datas[index]['selected']
                          ? MediaQuery.of(context).size.width - 141
                          : MediaQuery.of(context).size.width - 132,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UpCheck(datas[index]["createdTime"])
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFEBEA),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: SizedBox(
                                    height: 16,
                                    child: Center(
                                      child: C2_10px_Sb(
                                        text: 'UP',
                                        color: Color(0xFFF03A2E),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          UpCheck(datas[index]["createdTime"])
                              ? SizedBox(
                                  width: 8,
                                )
                              : Container(),
                          Flexible(child: T4_16px(text: datas[index]['title'])),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    datas[index]['selected']
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              color: PeeroreumColor.primaryPuple[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SizedBox(
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
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isReadList
                                      .contains(datas[index]['id'].toString())
                                  ? PeeroreumColor.gray[300]
                                  : PeeroreumColor.gray[200],
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
                SizedBox(
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
                              color: datas[index]["memberProfileDto"]
                                          ["grade"] !=
                                      null
                                  ? PeeroreumColor.gradeColor[datas[index]
                                      ["memberProfileDto"]["grade"]]!
                                  : Color.fromARGB(255, 186, 188, 189)),
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
                            image: datas[index]["memberProfileDto"]
                                        ["profileImage"] !=
                                    null
                                ? DecorationImage(
                                    image: NetworkImage(datas[index]
                                        ["memberProfileDto"]["profileImage"]),
                                    fit: BoxFit.cover)
                                : DecorationImage(
                                    image:
                                        AssetImage('assets/images/user.jpg')),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Flexible(
                        child: B4_14px_M(
                            text: datas[index]["memberProfileDto"]["nickname"]),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      C1_12px_M(
                        text: '${timeCheck(datas[index]["createdTime"])}전',
                        color: PeeroreumColor.gray[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: SvgPicture.asset(
                          'assets/icons/dot.svg',
                          color: PeeroreumColor.gray[600],
                        ),
                      ),
                      C1_12px_M(
                        text: '좋아요 ${datas[index]["likes"]}개',
                        color: PeeroreumColor.gray[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: SvgPicture.asset(
                          'assets/icons/dot.svg',
                          color: PeeroreumColor.gray[600],
                        ),
                      ),
                      C1_12px_M(
                        text: '댓글 ${datas[index]["comments"]}개',
                        color: PeeroreumColor.gray[400],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
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
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
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
                itemCount: DetailSubjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _detailSubject = DetailSubjects[index];
                          detailSubject = index;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          DetailSubjects[index],
                          style: TextStyle(
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
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
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
                          _grade = index;
                          _subject = null;
                          _detailSubject = null;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          grades[index],
                          style: TextStyle(
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
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
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
                itemCount: Subjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _subject = Subjects[index];
                          subject = index;
                          DetailSubjects = ['전체'];
                          List<String> AddDetailSubjects;
                          AddDetailSubjects = ((_grade! <= 3)
                              ? DetailMiddleSubjects[_subject]
                              : DetailHighSubjects[_subject])!;
                          if (index != 0) {
                            DetailSubjects.addAll(AddDetailSubjects);
                          }
                          _detailSubject = null;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          Subjects[index],
                          style: TextStyle(
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

    List<dynamic> addedDatas = [];
    currentPage++;
    var IeduResult = await http.get(
        Uri.parse(
            '${API.hostConnect}/question/search/${keyword}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (IeduResult.statusCode == 200) {
      addedDatas = jsonDecode(utf8.decode(IeduResult.bodyBytes))['data'];
      setState(() {
        datas.addAll(addedDatas);
        _isLoading = false;
      });
    } else {
      print("에러 loadMoreData ${IeduResult.statusCode}");
    }
  }
}