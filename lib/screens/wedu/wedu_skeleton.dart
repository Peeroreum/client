import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonWedu extends StatefulWidget {
  const SkeletonWedu({super.key});

  @override
  State<SkeletonWedu> createState() => _SkeletonWeduState();
}

class _SkeletonWeduState extends State<SkeletonWedu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyWidget(),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 12),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                      color: PeeroreumColor.gray[100],
                      borderRadius: BorderRadius.circular(37.0)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/search.svg',
                        color: PeeroreumColor.gray[600],
                      ),
                      SizedBox(width: 8.0),
                      SizedBox(
                        child: Text(
                          '같이방에서 함께 공부해요!',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(right: 8),
                  child: SvgPicture.asset(
                    'assets/icons/plus_square.svg',
                    color: PeeroreumColor.gray[800],
                    width: 24,
                  ),
                ),
                onTap: () {},
              ),
              GestureDetector(
                child: SvgPicture.asset(
                  'assets/icons/bell_none.svg',
                  color: PeeroreumColor.gray[800],
                ),
                onTap: () {
                  Fluttertoast.showToast(msg: "준비중입니다.");
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Shimmer.fromColors(
        baseColor: PeeroreumColor.gray[200]!,
        highlightColor: PeeroreumColor.white,
        child: Column(children: [
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                //첫번째 열
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 131,
                    height: 24,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: PeeroreumColor.gray[200]),
                  ),
                  Container(
                    width: 48,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: PeeroreumColor.gray[200],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 150,
                  padding: EdgeInsets.fromLTRB(8, 20, 8, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PeeroreumColor.gray[200]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        //프로필사진
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: PeeroreumColor.gray[200]),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            //과목
                            width: 34,
                            height: 20,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: PeeroreumColor.gray[200]),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Container(
                            //같이방이름
                            width: 90,
                            height: 24,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: PeeroreumColor.gray[200]),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Container(
                        //같이방정보
                        width: 101,
                        height: 16,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: PeeroreumColor.gray[200]),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        //진행률
                        width: 58,
                        height: 24,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: PeeroreumColor.gray[200]),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  width: 8,
                );
              },
              itemCount: 3,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 8,
            color: PeeroreumColor.gray[50],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 131,
                  height: 24,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: PeeroreumColor.gray[200]),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              //드롭다운
              children: [
                Container(
                  width: 75,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: PeeroreumColor.gray[200]),
                ),
                SizedBox(
                  width: 8,
                ),
                Container(
                  width: 75,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: PeeroreumColor.gray[200]),
                ),
                Spacer(),
                Container(
                  width: 75,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: PeeroreumColor.gray[200]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PeeroreumColor.gray[200]!)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //같이방사진
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: PeeroreumColor.gray[200]),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 20,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: PeeroreumColor.gray[200]),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Container(
                                width: 90,
                                height: 24,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: PeeroreumColor.gray[200]),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Container(
                            width: 134,
                            height: 16,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: PeeroreumColor.gray[200]),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 8,
                );
              },
              itemCount: 5,
            ),
          )
        ]),
      ),
    );
  }
}
