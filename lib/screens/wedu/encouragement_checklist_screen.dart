import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';

import '../../api/NotificationApi.dart';
import '../../data/NotificationSetting.dart';
import '../../designs/PeeroreumColor.dart';

class EncouragementCheckList extends StatefulWidget {
  @override
  State<EncouragementCheckList> createState() => _EncouragementCheckListState();
}

class _EncouragementCheckListState extends State<EncouragementCheckList> {
  List<dynamic> notSuccessList = [];
  List<String> receiverList = [];
  late List<bool> isCheckedList = List.generate(notSuccessList.length, (index) => false);
  late List<bool> isActiveList = List.generate(notSuccessList.length, (index) => true);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    receiverList =[];
  }

  sendNotification() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    var sender = await storage.read(key: "nickname");
    for(String receiver in receiverList) {
      NotificationApi.sendEncouragement(sender!, receiver);
      print("$receiver 님에게 알림 전송");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    notSuccessList = ModalRoute.of(context)!.settings.arguments as List<dynamic>;

    return Scaffold(
        backgroundColor: PeeroreumColor.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: PeeroreumColor.white,
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
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
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
                      TextButton.icon(
                        onPressed: () {
                          for (int i = 0; i < isCheckedList.length; i++) {
                            if (isActiveList[i] == true){
                              if (isCheckedList[i]==false) {
                                setState(() {
                                  isCheckedList[i] = true;
                                });
                              }
                            }
                          }
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/check.svg',
                          color: PeeroreumColor.gray[500],
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(right: 0),
                        ),
                        label: Text(
                          '전체선택',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: PeeroreumColor.gray[500]),
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
                notOkList()
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () {
                for (int i = 0; i < isCheckedList.length; i++) {
                  if (isActiveList[i] == true){
                    if (isCheckedList[i]) {
                      setState(() {
                        // _isChecked 값이 true인 경우에만 isActive를 false로 설정
                        isActiveList[i] = false;
                        receiverList.add(notSuccessList[i]['nickname']);
                      });
                    }
                  }
                }
                sendNotification();
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
        ));
  }

  notOkList() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: double.maxFinite,
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
                                  color: PeeroreumColor
                                      .gradeColor[notSuccessList[index]['grade']]!),
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
                                image: notSuccessList[index]["profileImage"] != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            notSuccessList[index]["profileImage"]),
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
                        notSuccessList[index]['nickname'],
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
                        if (isActiveList[index]){
                          setState(() {
                            isCheckedList[index] = !isCheckedList[index];
                          });
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PeeroreumColor.gray[200]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                          color: isActiveList[index]
                          ? (isCheckedList[index]
                              ? PeeroreumColor.primaryPuple[400]!
                              : PeeroreumColor.white)
                          : PeeroreumColor.gray[300]!,
                        ),
                        child: isCheckedList[index]
                            ? Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            : null,
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
