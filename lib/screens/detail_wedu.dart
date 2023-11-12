import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class DetailWedu extends StatefulWidget {
  const DetailWedu({super.key});

  @override
  State<DetailWedu> createState() => _DetailWeduState();
}

class _DetailWeduState extends State<DetailWedu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: AppBar(
        backgroundColor: PeeroreumColor.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
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
                color: PeeroreumColor.black
              ),
            ),
            Icon(
              Icons.lock,
              color: PeeroreumColor.gray[400],
              size: 18,
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                  Icons.more_vert_outlined,
                color: PeeroreumColor.gray[800],
              )
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🔥',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: PeeroreumColor.black
                    ),
                  ),
                  Text(
                    '+',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: PeeroreumColor.black
                    ),
                  ),
                  Text(
                    '10',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: PeeroreumColor.black
                    ),
                  )
                ],
              ),
            ),
            Divider(
              color: PeeroreumColor.gray[100],
              thickness: 1,
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  side: BorderSide(
                    color: PeeroreumColor.gray[200]!
                  )
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Card(
                            elevation: 0,
                            color: PeeroreumColor.gray[50],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                side: BorderSide(
                                    color: PeeroreumColor.gray[100]!
                                )
                            ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '목표 달성',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600]
                                  ),
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
                                        color: PeeroreumColor.gray[800]
                                      ),
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
                                          color: PeeroreumColor.gray[800]
                                      ),
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
                                          color: PeeroreumColor.gray[800]
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                            color: PeeroreumColor.white
                          ),
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
                              color: PeeroreumColor.gray[600]
                            ),
                          ),
                          Text(
                            '100',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: PeeroreumColor.gray[600]
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}