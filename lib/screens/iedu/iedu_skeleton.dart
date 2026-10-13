import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 71,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: PeeroreumColor.gray[200]),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        width: 75,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: PeeroreumColor.gray[200]),
                      ),
                      const SizedBox(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 8,
                      );
                    },
                    itemCount: 6,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
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
                                const Spacer(),
                                Container(
                                  width: 42,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: PeeroreumColor.gray[200]),
                                ),
                              ],
                            ),
                            const SizedBox(
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
                                const SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  width: 35,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: PeeroreumColor.gray[200]),
                                ),
                                const SizedBox(
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
                shape: const CircleBorder(),
                onPressed: () {},
                elevation: 5,
                backgroundColor: PeeroreumColor.primaryPurple[400],
                child: SizedBox(
                  width: 24,
                  child: SvgPicture.asset(
                    'assets/icons/pencil_with_line.svg',
                    colorFilter: const ColorFilter.mode(
                        PeeroreumColor.white, BlendMode.srcIn),
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
