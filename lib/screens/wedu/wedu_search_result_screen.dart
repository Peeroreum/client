import 'dart:convert';

import 'package:custom_widget_marquee/custom_widget_marquee.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
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
  List<String> gradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> subjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];

  @override
  void initState() {
    super.initState();
    fetchDatas();
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

  Future<String> getShortLink(String screenName, String id) async {
    String dynamicLinkPrefix = 'https://peeroreum.page.link';
    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: dynamicLinkPrefix,
      link: Uri.parse('$dynamicLinkPrefix/home'),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.peeroreum_client',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.example.peeroreumClient',
        minimumVersion: '0',
      ),
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    return dynamicLink.shortUrl.toString();
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
                              '다른 검색어를 입력해 보세요!',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: PeeroreumColor.gray[700]),
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
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      image: (datas[index]["imagePath"] != null)
                          ? DecorationImage(
                              image: NetworkImage(datas[index]["imagePath"]),
                              fit: BoxFit.cover)
                          : DecorationImage(
                              image: AssetImage(
                                  'assets/images/example_logo.png'))),
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return roominfo(index);
              },
            );
          },
        );
      },
    );
  }

  Widget roominfo(index) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                          image: (datas[index]['imagePath'] != null)
                              ? DecorationImage(
                                  image:
                                      NetworkImage(datas[index]['imagePath']),
                                  fit: BoxFit.cover)
                              : DecorationImage(
                                  image: AssetImage(
                                      'assets/images/example_logo.png')),
                          border: Border.all(
                              width: 1, color: PeeroreumColor.gray[200]!),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    ),
                    Container(
                      height: 72,
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                subjectList[datas[index]["subject"]],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: PeeroreumColor.subjectColor[
                                        subjectList[datas[index]
                                            ['subject']]]?[1],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              datas[index]['locked'].toString() == "true"
                                  ? SvgPicture.asset('assets/icons/lock.svg',
                                      color: PeeroreumColor.gray[400])
                                  : SizedBox(),
                              datas[index]['locked'].toString() == "true"
                                  ? SizedBox(width: 4)
                                  : SizedBox(),
                              SizedBox(
                                width: datas[index]['locked'].toString() ==
                                        "true"
                                    ? MediaQuery.of(context).size.width * 0.42
                                    : MediaQuery.of(context).size.width * 0.48,
                                child: CustomWidgetMarquee(
                                  animationDuration: Duration(seconds: 3),
                                  pauseDuration: Duration(seconds: 1),
                                  directionOption: DirectionOption.oneDirection,
                                  child: Text(
                                    datas[index]["title"]!,
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: PeeroreumColor.black),
                                  ),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: PeeroreumColor.gray[600])),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                              Text(
                                  '${datas[index]["attendingPeopleNum"]!}명 참여중',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: PeeroreumColor.gray[600])),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: SvgPicture.asset(
                                  'assets/icons/dot.svg',
                                  color: PeeroreumColor.gray[600],
                                ),
                              ),
                              Text('D-${datas[index]["dday"]!}',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: PeeroreumColor.gray[600])),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: PeeroreumColor.white,
                      border: Border.all(color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    onPressed: () async {
                      Share.share(await getShortLink(
                        '/home',
                        '$index',
                      ));
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/share.svg',
                    ),
                  ),
                )
              ],
            ),
            roominfo_tag(index),
            SizedBox(
              height: 8,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                inviDatas[datas[index]['id']]['challenge'],
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              decoration: BoxDecoration(
                  color: PeeroreumColor.gray[100],
                  borderRadius: BorderRadius.circular(8)),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              height: 162,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          inviDatas[datas[index]['id']]['invitationUrl']),
                      fit: BoxFit.cover),
                  color: PeeroreumColor.primaryPuple[400],
                  borderRadius: BorderRadius.circular(8)),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 32),
              width: double.maxFinite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        '닫기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.gray[600],
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(PeeroreumColor.gray[300]),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 12)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        datas[index]['locked'].toString() == "true"
                            ? insertPassword(index)
                            : enrollWedu(index);
                        fetchDatas();
                        setState(() {});
                      },
                      child: Text(
                        '참여하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            PeeroreumColor.primaryPuple[400]),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 12)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget roominfo_tag(roomIndex) {
    if (hashTags[datas[roomIndex]['id']]!.isEmpty) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 26,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: PeeroreumColor.primaryPuple[400]!),
                    borderRadius: BorderRadius.all(Radius.circular(100.0))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '#',
                      style: TextStyle(
                        color: PeeroreumColor.primaryPuple[200],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      hashTags[datas[roomIndex]['id']]![index],
                      style: TextStyle(
                        color: PeeroreumColor.primaryPuple[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: 4,
              );
            },
            itemCount: hashTags[datas[roomIndex]['id']]!.length),
      ),
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
      Fluttertoast.showToast(msg: "같이방 참여 완료!");
    } else if (enrollResult.statusCode == 409) {
      Fluttertoast.showToast(msg: '이미 참여 중인 같이방입니다.');
    } else {
      Fluttertoast.showToast(msg: '잠시 후에 다시 시도해 주세요.');
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
                        Navigator.pop(context);
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
                            : Fluttertoast.showToast(msg: '비밀번호가 일치하지 않습니다.');
                        Navigator.pop(context);
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
