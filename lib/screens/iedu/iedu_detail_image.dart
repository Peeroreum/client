import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:photo_view/photo_view.dart';

class ImageDetailIedu extends StatefulWidget {
  final List<dynamic> imageList;
  final int initialPage;

  const ImageDetailIedu({
    Key? key,
    required this.imageList,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  State<ImageDetailIedu> createState() => _ImageDetailIeduState(imageList,initialPage);
}

class _ImageDetailIeduState extends State<ImageDetailIedu> {
  _ImageDetailIeduState(this.imageList, this.initialPage);
  List<dynamic> imageList;
  int initialPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          CarouselSlider(
            items: imageList.map((i) {
              var imageUrl = i.toString();
              return Container(
                child: PhotoView(
                  backgroundDecoration: BoxDecoration(
                    color: PeeroreumColor.black
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  filterQuality: FilterQuality.high,
                  imageProvider: NetworkImage(imageUrl),
                )
              );
              // 여기에 이미지 위젯 생성 코드 추가
            }).toList(),
            options: CarouselOptions(
              enableInfiniteScroll: false,
              viewportFraction: 1,
              height: MediaQuery.of(context).size.height,
              initialPage: initialPage,
              onPageChanged: (index, reason) {
                setState(() {
                  initialPage = index;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: kToolbarHeight),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 18,
                    height: 18,
                    child: SvgPicture.asset("assets/icons/x.svg", color: PeeroreumColor.white,),
                  ),
                ),
                Container(
                  child: T4_16px(text: "${initialPage +1} / ${imageList.length}",
                  color: PeeroreumColor.white,),
                ),
                Container(
                  height: 18,
                  width: 18,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
