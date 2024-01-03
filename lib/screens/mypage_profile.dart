// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, deprecated_member_use, non_constant_identifier_names, avoid_print, sized_box_for_whitespace, must_be_immutable, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/detail_wedu_screen.dart';
import 'package:peeroreum_client/screens/in_wedu.dart';
import 'package:peeroreum_client/screens/mypage_profile_friend.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyPageProfile extends StatefulWidget {
  String nickname;
  bool am_i;
  MyPageProfile(this.nickname, this.am_i);

  @override
  State<MyPageProfile> createState() => _MyPageProfileState(nickname, am_i);
}

class _MyPageProfileState extends State<MyPageProfile> {
  String nickname;
  bool am_i;
  _MyPageProfileState(this.nickname, this.am_i);

  var token;
  final nickname_controller = TextEditingController();
  List<dynamic> inroom_datas = [];
  List<String> dropdownGradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> dropdownSubjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
  late bool is_friend;
  List<dynamic> badges = ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
    is_friend = false;
  }

  fetchStatus() async {
    token = await FlutterSecureStorage().read(key: "memberInfo");
  }

  follow() async {
    //친구 팔로우
    var friendName = await http.post(
        Uri.parse('${API.hostConnect}/member/friend/follow?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (friendName.statusCode == 200) {
      is_friend = true;
    } else if (friendName.statusCode == 404) {
      Fluttertoast.showToast(msg: "존재하지 않는 회원입니다.");
    } else if (friendName.statusCode == 400) {
      Fluttertoast.showToast(msg: "본인은 팔로우할 수 없습니다.");
    } else if (friendName.statusCode == 409) {
      Fluttertoast.showToast(msg: "이미 팔로우 중인 회원입니다.");
    } else {
      is_friend = false;
      print("친구팔로 에러${friendName.statusCode}");
    }
  }

  unfollow() async {
    //친구 언팔로우
    var friendName = await http.delete(
        Uri.parse(
            '${API.hostConnect}/member/friend/unfollow?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (friendName.statusCode == 200) {
      is_friend = false;
    } else {
      is_friend = true;
      print("친구언팔 에러${friendName.statusCode}");
    }
  }

  searchfriend() async {
    var friendName = await http.get(
        Uri.parse(
            '${API.hostConnect}/member/profile?nickname=${nickname_controller.text}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (friendName.statusCode == 200) {
      // check_friend();
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              MyPageProfile(nickname_controller.text, false)));
    } else if (friendName.statusCode == 404) {
      Fluttertoast.showToast(msg: "존재하지 않는 회원입니다.");
    } else {
      print("친구찾기 에러${friendName.statusCode}");
    }
  }

  void check_friend() async {
    var myfriend = await http.get(
        Uri.parse(
            '${API.hostConnect}/member/friend=${nickname_controller.text}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (myfriend.statusCode == 200) {
      is_friend = true;
    } else {
      is_friend = false;
      print("친구체크 에러${myfriend.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchStatus(),
          builder: (context, snapshot) {
            return bodyWidget();
          }),
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
                onPressed: () {
                  search_friend();
                },
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

  void search_friend() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          title: Text("친구 찾기", textAlign: TextAlign.center),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
            color: PeeroreumColor.black,
          ),
          titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 48,
            child: TextFormField(
              controller: nickname_controller,
              decoration: InputDecoration(
                hintText: '닉네임을 정확하게 입력해주세요.',
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: PeeroreumColor.gray[600],
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              cursorColor: PeeroreumColor.gray[600],
            ),
          ),
          contentTextStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: PeeroreumColor.gray[600],
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: PeeroreumColor.gray[300], // 배경 색상
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16), // 패딩
                      shape: RoundedRectangleBorder(
                        // 모양
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: PeeroreumColor.gray[600]),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        searchfriend();
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: PeeroreumColor.primaryPuple[400],
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: PeeroreumColor.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
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
                '$nickname',
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
                  if ((is_friend == true) && (am_i == false)) {
                    unfollow();
                  } else if ((is_friend == false) && (am_i == false)) {
                    follow();
                  } else if ((is_friend == false) && (am_i == true)) {
                    print('프로필 공유');
                    Fluttertoast.showToast(msg: "복사되었습니다");
                  } else {
                    print('error');
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MyPageProfileFriend(nickname)));
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: SizedBox(
              height: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    '${badges.length}개 보유',
                    style: TextStyle(
                      color: PeeroreumColor.gray[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 15), //left:20 변경
                height: 52,
                child: Badge(),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget Badge() {
    return Row(
      children: [
        Container(
          width: 48, //52에서 overflow문제로 변경
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PeeroreumColor.gray[100],
          ),
        ),
        Container(
          width: 2,
        ),
        Container(
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PeeroreumColor.gray[100],
          ),
        ),
        Container(
          width: 2,
        ),
        Container(
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PeeroreumColor.gray[100],
          ),
        )
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
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
