// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:http/http.dart' as http;

class MyPageProfileFriend extends StatefulWidget {
  const MyPageProfileFriend(String s, {super.key});

  @override
  State<MyPageProfileFriend> createState() => _MyPageProfileFriendState();
}

class _MyPageProfileFriendState extends State<MyPageProfileFriend> {
  var token;
  var myfriends = [];

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "memberInfo");
    var friend = await http.get(Uri.parse('${API.hostConnect}/member/friend'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (friend.statusCode == 200) {
      myfriends = jsonDecode(utf8.decode(friend.bodyBytes))['data'];
      print("친구 성공 ${myfriends[0]["nickname"]}");
    } else {
      print("친구 에러 ${friend.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 20,
            ),
            child: Text(
              '전체 ${myfriends.length} 명',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.gray[500],
              ),
            ),
          ),
          Container(
            height: 1,
            color: PeeroreumColor.gray[100],
          ),
          friends(),
          Container(
            height: 1,
            color: PeeroreumColor.gray[200],
          )
        ],
      ),
    );
  }

  Widget friends() {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 2,
                        color: PeeroreumColor
                            .gradeColor[myfriends[index]["grade"]]!),
                  ),
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: PeeroreumColor.white,
                      ),
                      image: DecorationImage(
                          image: myfriends[index]["profileImage"] ??
                              AssetImage(
                                'assets/images/user.jpg',
                              )),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  myfriends[index]["nickname"],
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PeeroreumColor.gray[800],
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 1,
            color: PeeroreumColor.gray[200],
          );
        },
        itemCount: myfriends.length);
  }
}
