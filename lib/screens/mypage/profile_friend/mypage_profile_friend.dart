// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/follower/follower_api.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/follower/follower_controller.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/following/following_api.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/following/following_controller.dart';

class MyPageProfileFriend extends StatelessWidget {
  final String nickname;
  final int index;

  MyPageProfileFriend(this.nickname, {super.key, this.index = 0});

  final FollowerController followerController =
      Get.put(FollowerController(FollowerProvider()));

  final FollowingController followingController =
      Get.put(FollowingController(FollowingProvider()));

  @override
  Widget build(BuildContext context) {
    // 상태 변경을 빌드 후에 수행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      followerController.fetchFriends(nickname);
      followingController.fetchFriends(nickname);
      followerController.fetchMyNickname();
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
          colorFilter:
              ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
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
      initialIndex: index,
      child: Column(
        children: [
          TabBar(
              indicatorColor: PeeroreumColor.primaryPurple[400],
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: PeeroreumColor.primaryPurple[400],
              unselectedLabelColor: PeeroreumColor.gray[800],
              unselectedLabelStyle: TextStyle(
                color: PeeroreumColor.gray[800],
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              labelStyle: TextStyle(
                color: PeeroreumColor.primaryPurple[400],
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
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
                    if (followerController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (followerController.followers.isEmpty) {
                      return Center(child: Text("팔로워 목록이 없습니다."));
                    }

                    return follower();
                  }),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Obx(() {
                    if (followingController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (followingController.followings.isEmpty) {
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
              '${followerController.followers.length}',
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
              '${followingController.followings.length}',
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
            final follower = followerController.followers[index];
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                final amI =
                    followerController.myNickname.value == follower.nickname;
                Get.to(() => MyPageProfile(follower.nickname!, amI));
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
          itemCount: followerController.followers.length),
    );
  }

  Widget followings() {
    return Flexible(
      child: ListView.separated(
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            final following = followingController.followings[index];
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                final amI =
                    followingController.myNickname.value == following.nickname;
                Get.to(() => MyPageProfile(following.nickname!, amI));
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
          itemCount: followingController.followings.length),
    );
  }
}
