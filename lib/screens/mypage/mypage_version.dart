import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:peeroreum_client/data/app_update.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';

class MyPageVersion extends StatefulWidget {
  const MyPageVersion({super.key});

  @override
  State<MyPageVersion> createState() => _MyPageVersionState();
}

class _MyPageVersionState extends State<MyPageVersion> {
  PackageInfo? packageInfo;
  AppVersionInfo? versionInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final results =
        await Future.wait([PackageInfo.fromPlatform(), AppUpdate.fetchInfo()]);
    if (!mounted) return;
    setState(() {
      packageInfo = results[0] as PackageInfo;
      versionInfo = results[1] as AppVersionInfo?;
    });
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
          Get.back();
        },
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          colorFilter:
              ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
        ),
      ),
      title: const Text(
        "버전정보",
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                width: 1,
                color: PeeroreumColor.gray[200]!,
              ),
            ),
            child: packageInfo != null
                ? peerVersion()
                : Center(
                    child: CircularProgressIndicator(
                        color: PeeroreumColor.primaryPurple[400])),
          ),
        ],
      ),
    );
  }

  Widget peerVersion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              // 실제 앱 아이콘(iOS AppIcon 1024와 동일 이미지), 흰 배경이라 얇은 테두리로 구분
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.8),
                  border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                  image: const DecorationImage(
                      image: AssetImage('assets/images/peeroreum_logo_v2.png'),
                      fit: BoxFit.cover)),
            ),
            const SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '피어오름',
                  style: TextStyle(
                    color: PeeroreumColor.black,
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  packageInfo?.version ?? '0.0.0',
                  style: TextStyle(
                      color: PeeroreumColor.gray[600],
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          width: 16,
        ),
        versionStatus(),
      ],
    );
  }

  // 서버 최신 버전과 비교해 최신이면 뱃지, 아니면 업데이트 버튼 (조회 실패 시 표시 안 함)
  Widget versionStatus() {
    final info = versionInfo;
    if (info == null) return const SizedBox.shrink();
    if (info.hasNewVersion) {
      return GestureDetector(
        onTap: () => AppUpdate.openStore(info.storeUrl),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
          decoration: BoxDecoration(
            color: PeeroreumColor.primaryPurple[400],
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text(
            '업데이트',
            style: TextStyle(
              color: PeeroreumColor.white,
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: PeeroreumColor.primaryPurple[400]!,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
        child: Text(
          '최신버전',
          style: TextStyle(
            color: PeeroreumColor.primaryPurple[400],
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
