// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';

import 'package:custom_widget_marquee/custom_widget_marquee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/wedu/wedu_create_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:peeroreum_client/screens/wedu/wedu_search.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:peeroreum_client/screens/wedu/wedu_skeleton.dart';
import 'package:uni_links/uni_links.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

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
  List<String> dropdownGradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> dropdownSubjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
  List<String> dropdownSortTypeList = ['최신순', '추천순', '인기순'];
  String selectedGrade = '전체';
  String selectedSubject = '전체';
  String selectedSortType = '최신순';

  var grade = 0;
  var subject = 0;

  @override
  void initState() {
    super.initState();
    fetchDatas();
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

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    nickname = await FlutterSecureStorage().read(key: "nickname");

    var weduResult = await http.get(
        Uri.parse(
            '${API.hostConnect}/wedu?sort=$selectedSortType&grade=$grade&subject=$subject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (weduResult.statusCode == 200) {
      datas = jsonDecode(utf8.decode(weduResult.bodyBytes))['data'];
    } else {
      print("에러${weduResult.statusCode}");
    }
    var inWeduResult = await http.get(
        Uri.parse('${API.hostConnect}/wedu/in?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (inWeduResult.statusCode == 200) {
      inroom_datas = jsonDecode(utf8.decode(inWeduResult.bodyBytes))['data'];
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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => searchWedu()));
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
        Container(
          margin: const EdgeInsets.only(right: 20),
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(right: 8),
                  child: SvgPicture.asset(
                    'assets/icons/plus_square.svg',
                    color: PeeroreumColor.gray[800],
                    width: 24,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => CreateWedu(),
                        transitionDuration: const Duration(seconds: 0),
                        reverseTransitionDuration: const Duration(seconds: 0)),
                  );
                },
              ),
              GestureDetector(
                child: SvgPicture.asset(
                  'assets/icons/bell_none.svg',
                  color: PeeroreumColor.gray[800],
                ),
                onTap: () {
                  Fluttertoast.showToast(msg: "준비중입니다.");
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Container(
          child: Column(
        children: [
          room_body(),
          (inroom_datas.isNotEmpty)
              ? SizedBox(
                  height: 180, //180으로 나중에 수정
                  child: in_room_body())
              : SizedBox(
                  height: 0,
                ),
          (inroom_datas.isNotEmpty)
              ? SizedBox(
                  height: 20,
                )
              : SizedBox(
                  height: 0,
                ),
          Container(
            height: 8,
            color: PeeroreumColor.gray[50],
          ),
          // Divider(
          //   height: 28,
          //   thickness: 8,
          //   color: PeeroreumColor.gray[50],
          // ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('같이방',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard')),
              ],
            ),
          ),
          dropdown_body(),
          datas.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 4,
                      color: PeeroreumColor.gray[50],
                    ),
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
                  ],
                )
              : Expanded(child: listview_body())
        ],
      )),
    );
  }

  Widget room_body() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "참여 중인 같이방",
                  style: TextStyle(
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
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => InWedu()));
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
            padding: EdgeInsets.fromLTRB(8, 20, 8, 16),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1, color: PeeroreumColor.gray[200]!),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        image: (inroom_datas[rindex]['imagePath'] != null)
                            ? DecorationImage(
                                image: NetworkImage(
                                    inroom_datas[rindex]['imagePath']),
                                fit: BoxFit.cover)
                            : DecorationImage(
                                image: AssetImage(
                                    'assets/images/example_logo.png')))),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: PeeroreumColor.subjectColor[dropdownSubjectList[
                            inroom_datas[rindex]['subject']]]?[0],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 8),
                        child: Text(
                          dropdownSubjectList[inroom_datas[rindex]['subject']],
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
                    Flexible(
                      child: CustomWidgetMarquee(
                        animationDuration: Duration(seconds: 5),
                        pauseDuration: Duration(seconds: 1),
                        directionOption: DirectionOption.oneDirection,
                        child: Text(
                          inroom_datas[rindex]["title"]!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PeeroreumColor.black),
                        ),
                      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SvgPicture.asset(
                        'assets/icons/dot.svg',
                        color: PeeroreumColor.gray[600],
                      ),
                    ),
                    Text('${inroom_datas[rindex]["attendingPeopleNum"]!}명',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SvgPicture.asset(
                        'assets/icons/dot.svg',
                        color: PeeroreumColor.gray[600],
                      ),
                    ),
                    Text('D-${inroom_datas[rindex]["dday"]!}',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                  ],
                ),
                SizedBox(
                  height: 8,
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
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailWedu(inroom_datas[rindex]["id"])));
          },
        );
      },
    );
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
                                    dropdownSubjectList[datas[index]
                                        ['subject']]]?[0],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  dropdownSubjectList[datas[index]['subject']],
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
                                    color: PeeroreumColor.gray[400], width: 12)
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
              backgroundColor: Colors.transparent,
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
                                  dropdownSubjectList[datas[index]
                                      ['subject']]]?[0],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                dropdownSubjectList[datas[index]["subject"]],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    height: 1.6,
                                    fontFamily: 'Pretendard',
                                    color: PeeroreumColor.subjectColor[
                                        dropdownSubjectList[datas[index]
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
                                  ? SizedBox(
                                      width: 4,
                                    )
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
                              Text(dropdownGradeList[datas[index]["grade"]],
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
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
                                      fontSize: 14,
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
                  width: 48,
                  height: 48,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      border: Border.all(color: PeeroreumColor.gray[200]!),
                      color: PeeroreumColor.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchDatas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SkeletonWedu();
            } else if (snapshot.hasError) {
              // 에러 발생 시
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return bodyWidget();
            }
          }),
    );
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
                                : Fluttertoast.showToast(
                                    msg: '비밀번호가 일치하지 않습니다.');
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
}
