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
  late List<bool> isCheckedList = List.generate(successList.length, (index) => false);
  late List<bool> isActiveList = List.generate(successList.length, (index) => true);

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
      NotificationApi.sendCompliment(sender!, receiver);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    successList = ModalRoute.of(context)!.settings.arguments as List<dynamic>;

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
                )
            )
          ],
        ),
        body: SingleChildScrollView(
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
              okList()
            ],
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
                  backgroundColor:
                      MaterialStateProperty.all(PeeroreumColor.primaryPuple[400]),
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
    return Container(
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
                                  : DecorationImage(
                                  image: AssetImage('assets/images/user.jpg')),
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
          itemCount: successList.length
      )
    );
  }
}