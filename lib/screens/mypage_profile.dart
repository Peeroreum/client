// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/detail_wedu_screen.dart';
import 'package:peeroreum_client/screens/in_wedu.dart';

class MyPageProfile extends StatefulWidget {
  const MyPageProfile({super.key});

  @override
  State<MyPageProfile> createState() => _MyPageProfileState();
}

class _MyPageProfileState extends State<MyPageProfile> {
  var token;
  List<dynamic> datas = [];
  List<dynamic> inroom_datas = [];
  List<dynamic> inviDatas = [];
  List<dynamic> hashTags = [];
  List<String> dropdownGradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> dropdownSubjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
  List<String> dropdownSortTypeList = ['최신순', '추천순', '인기순'];
  bool am_i = false;
  bool is_friend = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: bodyWidget(),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      elevation: 1,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          color: PeeroreumColor.gray[800],
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "프로필",
        style: TextStyle(
            color: PeeroreumColor.black,
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.only(right: 4),
                constraints: BoxConstraints(),
                icon: SvgPicture.asset('assets/icons/search.svg',
                    color: PeeroreumColor.black),
                onPressed: () {},
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: SvgPicture.asset(
                  'assets/icons/icon_dots_mono.svg',
                  color: PeeroreumColor.black,
                ),
                onPressed: () {},
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            myProfile(),
            myWedu(),
          ],
        ),
      ),
    );
  }

  Widget myProfile() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          myinfo(),
          SizedBox(
            height: 16,
          ),
          friends(),
        ],
      ),
    );
  }

  Widget myinfo() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
          //color: PeeroreumColor.gradeColor[dropdownGradeList[index]['grade']]!,
          color: PeeroreumColor.gray[200],
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/color_logo.png'),
                  Container(width: 4),
                  Text(
                    '+',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(width: 2),
                  Text(
                    'NN',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.all(3.5),
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PeeroreumColor.gray[200]!
                      //color: PeeroreumColor.gradeColor[successList[index]['grade']]!
                      ),
                  image: DecorationImage(
                      image: AssetImage('assets/images/user.jpg')),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'name',
                style: TextStyle(
                  color: PeeroreumColor.gray[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          SizedBox(
            height: 104,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (am_i = false) {
                    is_friend = !is_friend;
                  } else {
                    //프로필공유하는 링크
                  }
                });
              },
              style: ButtonStyle(
                  maximumSize: am_i
                      ? MaterialStateProperty.all<Size>(Size(138, 40))
                      : MaterialStateProperty.all<Size>(Size(124, 40)),
                  backgroundColor: am_i
                      ? MaterialStateProperty.all(
                          PeeroreumColor.primaryPuple[400])
                      : (is_friend
                          ? MaterialStateProperty.all(PeeroreumColor.gray[300])
                          : MaterialStateProperty.all(
                              PeeroreumColor.primaryPuple[400])),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  am_i
                      ? SvgPicture.asset(
                          'assets/icons/share.svg',
                          color: PeeroreumColor.white,
                        )
                      : SvgPicture.asset(
                          'assets/icons/plus_user.svg',
                          color: is_friend
                              ? PeeroreumColor.gray[600]
                              : PeeroreumColor.white,
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    am_i ? '프로필 공유' : (is_friend ? '친구 끊기' : '친구신청'),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: am_i
                          ? PeeroreumColor.white
                          : (is_friend
                              ? PeeroreumColor.gray[600]
                              : PeeroreumColor.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget friends() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Column(
            children: [
              Text(
                '친구',
                style: TextStyle(
                  color: PeeroreumColor.gray[800],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                'NN',
                style: TextStyle(
                  color: PeeroreumColor.gray[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '배지',
                    style: TextStyle(
                      color: PeeroreumColor.gray[800],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'NN 개 보유',
                    style: TextStyle(
                      color: PeeroreumColor.gray[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: PeeroreumColor.gray[100]),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: PeeroreumColor.gray[100]),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: PeeroreumColor.gray[100]),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget myWedu() {
    return Column(
      children: [
        room_body(),
        (inroom_datas.length != 0)
            ? SizedBox(height: 193, child: in_room_body())
            : SizedBox(height: 0),
      ],
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
              child: Text(
                '전체 보기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: PeeroreumColor.gray[500],
                ),
              ),
            )
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
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: (inroom_datas[index]['imagePath'] != null)
                      ? Image.network(inroom_datas[index]['imagePath']!,
                          width: 48, height: 48)
                      : Image.asset('assets/images/example_logo.png',
                          width: 48, height: 48),
                ),
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
                            inroom_datas[index]['subject']]]?[0],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 8),
                        child: Text(
                          dropdownSubjectList[inroom_datas[index]['subject']],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: PeeroreumColor.subjectColor[
                                dropdownSubjectList[inroom_datas[index]
                                    ['subject']]]?[1],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      width: 98,
                      child: Text(
                        inroom_datas[index]["title"]!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PeeroreumColor.black),
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
                    Text(dropdownGradeList[inroom_datas[index]["grade"]],
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Text('⋅'),
                    ),
                    Text('${inroom_datas[index]["attendingPeopleNum"]!}명 참여중',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Text('⋅'),
                    ),
                    Text('D-${inroom_datas[index]["dday"]!}',
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
                  '${inroom_datas[index]["progress"]}% 달성', //이후 퍼센티지 수정
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
                builder: (context) => DetailWedu(inroom_datas[index]["id"])));
          },
        );
      },
    );
  }
}
