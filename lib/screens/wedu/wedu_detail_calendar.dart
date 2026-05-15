import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';
import 'package:peeroreum_client/screens/pie_chart.dart';
import 'package:peeroreum_client/screens/report.dart';

class DetailWeduCalendar extends StatefulWidget {
  DetailWeduCalendar(this.id, this.weduTitle, {super.key});

  int id;
  String weduTitle;

  @override
  State<DetailWeduCalendar> createState() =>
      _DetailWeduCalendarState(id, weduTitle);
}

final days = ['월', '화', '수', '목', '금', '토', '일'];
late List<List<int>> calendarDays;
int daysInMonth = 0;
DateTime currentDate = DateTime.now();
DateTime firstDayOfCurrentMonth =
    DateTime(currentDate.year, currentDate.month, 1);
DateTime lastDayOfCurrentMonth = DateTime(currentDate.year, currentDate.month,
    DateTime(currentDate.year, currentDate.month + 1, 0).day);

int? focusedDay;
int? savedFocusedDay = focusedDay;
int? focusedMonth;

var startDate = currentDate;
var finalDate = currentDate;

bool _isLeftButtonWork = startDate.isBefore(firstDayOfCurrentMonth);
bool _isRightButtonWork = finalDate.isAfter(lastDayOfCurrentMonth);

class _DetailWeduCalendarState extends State<DetailWeduCalendar> {
  late Future initFuture;
  int id;
  String weduTitle;

  _DetailWeduCalendarState(this.id, this.weduTitle);

  dynamic weduData = '';
  dynamic weduMonthlyData = '';
  dynamic weduFire = '';
  List<dynamic> challengeImage = [];
  List<dynamic> successList = [];
  List<dynamic> notSuccessList = [];
  List<dynamic> challengeImageList = [];

  List<dynamic> progress = [];
  bool amI = false;
  bool isMyImage = true;
  var myNickname;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    calendarDays = generateCalendarDays();
    focusedDay = DateTime.now().day;
    savedFocusedDay = focusedDay;
    focusedMonth = currentDate.month;
    if (currentDate.isAfter(finalDate)) {
      currentDate = finalDate;
      focusedMonth = finalDate.month;
      focusedDay = finalDate.day;
      savedFocusedDay = focusedDay;
    }
    initFuture = fetchData();
  }

  void _updateCalendar() {
    setState(() {
      calendarDays = generateCalendarDays();
      if (focusedMonth == currentDate.month) {
        focusedDay = savedFocusedDay;
      }
      if (currentDate.year == startDate.year &&
          currentDate.month == startDate.month) {
        _isLeftButtonWork = false;
      } else {
        _isLeftButtonWork = true;
      }
      if (currentDate.year == finalDate.year &&
          currentDate.month == finalDate.month) {
        _isRightButtonWork = false;
      } else {
        _isRightButtonWork = true;
      }
    });
    fetchData();
  }

  Future<void> fetchData() async {
    myNickname = await const FlutterSecureStorage().read(key: "nickname");

    var weduResult = await ApiClient().get('/wedu/$id');
    if (weduResult.statusCode == 200) {
      weduData = weduResult.data['data'];
      weduFire = weduData['continuousDate'];
    } else {
      print("에러${weduResult.statusCode}");
    }

    String requestFormatDate2 = DateFormat('yyyyMMdd').format(currentDate);
    var weduProgressResult =
        await ApiClient().get('/wedu/$id/monthly/$requestFormatDate2');

    if (weduProgressResult.statusCode == 200) {
      weduMonthlyData = weduProgressResult.data['data'];
      progress = weduMonthlyData['monthlyProgress'];
      startDate = DateTime.parse(weduMonthlyData['createdDate']);
      finalDate = DateTime.parse(weduMonthlyData['targetDate']);
    } else {
      print("에러${weduProgressResult.statusCode}");
    }

    DateTime requestDate =
        DateTime(currentDate.year, focusedMonth!, savedFocusedDay!);
    String requestFormatDate = DateFormat('yyyyMMdd').format(requestDate);
    var challengeList =
        await ApiClient().get('/wedu/$id/challenge/$requestFormatDate');
    if (challengeList.statusCode == 200) {
      successList = challengeList.data['data']['successMembers'];
      notSuccessList = challengeList.data['data']['failMembers'];

      var me = successList.firstWhere(
          (member) => member['nickname'] == myNickname,
          orElse: () => null);
      if (me != null) {
        successList.remove(me);
        successList.insert(0, me);
      }

      me = notSuccessList.firstWhere(
          (member) => member['nickname'] == myNickname,
          orElse: () => null);
      if (me != null) {
        notSuccessList.remove(me);
        notSuccessList.insert(0, me);
      }
    } else {
      print("목록${challengeList.statusCode}");
    }

    if (successList.isNotEmpty) {
      await fetchImages(successList);
    }

    setState(() {});
  }

  fetchImages(List<dynamic> successList) async {
    DateTime requestDate =
        DateTime(currentDate.year, focusedMonth!, savedFocusedDay!);
    String formatDate = DateFormat('yyyyMMdd').format(requestDate);
    List<dynamic> resultImageList = [];
    for (var index = 0; index < successList.length; index++) {
      var successOne = successList[index]['nickname'].toString();
      var result =
          await ApiClient().get('/wedu/$id/challenge/$successOne/$formatDate');
      if (result.statusCode == 200) {
        resultImageList.add(result.data['data']['imageUrls']);
      } else {
        print('이미지 에러 ${result.statusCode}');
      }
    }
    challengeImageList = resultImageList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: PeeroreumColor.white,
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Scaffold(
            backgroundColor: PeeroreumColor.white,
            appBar: AppBar(
              backgroundColor: PeeroreumColor.white,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  color: PeeroreumColor.gray[800],
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      weduTitle,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: PeeroreumColor.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/icon_dots_mono.svg',
                      color: PeeroreumColor.white,
                    ))
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset((weduFire == 0)
                            ? 'assets/icons/fire_off.svg'
                            : 'assets/icons/fire.svg'),
                        const SizedBox(
                          width: 2,
                        ),
                        (weduFire == 0)
                            ? Container()
                            : const Text(
                                '+',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: PeeroreumColor.black),
                              ),
                        const SizedBox(
                          width: 2,
                        ),
                        (weduFire == 0)
                            ? Text(
                                '친구들이 기다리고 있어요!',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: PeeroreumColor.gray[600]),
                              )
                            : Text(
                                '$weduFire',
                                style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: PeeroreumColor.black),
                              )
                      ],
                    ),
                    Divider(
                      thickness: 1,
                      color: PeeroreumColor.gray[100],
                    )
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                color: PeeroreumColor.white,
                child: bodyWidget(),
              ),
            ),
          );
        }
      },
    );
  }

  Widget bodyWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          calendarHeader(),
          calendarBody(),
          Divider(
            color: PeeroreumColor.gray[50],
            thickness: 8,
          ),
          calendarList(),
        ],
      ),
    );
  }

  calendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (_isLeftButtonWork) {
                setState(() {
                  currentDate = DateTime(
                    currentDate.year,
                    currentDate.month - 1,
                  );
                  _updateCalendar();
                });
              }
            },
            icon: SvgPicture.asset(
              'assets/icons/left.svg',
              color: PeeroreumColor.gray[500],
            ),
          ),
          Text(
            '${currentDate.month}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 2,
          ),
          const Text(
            '월',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              if (_isRightButtonWork) {
                setState(() {
                  currentDate = DateTime(
                    currentDate.year,
                    currentDate.month + 1,
                  );
                  _updateCalendar();
                });
              }
            },
            icon: SvgPicture.asset('assets/icons/right.svg',
                width: 24, color: PeeroreumColor.gray[500]),
          )
        ],
      ),
    );
  }

  calendarBody() {
    return Container(
      width: 390,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int day = 0; day < 7; day++)
                Container(
                  alignment: Alignment.center,
                  height: 24,
                  width: 36,
                  child: Text(
                    days[day],
                    style: const TextStyle(
                      fontFamily: 'pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: PeeroreumColor.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          for (List<int> week in calendarDays)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int day in week)
                  if (day != 0 &&
                      day >= 1 &&
                      day <= daysInMonth &&
                      day <= progress.length)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      alignment: Alignment.center,
                      height: 36,
                      width: 36,
                      child: (currentDate.year == startDate.year &&
                                  currentDate.month == startDate.month &&
                                  day < startDate.day) ||
                              (currentDate.year == finalDate.year &&
                                  currentDate.month == finalDate.month &&
                                  day > finalDate.day)
                          ? Container(
                              alignment: Alignment.center,
                              width: 36,
                              height: 36,
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontFamily: 'pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[500],
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  focusedMonth = currentDate.month;
                                  if (focusedDay == day) {
                                    focusedDay = null;
                                  } else {
                                    focusedDay = day;
                                    savedFocusedDay = focusedDay;
                                  }
                                  fetchData();
                                });
                              },
                              child: (focusedDay == day
                                  ? Container(
                                      alignment: Alignment.center,
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: PeeroreumColor.primaryPuple[400],
                                      ),
                                      child: Text(
                                        '${progress[day - 1]}',
                                        style: const TextStyle(
                                          fontFamily: 'pretendard',
                                          color: PeeroreumColor.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : CustomPaint(
                                      painter: PieChart()
                                        ..percentage =
                                            progress[day - 1].toInt(),
                                      child: Center(
                                        child: Text(
                                          '$day',
                                          style: TextStyle(
                                            fontFamily: 'pretendard',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: PeeroreumColor.gray[500],
                                          ),
                                        ),
                                      ),
                                    )),
                            ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      alignment: Alignment.center,
                      height: 36,
                      width: 36,
                      child: const Text(''),
                    ),
              ],
            ),
        ],
      ),
    );
  }

  calendarList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '달성',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: PeeroreumColor.gray[800]),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    '${successList.length}',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: PeeroreumColor.gray[800]),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/wedu/challenge/ok', arguments: successList);
                },
                child: Text(
                  '전체보기',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: PeeroreumColor.gray[500]),
                ),
              ),
            ],
          ),
        ),
        (successList.isNotEmpty) ? okList() : Container(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '미달성',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: PeeroreumColor.gray[800]),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    '${notSuccessList.length}',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: PeeroreumColor.gray[800]),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/wedu/challenge/notok',
                      arguments: notSuccessList);
                },
                child: Text(
                  '전체보기',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: PeeroreumColor.gray[500]),
                ),
              ),
            ],
          ),
        ),
        notOkList()
      ],
    );
  }

  okList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 8),
        itemCount: successList.length,
        itemBuilder: (BuildContext context, int index) {
          String okNickname = successList[index]['nickname'];
          if (okNickname.length > 5) {
            okNickname = okNickname.substring(0, 5);
          }
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
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
                            : const DecorationImage(
                                image: AssetImage('assets/images/user.jpg')),
                      ),
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      isScrollControlled: true,
                      builder: (context) {
                        return challengeImages(successList[index], index);
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  okNickname,
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: PeeroreumColor.gray[800]),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  notOkList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 8),
        itemCount: notSuccessList.length,
        itemBuilder: (BuildContext context, int index) {
          String notOkNickname = notSuccessList[index]['nickname'];
          if (notOkNickname.length > 5) {
            notOkNickname = notOkNickname.substring(0, 5);
          }
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (myNickname == notSuccessList[index]['nickname']) {
                      amI = true;
                    }
                    Get.to(() =>
                        MyPageProfile(notSuccessList[index]['nickname'], amI));
                  },
                  child: Container(
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
                            : const DecorationImage(
                                image: AssetImage('assets/images/user.jpg')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  notOkNickname,
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: PeeroreumColor.gray[800]),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  aboutImageWedu(String successOneNickname) {
    isMyImage = myNickname == successOneNickname;
    return Container(
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: isMyImage
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                Get.back();
              },
              child: Container(
                  margin: EdgeInsets.fromLTRB(
                      0,
                      16,
                      0,
                      MediaQuery.of(context).viewPadding.bottom > 20
                          ? MediaQuery.of(context).viewPadding.bottom
                          : 20.0),
                  height: 56,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '삭제하기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: PeeroreumColor.error,
                      ),
                    ),
                  )),
            )
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                await Get.to(() => Report(
                      data: "[같이해냄] 챌린지 이미지 신고\n" +
                          "날짜 : ${DateTime(currentDate.year, focusedMonth!, savedFocusedDay!).toString().substring(0, 10)}\n" +
                          "같이방 아이디 : $id\n" +
                          "같이방 이름 : $weduTitle\n" +
                          "업로드한 사람 : ${successOneNickname}\n",
                    ));
                int count = 0;
                Get.until((route) {
                  bool shouldPop = count == 2;
                  count++;
                  return shouldPop;
                });
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    0,
                    16,
                    0,
                    MediaQuery.of(context).viewPadding.bottom > 20
                        ? MediaQuery.of(context).viewPadding.bottom
                        : 20.0),
                height: 56,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: const Text('신고하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: PeeroreumColor.error,
                    )),
              ),
            ),
    );
  }

  challengeImages(dynamic successOne, var index) {
    challengeImage = challengeImageList[index];

    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (myNickname == successOne["nickname"]) {
                          amI = true;
                        }
                        Get.to(
                            () => MyPageProfile(successOne["nickname"], amI));
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 2,
                              color: PeeroreumColor
                                  .gradeColor[successOne['grade']]!),
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
                            image: successOne["profileImage"] != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                        successOne["profileImage"]),
                                    fit: BoxFit.cover)
                                : const DecorationImage(
                                    image:
                                        AssetImage('assets/images/user.jpg')),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      successOne["nickname"].toString(),
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: PeeroreumColor.gray[800]),
                    )
                  ],
                ),
                GestureDetector(
                  child: SvgPicture.asset(
                    'assets/icons/icon_dots_mono.svg',
                    color: PeeroreumColor.gray[800],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return aboutImageWedu(
                              successOne["nickname"].toString());
                        });
                  },
                )
              ],
            ),
            const SizedBox(height: 20),
            CarouselSlider(
              items: challengeImage.map((i) {
                var imageUrl = i.toString();
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: PeeroreumColor.gray[100],
                          image: i != null
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover)
                              : null),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(60, 0, 0, 0),
                            ),
                            child: Text(
                              '${challengeImage.indexOf(i) + 1} / ${challengeImage.length}',
                              style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: PeeroreumColor.white),
                            )),
                      ),
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                enableInfiniteScroll: false,
                viewportFraction: 1,
                height: 380,
                enlargeCenterPage: false,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              width: double.maxFinite,
              child: TextButton(
                onPressed: () {
                  Get.back();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(PeeroreumColor.gray[300]),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
                child: Text(
                  '닫기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<List<int>> generateCalendarDays() {
  focusedDay = null;
  int currentMonth = currentDate.month;
  DateTime firstDayOfMonth = DateTime(currentDate.year, currentMonth, 1);
  int startingDay = (firstDayOfMonth.weekday - 1) % 7;
  daysInMonth = DateTime(currentDate.year, currentMonth + 1, 0).day;

  List<List<int>> calendarDays = [];
  List<int> week = [];

  for (int i = 1; i <= daysInMonth + startingDay; i++) {
    if (i > startingDay) {
      week.add(i - startingDay);
    } else {
      week.add(0);
    }

    if (i % 7 == 0 || i == daysInMonth + startingDay) {
      while (week.length < 7) {
        week.add(0);
      }

      calendarDays.add(List.from(week));
      week.clear();
    }
  }

  if (week.isNotEmpty) {
    calendarDays.add(List.from(week));
  }

  return calendarDays;
}
