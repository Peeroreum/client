import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/data/IeduRead.dart';
import 'package:peeroreum_client/data/Subject.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/alert/alert_view.dart';
import 'package:peeroreum_client/screens/iedu/iedu_create.dart';
import 'package:peeroreum_client/screens/iedu/iedu_detail.dart';
import 'package:peeroreum_client/screens/iedu/iedu_search.dart';
import 'package:peeroreum_client/screens/iedu/iedu_skeleton.dart';

class HomeIedu extends StatefulWidget {
  const HomeIedu({super.key});

  @override
  State<HomeIedu> createState() => _HomeIeduState();
}

class _HomeIeduState extends State<HomeIedu> {
  final grades = ['전체', '중1', '중2', '중3', '고1', '고2', '고3', '대학'];
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

  List<dynamic> data = [];
  List<String> isReadList = [];
  bool whyrano = false;

  var nickname;
  var profileImage;
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

  getReadListData() async {
    List<String>? data = await Read.getRead();
    isReadList = data!;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFuture = fetchStatus();
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
            return const SkeletonIedu();
          } else if (snapshot.hasError) {
            // 에러 발생 시
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return RefreshIndicator(
              onRefresh: () => fetchStatus(),
              color: PeeroreumColor.primaryPuple[400],
              child: SafeArea(
                child: Container(
                  color: PeeroreumColor.white,
                  child: bodyWidget(),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> fetchStatus() async {
    nickname = await const FlutterSecureStorage().read(key: "nickname");
    profileImage = await const FlutterSecureStorage().read(key: "profileImage");
    _grade = 0;

    await fetchIeduData();
    await getReadListData();
  }

  fetchIeduData() async {
    currentPage = 0;
    try {
      var ieduResult = await ApiClient().get(
          '/question?grade=$_grade&subject=$subject&detailSubject=$detailSubject&page=$currentPage');
      if (ieduResult.statusCode == 200) {
        print("성공 fetchIeduData ${ieduResult.statusCode}");
        data = ieduResult.data['data'];
      } else {
        print("에러 fetchIeduData ${ieduResult.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
    if (mounted) {
      setState(() {});
    }
  }

  void loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> addedData = [];
    currentPage++;
    try {
      var ieduResult = await ApiClient().get(
          '/question?grade=$_grade&subject=$subject&detailSubject=$detailSubject&page=$currentPage');
      if (ieduResult.statusCode == 200) {
        addedData = ieduResult.data['data'];
        setState(() {
          data.addAll(addedData);
          _isLoading = false;
        });
        print("성공 loadMoreData ${ieduResult.statusCode}");
      } else {
        print("에러 loadMoreData ${ieduResult.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        _isLoading = false;
      });
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
        padding: const EdgeInsets.fromLTRB(20, 20, 0, 12),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const SearchIedu());
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: PeeroreumColor.gray[100],
                      borderRadius: BorderRadius.circular(37.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/search.svg',
                        color: PeeroreumColor.gray[600],
                      ),
                      const SizedBox(width: 8.0),
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
            const SizedBox(
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
                  Get.to(() => Alert());
                },
              ),
            ),
            const SizedBox(
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
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Stack(alignment: Alignment.bottomRight, children: [
          Column(
            children: [
              dropdownBody(),
              data.isEmpty
                  ? Expanded(child: noIedu())
                  : Expanded(child: asks()),
              Container(
                height: 8,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () {
                Get.to(() => const CreateIedu());
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

  dropdownBody() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
                    _grade != null ? grades[_grade!] : grades[0],
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        color: _grade != null
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
          AbsorbPointer(
            absorbing: _grade == 7,
            child: GestureDetector(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: focusColor["subject"] ?? PeeroreumColor.gray[200]!,
                  ),
                  color: _grade == 7
                      ? PeeroreumColor.gray[100]
                      : Colors.transparent,
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
          ),
          const SizedBox(
            width: 8,
          ),
          // 상세 과목
          AbsorbPointer(
            absorbing: _grade == 7,
            child: GestureDetector(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: focusColor["detailSubject"] ??
                        PeeroreumColor.gray[200]!,
                  ),
                  color: _grade == 7
                      ? PeeroreumColor.gray[100]
                      : Colors.transparent,
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
                          _grade = index;
                          _detailSubject = null;
                          detailSubject = 0;
                          focusColor["grade"] = PeeroreumColor.gray[200]!;
                          if (_grade == 7) {
                            _subject = null;
                            subject = 0;
                          }
                        });
                        fetchIeduData();
                        Get.back();
                        if (data.isNotEmpty) {
                          _scrollController.animateTo(0,
                              duration: const Duration(milliseconds: 750),
                              curve: Curves.ease);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          detailSubjects = ['전체'];
                          List<String> addDetailSubjects;
                          addDetailSubjects = ((_grade! <= 3)
                              ? detailMiddleSubjects[_subject]
                              : detailHighSubjects[_subject])!;
                          if (index != 0) {
                            detailSubjects.addAll(addDetailSubjects);
                          }
                          _detailSubject = null;
                          detailSubject = 0;
                          focusColor['subject'] = PeeroreumColor.gray[200]!;
                          fetchIeduData();
                        });
                        Get.back();
                        if (data.isNotEmpty) {
                          _scrollController.animateTo(0,
                              duration: const Duration(milliseconds: 750),
                              curve: Curves.ease);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          print(
                              '_detailSubject = $_detailSubject, detailSubject = $detailSubject');
                          fetchIeduData();
                        });
                        Get.back();
                        if (data.isNotEmpty) {
                          _scrollController.animateTo(0,
                              duration: const Duration(milliseconds: 750),
                              curve: Curves.ease);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              await Get.to(() =>
                  DetailIedu(data[index]['id'], data[index]['selected']));
              fetchIeduData();
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
                                        child: C2_10px_Sb(
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
                                child: T4_16px(
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
                                color: PeeroreumColor.primaryPuple[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const SizedBox(
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
                                  child: C2_10px_Sb(
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
                          child: B4_14px_M(
                            text: data[index]["memberProfileDto"]["nickname"],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        C1_12px_M(
                          text: '${timeCheck(data[index]["createdTime"])} 전',
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
                          text: '좋아요 ${data[index]["likes"]}개',
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
      },
    );
  }

  noIedu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/no_wedu_oreum.png',
          width: 150,
        ),
        const Text(
          '찾으시는 질문이 없어요 🥲',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: PeeroreumColor.black,
          ),
        ),
        const SizedBox(
          height: 56,
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
