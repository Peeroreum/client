// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';

class Ranking extends StatefulWidget {
  const Ranking({super.key});

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: AppBar(
        title: B2_20px_M(text: "랭킹"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: PeeroreumColor.white,
      ),
      body: Container(
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(color: PeeroreumColor.gray[100]!, width: 1.0),
        )),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Spacer(),
                GestureDetector(
                  onTap: () {
                    rankingHelp();
                  },
                  child: T5_14px(
                    text: "ⓘ 랭킹 안내",
                    color: PeeroreumColor.gray[500],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Ranker(
                    name: "우리",
                    image: "assets/images/silvermedal.png",
                    rank: "2위",
                    height: 48.0,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Ranker(
                    name: "귀여운",
                    image: "assets/images/goldmedal.png",
                    rank: "1위",
                    height: 64.0,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Ranker(
                    name: "오르미",
                    image: "assets/images/bronzemedal.png",
                    rank: "3위",
                    height: 40.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            myranking(),
            SizedBox(
              height: 8,
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: 7,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 8,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return rankings();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  rankingHelp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            contentPadding: EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: PeeroreumColor.white,
            surfaceTintColor: Colors.transparent,
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 24,
                      ),
                      Expanded(
                        child: Center(
                          child: T2_20px(
                            text: "랭킹 안내",
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: SvgPicture.asset(
                          'assets/icons/x.svg',
                          color: PeeroreumColor.black,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  B3_18px_M(text: "매일 자정마다 오늘의 랭킹이 업데이트됩니다."),
                  SizedBox(
                    height: 12,
                  ),
                  B4_14px_M(text: "목표 달성 횟수, 질문 및 답변 수, 채택 횟수 반영"),
                  SizedBox(
                    height: 32,
                  ),
                ],
              ),
            ),
          );
        });
  }

  myranking() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
          color: PeeroreumColor.gray[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PeeroreumColor.gray[200]!, width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 25,
                child: Center(
                  child: T3_18px(text: "N 위"),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 2, color: Color.fromARGB(255, 186, 188, 189)),
                ),
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1,
                      color: PeeroreumColor.white,
                    ),
                    image: DecorationImage(
                        image: AssetImage(
                      'assets/images/user.jpg',
                    )),
                  ),
                ),
              ),
              Container(width: 8),
              B4_14px_M(
                text: "nickname (나)",
                color: PeeroreumColor.gray[800],
              ),
            ],
          ),
          B4_14px_M(text: "N 점"),
        ],
      ),
    );
  }

  rankings() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
          color: PeeroreumColor.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PeeroreumColor.gray[200]!, width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 25,
                child: Center(
                  child: T3_18px(text: "N 위"),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 2, color: Color.fromARGB(255, 186, 188, 189)),
                ),
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1,
                      color: PeeroreumColor.white,
                    ),
                    image: DecorationImage(
                        image: AssetImage(
                      'assets/images/user.jpg',
                    )),
                  ),
                ),
              ),
              Container(width: 8),
              B4_14px_M(
                text: "nickname",
                color: PeeroreumColor.gray[800],
              ),
            ],
          ),
          B4_14px_M(text: "N 점"),
        ],
      ),
    );
  }
}

class Ranker extends StatelessWidget {
  final dynamic name;
  final dynamic image;
  final dynamic rank;
  final dynamic height;

  const Ranker({
    Key? key,
    this.name,
    required this.image,
    required this.rank,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
              height: 24,
              child: Center(
                  child: B4_14px_M(
                text: name ?? "name",
                color: PeeroreumColor.gray[800],
              ))),
          Container(
            width: 71,
            height: 82,
            decoration:
                BoxDecoration(image: DecorationImage(image: AssetImage(image))),
          ),
          SizedBox(
            height: 4,
          ),
          Container(
            width: 88,
            height: height ?? 48,
            padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: PeeroreumColor.gray[100],
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 24,
                child: Center(
                  child: T4_16px(
                    text: rank,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
