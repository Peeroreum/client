import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
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
  State<ImageDetailIedu> createState() => _ImageDetailIeduState();
}

class _ImageDetailIeduState extends State<ImageDetailIedu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: PeeroreumColor.black,
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                margin: EdgeInsets.only(right: 20),
                width: 18,
                height: 18,
                child: SvgPicture.asset(
                  'assets/icons/x.svg',
                  color: PeeroreumColor.white,
                  width: 24,
                ),
              ))
        ],
      ),
      body: CarouselSlider(
            items: widget.imageList.map((i) {
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
              initialPage: widget.initialPage
            ),
          ),
    );
  }
}
