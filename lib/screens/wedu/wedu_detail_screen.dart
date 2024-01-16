import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_widget_marquee/custom_widget_marquee.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_calendar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;

import '../../api/PeeroreumApi.dart';

class DetailWedu extends StatefulWidget {
  DetailWedu(this.id);
  int id;

  @override
  State<DetailWedu> createState() => _DetailWeduState(id);
}

double stackWidth = 0;
double leftPosition = 0;

class _DetailWeduState extends State<DetailWedu> {
  int id;

  bool isExpanded = true;
  _DetailWeduState(this.id);
  var token, email, nickname;

  final ImagePicker picker = ImagePicker();
  final List<XFile> _images = [];

  List<dynamic> successList = [];
  List<dynamic> notSuccessList = [];
  List<dynamic> challengeImageList = [];
  List<dynamic> challengeImage = [];
  dynamic weduData = '';
  dynamic weduTitle = '';
  dynamic weduImage = null;
  dynamic weduDday = '';
  dynamic weduProgress = '';
  dynamic weduChallenge = '';
  dynamic weduFire = '';
  double percent = 0.0;

  bool isMyImage = true;
  bool isCreator = false;
  bool isSuccess = false;
  bool isDialogShow = false;

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  Future<void> fetchDatas() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    token = await storage.read(key: "accessToken");
    email = await storage.read(key: "email");
    nickname = await storage.read(key: "nickname");

    var weduResult = await http.get(Uri.parse('${API.hostConnect}/wedu/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (weduResult.statusCode == 200) {
      weduData = await jsonDecode(utf8.decode(weduResult.bodyBytes))['data'];
      weduTitle = weduData['title'];
      weduImage = weduData['imageUrl'];
      weduDday = weduData['dday'];
      weduProgress = weduData['progress'].toString();
      weduChallenge = weduData['challenge'];
      weduFire = weduData['continuousDate'];
      percent = double.parse(weduProgress) / 100;

      isCreator = email == weduData['hostMail'];
      if (weduProgress == '0') {
        leftPosition = 0; // percent가 0일 때의 처리
      } else if (weduProgress == '100') {
        leftPosition = stackWidth * percent - 42; // percent가 1일 때의 처리
      } else {
        leftPosition = stackWidth * percent - 21; // 그 외의 경우의 처리
      }
    } else {
      print("에러${weduResult.statusCode}");
    }

    var now = DateTime.now();
    String formatDate = DateFormat('yyyyMMdd').format(now);
    var challengeList = await http.get(
        Uri.parse('${API.hostConnect}/wedu/$id/challenge/$formatDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (challengeList.statusCode == 200) {
      successList = await jsonDecode(utf8.decode(challengeList.bodyBytes))['data']['successMembers'];
      notSuccessList = await jsonDecode(utf8.decode(challengeList.bodyBytes))['data']['failMembers'];
    } else {
      print("목록${challengeList.statusCode}");
    }

    await fetchImages(successList);
    checkChallenge();
  }

  fetchImages(List<dynamic> successList) async {
    var now = DateTime.now();
    String formatDate = DateFormat('yyyyMMdd').format(now);
    List<dynamic> resultImageList = [];
    for (var index = 0; index < successList.length; index++) {
      var successOne = successList[index]['nickname'].toString();
      if(nickname == successOne) {
        setState(() {
          isSuccess = true;
        });
      }
      var result = await http.get(
          Uri.parse(
              '${API.hostConnect}/wedu/$id/challenge/$successOne/$formatDate'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          });
      if (result.statusCode == 200) {
        var body = await jsonDecode(result.body);
        resultImageList.add(body['data']['imageUrls']);
      } else {
        print('이미지 에러 ${result.body}');
      }
    }
    challengeImageList = resultImageList;
  }

  checkChallenge() {
    if(!isSuccess && !isDialogShow) {
      isDialogShow = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 20),
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: PeeroreumColor.white,
                surfaceTintColor: Colors.transparent,
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(width: 24,),
                          Expanded(
                            child: Center(
                              child: Text(
                                '오늘의 미션',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: PeeroreumColor.black
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: SvgPicture.asset('assets/icons/x.svg', color: PeeroreumColor.black,),
                          )
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 96,
                              width: 106,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                        'assets/images/yeolgong_oreum.png',
                                      ),
                                      fit: BoxFit.cover
                                  )
                              ),
                            ),
                            SizedBox(height: 16,),
                            Text(
                              weduChallenge,
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: PeeroreumColor.black
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          showDoChallengeBottomSheet();
                        },
                        child: Container(
                          height: 48,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: PeeroreumColor.primaryPuple[400],
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Center(
                            child: Text(
                              '지금 인증하러 가기',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: PeeroreumColor.white
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
        );
      });
    }
  }

  void takeFromCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    } else {
      // 이미지 선택이 취소되었을 때의 처리
      print('Image selection cancelled');
    }

    postImages();
  }

  void takeFromGallery() async {
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        print("리스트에 이미지 저장");
        _images.addAll(selectedImages);
      });
    }

    postImages();
  }

  Future<void> postImages() async {
    var dio = Dio();
    var formData = FormData();

    dio.options.contentType = 'multipart/form-data';
    dio.options.headers = {'Authorization': 'Bearer $token'};

    for (var image in _images) {
      var file = await MultipartFile.fromFile(image.path);
      formData.files.add(MapEntry('files', file));
    }
    var response =
        await dio.post('${API.hostConnect}/wedu/$id/challenge', data: formData);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '오늘의 챌린지 인증 성공!');
      fetchDatas();
      setState(() {});
    } else {
      Fluttertoast.showToast(msg: '잠시 후에 다시 시작해 주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchDatas(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: PeeroreumColor.white,
          appBar: AppBar(
            backgroundColor: PeeroreumColor.white,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/arrow-left.svg',
                color: PeeroreumColor.gray[800],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: CustomWidgetMarquee(
                    child: Text(
                      weduTitle,
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: PeeroreumColor.black),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return changeDetailWedu();
                        });
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/icon_dots_mono.svg',
                    width: 24,
                    height: 24,
                    color: PeeroreumColor.gray[800],
                  ))
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/fire.svg'),
                      Text(
                        '+',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: PeeroreumColor.black),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        '$weduFire',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: PeeroreumColor.black),
                      )
                    ],
                  ),
                  Divider(
                    thickness: 1,
                    color: PeeroreumColor.gray[100],
                  )
                ],
              ),
            ),
          ),
          body: bodyWidget(),
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () {
                  showDoChallengeBottomSheet();
                },
                child: Text(
                  '인증하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.white,
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        PeeroreumColor.primaryPuple[400]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
              ),
            ),
          ),
        );
      },
    );
  }

  okList() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 8),
        itemCount: successList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    //padding: EdgeInsets.all(3.5),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2,
                          color: PeeroreumColor
                              .gradeColor[successList[index]['grade']]!),
                      // image: DecorationImage(
                      //     image: AssetImage('assets/images/user.jpg',)
                      // ),
                    ),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                          color: PeeroreumColor.white,
                        ),
                        image: successList[index]["profileImage"] != null
                            ? DecorationImage(
                                image: NetworkImage(
                                    successList[index]["profileImage"]),
                                fit: BoxFit.cover)
                            : DecorationImage(
                                image: AssetImage('assets/images/user.jpg')),
                      ),
                    ),
                  ),
                  onTap: () async{
                    await showModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      isScrollControlled: true,
                      builder: (context) {
                        return challengeImages(successList[index], index);
                      },
                    // ).timeout(const Duration(seconds: 5), onTimeout: () async{
                    //   await fetchImages(successList[index]);
                    //}
                    );
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '${successList[index]['nickname']}',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: PeeroreumColor.gray[800]),
                )
              ],
            ),
          ));
        },
      ),
    );
  }

  notOkList() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 8),
        itemCount: notSuccessList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  //padding: EdgeInsets.all(3.5),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 2,
                        color: PeeroreumColor
                            .gradeColor[notSuccessList[index]['grade']]!),
                    // image: DecorationImage(
                    //   image: AssetImage('assets/images/user.jpg')
                    // ),
                  ),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1,
                        color: PeeroreumColor.white,
                      ),
                      image: notSuccessList[index]["profileImage"] != null
                          ? DecorationImage(
                              image: NetworkImage(
                                  notSuccessList[index]["profileImage"]),
                              fit: BoxFit.cover)
                          : DecorationImage(
                              image: AssetImage('assets/images/user.jpg')),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '${notSuccessList[index]['nickname']}',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: PeeroreumColor.gray[800]),
                )
              ],
            ),
          ));
        },
      ),
    );
  }

  challengeImages(dynamic successOne, var index) {
    challengeImage = challengeImageList[index];

    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonBar(
              buttonPadding: EdgeInsets.all(0),
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 2,
                            color: PeeroreumColor
                                .gradeColor[successOne['grade']]!),
                      ),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: PeeroreumColor.white,
                          ),
                          image: successOne["profileImage"] != null
                              ? DecorationImage(
                                  image:
                                      NetworkImage(successOne["profileImage"]),
                                  fit: BoxFit.cover)
                              : DecorationImage(
                                  image: AssetImage('assets/images/user.jpg')),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      successOne["nickname"].toString(),
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: PeeroreumColor.gray[800]),
                    )
                  ],
                ),
                GestureDetector(
                  child: SvgPicture.asset(
                    'assets/icons/icon_dots_mono.svg',
                    color: PeeroreumColor.gray[800],
                  ),
                  onTap: () async {
                    await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return aboutImageWedu(successOne["nickname"]);
                        });
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            SizedBox(height: 20),
            CarouselSlider(
              items: challengeImage.map((i) {
                var imageUrl = i.toString();
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: PeeroreumColor.gray[100],
                          image: i != null
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover)
                              : null),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                            margin: EdgeInsets.all(12),
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color.fromARGB(100, 0, 0, 0),
                            ),
                            child: Text(
                              '${challengeImage.indexOf(i) + 1} / ${challengeImage.length}',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: PeeroreumColor.white),
                            )),
                      ),
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                enableInfiniteScroll: false,
                viewportFraction: 1,
                height: 380,
                enlargeCenterPage: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 48,
              margin: EdgeInsets.symmetric(
                vertical: 8,
              ),
              width: double.maxFinite,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '닫기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(PeeroreumColor.gray[300]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bodyWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  color: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: PeeroreumColor.gray[200]!)),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      image: weduImage != null
                                          ? DecorationImage(
                                              image: NetworkImage(weduImage),
                                              fit: BoxFit.cover)
                                          : DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/example_logo.png')),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          width: 1,
                                          color: PeeroreumColor.gray[100]!),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    height: 64,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '목표 달성',
                                          style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  PeeroreumColor.gray[600]),
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
                                                  color: PeeroreumColor
                                                      .gray[800]),
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
                                                  color: PeeroreumColor
                                                      .gray[800]),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              '${weduDday}',
                                              style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                  color: PeeroreumColor
                                                      .gray[800]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                child: SvgPicture.asset(
                                  'assets/icons/right.svg',
                                  color: PeeroreumColor.gray[500],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetailWeduCalendar(
                                                  id, weduTitle.toString())));
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 16,
                          thickness: 1,
                          color: PeeroreumColor.gray[100],
                        ),
                        Container(
                          child: SizedBox(
                            child: LinearPercentIndicator(
                              padding: EdgeInsets.all(0),
                              lineHeight: 8,
                              animationDuration: 2000,
                              percent: percent,
                              backgroundColor: PeeroreumColor.gray[200],
                              linearGradient: LinearGradient(colors: [
                                PeeroreumColor.primaryPuple[400]!,
                                Color(0xffada5fc)
                              ]),
                              barRadius: Radius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                children: [
                                  Text(
                                    '${weduProgress}',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: PeeroreumColor.primaryPuple[400]),
                                  ),
                                  SizedBox(width: 2,),
                                  Text(
                                    '%',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: PeeroreumColor.primaryPuple[400]),
                                  ),
                                  SizedBox(width: 2,),
                                  Text(
                                    '달성',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: PeeroreumColor.primaryPuple[400]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '100',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: PeeroreumColor.gray[600]),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: PeeroreumColor.gray[200]!)),
                  child: Theme(
                    data: ThemeData(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                        backgroundColor: PeeroreumColor.white,
                        collapsedBackgroundColor: PeeroreumColor.white,
                        trailing: SvgPicture.asset(
                          isExpanded
                              ? 'assets/icons/down.svg'
                              : 'assets/icons/up.svg',
                          color: PeeroreumColor.gray[500],
                        ),
                        title: Container(
                          color: PeeroreumColor.white,
                          child: Row(
                            children: [
                              Container(
                                height: 28,
                                padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                                decoration: BoxDecoration(
                                    color: PeeroreumColor.primaryPuple[50],
                                    borderRadius: BorderRadius.circular(16)),
                                child: Center(
                                  child: Text(
                                    '오늘의 미션',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: PeeroreumColor.primaryPuple[400],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  isExpanded ? weduChallenge : "",
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: PeeroreumColor.gray[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onExpansionChanged: (value) {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        children: [
                          Container(
                            color: PeeroreumColor.white,
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 100,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    child: Text(
                                      weduChallenge,
                                      style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: PeeroreumColor.gray[800]),
                                    ),
                                  ),
                                ),
                                Image.asset('assets/images/wedu_mission.png'),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: PeeroreumColor.gray[50],
            thickness: 8,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '달성',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: PeeroreumColor.gray[800]),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${successList.length}',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: PeeroreumColor.gray[600]),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/wedu/challenge/ok/compliment',
                        arguments: successList);
                  },
                  child: Text(
                    '전체보기',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: PeeroreumColor.gray[500]),
                  ),
                ),
              ],
            ),
          ),
          (successList.isNotEmpty) ? okList() : Container(),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '미달성',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: PeeroreumColor.gray[800]),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${notSuccessList.length}',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: PeeroreumColor.gray[600]),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/wedu/challenge/notok/encouragement',
                        arguments: notSuccessList);
                  },
                  child: Text(
                    '전체보기',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: PeeroreumColor.gray[500]),
                  ),
                ),
              ],
            ),
          ),
          notOkList()
        ],
      ),
    );
  }

  Widget changeDetailWedu() {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: isCreator
      ? Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 16, top: 4),
              child: Text(
                '같이방 관리',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: PeeroreumColor.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                //wedu_change(context);
              },
              style: TextButton.styleFrom(
                minimumSize: Size.fromHeight(40),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(0),
              ),
              child: Text(
                '같이방 수정',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: PeeroreumColor.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await confirmWeduDeleteMessage();
              },
              style: TextButton.styleFrom(
                minimumSize: Size.fromHeight(40),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(0),
              ),
              child: Text(
                '같이방 삭제',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: PeeroreumColor.error,
                ),
              ),
            ),
          ],
        ),
      )
      : GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await confirmOutWeduMessage();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0,16,0,41),
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20,),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('나가기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: PeeroreumColor.error,

          ),
          ),
        )
      ),
    )
    );
  }

  aboutImageWedu(String successOneNickname){
    isMyImage = nickname == successOneNickname;
    return Container(
      decoration: BoxDecoration(
          color: PeeroreumColor.white, // 여기에 색상 지정
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
      child: isMyImage
      ? GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          await confirmChallengeDeleteMessage();
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0,16,0,41),
          height: 56,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20,),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text('삭제하기',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: PeeroreumColor.error,
              
            ),
            ),
          )
        ),
      )
      : GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          Fluttertoast.showToast(msg: '준비 중입니다.');
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0,16,0,41),
          height: 56,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20,),
          child: Text('신고하기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: PeeroreumColor.error,
          )),
        ),
      ),
    );
  }

  confirmWeduDeleteMessage() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "같이방 삭제",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "정말 삭제하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(height: 4,),
                Text(
                  "모든 참여자의 같이방 데이터가 삭제됩니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300], // 배경 색상
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16), // 패딩
                          shape: RoundedRectangleBorder(
                            // 모양
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          deleteWedu();
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '삭제',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  confirmOutWeduMessage() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "같이방 나가기",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "정말 나가시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(height: 4,),
                Text(
                  "퇴장 시 인증 데이터가 삭제됩니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300], // 배경 색상
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16), // 패딩
                          shape: RoundedRectangleBorder(
                            // 모양
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          outWedu();
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '나가기',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  confirmChallengeDeleteMessage(){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "인증사진을 삭제하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(height: 4,),
                Text(
                  "삭제 시 챌린지가 미달성 처리됩니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300], // 배경 색상
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16), // 패딩
                          shape: RoundedRectangleBorder(
                            // 모양
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteChallenge();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '삭제',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteChallenge() async {
    var result = await http.delete(Uri.parse('${API.hostConnect}/wedu/$id/challenge'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });

    if(result.statusCode == 200) {
      print("챌린지 인증 삭제 성공");
      setState(() {
        fetchDatas();
      });
    } else {
      print("챌린지 인증 삭제 실패 ${result.statusCode}");
    }
  }

  void outWedu() async {
    var result = await http.delete(Uri.parse('${API.hostConnect}/wedu/$id/out'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if(result.statusCode == 200) {
      print("같이방 나가기 성공");
    } else {
      print("같이방 나가기 실패 ${result.statusCode}");
    }
  }

  void deleteWedu() async {
    var result = await http.delete(Uri.parse('${API.hostConnect}/wedu/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if(result.statusCode == 200) {
      print("같이방 삭제 성공");
    } else {
      print("같이방 삭제 실패 ${result.statusCode}");
    }
  }

  void showDoChallengeBottomSheet() {
    _images.clear();
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: PeeroreumColor.white, // 여기에 색상 지정
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '인증 방식을 선택하세요.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.gray[800],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            takeFromCamera();
                            Navigator.pop(context);
                          },
                          child: Text(
                            '카메라',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PeeroreumColor.white,
                            ),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(
                                  PeeroreumColor
                                      .primaryPuple[400]),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.all(12)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  ))),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            takeFromGallery();
                            Navigator.pop(context);
                          },
                          child: Text(
                            '갤러리',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PeeroreumColor.white,
                            ),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(
                                  PeeroreumColor
                                      .primaryPuple[400]),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.all(12)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  ))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}