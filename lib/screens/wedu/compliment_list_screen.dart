import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';
import 'package:get/get.dart';

class ComplimentList extends StatefulWidget {
  const ComplimentList({super.key});

  @override
  State<ComplimentList> createState() => _ComplimentListState();
}

class _ComplimentListState extends State<ComplimentList> {
  List<dynamic> successList = [];
  bool amI = false;
  String? myNickname;

  Future<void> fetchDatas() async {
    myNickname = await const FlutterSecureStorage().read(key: "nickname");
  }

  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = fetchDatas();
  }

  @override
  Widget build(BuildContext context) {
    successList = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: PeeroreumColor.white,
            appBar: AppBar(
              backgroundColor: PeeroreumColor.white,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/x.svg',
                  colorFilter: ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
                  width: 18,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              title: const Text(
                '달성',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: PeeroreumColor.black),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
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
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                '${successList.length}',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: PeeroreumColor.gray[500]),
                              ),
                              const SizedBox(
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
                    okList()
                  ],
                ),
            ),
          );
        });
  }

  okList() {
    return Flexible(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height-140,
        child: ListView.separated(
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (myNickname == successList[index]['nickname']) {
                    amI = true;
                  }
                  Get.to(() =>
                      MyPageProfile(successList[index]['nickname'], amI));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 2,
                              color: PeeroreumColor
                                  .gradeColor[successList[index]['grade']]!),
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
                            image: successList[index]["profileImage"] != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                        successList[index]["profileImage"]),
                                    fit: BoxFit.cover)
                                : const DecorationImage(
                                    image:
                                        AssetImage('assets/images/user.jpg')),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        (successList[index]['nickname'] == myNickname)
                            ? '$myNickname (나)'
                            : successList[index]['nickname'],
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
            itemCount: successList.length));
  }
}
