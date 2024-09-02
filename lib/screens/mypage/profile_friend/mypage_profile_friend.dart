// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/follower/follower_api.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/follower/follower_controller.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/following/following_api.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/following/following_controller.dart';

class MyPageProfileFriend extends StatelessWidget {
  var nickname;
  MyPageProfileFriend(this.nickname);

  var mynickname;

  bool am_i = false;

  final FollowerController follower_controller =
      Get.put(FollowerController(FollowerProvider()));

  final FollowingController following_controller =
      Get.put(FollowingController(FollowingProvider()));

  @override
  Widget build(BuildContext context) {
    // 상태 변경을 빌드 후에 수행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      follower_controller.fetchFriends(nickname);
      following_controller.fetchFriends(nickname);
      follower_controller.fetchMyNickname();
    });

    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: appbarWidget(),
      body: bodyWidget(),
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
          Get.back();
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
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
              indicatorColor: PeeroreumColor.primaryPuple[400],
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: PeeroreumColor.primaryPuple[400],
              unselectedLabelColor: PeeroreumColor.gray[800],
              unselectedLabelStyle: TextStyle(
                color: PeeroreumColor.gray[800],
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              labelStyle: TextStyle(
                color: PeeroreumColor.primaryPuple[400],
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  text: '팔로워',
                ),
                Tab(
                  text: '팔로잉',
                )
              ]),
          Container(
            height: 1,
            color: PeeroreumColor.gray[100],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Obx(() {
                    if (follower_controller.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (follower_controller.followers.isEmpty) {
                      return Center(child: Text("팔로워 목록이 없습니다."));
                    }

                    return follower();
                  }),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Obx(() {
                    if (following_controller.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (following_controller.followings.isEmpty) {
                      return Center(child: Text("팔로잉 목록이 없습니다."));
                    }

                    return following();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget follower() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '전체 팔로워',
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
              '${follower_controller.followers.length}',
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
        Divider(
          color: PeeroreumColor.gray[100],
          thickness: 1,
          height: 8,
        ),
        followers(),
      ],
    );
  }

  Widget following() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '전체 팔로잉',
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
              '${following_controller.followings.length}',
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
        Divider(
          color: PeeroreumColor.gray[100],
          thickness: 1,
          height: 8,
        ),
        followings(),
      ],
    );
  }

  Widget followers() {
    return Flexible(
      child: ListView.separated(
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            final follower = follower_controller.followers[index];
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (mynickname == follower.nickname) {
                  am_i = true;
                }
                Get.to(() => MyPageProfile(follower.nickname!, am_i));
              },
              child: Container(
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
                            color: PeeroreumColor.gradeColor[follower.grade]!),
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
                          image: follower.profileImage != null
                              ? DecorationImage(
                                  image: NetworkImage(follower.profileImage!),
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
                      follower.nickname!,
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: PeeroreumColor.gray[800]),
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(
                color: PeeroreumColor.gray[100],
                thickness: 1,
                height: 8,
              ),
          itemCount: follower_controller.followers.length),
    );
  }

  Widget followings() {
    return Flexible(
      child: ListView.separated(
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            final following = following_controller.followings[index];
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (mynickname == following.nickname) {
                  am_i = true;
                }
                Get.to(() => MyPageProfile(following.nickname!, am_i));
              },
              child: Container(
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
                            color: PeeroreumColor.gradeColor[following.grade]!),
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
                          image: following.profileImage != null
                              ? DecorationImage(
                                  image: NetworkImage(following.profileImage!),
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
                      following.nickname!,
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: PeeroreumColor.gray[800]),
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(
                color: PeeroreumColor.gray[100],
                thickness: 1,
                height: 8,
              ),
          itemCount: following_controller.followings.length),
    );
  }
}
