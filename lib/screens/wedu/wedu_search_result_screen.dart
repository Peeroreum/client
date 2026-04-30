import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/wedu/wedu_create_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_room_info_sheet.dart';
import 'package:share_plus/share_plus.dart';

import '../../api/PeeroreumApi.dart';
import '../../data/WeduSearchHistory.dart';

class SearchResultWedu extends StatefulWidget {
  final String keyword;
  SearchResultWedu(this.keyword);

  @override
  State<SearchResultWedu> createState() => _SearchResultWeduState(keyword);
}

class _SearchResultWeduState extends State<SearchResultWedu> {
  var token;

  String keyword;
  _SearchResultWeduState(this.keyword);

  List<Map<String, String>> _searchHistory = [];
  List<dynamic> datas = [];
  Map<dynamic, dynamic> inviDatas = {};
  Map<dynamic, List<dynamic>> hashTags = {};
  List<String> gradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3', '대학'];
  List<String> subjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타', '대학'];
  List<dynamic> inroom_datas = [];

  @override
  void initState() {
    super.initState();
    fetchDatas();
    fetchInRoomDatas();
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    var weduResult = await http
        .get(Uri.parse('${API.hostConnect}/wedu/search/${keyword}'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (weduResult.statusCode == 200) {
      datas = jsonDecode(utf8.decode(weduResult.bodyBytes))['data'];
      print("데이터 fetch 완료 \n $datas");
    } else {
      print("에러${weduResult.statusCode}");
    }

    await fetchImage(datas);
  }

  fetchImage(datas) async {
    var inviData;
    for (var data in datas) {
      inviData = await fetchInvitation(data['id']);
      inviDatas.addAll({data['id']: inviData});
      hashTags.addAll({data['id']: inviData['hashTags']});
    }
  }

  fetchInvitation(id) async {
    var inviResult = await http
        .get(Uri.parse('${API.hostConnect}/wedu/$id/invitation'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (inviResult.statusCode == 200) {
      return await jsonDecode(utf8.decode(inviResult.bodyBytes))['data'];
    } else {
      print("에러${inviResult.statusCode}");
    }
  }

  _loadSearchHistory() async {
    _searchHistory = await SearchHistory.getSearchHistory();
    setState(() {});
  }

  _saveSearchHistory(String value) async {
    await SearchHistory.addSearchItem(value);
    _loadSearchHistory();
  }

  fetchInRoomDatas() async {
    String? nickname = await FlutterSecureStorage().read(key: "nickname");

    var result = await http.get(
        Uri.parse('${API.hostConnect}/wedu/in?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });

    if (result.statusCode == 200) {
      if (mounted) {
        setState(() {
          inroom_datas = json.decode(result.body)['data'];
        });
      }
    }
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

  bool search_clear = false;

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
                  Get.back(result: _searchHistory);
                },
              ),
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.fromLTRB(0, 12, 20, 12),
                child: SearchBar(
                  controller: textEditingController,
                  onTap: () {
                    Get.back(result: _searchHistory);
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
          body: SafeArea(
            child: FutureBuilder<void>(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                    color: PeeroreumColor.black),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                '같이방을 만들어보세요!',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: PeeroreumColor.gray[700]),
                              ),
                              SizedBox(
                                height: 32,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => CreateWedu());
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  height: 48,
                                  width: 185,
                                  decoration: BoxDecoration(
                                    color: PeeroreumColor.primaryPuple[400],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/plus_square2.svg',
                                        color: PeeroreumColor.white,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      T4_16px(
                                        text: '같이방 만들러 가기',
                                        color: PeeroreumColor.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 56,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Text(
                                    '검색된 같이방',
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
                            Expanded(child: listview_body())
                          ],
                        );
                }
              },
            ),
          )),
    );
  }

  Widget listview_body() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: datas.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PeeroreumColor.gray[50],
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[200]!),
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
                                    subjectList[datas[index]['subject']]]?[0],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  subjectList[datas[index]['subject']],
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: PeeroreumColor.subjectColor[
                                        subjectList[datas[index]
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
                                    color: PeeroreumColor.gray[400], width: 12)
                                : Container(),
                            datas[index]['locked'].toString() == "true"
                                ? SizedBox(width: 4)
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
                            Text(gradeList[datas[index]["grade"]],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('${datas[index]["attendingPeopleNum"]!}명',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('D-${datas[index]["dday"]!}',
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
              onShare: (shareRect) {
                final roomId = datas[index]['id'].toString();
                final roomName = datas[index]['title'] as String? ?? '같이방';
                Share.share(buildShareMessage(roomName, roomId),
                    sharePositionOrigin: shareRect);
              },
              onEnroll: () {
                Get.back();
                datas[index]['locked'].toString() == 'true'
                    ? insertPassword(index)
                    : enrollWedu(index);
              },
            );
          },
        );
      },
    );
  }


  void enrollWedu(index) async {
    var id = datas[index]['id'];
    var enrollResult = await http
        .post(Uri.parse('${API.hostConnect}/wedu/$id/enroll'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (enrollResult.statusCode == 200) {
      PeeroreumToast.show(context, "같이방에 참여했어요!");
    } else if (enrollResult.statusCode == 409) {
      PeeroreumToast.show(context, '이미 참여 중인 같이방이에요.');
    } else {
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.');
      print('에러${enrollResult.statusCode}${enrollResult.body}');
    }
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
            title: Text("비밀번호", textAlign: TextAlign.center),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
              color: PeeroreumColor.black,
            ),
            titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            content: Container(
              color: PeeroreumColor.white,
              width: MediaQuery.of(context).size.width * 0.8,
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
                      borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                cursorColor: PeeroreumColor.gray[600],
              ),
            ),
            actions: [
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
                            : PeeroreumToast.show(context, '비밀번호가 일치하지 않아요.',
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
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
