// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:peeroreum_client/screens/in_wedu.dart';
import 'package:peeroreum_client/screens/search_wedu.dart';

class HomeWedu extends StatefulWidget {
  const HomeWedu({super.key});

  @override
  State<HomeWedu> createState() => _HomeWeduState();
}

class _HomeWeduState extends State<HomeWedu> {
  int selectedIndex = 1;
  List<Map<String, String>> datas = [];
  List<Map<String, String>> inroom_datas = [];
  List<String> dropdownGradeList = ['전체', '중1', '중2'];
  List<String> dropdownClassList = ['전체', '국어', '수학'];
  List<String> dropdownTypeList = ['추천순', '인기순'];
  String selectedDropdownGrade = '전체';
  String selectedDropdownClass = '국어';
  String selectedDropdownType = '추천순';

  @override
  void initState() {
    super.initState();
    datas = [
      {
        "cid": "1",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "국어",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "2",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "수학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "3",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "영어",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "4",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "과학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "5",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "수학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
    ];
    inroom_datas = [
      {
        "cid": "1",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "국어",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "2",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "수학",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      },
      {
        "cid": "3",
        "group_profile": "assets/images/splash_logo.png",
        "subject": "영어",
        "name": "Group Name",
        "grade": "학년",
        "number": "NN",
        "day": "NNN",
      }
    ];
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 0, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => searchWedu()));
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(37.0))),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                        SizedBox(width: 8.0),
                        SizedBox(
                          child: Text(
                            '같이방에서 함께 공부해요!',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 20, 0),
          child: Row(
            children: [
              Icon(
                Icons.add_box,
                size: 24,
                color: Colors.grey[800],
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                Icons.notifications_none,
                size: 24,
                color: Colors.grey[800],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          child: Column(
        children: [
          room_body(),
          Expanded(child: in_room_body()),
          Container(
            height: 8,
            color: Color(0xFFF1F2F3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => InWedu()));
                        },
                        child: Text('전체 보기',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey[500])))
                  ],
                ),
              ),
            ],
          ),
          dropdown_body(),
          Expanded(child: listview_body())
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
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => InWedu()));
                },
                child: Text('전체 보기',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[500])))
          ],
        ),
      ),
    );
  }

  Widget in_room_body() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: inroom_datas.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 180,
          padding: EdgeInsets.fromLTRB(8, 20, 8, 16),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Color(0xFFEAEBEC)),
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Color(0xFFEAEBEC)),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Image.asset(inroom_datas[index]["group_profile"]!,
                    width: 48, height: 48),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 76,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFFFE9E9)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                inroom_datas[index]["subject"]!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Color(0xFFF86060),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            inroom_datas[index]["name"]!,
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            Text(inroom_datas[index]["grade"]!,
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600])),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('${inroom_datas[index]["number"]!}명 참여중',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600])),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('D-${inroom_datas[index]["day"]!}',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(
                            '${inroom_datas[index]["number"]}%', //이후 퍼센티지 수정
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7260F8)),
                          ),
                          SizedBox(width: 2),
                          Text(
                            "달성",
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7260F8),
                            ),
                          ),
                        ],
                      )
                    ]),
              )
            ],
          ),
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
                      border: Border.all(color: Color(0xFFEAEBEC), width: 1),
                      borderRadius: BorderRadius.circular(8)),
                  child: SizedBox(
                    width: 75,
                    height: 40,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: DropdownButton(
                          icon: Padding(
                            padding: EdgeInsets.only(left: 7.0), //나중에 수정 8.0
                            child: Icon(Icons.expand_more,
                                color: Color(0xFF6C6D6D)),
                          ),
                          iconSize: 18,
                          underline: SizedBox.shrink(),
                          value: selectedDropdownGrade,
                          items: dropdownGradeList.map((String item) {
                            return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ));
                          }).toList(),
                          onChanged: (dynamic value) {
                            setState(() {
                              selectedDropdownGrade = value;
                            });
                          }),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFEAEBEC), width: 1),
                      borderRadius: BorderRadius.circular(8)),
                  child: SizedBox(
                    width: 75,
                    height: 40,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: DropdownButton(
                          icon: Padding(
                            padding:
                                const EdgeInsets.only(left: 7.0), //나중에 수정 8.0
                            child: Icon(Icons.expand_more,
                                color: Color(0xFF6C6D6D)),
                          ),
                          iconSize: 18,
                          underline: SizedBox.shrink(),
                          value: selectedDropdownClass,
                          items: dropdownClassList.map((String item) {
                            return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(fontSize: 14),
                                ));
                          }).toList(),
                          onChanged: (dynamic value) {
                            setState(() {
                              selectedDropdownClass = value;
                            });
                          }),
                    ),
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
                border: Border.all(color: Color(0xFFEAEBEC), width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: SizedBox(
              width: 87,
              height: 40,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: DropdownButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 6.0), //나중에 수정 8.0
                    child: Icon(
                      Icons.expand_more,
                      color: Color(0xFF6C6D6D),
                    ),
                  ),
                  iconSize: 18,
                  underline: SizedBox.shrink(),
                  value: selectedDropdownType,
                  items: dropdownTypeList.map((String item) {
                    return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 14),
                        ));
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      selectedDropdownType = value;
                    });
                  },
                ),
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
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Color(0xFFEAEBEC)),
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Color(0xFFEAEBEC)),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Image.asset(datas[index]["group_profile"]!,
                    width: 44, height: 44),
              ),
              Container(
                height: 44,
                padding: EdgeInsets.only(left: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFFFE9E9)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                datas[index]["subject"]!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Color(0xFFF86060),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            datas[index]["name"]!,
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(datas[index]["grade"]!,
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600])),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Text('⋅'),
                          ),
                          Text('${datas[index]["number"]!}명 참여중',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600])),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Text('⋅'),
                          ),
                          Text('D-${datas[index]["day"]!}',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600])),
                        ],
                      )
                    ]),
              )
            ],
          ),
        );
      },
    );
  }

  Widget bottomNavigatorBarWidget() {
    return BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '같이해냄'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '질의응답'),
          BottomNavigationBarItem(icon: Icon(Icons.stars), label: '랭킹'),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity), label: '마이페이지'),
        ],
        currentIndex: selectedIndex,
        unselectedItemColor: Colors.grey[400],
        unselectedLabelStyle: TextStyle(fontFamily: 'Pretendard', fontSize: 12),
        selectedItemColor: Color(0xFF7260F8),
        selectedLabelStyle: TextStyle(fontFamily: 'Pretendard', fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: bodyWidget(),
      bottomNavigationBar: bottomNavigatorBarWidget(),
    );
  }
}
