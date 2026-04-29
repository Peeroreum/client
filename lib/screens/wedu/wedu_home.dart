// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:dio/dio.dart' as dio;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/alert/alert_view.dart';
import 'package:peeroreum_client/screens/wedu/wedu_create_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:peeroreum_client/screens/wedu/wedu_search.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:peeroreum_client/screens/wedu/wedu_skeleton.dart';
import 'package:peeroreum_client/screens/wedu/wedu_room_info_sheet.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart';
import 'package:share_plus/share_plus.dart';

class HomeWedu extends StatefulWidget {
  const HomeWedu({super.key});

  @override
  State<HomeWedu> createState() => _HomeWeduState();
}

class _HomeWeduState extends State<HomeWedu> {
  var token, nickname;
  int selectedIndex = 1;
  List<dynamic> datas = [];
  List<dynamic> inroom_datas = [];
  Map<dynamic, dynamic> inviDatas = {};
  Map<dynamic, List<dynamic>> hashTags = {};
  List<Map<String, String>> searchData = [];
  List<String> dropdownGradeList = [
    '전체',
    '중1',
    '중2',
    '중3',
    '고1',
    '고2',
    '고3',
    '대학'
  ];
  List<String> dropdownSubjectList = [
    '전체',
    '국어',
    '영어',
    '수학',
    '사회',
    '과학',
    '기타',
    '대학'
  ];
  List<String> dropdownSortTypeList = ['최신순', '추천순', '인기순'];
  String selectedGrade = '전체';
  String selectedSubject = '전체';
  String selectedSortType = '최신순';

  var grade = 0;
  var subject = 0;

  late Future initFuture;

  ScrollController _scrollController = ScrollController();
  int currentPage = 0;
  bool _isLoading = false;
  bool _isUp = true;

  @override
  void initState() {
    super.initState();
    initFuture = fetchDatas();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        loadMoreData();
      }
      if (_scrollController.offset ==
          _scrollController.position.minScrollExtent) {
        setState(() {
          _isUp = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isUp = false;
        });
      }
    });
    currentPage = 0;
  }

  /// 같이방 초대 딥링크 생성: peeroreum://wedu/{roomId}
  String getInviteLink(String roomId) {
    return 'peeroreum://wedu/$roomId';
  }

  /// 공유 메시지 생성 (앱 미설치 사용자를 위한 스토어 링크 포함)
  String buildShareMessage(String roomName, String roomId) {
    return '📚 피어오름 같이방 \'$roomName\'에 초대합니다!\n\n'
        '앱이 설치된 경우 아래 링크를 눌러 바로 입장하세요:\n'
        '${getInviteLink(roomId)}\n\n'
        '앱이 없다면 설치 후 참여해요 🙌\n'
        '• 안드로이드: https://play.google.com/store/apps/details?id=com.peeroreum.peeroreum_client\n'
        '• iOS: https://apps.apple.com/app/id피어오름앱ID';
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    nickname = await FlutterSecureStorage().read(key: "nickname");

    await fetchInWeduData();
    await fetchWeduData();
  }

  fetchInWeduData() async {
    var dio1 = dio.Dio();
    try {
      var inWeduResult = await dio1.get(
          '${API.hostConnect}/wedu/in?nickname=$nickname',
          options: dio.Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }));
      if (inWeduResult.statusCode == 200) {
        inroom_datas = inWeduResult.data['data'];
      } else {
        print("에러${inWeduResult.statusCode}");
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        print('Dio error! STATUS: ${e.response?.statusCode}');
      } else {
        print('Error sending request! ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  fetchWeduData() async {
    currentPage = 0;
    var dio1 = dio.Dio();
    try {
      var weduResult = await dio1.get(
          '${API.hostConnect}/wedu?sort=$selectedSortType&grade=$grade&subject=$subject&page=$currentPage',
          options: dio.Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }));
      if (weduResult.statusCode == 200) {
        datas = weduResult.data['data'];
        fetchImage(datas);
      } else {
        print("에러${weduResult.statusCode}");
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        print('Dio error! STATUS: ${e.response?.statusCode}');
      } else {
        print('Error sending request! ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
    if (mounted) {
      setState(() {});
    }
  }

  fetchImage(datas) async {
    var inviData;
    for (var data in datas) {
      inviData = await fetchInvitation(data['id']);
      inviDatas.addAll({data['id']: inviData});
      hashTags.addAll({data['id']: inviData['hashTags']});
    }
  }

  void loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> addedDatas = [];
    currentPage++;
    var dio1 = dio.Dio();
    try {
      var weduResult = await dio1.get(
          '${API.hostConnect}/wedu?sort=$selectedSortType&grade=$grade&subject=$subject&page=$currentPage',
          options: dio.Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }));
      if (weduResult.statusCode == 200) {
        addedDatas = weduResult.data['data'];
        setState(() {
          datas.addAll(addedDatas);
          _isLoading = false;
        });
      } else {
        print("에러${weduResult.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        print('Dio error! STATUS: ${e.response?.statusCode}');
      } else {
        print('Error sending request! ${e.message}');
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        _isLoading = false;
      });
    }

    fetchImage(addedDatas);
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      // systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 12),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          //mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: GestureDetector(
                onTap: () {
                  Get.to(() => searchWedu());
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
                          '같이방에서 함께 공부해요!',
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
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: 24,
                height: 24,
                margin: EdgeInsets.only(right: 8),
                child: SvgPicture.asset(
                  'assets/icons/plus_square2.svg',
                  color: PeeroreumColor.gray[800],
                  width: 24,
                  height: 24,
                ),
              ),
              onTap: () {
                if (inroom_datas.length < 10) {
                  Get.to(() => CreateWedu());
                } else {
                  PeeroreumToast.show(context, '같이방은 10개까지만 참여 가능해요.');
                }
              },
            ),
            GestureDetector(
              child: SvgPicture.asset(
                'assets/icons/bell_none.svg',
                color: PeeroreumColor.gray[800],
              ),
              onTap: () {
                Get.to(() => Alert());
              },
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
      appBar: room_body(),
      body: NestedScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              if (inroom_datas.isNotEmpty)
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: false,
                  floating: true,
                  backgroundColor: PeeroreumColor.white,
                  elevation: 0,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: Column(
                          children: [
                            SizedBox(
                              height: 180,
                              child: in_room_body(),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ];
          },
          body: datas.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    sliver(),
                    Image.asset(
                      'assets/images/no_wedu_oreum.png',
                      width: 150,
                    ),
                    Text(
                      '찾으시는 같이방이 없어요 🥲',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: PeeroreumColor.black,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    sliver(),
                    Container(
                      height: _isUp ? 0 : 1,
                      color: PeeroreumColor.gray[200],
                    ),
                    Expanded(child: listview_body()),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                )),
    );
  }

  Widget sliver() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 8,
          color: PeeroreumColor.gray[50],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '같이방',
                style: TextStyle(
                  color: PeeroreumColor.gray[800],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
        ),
        dropdown_body(),
      ],
    );
  }

  PreferredSizeWidget room_body() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "참여 중인 같이방",
                  style: TextStyle(
                      color: PeeroreumColor.black,
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  '${inroom_datas.length}',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.gray[600]),
                ),
              ],
            ),
            GestureDetector(
                onTap: () {
                  Get.to(() => InWedu());
                },
                child: Text('전체보기',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: PeeroreumColor.gray[500])))
          ],
        ),
      ),
    );
  }

  Widget in_room_body() {
    return FutureBuilder<void>(
        future: fetchInWeduData(),
        builder: (context, snapshot) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            // shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: inroom_datas.length,
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                width: 8,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              int rindex = inroom_datas.length - 1 - index;
              return GestureDetector(
                child: Container(
                  width: 150,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: PeeroreumColor.gray[50],
                          border: Border.all(
                              width: 1, color: PeeroreumColor.gray[200]!),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: (inroom_datas[rindex]['imagePath'] != null)
                              ? Image.network(
                                  inroom_datas[rindex]['imagePath'],
                                  fit: BoxFit.cover,
                                )
                              : SvgPicture.asset(
                                  'assets/images/default.svg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              color: PeeroreumColor.subjectColor[
                                  dropdownSubjectList[inroom_datas[rindex]
                                      ['subject']]]?[0],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                dropdownSubjectList[inroom_datas[rindex]
                                    ['subject']],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: PeeroreumColor.subjectColor[
                                      dropdownSubjectList[inroom_datas[rindex]
                                          ['subject']]]?[1],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          SizedBox(
                            width: 90,
                            height: 24,
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  inroom_datas[rindex]["title"]!,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: PeeroreumColor.black,
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dropdownGradeList[inroom_datas[rindex]["grade"]],
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: PeeroreumColor.gray[600])),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: SvgPicture.asset(
                              'assets/icons/dot.svg',
                              color: PeeroreumColor.gray[600],
                            ),
                          ),
                          Text(
                              '${inroom_datas[rindex]["attendingPeopleNum"]!}명',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: PeeroreumColor.gray[600])),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: SvgPicture.asset(
                              'assets/icons/dot.svg',
                              color: PeeroreumColor.gray[600],
                            ),
                          ),
                          inroom_datas[rindex]["dday"] > 0
                              ? Text('D-${inroom_datas[rindex]["dday"]!}',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: PeeroreumColor.gray[600]))
                              : Text(
                                  'D+${inroom_datas[rindex]["dday"].toString().substring(1)}',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: PeeroreumColor.gray[600])),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        '${inroom_datas[rindex]["progress"]}% 달성', //이후 퍼센티지 수정
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: PeeroreumColor.primaryPuple[400]),
                      )
                    ],
                  ),
                ),
                onTap: () async {
                  await Get.to(() => DetailWedu(inroom_datas[rindex]["id"]));
                  fetchDatas();
                },
              );
            },
          );
        });
  }

  Widget dropdown_body() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: PeeroreumColor.gray[200]!, width: 1),
                      borderRadius: BorderRadius.circular(8)),
                  child: SizedBox(
                    width: 75,
                    height: 40,
                    child: DropdownButton2(
                        buttonStyleData: const ButtonStyleData(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          height: 40,
                          width: 75,
                        ),
                        iconStyleData: IconStyleData(
                          icon: SvgPicture.asset('assets/icons/down.svg',
                              color: PeeroreumColor.gray[600]),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          elevation: 0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: PeeroreumColor.gray[200]!),
                            color: PeeroreumColor.white,
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: 44,
                        ),
                        underline: SizedBox.shrink(),
                        value: selectedGrade,
                        items: dropdownGradeList.map((String item) {
                          return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ));
                        }).toList(),
                        onChanged: (dynamic value) {
                          setState(() {
                            selectedGrade = value;
                            grade = dropdownGradeList.indexOf(selectedGrade);
                            fetchWeduData();
                          });
                        }),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: PeeroreumColor.gray[200]!, width: 1),
                      borderRadius: BorderRadius.circular(8)),
                  child: SizedBox(
                    width: 75,
                    height: 40,
                    child: DropdownButton2(
                        buttonStyleData: const ButtonStyleData(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          height: 40,
                          width: 75,
                        ),
                        iconStyleData: IconStyleData(
                          icon: SvgPicture.asset('assets/icons/down.svg',
                              color: PeeroreumColor.gray[600]),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          elevation: 0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: PeeroreumColor.gray[200]!),
                            color: PeeroreumColor.white,
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: 44,
                        ),
                        underline: SizedBox.shrink(),
                        value: selectedSubject,
                        items: dropdownSubjectList.map((String item) {
                          return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ));
                        }).toList(),
                        onChanged: (dynamic value) {
                          setState(() {
                            selectedSubject = value;
                            subject =
                                dropdownSubjectList.indexOf(selectedSubject);
                            fetchWeduData();
                          });
                        }),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(color: PeeroreumColor.gray[200]!, width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: SizedBox(
              width: 87,
              height: 40,
              child: DropdownButton2(
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  height: 40,
                  width: 87,
                ),
                iconStyleData: IconStyleData(
                  icon: SvgPicture.asset('assets/icons/down.svg',
                      color: PeeroreumColor.gray[600]),
                ),
                dropdownStyleData: DropdownStyleData(
                  elevation: 0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PeeroreumColor.gray[200]!),
                    color: PeeroreumColor.white,
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 44,
                ),
                underline: SizedBox.shrink(),
                value: selectedSortType,
                items: dropdownSortTypeList.map((String item) {
                  return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ));
                }).toList(),
                onChanged: (dynamic value) {
                  setState(() {
                    selectedSortType = value;
                    fetchWeduData();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listview_body() {
    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: datas.length + (_isLoading ? 1 : 0),
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        if (index < datas.length) {
          return GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                  border:
                      Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PeeroreumColor.gray[50],
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: (datas[index]["imagePath"] != null)
                          ? Image.network(
                              datas[index]["imagePath"],
                              fit: BoxFit.cover,
                            )
                          : SvgPicture.asset(
                              'assets/images/default.svg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  color: PeeroreumColor.subjectColor[
                                      dropdownSubjectList[datas[index]
                                          ['subject']]]?[0],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  child: Text(
                                    dropdownSubjectList[datas[index]
                                        ['subject']],
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: PeeroreumColor.subjectColor[
                                          dropdownSubjectList[datas[index]
                                              ['subject']]]?[1],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              datas[index]['locked'].toString() == "true"
                                  ? SvgPicture.asset('assets/icons/lock.svg',
                                      color: PeeroreumColor.gray[400],
                                      width: 12)
                                  : SizedBox(),
                              datas[index]['locked'].toString() == "true"
                                  ? SizedBox(
                                      width: 4,
                                    )
                                  : SizedBox(),
                              Flexible(
                                child: Text(
                                  datas[index]["title"]!,
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: PeeroreumColor.black),
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   height: 4,
                          // ),
                          Row(
                            children: [
                              Text(dropdownGradeList[datas[index]["grade"]],
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: PeeroreumColor.gray[600])),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                              Text('${datas[index]["attendingPeopleNum"]!}명',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: PeeroreumColor.gray[600])),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                              datas[index]["dday"] > 0
                                  ? Text('D-${datas[index]["dday"]!}',
                                      style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: PeeroreumColor.gray[600]))
                                  : Text(
                                      'D+${datas[index]["dday"].toString().substring(1)}',
                                      style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: PeeroreumColor.gray[600])),
                            ],
                          )
                        ]),
                  )
                ],
              ),
            ),
            onTap: () {
              WeduRoomInfoSheet.show(
                context,
                roomData: datas[index],
                inviData: inviDatas[datas[index]['id']] ?? {},
                hashTagsList: hashTags[datas[index]['id']] ?? [],
                isAlreadyJoined: inroom_datas
                    .any((item) => item['id'] == datas[index]['id']),
                onShare: () async {
                  final roomId = datas[index]['id'].toString();
                  final thuUrl = (inviDatas[datas[index]['id']]
                              ?['invitationUrl'] ?? '')
                          .toString();
                  final roomName = datas[index]['title'] as String? ?? '';
                  final storeUrl = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.peeroreum.peeroreum_client');
                  final feedLink = Link(
                    androidExecutionParams: {'roomId': roomId},
                    iosExecutionParams: {'roomId': roomId},
                    webUrl: storeUrl,
                    mobileWebUrl: storeUrl,
                  );
                  final feedTemplate = FeedTemplate(
                    content: Content(
                      title: '📚 $roomName',
                      description: '피어오름 같이방에 초대합니다!',
                      imageUrl: Uri.parse(thuUrl),
                      link: feedLink,
                    ),
                    buttons: [Button(title: '참여하기', link: feedLink)],
                  );
                  final available = await ShareClient.instance
                      .isKakaoTalkSharingAvailable();
                  if (available) {
                    try {
                      final uri = await ShareClient.instance
                          .shareDefault(template: feedTemplate);
                      await ShareClient.instance.launchKakaoTalk(uri);
                    } catch (e) {
                      Share.share(buildShareMessage(roomName, roomId));
                    }
                  } else {
                    Share.share(buildShareMessage(roomName, roomId));
                  }
                },
                onEnroll: () {
                  if (inroom_datas.length < 10) {
                    Get.back();
                    datas[index]['locked'].toString() == 'true'
                        ? insertPassword(index)
                        : enrollWedu(index);
                    fetchDatas();
                    setState(() {});
                  } else {
                    PeeroreumToast.show(context, '같이방은 10개까지만 참여 가능해요.');
                  }
                },
              );
            },
          );
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SkeletonWedu();
            } else if (snapshot.hasError) {
              // 에러 발생 시
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return RefreshIndicator(
                onRefresh: () => fetchDatas(),
                color: PeeroreumColor.primaryPuple[400],
                child: SafeArea(
                  child: Container(
                    color: PeeroreumColor.white,
                    child: bodyWidget(),
                  ),
                ),
              );
            }
          }),
    );
  }

  fetchInvitation(id) async {
    var dio1 = dio.Dio();
    try {
      var inviResult = await dio1.get('${API.hostConnect}/wedu/$id/invitation',
          options: dio.Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }));
      if (inviResult.statusCode == 200) {
        return inviResult.data['data'];
      } else {
        print("에러${inviResult.statusCode}");
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        print('Dio error! STATUS: ${e.response?.statusCode}');
      } else {
        print('Error sending request! ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  void enrollWedu(index) async {
    var id = datas[index]['id'];
    var dio1 = dio.Dio();
    try {
      var enrollResult = await dio1.post('${API.hostConnect}/wedu/$id/enroll',
          options: dio.Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }));
      if (enrollResult.statusCode == 200) {
        PeeroreumToast.show(context, "같이방에 참여했어요!");
      } else {
        PeeroreumToast.show(context, "잠시 후에 다시 시도해 주세요.");
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 409) {
          PeeroreumToast.show(context, '이미 참여 중인 같이방이에요.');
        } else if (e.response?.statusCode == 404) {
          PeeroreumToast.show(context, '존재하지 않는 같이방입니다.');
        } else {
          PeeroreumToast.show(context, "잠시 후에 다시 시도해 주세요.");
          print("에러${e.response?.statusCode}");
        }
      } else {
        PeeroreumToast.show(context, "잠시 후에 다시 시도해 주세요.");
        print("Error sending request! ${e.message}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }
    setState(() {});
  }

  void insertPassword(index) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: PeeroreumColor.white,
            surfaceTintColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            iconPadding: EdgeInsets.zero,
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "비밀번호",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                      color: PeeroreumColor.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    color: PeeroreumColor.white,
                    height: 48,
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력하세요.',
                        hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600]),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: PeeroreumColor.gray[200]!),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: PeeroreumColor.gray[200]!),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                      cursorColor: PeeroreumColor.gray[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            '취소',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: PeeroreumColor.gray[600]),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: PeeroreumColor.gray[300], // 배경 색상
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16), // 패딩
                            shape: RoundedRectangleBorder(
                              // 모양
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            passwordController.text == datas[index]['password']
                                ? enrollWedu(index)
                                : PeeroreumToast.show(
                                    context, '비밀번호가 일치하지 않아요.',
                                    isError: true);
                            Get.back();
                          },
                          child: Text(
                            '확인',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: PeeroreumColor.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: PeeroreumColor.primaryPuple[400],
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }
}
