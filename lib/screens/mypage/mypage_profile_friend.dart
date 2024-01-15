// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';

class MyPageProfileFriend extends StatefulWidget {
  var nickname;
  MyPageProfileFriend(this.nickname);

  @override
  State<MyPageProfileFriend> createState() =>
      _MyPageProfileFriendState(nickname);
}

class _MyPageProfileFriendState extends State<MyPageProfileFriend> {
  var nickname;
  _MyPageProfileFriendState(this.nickname);
  var token;
  var myfriends = [];

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    var friend = await http
        .get(Uri.parse('${API.hostConnect}/member/friend/$nickname'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (friend.statusCode == 200) {
      myfriends = jsonDecode(utf8.decode(friend.bodyBytes))['data'];
      print("친구 성공");
    } else {
      print("친구 에러 ${friend.statusCode}, $nickname");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchDatas(),
          builder: (context, snapshot) {
            return bodyWidget();
          }),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      surfaceTintColor: PeeroreumColor.white,
      shadowColor: PeeroreumColor.white,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/x.svg',
          color: PeeroreumColor.gray[800],
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "친구",
        style: TextStyle(
            color: PeeroreumColor.black,
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  Widget bodyWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical:13, horizontal:20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '전체',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: PeeroreumColor.gray[500]),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${myfriends.length}',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: PeeroreumColor.gray[500]),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    '명',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: PeeroreumColor.gray[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          color: PeeroreumColor.gray[100],
          thickness: 1,
          height: 8,
        ),
        friends(),
        // Divider(
        //   color: PeeroreumColor.gray[100],
        //   thickness: 1,
        //   height: 8,
        // ),
      ],
    );
  }

  Widget friends() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height-140,
      child: ListView.separated(
        scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2,
                          color: PeeroreumColor.gradeColor[myfriends[index]['grade']]!),
                    ),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                          color: PeeroreumColor.white,
                        ),
                        image: myfriends[index]["profileImage"] != null
                            ? DecorationImage(
                            image: NetworkImage(
                                myfriends[index]["profileImage"]),
                            fit: BoxFit.cover)
                            : DecorationImage(
                            image: AssetImage('assets/images/user.jpg')),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    myfriends[index]['nickname'],
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: PeeroreumColor.gray[800]),
                  )
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(
            color: PeeroreumColor.gray[100],
            thickness: 1,
            height: 8,
          ),
          itemCount: myfriends.length),
    );
    // return ListView.separated(
    //     shrinkWrap: true,
    //     itemBuilder: (BuildContext context, int index) {
    //       return ElevatedButton(
    //         onPressed: () {
    //           Navigator.of(context).push(MaterialPageRoute(
    //               builder: (context) =>
    //                   MyPageProfile(myfriends[index]["nickname"], false)));
    //         },
    //         style: ElevatedButton.styleFrom(
    //           minimumSize: Size.fromHeight(56),
    //           backgroundColor: PeeroreumColor.white,
    //           elevation: 0,
    //           padding: EdgeInsets.all(0),
    //         ),
    //         child: Container(
    //           padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    //           child: Row(
    //             children: [
    //               Container(
    //                 width: 40,
    //                 height: 40,
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   border: Border.all(
    //                       width: 2,
    //                       color: PeeroreumColor
    //                           .gradeColor[myfriends[index]["grade"]]!),
    //                 ),
    //                 child: Container(
    //                   height: 36,
    //                   width: 36,
    //                   decoration: BoxDecoration(
    //                     shape: BoxShape.circle,
    //                     border: Border.all(
    //                       width: 2,
    //                       color: PeeroreumColor.white,
    //                     ),
    //                     image: myfriends[index]["profileImage"] != null
    //                         ? DecorationImage(
    //                             image: NetworkImage(
    //                                 myfriends[index]["profileImage"]),
    //                             fit: BoxFit.cover)
    //                         : DecorationImage(
    //                             image: AssetImage(
    //                             'assets/images/user.jpg',
    //                           )),
    //                   ),
    //                 ),
    //               ),
    //               SizedBox(
    //                 width: 8,
    //               ),
    //               Text(
    //                 myfriends[index]["nickname"],
    //                 style: TextStyle(
    //                   fontFamily: 'Pretendard',
    //                   fontSize: 14,
    //                   fontWeight: FontWeight.w500,
    //                   color: PeeroreumColor.gray[800],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       );
    //     },
    //     separatorBuilder: (BuildContext context, int index) {
    //       return Container(
    //         height: 1,
    //         color: PeeroreumColor.gray[200],
    //       );
    //     },
    //     itemCount: myfriends.length);
  }
}
