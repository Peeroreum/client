import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/data/Checklist.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';

import '../../api/NotificationApi.dart';
import '../../data/NotificationSetting.dart';
import '../../designs/PeeroreumColor.dart';

class EncouragementCheckList extends StatefulWidget {
  EncouragementCheckList(this.notSuccessList, this.id);
  List<dynamic> notSuccessList;
  int id;

  @override
  State<EncouragementCheckList> createState() =>
      _EncouragementCheckListState(notSuccessList, id);
}

class _EncouragementCheckListState extends State<EncouragementCheckList> {
  _EncouragementCheckListState(this.notSuccessList, this.id);
  List<dynamic> notSuccessList;
  int id;

  List<String> receiverList = [];
  List<String> sendList = [];
  late List<Map<String, String>> callchecklist = [];
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
    fetchChecklistData();
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
  

  fetchChecklistData() async {
    List<String>? data = await encouragementChecklistData();
    if (data != null) {
      setState(() {
        sendList = data;
        updateChecklist();
      });
    } else {
      print('리스트에 이름이 없습니다');
    }
  }

  void updateChecklist() {
    for (int i = 0; i < notSuccessList.length; i++) {
      print(notSuccessList[i]['nickname']);
      if (sendList.contains('(${notSuccessList[i]['nickname']})')) {
        setState(() {
          //isCheckedList[i] = true;
          isActiveList[i] = false;
        });
      } else {
        print('이름 포함하지 않음');
      }
    }
  }

  getChecklistData() async {
    List<Map<String, String>>? data =
        await CheckEncouragementList.getEncouragementCheck(id);
    print('get해서 callchecklist에 넣음');
    setState(() {
      callchecklist = data!;
    });
  }

  sendNotification() async {
    for (String receiver in receiverList) {
      if (sender != receiver) {
        NotificationApi.sendEncouragement(sender!, receiver);
        print("$receiver 님에게 알림 전송");
      }
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
            Navigator.of(context).pop();
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
        actions: [
          IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/icons/icon_dots_mono.svg',
                color: PeeroreumColor.gray[800],
                width: 24,
              ))
        ],
      ),
      body: FutureBuilder<void>(
          future: fetchStatus(),
          builder: (context, snapshot) {
            return SizedBox(
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
                            if(isSelectAll == false){
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
                            } else{
                              isCheckedList = List.generate(notSuccessList.length, (index) => false);
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
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async{
                          if(isCheckedList.contains(true)){
                            print(isCheckedList);
                            await getChecklistData();
                            for (int i = 0; i < isCheckedList.length; i++) {
                              if (isActiveList[i] == true) {
                                if (isCheckedList[i]) {
                                  setState(() {
                                    // _isChecked 값이 true인 경우에만 isActive를 false로 설정
                                    isActiveList[i] = false;
                                    receiverList.add(notSuccessList[i]['nickname']);
                                  });
                                  callchecklist.add({notSuccessList[i]['nickname'] : DateTime.now().toString().substring(0, 10)});
                                }
                              }
                            }
                            CheckEncouragementList.setEncouragementCheck(id,callchecklist);
                            sendNotification();
                            Fluttertoast.showToast(msg: "독려하기 완료!");
                            isCheckedList = List.generate(notSuccessList.length, (index) => false);
                            print(isCheckedList);
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
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ))),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
      // bottomNavigationBar: Container(
      //   padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
      //   child: SizedBox(
      //     height: 48,
      //     child: TextButton(
      //       onPressed: () {
      //         for (int i = 0; i < isCheckedList.length; i++) {
      //           if (isActiveList[i] == true) {
      //             if (isCheckedList[i]) {
      //               setState(() {
      //                 // _isChecked 값이 true인 경우에만 isActive를 false로 설정
      //                 isActiveList[i] = false;
      //                 receiverList.add(notSuccessList[i]['nickname']);
      //               });
      //             }
      //           }
      //         }
      //         sendNotification();
      //       },
      //       child: Text(
      //         '독려하기',
      //         style: TextStyle(
      //           fontFamily: 'Pretendard',
      //           fontSize: 16,
      //           fontWeight: FontWeight.w600,
      //           color: PeeroreumColor.white,
      //         ),
      //       ),
      //       style: ButtonStyle(
      //           backgroundColor: MaterialStateProperty.all(
      //               PeeroreumColor.primaryPuple[400]),
      //           padding: MaterialStateProperty.all(
      //               EdgeInsets.symmetric(vertical: 12)),
      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //               RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(8.0),
      //           ))),
      //     ),
      //   ),
      // )
    );
  }

  notOkList() {
    return Flexible(
        //width: MediaQuery.of(context).size.width,
        //height: MediaQuery.of(context).size.height-301,
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
                            //padding: EdgeInsets.all(3.5),
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

  Future<List<String>?> encouragementChecklistData() async {
    String? me = await FlutterSecureStorage().read(key: "nickname");
    List<String> namelist = ['($me)'];
    List<Map<String, String>>? checklistdata =
        await CheckEncouragementList.getEncouragementCheck(id);
    if (checklistdata != null) {
      checklistdata.removeWhere((element) => element.values
          .any((value) => value != DateTime.now().toString().substring(0, 10)));
      CheckEncouragementList.setEncouragementCheck(id, checklistdata);
    }

    List<Map<String, String>>? listdata =
        await CheckEncouragementList.getEncouragementCheck(id);
    if (listdata != null) {
      print(listdata);
      for (var map in listdata) {
        namelist.add(map.keys.toString());
      }
      print(namelist);
    }
    return namelist;
  }
}
