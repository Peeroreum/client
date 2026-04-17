import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:peeroreum_client/data/Checklist.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';

import '../../api/NotificationApi.dart';
import '../../designs/PeeroreumColor.dart';
import 'package:get/get.dart';

class EncouragementCheckList extends StatefulWidget {
  EncouragementCheckList(this.notSuccessList, this.title, this.id);
  List<dynamic> notSuccessList;
  String title;
  int id;

  @override
  State<EncouragementCheckList> createState() =>
      _EncouragementCheckListState(notSuccessList, title, id);
}

class _EncouragementCheckListState extends State<EncouragementCheckList> {
  _EncouragementCheckListState(this.notSuccessList, this.title, this.id);
  List<dynamic> notSuccessList;
  String title;
  int id;

  List<String> receiverList = [];
  late List<bool> isCheckedList =
      List.generate(notSuccessList.length, (index) => false);
  late List<bool> isActiveList =
      List.generate(notSuccessList.length, (index) => true);
  var sender;
  var mygrade;
  var myimage;
  bool mycheck = false;
  bool isSelectAll = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      NotificationApi.sendEncouragement(
          sender!, receiver, title, id.toString());
      print("$receiver 님에게 알림 전송");
    }
  }

  fetchStatus() async {
    sender = await FlutterSecureStorage().read(key: "nickname");
    myimage = await FlutterSecureStorage().read(key: "profileImage");
    mygrade = await FlutterSecureStorage().read(key: "grade");
    //notSuccessList = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    var here_am_i =
        notSuccessList.where((user) => user['nickname'] == sender).toList();

    if (here_am_i.isNotEmpty) {
      mycheck = true;
    } else {
      mycheck = false;
    }
    //notSuccessList = notSuccessList.where((user) => user['nickname'] != sender).toList();
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
              color: PeeroreumColor.gray[800],
              width: 18,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            '미달성',
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
              return SafeArea(
                child: SizedBox(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
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
                                  '${notSuccessList.length}',
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
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: PeeroreumColor.gray[100],
                              onTap: () {
                                if (isSelectAll == false) {
                                  for (int i = 0;
                                      i < isCheckedList.length;
                                      i++) {
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
                                      notSuccessList.length, (index) => false);
                                  setState(() {
                                    isSelectAll = false;
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/check.svg',
                                    color: PeeroreumColor.gray[500],
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  T5_14px(
                                    text: "전체선택",
                                    color: PeeroreumColor.gray[500],
                                  )
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
                      notOkList(),
                    ],
                  ),
                ),
              );
            }),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  if (isCheckedList.contains(true)) {
                    print('isCheckedList: $isCheckedList');
                    receiverList = [];
                    for (int i = 0; i < isCheckedList.length; i++) {
                      if (isActiveList[i] == true) {
                        if (isCheckedList[i]) {
                          receiverList.add(notSuccessList[i]['nickname']);
                        }
                      }
                    }

                    if (receiverList.isNotEmpty) {
                      await sendNotification();
                      PeeroreumToast.show(context, '재촉하기에 성공했어요.');
                    }
                    setState(() {
                      isCheckedList = List.generate(
                          notSuccessList.length, (index) => false);
                      isSelectAll = false;
                    });
                  }
                },
                child: Text(
                  '독려하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.white,
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        PeeroreumColor.primaryPuple[400]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
              ),
            ),
          ),
        ));
  }

  notOkList() {
    return Flexible(
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2,
                                  color: PeeroreumColor.gradeColor[
                                      notSuccessList[index]['grade']]!),
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
                                image: notSuccessList[index]["profileImage"] !=
                                        null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            notSuccessList[index]
                                                ["profileImage"]),
                                        fit: BoxFit.cover)
                                    : DecorationImage(
                                        image: AssetImage(
                                            'assets/images/user.jpg')),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            (notSuccessList[index]['nickname'] == sender)
                                ? '$sender (나)'
                                : notSuccessList[index]['nickname'],
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: PeeroreumColor.gray[800]),
                          ),
                        ],
                      ),
                    ),
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
                                ? PeeroreumColor.primaryPuple[400]!
                                : PeeroreumColor.gray[200]!),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                          color: isActiveList[index]
                              ? (isCheckedList[index]
                                  ? PeeroreumColor.primaryPuple[400]!
                                  : PeeroreumColor.white)
                              : PeeroreumColor.gray[300]!,
                        ),
                        child: //isCheckedList[index]
                            //?
                            // Center(
                            SvgPicture.asset(
                          'assets/icons/check.svg',
                          color: PeeroreumColor.white,
                        ),
                        // )
                        //: null,
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
            itemCount: notSuccessList.length));
  }
}
