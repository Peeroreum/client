// ignore_for_file: prefer_const_constructors, deprecated_member_use, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/data/IeduRead.dart';
import 'package:peeroreum_client/data/Subject.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/iedu/iedu_create.dart';
import 'package:peeroreum_client/screens/iedu/iedu_detail.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/screens/iedu/iedu_search.dart';

class HomeIedu extends StatefulWidget {
  const HomeIedu({super.key});

  @override
  State<HomeIedu> createState() => _HomeIeduState();
}

class _HomeIeduState extends State<HomeIedu> {
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

  List<dynamic> datas = [];
  List<String> isReadList = [];
  bool whyrano = false;

  var token;
  var nickname;
  var profileImage;
  var my_grade;
  int? _grade;
  String? _subject;
  String? _detailSubject;
  int subject = 0;
  int detailSubject = 0;

  late Future initFuture;
  int currentPage = 0;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  Map<String, Color> focusColor = {
    "grade": PeeroreumColor.gray[200]!,
    "subjet": PeeroreumColor.gray[200]!,
    "detailSubject": PeeroreumColor.gray[200]!
  };

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

  getReadlistData() async {
    List<String>? data = await Read.getRead();
    isReadList = data!;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFuture = fetchStatus();
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
    fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
        future: initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            // 에러 발생 시
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return RefreshIndicator(
              onRefresh: () => fetchStatus(),
              color: PeeroreumColor.primaryPuple[400],
              child: bodyWidget(),
            );
          }
        },
      ),
    );
  }

  Future<void> fetchStatus() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    my_grade = await FlutterSecureStorage().read(key: "grade");
    nickname = await FlutterSecureStorage().read(key: "nickname");
    profileImage = await FlutterSecureStorage().read(key: "profileImage");
    _grade ??= int.parse(my_grade!);

    await fetchIeduData();
    await getReadlistData();
  }

  fetchIeduData() async {
    currentPage = 0;
    var IeduResult = await http.get(
        Uri.parse(
            '${API.hostConnect}/question?grade=$_grade&subject=$subject&detailSubject=$detailSubject&page=$currentPage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (IeduResult.statusCode == 200) {
      print("성공 fetchIeduData ${IeduResult.statusCode}");
      datas = jsonDecode(utf8.decode(IeduResult.bodyBytes))['data'];
    } else {
      print("에러 fetchIeduData ${IeduResult.statusCode}");
    }
    if (mounted) {
      setState(() {});
    }
  }

  loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> addedDatas = [];
    currentPage++;
    var IeduResult = await http.get(
        Uri.parse(
            '${API.hostConnect}/question?grade=$_grade&subject=$subject&detailSubject=$detailSubject&page=$currentPage'),
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
      print("성공 loadMoreData ${IeduResult.statusCode}");
    } else {
      print("에러 loadMoreData ${IeduResult.statusCode}");
    }
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 12),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SearchIedu()));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: PeeroreumColor.gray[100],
                      borderRadius: BorderRadius.circular(37.0)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/search.svg',
                        color: PeeroreumColor.gray[600],
                      ),
                      SizedBox(width: 8.0),
                      SizedBox(
                        child: Text(
                          '모르는 문제를 검색해 보세요!',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
              child: GestureDetector(
                child: SvgPicture.asset(
                  'assets/icons/bell_none.svg',
                  color: PeeroreumColor.gray[800],
                ),
                onTap: () {
                  Fluttertoast.showToast(msg: "준비중입니다.");
                },
              ),
            ),
            SizedBox(
              width: 20,
            )
          ],
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Stack(alignment: Alignment.bottomRight, children: [
          Column(
            children: [
              dropdown_body(),
              datas.isEmpty ? noIedu() : Expanded(child: asks()),
              Container(
                height: 8,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              shape: CircleBorder(),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreateIedu();
                }));
              },
              elevation: 5,
              backgroundColor: PeeroreumColor.primaryPuple[400],
              child: SizedBox(
                width: 24,
                child: SvgPicture.asset(
                  'assets/icons/pencil_with_line.svg',
                  color: PeeroreumColor.white,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  dropdown_body() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // 학년
          GestureDetector(
            onTap: () {
              setState(() {
                focusColor["grade"] = PeeroreumColor.black;
              });
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
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
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    _grade != null
                        ? grades[_grade!]
                        : my_grade != null
                            ? grades[int.parse(my_grade!)]
                            : grades[0],
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
              setState(() {
                focusColor["subject"] = PeeroreumColor.black;
              });
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
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
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              if (_subject != null && _grade != 0) {
                setState(() {
                  focusColor["detailSubject"] = PeeroreumColor.black;
                });
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return detailSubjectSelect();
                    }).then((value) {
                  setState(() {
                    focusColor["detailSubject"] = PeeroreumColor.gray[200]!;
                  });
                });
              }
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      focusColor["detailSubject"] ?? PeeroreumColor.gray[200]!,
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

  gradeSelect() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.63,
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
                          _detailSubject = null;
                          detailSubject = 0;
                          focusColor["grade"] = PeeroreumColor.gray[200]!;
                        });
                        fetchIeduData();
                        Navigator.of(context).pop();
                        if (datas.isNotEmpty) {
                          _scrollController.animateTo(0,
                              duration: Duration(milliseconds: 750),
                              curve: Curves.ease);
                        }
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
      height: MediaQuery.of(context).size.height * 0.63,
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
                          detailSubject = 0;
                          focusColor['subject'] = PeeroreumColor.gray[200]!;
                          fetchIeduData();
                        });
                        Navigator.of(context).pop();
                        if (datas.isNotEmpty) {
                          _scrollController.animateTo(0,
                              duration: Duration(milliseconds: 750),
                              curve: Curves.ease);
                        }
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

  detailSubjectSelect() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
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
                          print(
                              '_detailSubject = $_detailSubject, detailSubject = $detailSubject');
                          fetchIeduData();
                        });
                        Navigator.of(context).pop();
                        if (datas.isNotEmpty) {
                          _scrollController.animateTo(0,
                              duration: Duration(milliseconds: 750),
                              curve: Curves.ease);
                        }
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

  asks() {
    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: datas.length + (_isLoading ? 1 : 0),
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        if (index < datas.length) {
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
              fetchIeduData();
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                  color: isReadList.contains(datas[index]['id'].toString())
                      ? PeeroreumColor.gray[100]
                      : PeeroreumColor.white,
                  border:
                      Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: datas[index]['selected']
                            ? MediaQuery.of(context).size.width - 142
                            : MediaQuery.of(context).size.width - 133,
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
                            Flexible(
                                child: T4_16px(
                              text: datas[index]['title'],
                              overflow: TextOverflow.ellipsis,
                            )),
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
                            text: datas[index]["memberProfileDto"]["nickname"],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        C1_12px_M(
                          text: '${timeCheck(datas[index]["createdTime"])} 전',
                          color: PeeroreumColor.gray[400],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: SvgPicture.asset(
                            'assets/icons/dot.svg',
                            color: PeeroreumColor.gray[400],
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
                            color: PeeroreumColor.gray[400],
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
        }
      },
    );
  }

  noIedu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 69,
        ),
        Image.asset(
          'assets/images/no_wedu_oreum.png',
          width: 150,
        ),
        Text(
          '찾으시는 질문이 없어요 🥲',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: PeeroreumColor.black,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }
}
