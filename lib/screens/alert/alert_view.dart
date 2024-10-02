import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/alert/alert_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/alert/alert_model.dart';
import 'package:flutter/material.dart';

class Alert extends GetView<AlertController> {
  Alert({super.key});
  final AlertController alertController = Get.put(AlertController());

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
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          color: PeeroreumColor.gray[800],
        ),
      ),
      title: Text(
        "알림",
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
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
                indicatorColor: PeeroreumColor.primaryPuple[400],
                indicatorSize: TabBarIndicatorSize.tab,
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
                    text: '활동 알림',
                  ),
                  Tab(
                    text: '서비스 알림',
                  )
                ]),
            Container(
              height: 1,
              color: PeeroreumColor.gray[100],
            ),
            Expanded(
              child: TabBarView(children: [
                Obx(() => alertController.activity_alerts.isNotEmpty
                    ? activities()
                    : Center(
                        child: Text(
                        '활동 알림이 없습니다.',
                        style: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: PeeroreumColor.gray[600]),
                      ))),
                Obx(() => alertController.service_alert.isNotEmpty
                    ? services()
                    : Center(
                        child: Text(
                        '서비스 알림이 없습니다.',
                        style: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: PeeroreumColor.gray[600]),
                      )))
              ]),
            )
          ],
        ),
      ),
    );
  }
  Widget buildAlertListView(List<AlertModel> alerts) {
    return ListView.separated(
      itemCount: alerts.length,
      separatorBuilder: (context, index) => const Divider(), // 구분선 추가
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return AlertListView(
          title: alert.title!,
          description: alert.description!, // AlertModel에서 적절한 필드 사용
          timeago: alert.timeago!, // AlertModel에서 적절한 필드 사용
        );
      },
    );
  }

  Widget activities() {
    return Obx(() {
      return buildAlertListView(alertController.activity_alerts);
    });
  }

  Widget services() {
    return Obx(() {
      return buildAlertListView(alertController.service_alert);
    });
  }
}

class AlertListView extends StatelessWidget {
  final String title;
  final String description;
  final String timeago;

  const AlertListView({
    required this.title,
    required this.description,
    required this.timeago,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              C1_12px_M(text: title, color: PeeroreumColor.gray[600]),
              const Spacer(),
              C1_12px_M(text: timeago, color: PeeroreumColor.gray[600])
            ],
          ),
          SizedBox(height: 8,),
          B4_14px_R(text: description),
        ],
      ),
    );
  }
}

