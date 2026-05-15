import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';

class ManagementCheckList extends StatefulWidget {
  ManagementCheckList(this.memberList, this.title, this.id, {super.key});

  List<dynamic> memberList;
  String title;
  int id;

  @override
  State<ManagementCheckList> createState() =>
      _ManagementCheckListState(memberList, title, id);
}

class _ManagementCheckListState extends State<ManagementCheckList> {
  _ManagementCheckListState(this.memberList, this.title, this.id);

  List<dynamic> memberList;
  String title;
  int id;

  List<String> selectedUserList = [];
  late List<bool> isCheckedList =
      List.generate(memberList.length, (index) => false);
  late List<bool> isActiveList =
      List.generate(memberList.length, (index) => true);

  var myNickname;
  bool isSelectAll = false;

  @override
  void initState() {
    super.initState();
    selectedUserList = [];
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
      return true;
    }
  }

  fetchStatus() async {
    myNickname = await const FlutterSecureStorage().read(key: "nickname");
    var response = await ApiClient().get('/wedu/$id/members');

    if (response.statusCode == 200) {
      var data = response.data['data'];
      for (var m in data) {
        for (int i = 0; i < memberList.length; i++) {
          if (memberList[i]['nickname'] == m['nickname']) {
            memberList[i]['memberId'] = m['memberId'];
          }
        }
      }
    }

    setState(() {
      for (int i = 0; i < memberList.length; i++) {
        if (memberList[i]['nickname'] == myNickname) {
          isActiveList[i] = false;
        } else {
          isActiveList[i] = true;
        }
      }
    });
  }

  void kickMember(List<String> nicknameList) async {
    bool allSuccess = true;

    for (var nickname in nicknameList) {
      var member = memberList.firstWhere((m) => m['nickname'] == nickname,
          orElse: () => null);
      if (member == null) continue;

      var memberId = member['memberId'];
      var result = await ApiClient().delete('/wedu/$id/kick/$memberId');

      if (result.statusCode == 200) {
        setState(() {
          memberList.removeWhere((m) => m['nickname'] == nickname);
        });
      } else {
        allSuccess = false;
      }
    }

    if (allSuccess) {
      PeeroreumToast.show(context, "참여를 종료했어요.");
    } else {
      PeeroreumToast.show(context, "참여 종료에 실패한 사용자가 있어요.", isError: true);
    }

    setState(() {
      isCheckedList = List.generate(memberList.length, (index) => false);
      isSelectAll = false;
      selectedUserList.clear();
    });
  }

  showKickDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "이 사용자의 같이방 참여를 종료할까요?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "종료 후에도 다시 초대할 수 있어요.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          print("강퇴할 유저 목록: $selectedUserList");
                          Get.back();
                          kickMember(selectedUserList);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
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
              Get.back();
              Get.to(() => DetailWedu(id));
            },
          ),
          title: const Text(
            '참여자 관리',
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
                              '${memberList.length}',
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
                                  memberList.length, (index) => false);
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
                              const SizedBox(
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
                  userListView()
                ],
              );
            }),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.of(context).viewPadding.bottom > 20
                  ? MediaQuery.of(context).viewPadding.bottom
                  : 20.0),
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () {
                selectedUserList.clear();
                for (int i = 0; i < isCheckedList.length; i++) {
                  if (isActiveList[i] == true && isCheckedList[i] == true) {
                    selectedUserList.add(memberList[i]['nickname']);
                  }
                }

                if (selectedUserList.isNotEmpty) {
                  showKickDialog();
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      PeeroreumColor.primaryPuple[400]),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ))),
              child: const Text(
                '참여 종료',
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

  userListView() {
    return Flexible(
        child: ListView.separated(
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                  color: PeeroreumColor
                                      .gradeColor[memberList[index]['grade']]!),
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
                                image: memberList[index]["profileImage"] != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            memberList[index]["profileImage"]),
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
                            (memberList[index]['nickname'] == myNickname)
                                ? '$myNickname (나)'
                                : memberList[index]['nickname'],
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
                        child: SvgPicture.asset(
                          'assets/icons/check.svg',
                          color: PeeroreumColor.white,
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
            itemCount: memberList.length));
  }
}
