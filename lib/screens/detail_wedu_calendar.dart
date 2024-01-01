import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/screens/pie_chart.dart';


import '../api/PeeroreumApi.dart';





class DetailWeduCalendar extends StatefulWidget {
  const DetailWeduCalendar({super.key});

  @override
  State<DetailWeduCalendar> createState() => _DetailWeduCalendarState();
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
  

 var progress = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31];

 @override
  void initState() {
    super.initState();
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



  @override
  Widget build(BuildContext context) {
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
                  Navigator.pop(context);
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
  }
  Widget bodyWidget(){
    return SingleChildScrollView(
      child: Column(
        children: [
          calendarHeader(),
          calendarBody(),
          Text('${currentDate.year}년${focusedMonth}월 ${focusedDay}일 ${savedFocusedDay}'),
          Text('${currentDate}'),
          Text('${finalDate}'),
          Divider(
              color: PeeroreumColor.gray[50],
              thickness: 8,
            ),
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

