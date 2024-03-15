import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonIedu extends StatefulWidget {
  const SkeletonIedu({super.key});

  @override
  State<SkeletonIedu> createState() => _SkeletonIeduState();
}

class _SkeletonIeduState extends State<SkeletonIedu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyWidget(),
    );
  }

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: Shimmer.fromColors(
        baseColor: PeeroreumColor.gray[200]!,
        highlightColor: PeeroreumColor.white,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    //드롭다운
                    children: [
                      Container(
                        width: 71,
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
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 8,
                      );
                    },
                    itemCount: 6,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: PeeroreumColor.gray[200]!)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 150,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: PeeroreumColor.gray[200]),
                                ),
                                Spacer(),
                                Container(
                                  width: 42,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: PeeroreumColor.gray[200]),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: PeeroreumColor.gray[200],
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  width: 35,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: PeeroreumColor.gray[200]),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  width: 154,
                                  height: 18,
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
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 10),
              child: FloatingActionButton(
                shape: CircleBorder(),
                onPressed: () {},
                elevation: 5,
                backgroundColor: PeeroreumColor.primaryPuple[400],
                child: SizedBox(
                  width: 24,
                  child: SvgPicture.asset(
                    'assets/icons/pencil_with_line.svg',
                    color: PeeroreumColor.white,
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
