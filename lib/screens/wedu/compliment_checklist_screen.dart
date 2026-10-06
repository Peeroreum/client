import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:peeroreum_client/api/notification_api.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/designs/peeroreum_typo.dart';
import 'package:get/get.dart';

class ComplimentCheckList extends StatefulWidget {
  const ComplimentCheckList(this.successList, this.title, this.id, {super.key});
  final List<dynamic> successList;
  final String title;
  final int id;

  @override
  State<ComplimentCheckList> createState() =>
      _ComplimentCheckListState();
}

class _ComplimentCheckListState extends State<ComplimentCheckList> {
  late List<dynamic> successList;
  late String title;
  late int id;

  List<String> receiverList = [];
  late List<bool> isCheckedList =
      List.generate(successList.length, (index) => false);
  late List<bool> isActiveList =
      List.generate(successList.length, (index) => true);
  String? sender;
  String? myGrade;
  String? myImage;
  bool myCheck = false;
  bool isSelectAll = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    successList = widget.successList;
    title = widget.title;
    id = widget.id;
    receiverList = [];
    fetchStatus();
  }

  bool controlAllSelect() {
    bool hasUncheckedActiveItem = false;
    for (int i = 0; i < isCheckedList.length; i++) {
      if (isActiveList[i] == true && isCheckedList[i] == false) {
        hasUncheckedActiveItem = true;
        break;
      }
    }
    if (hasUncheckedActiveItem) {
      return false;
    } else {
      // 모든 항목이 isActiveList[i] == true && isCheckedList[i] == true인 경우
      return true;
    }
  }

  sendNotification() async {
    for (String receiver in receiverList) {
      NotificationApi.sendCompliment(sender!, receiver, title, id.toString());
    }
  }

  fetchStatus() async {
    sender = await const FlutterSecureStorage().read(key: "nickname");
    myImage = await const FlutterSecureStorage().read(key: "profileImage");
    myGrade = await const FlutterSecureStorage().read(key: "grade");
    //successList = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    var hereAmI =
        successList.where((user) => user['nickname'] == sender).toList();
    if (hereAmI.isNotEmpty) {
      myCheck = true;
    } else {
      myCheck = false;
    }
    //successList = successList.where((user) => user['nickname'] != sender).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: PeeroreumColor.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: PeeroreumColor.white,
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
        body: FutureBuilder<void>(
            future: fetchStatus(),
            builder: (context, snapshot) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: PeeroreumColor.gray[100],
                          onTap: () {
                            if (isSelectAll == false) {
                              for (int i = 0; i < isCheckedList.length; i++) {
                                if (isActiveList[i] == true) {
                                  if (isCheckedList[i] == false) {
                                    setState(() {
                                      isCheckedList[i] = true;
                                    });
                                  }
                                }
                              }
                              setState(() {
                                isSelectAll = true;
                              });
                            } else {
                              isCheckedList = List.generate(
                                  successList.length, (index) => false);
                              setState(() {
                                isSelectAll = false;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/check.svg',
                                colorFilter: ColorFilter.mode(PeeroreumColor.gray[500]!, BlendMode.srcIn),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              T5(
                                text: "전체선택",
                                color: PeeroreumColor.gray[500],
                              ),
                            ],
                          ),
                        )
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
              );
            }),
        bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewPadding.bottom > 20 ? MediaQuery.of(context).viewPadding.bottom : 20.0),
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () async {
                  if (isCheckedList.isNotEmpty) {
                    receiverList = [];
                    for (int i = 0; i < isCheckedList.length; i++) {
                      if (isActiveList[i] == true) {
                        if (isCheckedList[i]) {
                          receiverList.add(successList[i]['nickname']);
                        }
                      }
                    }

                    if (receiverList.isNotEmpty) {
                      await sendNotification();
                      if (!context.mounted) return;
                      PeeroreumToast.show(context, '칭찬하기에 성공했어요.');
                    }

                    setState(() {
                      isCheckedList =
                          List.generate(successList.length, (index) => false);
                      isSelectAll = false;
                    });
                  }
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        PeeroreumColor.primaryPurple[400]),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
                child: const Text(
                  '칭찬하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.white,
                  ),
                ),
              ),
            ),
        ));
  }

  okList() {
    return Flexible(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height-299,
        child: ListView.separated(
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            //padding: EdgeInsets.all(3.5),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2,
                                  color: PeeroreumColor.gradeColor[
                                      successList[index]['grade']]!),
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
                                image: successList[index]["profileImage"] !=
                                        null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            successList[index]["profileImage"]),
                                        fit: BoxFit.cover)
                                    : const DecorationImage(
                                        image: AssetImage(
                                            'assets/images/user.jpg')),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            (successList[index]['nickname'] == sender)
                                ? '$sender (나)'
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
                    if (successList[index]['nickname'] != sender)
                      InkWell(
                        onTap: () {
                          if (isActiveList[index]) {
                            setState(() {
                              isCheckedList[index] = !isCheckedList[index];
                            });
                          }
                          setState(() {
                            isSelectAll = controlAllSelect();
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: (isCheckedList[index]
                                  ? PeeroreumColor.primaryPurple[400]!
                                  : PeeroreumColor.gray[200]!),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                            color: isActiveList[index]
                                ? (isCheckedList[index]
                                    ? PeeroreumColor.primaryPurple[400]!
                                    : PeeroreumColor.white)
                                : PeeroreumColor.gray[300]!,
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/check.svg',
                            colorFilter: const ColorFilter.mode(PeeroreumColor.white, BlendMode.srcIn),
                          ),
                        ),
                      ),
                  ],
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
