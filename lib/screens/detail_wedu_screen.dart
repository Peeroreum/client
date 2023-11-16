import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

final ImagePicker picker = ImagePicker();
const List<String> successList = ['수이', '공주', '밍밍이', '묭묭', '신졔', '철웅이'];
const List<String> notSuccessList = ['현지니', '쫑수', '꿍이', '단디', '루피', '짱기'];

class DetailWedu extends StatefulWidget {
  const DetailWedu({super.key});

  @override
  State<DetailWedu> createState() => _DetailWeduState();
}

class _DetailWeduState extends State<DetailWedu> {
  List<XFile?> _images = [];

  void takeImages() async {
    final List<XFile>? pickedImages =  await picker.pickMultiImage();
    if(pickedImages != null) {
      setState(() {
        _images = pickedImages;
      });
    }
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '9월모고 1등급 만들기',
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: PeeroreumColor.black),
            ),
            SizedBox(
              width: 7,
            ),
            SvgPicture.asset(
              'assets/icons/lock.svg',
              color: PeeroreumColor.gray[400],
              width: 12,
              height: 14,
            )
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
        bottom: PreferredSize(
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
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Divider(
                color: PeeroreumColor.gray[100],
                thickness: 1,
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(color: PeeroreumColor.gray[200]!)),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Card(
                                      elevation: 0,
                                      color: PeeroreumColor.gray[50],
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          side: BorderSide(
                                              color:
                                                  PeeroreumColor.gray[100]!)),
                                      child: Image.asset(
                                        'assets/images/example_logo.png',
                                        width: 64,
                                        height: 64,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Container(
                                      height: 64,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '목표 달성',
                                            style: TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    PeeroreumColor.gray[600]),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'DAY',
                                                style: TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18,
                                                    color: PeeroreumColor
                                                        .gray[800]),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                '-',
                                                style: TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18,
                                                    color: PeeroreumColor
                                                        .gray[800]),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                '22',
                                                style: TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18,
                                                    color: PeeroreumColor
                                                        .gray[800]),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              height: 8,
                              thickness: 1,
                              color: PeeroreumColor.gray[100],
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 6, 0, 10),
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              color: PeeroreumColor.primaryPuple[400],
                              width: 37,
                              child: Text(
                                '50%',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: PeeroreumColor.white),
                              ),
                            ),
                            LinearPercentIndicator(
                              padding: EdgeInsets.all(0),
                              lineHeight: 8,
                              percent: 0.5,
                              backgroundColor: PeeroreumColor.gray[200],
                              linearGradient: LinearGradient(colors: [
                                PeeroreumColor.primaryPuple[400]!,
                                Color(0xffada5fc)
                              ]),
                              barRadius: Radius.circular(8),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '0',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: PeeroreumColor.gray[600]),
                                ),
                                Text(
                                  '100',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: PeeroreumColor.gray[600]),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(color: PeeroreumColor.gray[200]!)),
                      child: ExpandedTile(
                          contentseparator: 0,
                          theme: ExpandedTileThemeData(
                              headerColor: PeeroreumColor.white,
                              contentBackgroundColor: PeeroreumColor.white,
                              titlePadding: EdgeInsets.zero,
                              trailingPadding: EdgeInsets.only(left: 8),
                              contentPadding:
                                  EdgeInsets.fromLTRB(16, 5, 16, 16)),
                          trailing: SvgPicture.asset(
                            'assets/icons/down.svg',
                            color: PeeroreumColor.gray[500],
                          ),
                          trailingRotation: 180,
                          title: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                    color: PeeroreumColor.primaryPuple[50],
                                    borderRadius: BorderRadius.circular(16)),
                                child: Text(
                                  '오늘의 미션',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: PeeroreumColor.primaryPuple[400],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 180,
                                child: Text(
                                  'ㅌㅊㅌㅊㅌㅊㅌㅊㅌㅊㅌㅊㅌㅊㅌㅊㅌㅊㅌㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊㅊ',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: PeeroreumColor.gray[800]),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Image.asset('assets/images/oreum.png')
                            ],
                          ),
                          controller: ExpandedTileController(isExpanded: true)),
                    ),
                  ],
                ),
              ),
              Divider(
                color: PeeroreumColor.gray[50],
                thickness: 8,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '달성',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: PeeroreumColor.gray[800]),
                    ),
                    Text(
                      '전체보기',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: PeeroreumColor.gray[500]),
                    ),
                  ],
                ),
              ),
              okList(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '미달성',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: PeeroreumColor.gray[800]),
                    ),
                    Text(
                      '전체보기',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: PeeroreumColor.gray[500]),
                    ),
                  ],
                ),
              ),
              notOkList()
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: TextButton(
          onPressed: () {
            takeImages();
          },
          child: Text(
            '인증하기',
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
              padding:
                  MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ))),
        ),
      ),
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
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    width: 48,
                    height: 48,
                    child: CircleAvatar(
                      radius: 250,
                      backgroundImage: AssetImage("assets/images/oreum.png"),
                      backgroundColor: PeeroreumColor.gray[50],
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      isScrollControlled: true,
                      builder: (context) {
                        return challengeImages(successList[index]);
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  successList[index],
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
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  child: CircleAvatar(
                    radius: 250,
                    backgroundImage: AssetImage("assets/images/oreum.png"),
                    backgroundColor: PeeroreumColor.gray[50],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  notSuccessList[index],
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

  challengeImages(String successNickname) {
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.65,
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        child: CircleAvatar(
                          radius: 250,
                          backgroundImage: AssetImage("assets/images/oreum.png"),
                          backgroundColor: PeeroreumColor.gray[50],
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        successNickname,
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
               CarouselSlider(
                  items: _images.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: double.maxFinite,
                          height: 380,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: PeeroreumColor.gray[100],
                          ),
                          child: Image.file(
                            File(i!.path),
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                    );
                  }).toList(),
                  options: CarouselOptions(
                      enableInfiniteScroll: false,
                    viewportFraction: 1,
                    height: MediaQuery.of(context).size.height * 0.45,
                    enlargeCenterPage: true,

                  ),
                ),
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
