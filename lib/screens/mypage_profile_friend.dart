import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class MyPageProfileFriend extends StatefulWidget {
  const MyPageProfileFriend(String s, {super.key});

  @override
  State<MyPageProfileFriend> createState() => _MyPageProfileFriendState();
}

class _MyPageProfileFriendState extends State<MyPageProfileFriend> {
  var myfriends = [
    {"name": "오르미"},
    {"name": "내리미"},
    {"name": "name"},
    {"name": "name"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: bodyWiget(),
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

  Widget bodyWiget() {
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
                  padding: EdgeInsets.all(3.5),
                  width: 40,
                  height: 40,
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
                  width: 8,
                ),
                Text(
                  myfriends[index]["name"]!,
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
