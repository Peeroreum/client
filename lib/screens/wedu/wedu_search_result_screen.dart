import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/widgets/error_retry_view.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/designs/peeroreum_typo.dart';
import 'package:peeroreum_client/screens/wedu/wedu_create_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_room_info_sheet.dart';
import 'package:share_plus/share_plus.dart';


class SearchResultWedu extends StatefulWidget {
  final String keyword;

  const SearchResultWedu(this.keyword, {super.key});

  @override
  State<SearchResultWedu> createState() => _SearchResultWeduState();
}

class _SearchResultWeduState extends State<SearchResultWedu> {
  late String keyword;

  List<dynamic> data = [];
  Map<dynamic, dynamic> inviData = {};
  Map<dynamic, List<dynamic>> hashTags = {};
  List<String> gradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3', '대학'];
  List<String> subjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타', '대학'];
  List<dynamic> inRoomData = [];
  late Future<void> _searchFuture;

  @override
  void initState() {
    super.initState();
    keyword = widget.keyword;
    _searchFuture = fetchData();
    fetchInRoomData();
  }

  Future<void> fetchData() async {
    var weduResult = await ApiClient().get('/wedu/search/$keyword');
    if (weduResult.statusCode == 200) {
      data = weduResult.data['data'];
      if (kDebugMode) {
        print("데이터 fetch 완료 \n $data");
      }
    } else {
      if (kDebugMode) {
        print("에러${weduResult.statusCode}");
      }
    }

    await fetchImage(data);
  }

  fetchImage(datas) async {
    dynamic inviData;
    for (var data in datas) {
      inviData = await fetchInvitation(data['id']);
      this.inviData.addAll({data['id']: inviData});
      hashTags.addAll({data['id']: inviData['hashTags']});
    }
  }

  fetchInvitation(id) async {
    var inviResult = await ApiClient().get('/wedu/$id/invitation');

    if (inviResult.statusCode == 200) {
      return inviResult.data['data'];
    } else {
      if (kDebugMode) {
        print("에러${inviResult.statusCode}");
      }
    }
  }



  fetchInRoomData() async {
    String? nickname = await const FlutterSecureStorage().read(key: "nickname");

    var result = await ApiClient()
        .get('/wedu/in', queryParameters: {'nickname': nickname});

    if (result.statusCode == 200) {
      if (mounted) {
        setState(() {
          inRoomData = result.data['data'];
        });
      }
    }
  }

  /// 같이방 초대 딥링크 생성: peeroreum://wedu/{roomId}
  String getInviteLink(String roomId) {
    return 'peeroreum://wedu/$roomId';
  }

  /// 공유 메시지 생성 (앱 미설치 사용자를 위한 스토어 링크 포함)
  String buildShareMessage(String roomName, String roomId) {
    return '📚 피어오름 같이방 \'$roomName\'에 초대합니다!\n\n'
        '앱이 설치된 경우 아래 링크를 눌러 바로 입장하세요:\n'
        '${getInviteLink(roomId)}\n\n'
        '앱이 없다면 설치 후 참여해요 🙌\n'
        '• 안드로이드: https://play.google.com/store/apps/details?id=com.peeroreum.peeroreum_client\n'
        '• iOS: https://apps.apple.com/app/id6476135072';
  }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          // 입력창이 없는 화면이라 키보드가 올라와도 레이아웃을 줄이지 않음
          // (검색창을 눌러 돌아갈 때 키보드가 먼저 올라와 빈 결과 화면이 넘치던 문제)
          resizeToAvoidBottomInset: false,
          backgroundColor: PeeroreumColor.white,
          appBar: AppBar(
              backgroundColor: PeeroreumColor.white,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  colorFilter: ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
                ),
                onPressed: () {
                  Get.back(result: 'back');
                },
              ),
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 20, 12),
                child: GestureDetector(
                  // 검색창을 누르면 현재 검색어를 들고 검색 화면으로 돌아가 바로 수정
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.back(result: 'edit'),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: PeeroreumColor.gray[100],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            keyword,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: PeeroreumColor.gray[800],
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/icons/search.svg',
                          colorFilter: ColorFilter.mode(
                              PeeroreumColor.gray[600]!, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          body: SafeArea(
            child: FutureBuilder<void>(
              future: _searchFuture,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return ErrorRetryView(
                    onRetry: () => setState(() {
                      _searchFuture = fetchData();
                    }),
                  );
                } else {
                  return data.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/no_wedu_oreum.png',
                                width: 150,
                              ),
                              const Text(
                                '찾으시는 같이방이 없어요 🥲',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: PeeroreumColor.black),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                '같이방을 만들어보세요!',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: PeeroreumColor.gray[700]),
                              ),
                              const SizedBox(
                                height: 32,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => const CreateWedu());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  height: 48,
                                  width: 185,
                                  decoration: BoxDecoration(
                                    color: PeeroreumColor.primaryPurple[400],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/plus_square2.svg',
                                        colorFilter: const ColorFilter.mode(PeeroreumColor.white, BlendMode.srcIn),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const T4(
                                        text: '같이방 만들러 가기',
                                        color: PeeroreumColor.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 56,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Text(
                                    '검색된 같이방',
                                    style: TextStyle(
                                        color: PeeroreumColor.gray[800],
                                        fontFamily: 'Pretendard',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    '${data.length}',
                                    style: TextStyle(
                                        color: PeeroreumColor.gray[600],
                                        fontFamily: 'Pretendard',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                            Expanded(child: listViewBody())
                          ],
                        );
                }
              },
            ),
          )),
    );
  }

  Widget listViewBody() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: data.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PeeroreumColor.gray[50],
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: (data[index]["imagePath"] != null)
                        ? Image.network(
                            data[index]["imagePath"],
                            fit: BoxFit.cover,
                          )
                        : SvgPicture.asset(
                            'assets/images/default.svg',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                color: PeeroreumColor.subjectColor[
                                    subjectList[data[index]['subject']]]?[0],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  subjectList[data[index]['subject']],
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: PeeroreumColor.subjectColor[
                                            subjectList[data[index]['subject']]]
                                        ?[1],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            data[index]['locked'].toString() == "true"
                                ? SvgPicture.asset('assets/icons/lock.svg',
                                    colorFilter: ColorFilter.mode(PeeroreumColor.gray[400]!, BlendMode.srcIn), width: 12)
                                : Container(),
                            data[index]['locked'].toString() == "true"
                                ? const SizedBox(width: 4)
                                : const SizedBox(),
                            Flexible(
                              child: Text(
                                data[index]["title"]!,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: 'Pretendard',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: PeeroreumColor.black),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(
                        //   height: 4,
                        // ),
                        Row(
                          children: [
                            Text(gradeList[data[index]["grade"]],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('${data[index]["attendingPeopleNum"]!}명',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('D-${data[index]["dday"]!}',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                          ],
                        )
                      ]),
                )
              ],
            ),
          ),
          onTap: () {
            WeduRoomInfoSheet.show(
              context,
              roomData: data[index],
              inviData: inviData[data[index]['id']] ?? {},
              hashTagsList: hashTags[data[index]['id']] ?? [],
              isAlreadyJoined:
                  inRoomData.any((item) => item['id'] == data[index]['id']),
              onShare: (shareRect) {
                final roomId = data[index]['id'].toString();
                final roomName = data[index]['title'] as String? ?? '같이방';
                Share.share(buildShareMessage(roomName, roomId),
                    sharePositionOrigin: shareRect);
              },
              onEnroll: () {
                Get.back();
                data[index]['locked'].toString() == 'true'
                    ? insertPassword(index)
                    : enrollWedu(index);
              },
            );
          },
        );
      },
    );
  }

  void enrollWedu(index, {String? password}) async {
    var id = data[index]['id'];
    final dynamic enrollResult;
    try {
      enrollResult = await ApiClient().post('/wedu/$id/enroll',
          data: password == null ? null : {'password': password});
    } catch (e) {
      return;
    }
    if (!mounted) return;
    if (enrollResult.statusCode == 200) {
      PeeroreumToast.show(context, "같이방에 참여했어요!");
    } else {
      PeeroreumToast.show(context, ApiClient.errorMessage(enrollResult),
          isError: true);
      if (kDebugMode) {
        print('에러${enrollResult.statusCode}');
      }
    }
  }

  void insertPassword(index) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: PeeroreumColor.white,
            surfaceTintColor: Colors.transparent,
            title: const Text("비밀번호", textAlign: TextAlign.center),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
              color: PeeroreumColor.black,
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            content: Container(
              color: PeeroreumColor.white,
              width: MediaQuery.of(context).size.width * 0.8,
              height: 48,
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력하세요.',
                  hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: PeeroreumColor.gray[600]),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                ),
                cursorColor: PeeroreumColor.gray[600],
              ),
            ),
            actions: [
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
                      onPressed: () {
                        // 비밀번호는 서버에서 확인
                        Get.back();
                        enrollWedu(index, password: passwordController.text);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: PeeroreumColor.primaryPurple[400],
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
          );
        });
  }
}
