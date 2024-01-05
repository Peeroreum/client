import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';


import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/screens/pie_chart.dart';


import '../../api/PeeroreumApi.dart';





class DetailWeduCalendar extends StatefulWidget {
  //const DetailWeduCalendar({super.key});
  DetailWeduCalendar(this.id, this.weduTitle);
  int id;
  String weduTitle;

  @override
  State<DetailWeduCalendar> createState() => _DetailWeduCalendarState(id, weduTitle);
}

final days = ['월', '화', '수', '목', '금', '토', '일'];
late List<List<int>> calendarDays;
 int daysInMonth = 0;
  DateTime currentDate = DateTime.now();
  DateTime firstDayOfCurrentMonth = DateTime(currentDate.year, currentDate.month, 1);
  DateTime lastDayOfCurrentMonth = DateTime(currentDate.year, currentDate.month, DateTime(currentDate.year, currentDate.month+1, 0).day);

  int? focusedDay; // Added variable to track the focused day
  int? savedFocusedDay=focusedDay;
  int? focusedMonth;

  DateTime startDate = DateTime(2023,9,10);
  DateTime finalDate = DateTime(2024,12,31);

  bool _isLeftButtonWork = startDate.isBefore(firstDayOfCurrentMonth);
  bool _isRightButtonWork = finalDate.isAfter(lastDayOfCurrentMonth);
  

class _DetailWeduCalendarState extends State<DetailWeduCalendar> {
  var token;
  int id;
  String weduTitle;
  _DetailWeduCalendarState(this.id, this.weduTitle);
  dynamic weduData = '';
  dynamic weduMonthlyData = '';
  dynamic challengeImage = '';
  List<dynamic> successList = [];
  List<dynamic> notSuccessList = [];
  List<dynamic> challengeImageList = [];

  List<dynamic> progress = [0,0,0,0,0,0,0,0,0, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31];

 @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    calendarDays = generateCalendarDays();
    focusedDay=DateTime.now().day;
    savedFocusedDay=focusedDay;
    focusedMonth=currentDate.month;
    if (currentDate.isAfter(finalDate)) {
      currentDate = finalDate;
      focusedMonth=finalDate.month;
      focusedDay=finalDate.day;
      savedFocusedDay=focusedDay;
    }
  }
   void _updateCalendar() {
    setState(() {
      calendarDays = generateCalendarDays();
      if(focusedMonth==currentDate.month){
        focusedDay=savedFocusedDay;
      }
      if(currentDate.year==startDate.year && currentDate.month==startDate.month){
        _isLeftButtonWork=false;
      }
      else{
        _isLeftButtonWork=true;
      }
      if(currentDate.year==finalDate.year && currentDate.month==finalDate.month){
        _isRightButtonWork=false;
      }
      else{
        _isRightButtonWork=true;
      }
    });
  }

  Future<void> fetchDatas() async {
    
    token = await const FlutterSecureStorage().read(key: "accessToken");

    var weduResult = await http.get(
        Uri.parse( '${API.hostConnect}/wedu/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    DateTime requestDate = DateTime(currentDate.year,focusedMonth!,savedFocusedDay!);
    String requestFormatDate = DateFormat('yyyyMMdd').format(requestDate);
    var weduProgress = await http.get(
      Uri.parse( '${API.hostConnect}/wedu/$id/monthly/$requestFormatDate'),
      //localhost:8080/wedu/2/monthly/20231231
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if(weduProgress.statusCode == 200){
      weduMonthlyData = await jsonDecode(utf8.decode(weduProgress.bodyBytes))['data'];
      progress = weduMonthlyData['monthlyProgress'];
      startDate = DateTime.parse(weduMonthlyData['createdDate']);
      finalDate = DateTime.parse(weduMonthlyData['targetDate']);
    } else{
      print("에러${weduProgress.statusCode}");
    }


    // if(weduResult.statusCode == 200) {
    //   weduData = await jsonDecode(utf8.decode(weduResult.bodyBytes))['data'];
    //   weduTitle = weduData['title'];
    // } else {
    //   print("에러${weduResult.statusCode}");
    // }

    //var now = DateTime.now();
    //String formatDate = DateFormat('yyyyMMdd').format(now);
    var challengeList = await http.get(
        Uri.parse( '${API.hostConnect}/wedu/$id/challenge/$requestFormatDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(challengeList.statusCode == 200) {
      successList = await jsonDecode(utf8.decode(challengeList.bodyBytes))['data']['successMembers'];
      notSuccessList = await jsonDecode(utf8.decode(challengeList.bodyBytes))['data']['failMembers'];
    } else {
      print("목록${challengeList.statusCode}");
    }

    await fetchImages(successList);
  }
   fetchImages(List<dynamic> successList) async {
    var now = DateTime.now();
    String formatDate = DateFormat('yyyyMMdd').format(now);
    List<dynamic> resultImageList = [];
    for (var index = 0; index < successList.length; index++) {
      var successOne = successList[index]['nickname'].toString();
      var result = await http.get(
          Uri.parse('${API.hostConnect}/wedu/$id/challenge/$successOne/$formatDate'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
      );
      if(result.statusCode == 200) {
        var body = await jsonDecode(result.body);
        resultImageList.add(body['data']['imageUrls'][0]);
      } else {
        print('이미지 에러 ${result.body}');
      }

    }
    challengeImageList = resultImageList;
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchDatas(),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   // 데이터를 기다리는 동안 로딩 인디케이터를 보여줌
        //   return Container(
        //     color: PeeroreumColor.white,
        //   );
        // } else if (snapshot.hasError) {
        //   // 에러 발생 시
        //   return Center(child: Text('Error: ${snapshot.error}'));
        // } else {
        //   // 데이터 로드 성공 시
          return Scaffold(
      backgroundColor: PeeroreumColor.white,
            appBar: AppBar(
              backgroundColor: PeeroreumColor.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  color: PeeroreumColor.gray[800],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "weduTitle",
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: PeeroreumColor.black),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  // SvgPicture.asset(
                  //   'assets/icons/lock.svg',
                  //   color: PeeroreumColor.gray[400],
                  //   width: 12,
                  //   height: 14,
                  // )
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/icon_dots_mono.svg',
                      color: PeeroreumColor.gray[800],
                    ))
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🔥',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: PeeroreumColor.black),
                    ),
                    Text(
                      '+',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: PeeroreumColor.black),
                    ),
                    Text(
                      '10',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: PeeroreumColor.black),
                    )
                  ],
                ),
              ),
            ),
            body: bodyWidget(),
        
          );
        //}
      },
    );
  }
  Widget bodyWidget(){
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
          // Text('${currentDate.year}년${focusedMonth}월 ${focusedDay}일 ${savedFocusedDay}'),
          // Text('${currentDate}'),
          // Text('$startDate'),
          // Text('${finalDate}'),
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
                if (_isLeftButtonWork)
                  setState(() {
                    currentDate = DateTime(
                      currentDate.year,
                      currentDate.month - 1,
                    );
                    _updateCalendar();
                  });
              },
              icon: SvgPicture.asset('assets/icons/left.svg'),
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
          Text('월',
           textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: 'pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),),
          
            IconButton(
              onPressed: () {
                if (_isRightButtonWork)
                  setState(() {
                    currentDate = DateTime(
                      currentDate.year,
                      currentDate.month + 1,
                    );
                    _updateCalendar();
                  });
              },
              icon: SvgPicture.asset('assets/icons/right.svg',
              width: 24,),
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
                    '${days[day]}',
                    style: TextStyle(
                      fontFamily: 'pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: PeeroreumColor.black,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          focusedMonth=currentDate.month;
                          if (focusedDay == day) {
                            focusedDay = null; // Unfocus if already focused
                          } else {
                            focusedDay = day; // Set focused day
                            savedFocusedDay = focusedDay;
                          }
                          fetchDatas();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        alignment: Alignment.center,
                        height: 36,
                        width: 36,
                        //decoration: BoxDecoration(
                        //  border: Border.all(
                        //    color: Colors.black,
                        //  ),
                        //),
                        child: focusedDay == day
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
                                  style: TextStyle(
                                    fontFamily: 'pretendard',
                                    color: PeeroreumColor.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : CustomPaint(
                                painter: PieChart()
                                  ..percentage = progress[day - 1].toInt(),
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
                              ),
                      ),
                    )
                  else
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      alignment: Alignment.center,
                      height: 36,
                      width: 36,
                      //decoration: BoxDecoration(
                      //  border: Border.all(
                      //    color: Colors.black,
                      //  ),
                      //),
                      child: Text(''),
                    ),
              ],
            ),
        ],
      ),
    );
  }
  
  calendarList(){
    return Column(
      children: [
        Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                      SizedBox(
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
                      Navigator.pushNamed(context, '/wedu/challenge/ok', arguments: successList);
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
            (successList.length > 0) ? okList() : Container(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                      SizedBox(
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
                      Navigator.pushNamed(context, '/wedu/challenge/notok', arguments: notSuccessList);
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
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 8),
        itemCount: successList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              child: Padding(
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
                          color: PeeroreumColor.gradeColor[successList[index]['grade']]!
                      ),
                      // image: DecorationImage(
                      //     image: AssetImage('assets/images/user.jpg',)
                      // ),
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
                      image: DecorationImage(
                          image: AssetImage('assets/images/user.jpg',)
                      ),
                    ),
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      isScrollControlled: true,
                      builder: (context) {
                        return challengeImages(successList[index], index);
                      },
                    ).timeout(const Duration(seconds: 5), onTimeout: () {
                      fetchImages(successList[index]);
                    });
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '${successList[index]['nickname']}',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: PeeroreumColor.gray[800]),
                )
              ],
            ),
          ));
        },
      ),
    );
  }

  notOkList() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 8),
        itemCount: notSuccessList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  //padding: EdgeInsets.all(3.5),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: PeeroreumColor.gradeColor[notSuccessList[index]['grade']]!
                      ),
                    // image: DecorationImage(
                    //   image: AssetImage('assets/images/user.jpg')
                    // ),
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
                      image: DecorationImage(
                          image: AssetImage('assets/images/user.jpg',)
                      ),
                    ),
                    ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '${notSuccessList[index]['nickname']}',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: PeeroreumColor.gray[800]),
                )
              ],
            ),
          ));
        },
      ),
    );
  }
  
  challengeImages(dynamic successOne, var index) {
    challengeImage = challengeImageList[index];
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.68,
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.5),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: PeeroreumColor.gradeColor[successOne['grade']]!
                          ),
                          image: DecorationImage(
                              image: AssetImage('assets/images/user.jpg')
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        successOne["nickname"].toString(),
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: PeeroreumColor.gray[800]
                        ),
                      )
                    ],
                  ),
                  GestureDetector(
                    child: SvgPicture.asset(
                      'assets/icons/icon_dots_mono.svg',
                      color: PeeroreumColor.gray[800],
                    ),
                    onTap: () {},
                  )
                ],
              ),
               SizedBox(height: 20),
              Container(
                width: double.maxFinite,
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: PeeroreumColor.gray[100],
                  image: DecorationImage(
                      image: NetworkImage(challengeImage),
                    fit: BoxFit.fill
                  )
                ),
              )
               // CarouselSlider(
               //    items: _images.map((i) {
               //      return Builder(
               //        builder: (BuildContext context) {
               //          return Container(
               //            width: double.maxFinite,
               //            height: 380,
               //            decoration: BoxDecoration(
               //              borderRadius: BorderRadius.circular(8),
               //              color: PeeroreumColor.gray[100],
               //            ),
               //            child: Image.file(
               //              File(i!.path),
               //              fit: BoxFit.fill,
               //            ),
               //          );
               //        },
               //      );
               //    }).toList(),
               //    options: CarouselOptions(
               //        enableInfiniteScroll: false,
               //      viewportFraction: 1,
               //      height: MediaQuery.of(context).size.height * 0.45,
               //      enlargeCenterPage: true,
               //
               //    ),
               //  ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(20),
          width: double.maxFinite,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              '닫기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PeeroreumColor.gray[600],
              ),
            ),
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(PeeroreumColor.gray[300]),
                padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
          ),
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
