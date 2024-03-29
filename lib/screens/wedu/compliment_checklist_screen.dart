import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/api/NotificationApi.dart';
import 'package:peeroreum_client/data/Checklist.dart';
import 'package:peeroreum_client/data/NotificationSetting.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';

class ComplimentCheckList extends StatefulWidget {
  ComplimentCheckList(this.successList, this.id);
  List<dynamic> successList;
  int id;

  @override
  State<ComplimentCheckList> createState() =>
      _ComplimentCheckListState(successList, id);
}

class _ComplimentCheckListState extends State<ComplimentCheckList> {
  _ComplimentCheckListState(this.successList, this.id);
  List<dynamic> successList;
  int id;

  List<String> receiverList = [];
  List<String> sendList = [];
  List<Map<String, String>> callchecklist = [];
  late List<bool> isCheckedList =
      List.generate(successList.length, (index) => false);
  late List<bool> isActiveList =
      List.generate(successList.length, (index) => true);
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
    List<String>? data = await complimentChecklistData();
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
    for (int i = 0; i < successList.length; i++) {
      print(successList[i]['nickname']);
      if (sendList.contains('(${successList[i]['nickname']})')) {
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
        await CheckComplimentList.getComplimentCheck(id);
    print('get해서 callchecklist에 넣음');
    setState(() {
      callchecklist = data!;
    });
  }

  sendNotification() async {
    for (String receiver in receiverList) {
      NotificationApi.sendCompliment(sender!, receiver);
    }
  }

  fetchStatus() async {
    sender = await FlutterSecureStorage().read(key: "nickname");
    myimage = await FlutterSecureStorage().read(key: "profileImage");
    mygrade = await FlutterSecureStorage().read(key: "grade");
    //successList = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    var here_am_i =
        successList.where((user) => user['nickname'] == sender).toList();
    if (here_am_i.isNotEmpty) {
      mycheck = true;
    } else {
      mycheck = false;
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
              color: PeeroreumColor.gray[800],
              width: 18,
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
                  width: 24,
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
                              isCheckedList = List.generate(successList.length, (index) => false);
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
          padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () async{
                if(isCheckedList.isNotEmpty){
                  await getChecklistData();
                  for (int i = 0; i < isCheckedList.length; i++) {
                    if (isActiveList[i] == true) {
                      if (isCheckedList[i]) {
                        setState(() {
                          // _isChecked 값이 true인 경우에만 isActive를 false로 설정
                          isActiveList[i] = false;
                          receiverList.add(successList[i]['nickname']);
                        });
                        callchecklist.add({successList[i]['nickname'] : DateTime.now().toString().substring(0, 10)});
                      }
                    }
                  }
                  CheckComplimentList.setComplimentCheck(id,callchecklist);
                  sendNotification();
                  Fluttertoast.showToast(msg: '칭찬하기 완료!');
                  isCheckedList = List.generate(successList.length, (index) => false);
                }
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
                        child: 
                        // isCheckedList[index]
                        //     ? Center(
                        //         child: 
                                SvgPicture.asset(
                                'assets/icons/check.svg',
                                color: PeeroreumColor.white,
                              ),
                              // )
                            // : null,
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

  Future<List<String>?> complimentChecklistData() async {
    String? me = await FlutterSecureStorage().read(key: "nickname");
    List<String> namelist = ['($me)'];
    List<Map<String, String>>? checklistdata =
        await CheckComplimentList.getComplimentCheck(id);
    if (checklistdata != null) {
      checklistdata.removeWhere((element) => element.values
          .any((value) => value != DateTime.now().toString().substring(0, 10)));
      CheckComplimentList.setComplimentCheck(id, checklistdata);
    }

    List<Map<String, String>>? listdata =
        await CheckComplimentList.getComplimentCheck(id);
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
