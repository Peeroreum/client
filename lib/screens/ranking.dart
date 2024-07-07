import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          )
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 16,),
            Row(
              children: [
                Spacer(),
                GestureDetector(
                  onTap: () {
                    
                  },
                  child: T5_14px(
                    text: "ⓘ 랭킹 안내",
                    color: PeeroreumColor.gray[500],
                  ),
                )
              ],
            ),
            SizedBox(height: 16,),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Ranker(
                    name: "귀여운", 
                    image: "assets/images/silvermedal.png",
                    rank: "2위",
                    height: 48.0,),
                  SizedBox(width: 8,),
                  Ranker(
                    name: "우리", 
                    image: "assets/images/goldmedal.png",
                    rank: "1위",
                    height: 64.0,),               
                  SizedBox(width: 8,),
                  Ranker(
                    name: "오르미", 
                    image: "assets/images/bronzemedal.png",
                    rank: "3위",
                    height: 40.0,),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: PeeroreumColor.gray[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PeeroreumColor.gray[200]!,
                  width: 1
                )
              ),
              child: Row(
                children: [
                  Container(
                    height: 25,
                    child: Center(
                      child: T3_18px(text: "N위"),
                    ),
                  ),
                  SizedBox(width: 16,),
                  Container(
                    height: 44,
                    width: 44,
                    
                  )
                ],
              ),
            )

                  
          ],
        ),
      ),
    );
  }
  rankingHelp(){
    return showDialog(context: context, builder: (BuildContext context){
      return Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: T2_20px(text: "랭킹 안내")),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: SvgPicture.asset(
                              'assets/icons/x.svg',
                              color: PeeroreumColor.gray[800],
                            ),
                          ),
                )
              ],
            )
        ],)
      );
    });
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
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
                    child: Column(
                      children: [
                        Container(
                          height: 24,
                          child: Center(child: B4_14px_M(text: name ?? "name"))),
                        Container(
                          width: 71,
                          height: 82,
                          decoration: BoxDecoration(
                            image: DecorationImage(image: AssetImage(image))
                          ),
                        ),
                        SizedBox(height: 4,),
                        Container(
                          width: 88,
                          height: height ?? 48,
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: PeeroreumColor.gray[100],
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 24,
                              child: Center(
                                child: T4_16px(text: rank,
                                color: PeeroreumColor.gray[600],),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
  }
}