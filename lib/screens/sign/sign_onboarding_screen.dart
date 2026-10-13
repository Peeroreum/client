import 'package:flutter/foundation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/data/onboarding_check.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:dots_indicator/dots_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final _controller = CarouselSliderController();
  int totalItems = 3;
  int pageIndex = 0;
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: AppBar(
            backgroundColor: PeeroreumColor.white,
            elevation: 0,
          )),
      body: SafeArea(
        child: Container(
          color: PeeroreumColor.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DotsIndicator(
                position: pageIndex,
                dotsCount: 3,
                decorator: DotsDecorator(
                  color: PeeroreumColor.gray[300]!,
                  activeColor: PeeroreumColor.primaryPurple[400],
                  size: const Size.square(8),
                  activeSize: const Size(20, 8),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: CarouselSlider(
                  items: [
                    buildCarouselItem(
                      '“같이 공부할 친구가 필요하다면?”',
                      '친구와 함께 공동 목표를 세워\n챌린지를 시작해 보세요.',
                      'assets/images/on_boarding1.png',
                    ),
                    buildCarouselItem(
                      '“친구야, 도와줘!”',
                      '모르는 문제를 친구에게 물어보고,\n다른 친구의 문제도 풀어 봐요.',
                      'assets/images/on_boarding2.png',
                    ),
                    buildCarouselItem(
                      '“중요한 건 꾸준히 하는 마음!”',
                      '공부 시간, 질문 답변 수, 목표 달성률에 따라\n달라지는 내 순위를 확인해 보세요.',
                      'assets/images/on_boarding3.png',
                    ),
                  ],
                  carouselController: _controller,
                  options: CarouselOptions(
                    height: 550,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        pageIndex = index;
                      });
                      if (kDebugMode) {
                        print('Current Page Index: $pageIndex');
                      }
                      if (index == 2) {
                        setState(() {
                          _isVisible = false;
                        });
                      } else {
                        setState(() {
                          _isVisible = true;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: PeeroreumColor.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: _isVisible,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  width: double.maxFinite,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      _controller.nextPage();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          PeeroreumColor.primaryPurple[400]),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PeeroreumColor.white,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !_isVisible,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  width: double.maxFinite,
                  height: 48,
                  child: TextButton(
                    onPressed: () async {
                      await OnboardingCheck.setUserType(false);
                      Get.offNamed('/signIn/email');
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          PeeroreumColor.primaryPurple[400]),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PeeroreumColor.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCarouselItem(String title, String description, String imagePath) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 350, height: 432),
          const SizedBox(
            height: 20,
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: PeeroreumColor.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: PeeroreumColor.gray[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
