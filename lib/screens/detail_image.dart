import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/designs/peeroreum_typo.dart';
import 'package:photo_view/photo_view.dart';

class ImageDetail extends StatefulWidget {
  final List<dynamic> imageList;
  final int initialPage;

  const ImageDetail({
    Key? key,
    required this.imageList,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  State<ImageDetail> createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  late List<dynamic> imageList;
  late int initialPage;

  @override
  void initState() {
    super.initState();
    imageList = widget.imageList;
    initialPage = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.black,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          CarouselSlider(
            items: imageList.map((i) {
              var imageUrl = i.toString();
              return Container(
                  color: PeeroreumColor.black,
                  child: PhotoView(
                    backgroundDecoration: const BoxDecoration(
                      color: PeeroreumColor.black,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    filterQuality: FilterQuality.high,
                    imageProvider: NetworkImage(imageUrl),
                    loadingBuilder: (context, event) => const Center(
                      child: CircularProgressIndicator(
                        color: PeeroreumColor.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ));
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
            margin: const EdgeInsets.only(top: kToolbarHeight),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: SvgPicture.asset("assets/icons/x.svg",
                        colorFilter: const ColorFilter.mode(
                            PeeroreumColor.white, BlendMode.srcIn)),
                  ),
                ),
                T4(
                  text: "${initialPage + 1} / ${imageList.length}",
                  color: PeeroreumColor.white,
                ),
                const SizedBox(
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
