import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/api/NotificationApi.dart';
import 'package:peeroreum_client/data/NotificationSetting.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class ComplimentCheckList extends StatefulWidget {
  @override
  State<ComplimentCheckList> createState() => _ComplimentCheckListState();
}

class _ComplimentCheckListState extends State<ComplimentCheckList> {
  List<dynamic> successList = [];
  List<String> receiverList = [];
  late List<bool> isCheckedList =
      List.generate(successList.length, (index) => false);
  late List<bool> isActiveList =
      List.generate(successList.length, (index) => true);
  var sender;
  var mygrade;
  var myimage;
  bool mycheck = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    receiverList = [];
  }

  sendNotification() async {
    for (String receiver in receiverList) {
      NotificationApi.sendCompliment(sender!, receiver);
    }
  }

  fetchStatus() async {
    if(mounted){
    sender = await FlutterSecureStorage().read(key: "nickname");
    myimage = await FlutterSecureStorage().read(key: "profileImage");
    mygrade = await FlutterSecureStorage().read(key: "grade");
    successList = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    var here_am_i =
        successList.where((user) => user['nickname'] == sender).toList();
    if (here_am_i.isNotEmpty) {
      setState(() {
        mycheck = true;
      });
    } else {
      setState(() {
        mycheck = false;
      });
    }
    successList =
        successList.where((user) => user['nickname'] != sender).toList();
    }
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
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '달성',
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
        body: FutureBuilder<void>(
            future: fetchStatus(),
            builder: (context, snapshot) {
              return Column(
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
                              '${successList.length}',
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
                              if (isActiveList[i] == true) {
                                if (isCheckedList[i] == false) {
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
                  mycheck ? OkMe() : Container(),
                  mycheck
                      ? Divider(
                          thickness: 1,
                          color: PeeroreumColor.gray[100],
                          height: 8,
                        )
                      : Container(),
                  okList()
                ],
              );
            }),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () {
                for (int i = 0; i < isCheckedList.length; i++) {
                  if (isActiveList[i] == true) {
                    if (isCheckedList[i]) {
                      setState(() {
                        // _isChecked 값이 true인 경우에만 isActive를 false로 설정
                        isActiveList[i] = false;
                        receiverList.add(successList[i]['nickname']);
                      });
                    }
                  }
                }
                sendNotification();
              },
              child: Text(
                '칭찬하기',
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

  OkMe() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
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
                          color: mygrade != null
                              ? PeeroreumColor.gradeColor[int.parse(mygrade)]!
                              : PeeroreumColor.error),
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
                        image: myimage != null
                            ? DecorationImage(
                                image: NetworkImage(myimage), fit: BoxFit.cover)
                            : DecorationImage(
                                image: AssetImage('assets/images/user.jpg')),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    sender != null ? '$sender' : '',
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
              onTap: () {},
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: PeeroreumColor.gray[200]!,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                  color: PeeroreumColor.gray[300]!,
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  okList() {
    return Flexible(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height-299,
        child: ListView.separated(
          scrollDirection: Axis.vertical,
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
                            successList[index]['nickname'],
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: PeeroreumColor.gray[800]),
                          )
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
            itemCount: successList.length));
  }
}
