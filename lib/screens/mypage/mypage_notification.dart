import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/data/notification_setting.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';

class MyPageNotification extends StatefulWidget {
  const MyPageNotification({super.key});

  @override
  State<MyPageNotification> createState() => _MyPageNotificationState();
}

class _MyPageNotificationState extends State<MyPageNotification> {
  bool _allChecked = false;
  bool _weduChecked = false;
  bool _iduChecked = false;
  bool _rankChecked = false;

  void check() {
    if (_weduChecked || _iduChecked || _rankChecked) {
      setState(() {
        _allChecked = false;
      });
    }
    if (_weduChecked && _iduChecked && _rankChecked) {
      setState(() {
        _allChecked = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotificationSetting();
  }

  getNotificationSetting() async {
    List<String>? setTypes = await NotificationSetting.getNotificationType();
    setTypes ??= ["true", "true", "true", "true"];

    setState(() {
      _allChecked = setTypes![0] == "true";
      _weduChecked = setTypes[1] == "true";
      _iduChecked = setTypes[2] == "true";
      _rankChecked = setTypes[3] == "true";
    });
  }

  setNotificationSetting() {
    List<String> setTypes = [
      _allChecked.toString(),
      _weduChecked.toString(),
      _iduChecked.toString(),
      _rankChecked.toString()
    ];
    NotificationSetting.setNotificationType(setTypes);
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
      surfaceTintColor: PeeroreumColor.white,
      shadowColor: PeeroreumColor.white,
      elevation: 0.2,
      leading: IconButton(
        onPressed: () {
          setNotificationSetting();
          Get.back();
        },
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          colorFilter:
              ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
        ),
      ),
      title: const Text(
        "알림 설정",
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
    return Container(
      color: PeeroreumColor.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: allNotification(),
          ),
          Container(
            height: 8,
            color: PeeroreumColor.gray[50],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                weduNotification(),
                Container(
                  height: 20,
                ),
                iduNotification(),
                Container(
                  height: 20,
                ),
                rankNotification(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget allNotification() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전체 알림',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
          child: CupertinoSwitch(
            value: _allChecked,
            activeTrackColor: PeeroreumColor.primaryPurple[400],
            inactiveTrackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _allChecked = value;
                _weduChecked = value;
                _iduChecked = value;
                _rankChecked = value;
              });
            },
          ),
        )
      ],
    );
  }

  Widget weduNotification() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '같이해냄 알림',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '챌린지 달성, 독려하기, 칭찬하기 등',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[600],
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
          child: CupertinoSwitch(
            value: _weduChecked,
            activeTrackColor: PeeroreumColor.primaryPurple[400],
            inactiveTrackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _weduChecked = value;
                check();
              });
            },
          ),
        )
      ],
    );
  }

  Widget iduNotification() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내가해냄 알림',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '댓글 등록, 채택 등',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[600],
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
          child: CupertinoSwitch(
            value: _iduChecked,
            activeTrackColor: PeeroreumColor.primaryPurple[400],
            inactiveTrackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _iduChecked = value;
                check();
              });
            },
          ),
        )
      ],
    );
  }

  Widget rankNotification() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '랭킹 알림',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PeeroreumColor.black,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '순위 변동, 일간 순위 공지 등',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: PeeroreumColor.gray[600],
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
          child: CupertinoSwitch(
            value: _rankChecked,
            activeTrackColor: PeeroreumColor.primaryPurple[400],
            inactiveTrackColor: PeeroreumColor.gray[200],
            onChanged: (value) {
              setState(() {
                _rankChecked = value;
                check();
              });
            },
          ),
        )
      ],
    );
  }
}
