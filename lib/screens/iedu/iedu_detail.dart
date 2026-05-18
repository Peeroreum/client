import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/detail_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:peeroreum_client/widgets/custom_image_picker.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/screens/iedu/iedu_whiteboard.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';
import 'package:peeroreum_client/screens/report.dart';

class DetailIedu extends StatefulWidget {
  final int id;
  final bool isQselected;
  const DetailIedu(this.id, this.isQselected, {super.key});

  @override
  State<DetailIedu> createState() => _DetailIeduState(id, isQselected);
}

class _DetailIeduState extends State<DetailIedu> {
  _DetailIeduState(this.id, this.isQselected);

  var id, nickname;
  TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late Future initFuture;
  int page = 0;
  bool _isLoading = false;

  int? _maxLines = 1; // 현재 줄 수
  int _visibleLines = 1; // 화면에 보이는 줄 수

  dynamic selectedData;
  dynamic sltProfileData;
  dynamic questionData = '';
  dynamic profileData = '';

  dynamic profileImage;
  dynamic grade;
  dynamic name = '';
  dynamic date = DateTime.now().toString();
  dynamic title = '';
  dynamic contents = '';
  List<dynamic> questionImage = [];
  int currentPage = 1;
  bool isLiked = false;
  dynamic isBookmarked;
  int likesNum = 0;
  int commentsNum = 0;
  dynamic isQselected;

  int selectedParent = -1;

  //----------------
  String comment = "";
  bool isSubmittable = false;

  XFile? _image;
  //----------------
  List<dynamic> commentData = [];

  void updateData() {
    setState(() {});
  }

  Future<void> fetchData() async {
    nickname = await const FlutterSecureStorage().read(key: "nickname");

    await fetchIeduQuestionData();
    await fetchIeduAnswerData();
    await fetchSelectedQuestion(isQselected);
  }

  fetchSelectedQuestion(bool selectExist) async {
    if (selectExist == true) {
      try {
        var selectedQuestionResult = await ApiClient().get('/answer/$id/selected');
        if (selectedQuestionResult.statusCode == 200) {
          selectedData = selectedQuestionResult.data['data'];
          sltProfileData = selectedData['memberProfileDto'];
        } else {
          print("fetchIeduQuestionData에러${selectedQuestionResult.statusCode}");
        }
      } catch (e) {
        print('Unexpected error: $e');
      }
    }
    setState(() {});
  }

  fetchIeduQuestionData() async {
    try {
      var inIeduQuestionResult = await ApiClient().get('/question/$id');
      if (inIeduQuestionResult.statusCode == 200) {
        questionData = inIeduQuestionResult.data['data'];
        profileData = questionData['memberProfileDto'];
        profileImage = profileData['profileImage'];
        grade = profileData['grade'];
        name = profileData['nickname'];
        date = questionData['createdTime'];
        title = questionData['title'];
        contents = questionData['content'];
        questionImage = questionData['imageUrls'];
        isLiked = questionData['liked'];
        isBookmarked = questionData['bookmarked'];
        likesNum = questionData['likes'];
        commentsNum = questionData['comments'];
        print(questionImage);
      } else if (inIeduQuestionResult.statusCode == 404) {
        Get.offAllNamed('/home/iedu');
        print("fetchIeduQuestionData ${inIeduQuestionResult.statusCode}");
      } else {
        print("fetchIeduQuestionData에러${inIeduQuestionResult.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
    setState(() {});
  }

  fetchIeduAnswerData() async {
    page = 0;
    print(page);
    try {
      var inIeduAnswerResult = await ApiClient().get('/answer?questionId=$id&page=$page');
      if (inIeduAnswerResult.statusCode == 200) {
        commentData = inIeduAnswerResult.data['data'];
        print(commentData);
        setState(() {});
      } else {
        print("fetchIeduAnswerData에러${inIeduAnswerResult.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initFuture = fetchData();
    _textController = TextEditingController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(loadMoreData);
    _scrollController.dispose();
    _textController.dispose();
    page = 0;
    super.dispose();
  }

  void loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> addedData = [];
    page++;
    try {
      var inIeduAnswerResult = await ApiClient().get('/answer?questionId=$id&page=$page');
      if (inIeduAnswerResult.statusCode == 200) {
        addedData = inIeduAnswerResult.data['data'];
        setState(() {
          commentData.addAll(addedData);
          _isLoading = false;
        });
      } else {
        print("에러${inIeduAnswerResult.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedParent != -1) {
          setState(() {
            selectedParent = -1;
          });
          // 뒤로 가기 버튼을 눌렀을 때 선택된 부모가 있으면 화면을 뒤로 가지 않고 selectedParent를 초기화합니다.
          return false;
        } else {
          // 선택된 부모가 없는 경우에는 뒤로 가기 동작을 허용합니다.
          return true;
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: FutureBuilder(
            future: initFuture,
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              // return Scaffold(
              //   body: RefreshIndicator(
              //       onRefresh: () => fetchDatas(),
              //       color: PeeroreumColor.primaryPuple[400],
              //       child: Container(),),
              // );
              // } else if (snapshot.hasError) {
              //   // 에러 발생 시
              //   return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
              // } else {
              //   return Scaffold(
              //             appBar: appbarWidget(),
              //             body: bodyWidget(),
              //           );
              // }
              return Scaffold(
                appBar: appbarWidget(),
                body: bodyWidget(),
              );
            }),
      ),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      surfaceTintColor: PeeroreumColor.white,
      shadowColor: PeeroreumColor.white,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          color: PeeroreumColor.gray[800],
        ),
        onPressed: () {
          Get.back();
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 4),
                  constraints: const BoxConstraints(),
                  child: isBookmarked != null && isBookmarked
                      ? SvgPicture.asset('assets/icons/bookmark_fill.svg',
                          color: PeeroreumColor.primaryPuple[400])
                      : SvgPicture.asset('assets/icons/bookmark.svg',
                          color: PeeroreumColor.black),
                ),
                onTap: () {
                  print(isBookmarked);
                  postBookmark();
                },
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(
                  height: 24,
                  width: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  child: SvgPicture.asset(
                    'assets/icons/icon_dots_mono.svg',
                    height: 24,
                    width: 24,
                    color: PeeroreumColor.black,
                  ),
                ),
                onTap: () async {
                  await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return deleteQuestionBottomSheet(name);
                      });
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        T2_20px(text: title),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: PeeroreumColor.gray[100],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                  () => MyPageProfile(name, nickname == name));
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 1,
                                    color: grade != null
                                        ? PeeroreumColor.gradeColor[grade]!
                                        : const Color.fromARGB(255, 186, 188, 189)),
                              ),
                              child: Container(
                                height: 26,
                                width: 26,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color:
                                          PeeroreumColor.white.withOpacity(0.0),
                                    )),
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: profileImage != null
                                        ? DecorationImage(
                                            image: Image.network(profileImage)
                                                .image,
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) {
                                              print(
                                                  'Error loading image: $exception');
                                            },
                                          )
                                        : const DecorationImage(
                                            image: AssetImage(
                                            'assets/images/user.jpg',
                                          )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          if (nickname == name)
                            const Text(
                              ' (나)',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Visibility(
                              visible: DateTime.now().year.toString() !=
                                  date.substring(0, 4),
                              child: Row(
                                children: [
                                  C1_12px_M(
                                      text: date.substring(0, 4),
                                      color: PeeroreumColor.gray[400]),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  C1_12px_M(
                                      text: '/',
                                      color: PeeroreumColor.gray[400]),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                ],
                              )),
                          C1_12px_M(
                              text: date.substring(5, 7),
                              color: PeeroreumColor.gray[400]),
                          const SizedBox(
                            width: 2,
                          ),
                          C1_12px_M(text: '/', color: PeeroreumColor.gray[400]),
                          const SizedBox(
                            width: 2,
                          ),
                          C1_12px_M(
                              text: date.substring(8, 10),
                              color: PeeroreumColor.gray[400]),
                          const SizedBox(
                            width: 4,
                          ),
                          C1_12px_M(
                              text: date.substring(11, 13),
                              color: PeeroreumColor.gray[400]),
                          const SizedBox(
                            width: 2,
                          ),
                          C1_12px_M(text: ':', color: PeeroreumColor.gray[400]),
                          const SizedBox(
                            width: 2,
                          ),
                          C1_12px_M(
                              text: date.substring(14, 16),
                              color: PeeroreumColor.gray[400]),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Column(
                    children: [B4_14px_R(text: contents)],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Visibility(
                    visible: questionImage.isNotEmpty,
                    child: CarouselSlider(
                      items: questionImage.map((i) {
                        var imageUrl = i?.toString();
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                int selectedIndex = questionImage.indexOf(i);
                                Get.to(() => ImageDetail(
                                    imageList: questionImage,
                                    initialPage: selectedIndex));
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: PeeroreumColor.gray[100],
                                    image: imageUrl != null
                                        ? DecorationImage(
                                            image:
                                                Image.network(imageUrl).image,
                                            fit: BoxFit.cover)
                                        : null),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: const Color.fromARGB(60, 0, 0, 0),
                                      ),
                                      child: Text(
                                        '$currentPage / ${questionImage.length}',
                                        style: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: PeeroreumColor.white),
                                      )),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                      options: CarouselOptions(
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentPage = index + 1;
                          });
                        },
                        enableInfiniteScroll: false,
                        viewportFraction: 1,
                        height: 180,
                        enlargeCenterPage: false,
                      ),
                    ),
                  ),
                  //350 * 180
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          postQLike();
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: isLiked
                                  ? SvgPicture.asset(
                                      'assets/icons/thumbs_up_fill.svg')
                                  : SvgPicture.asset(
                                      'assets/icons/thumbs_up.svg'),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Container(
                                constraints:
                                    const BoxConstraints(minWidth: 17, minHeight: 16),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: C1_12px_M(
                                        text: '$likesNum',
                                        color: PeeroreumColor.gray[600]))),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: SvgPicture.asset(
                                'assets/icons/chat_drop_dots.svg'),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Container(
                              constraints:
                                  const BoxConstraints(minWidth: 17, minHeight: 16),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: C1_12px_M(
                                      text: '$commentsNum',
                                      color: PeeroreumColor.gray[600]))),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 8,
              color: PeeroreumColor.gray[100],
            ),
            Visibility(
              visible: isQselected,
              child: selectedData != null
                  ? Container(
                      color: PeeroreumColor.primaryPuple[50]!,
                      child: MakeComment(
                        index: 0,
                        id: selectedData["id"],
                        hasParent: -1,
                        grade: selectedData['memberProfileDto']['grade'],
                        profileImage: selectedData['memberProfileDto']
                            ['profileImage'],
                        name: selectedData['memberProfileDto']['nickname'],
                        isQwselected: isQselected,
                        isChosen: selectedData["isSelected"],
                        comment: selectedData["content"],
                        commentImage: selectedData["images"],
                        createdTime: selectedData["createdTime"],
                        isLiked: selectedData["isLiked"],
                        likesNum: selectedData["likes"],
                        commentsNum: selectedData["comments"],
                        isDeleted: selectedData["isDeleted"],
                        updateData: fetchData,
                        qWriter: name,
                      ),
                    )
                  : Container(),
            ),
            //--대안--
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: (commentData)
                    .map<Widget>((commentData) {
                  return MakeComment(
                    index: this.commentData.indexOf(commentData),
                    id: commentData["id"],
                    hasParent: commentData["parentId"],
                    grade: commentData['memberProfileDto']['grade'],
                    profileImage: commentData['memberProfileDto']
                        ['profileImage'],
                    name: commentData['memberProfileDto']['nickname'],
                    isQwselected: isQselected,
                    isChosen: commentData["isSelected"],
                    comment: commentData["content"],
                    commentImage: commentData["images"],
                    createdTime: commentData["createdTime"],
                    isLiked: commentData["isLiked"],
                    likesNum: commentData["likes"],
                    commentsNum: commentData["comments"],
                    isDeleted: commentData["isDeleted"],
                    updateData: fetchData,
                    qWriter: name,
                  );
                }).toList(),
              ),
            ),
            // Expanded(
            //   child: ListView.separated(
            //     //physics: NeverScrollableScrollPhysics(),
            //     scrollDirection: Axis.vertical,
            //     //padding: EdgeInsets.symmetric(horizontal: 20),
            //     itemBuilder: (BuildContext context, int index) {
            //       return MakeComment(
            //           grade: commentDatas[index]["memberGrade"],
            //           name: commentDatas[index]["memberNickname"],
            //           isQselected: false,
            //           isChosen: commentDatas[index]["isDeleted"],
            //           comment: commentDatas[index]["content"],
            //           commentImage: commentDatas[index]["imagePaths"],
            //           );
            //     },
            //     separatorBuilder: (BuildContext context, int index) => Divider(),
            //     itemCount: commentDatas.length),
            // )
          ],
        ),
      ),
      bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: _image != null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                height: 212,
                width: double.maxFinite,
                color: Colors.black.withOpacity(0.4),
                child: Container(
                  height: 180,
                  width: double.maxFinite,
                  decoration: _image != null
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(_image!.path)),
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, right: 8),
                      width: 24,
                      height: 24,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _image = null;
                            if (comment == "") {
                              isSubmittable = false;
                            }
                          });
                        },
                        child: Opacity(
                            opacity: 0.4,
                            child:
                                SvgPicture.asset('assets/icons/x_circle.svg')),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: PeeroreumColor.gray[50],
                  border: Border(
                      top: BorderSide(
                    color: PeeroreumColor.gray[100]!,
                    width: 1.0,
                  ))),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: const BoxConstraints(minHeight: 48),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: PeeroreumColor.gray[100],
                        border: Border.all(color: PeeroreumColor.gray[200]!),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 108,
                            child: TextFormField(
                              focusNode: _focusNode,
                              controller: _textController,
                              style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                              maxLines: _maxLines,
                              cursorColor: PeeroreumColor.gray[600],
                              decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: (selectedParent == -1)
                                      ? "댓글을 입력하세요"
                                      : "대댓글을 입력하세요",
                                  hintStyle: TextStyle(
                                    color: PeeroreumColor.gray[600],
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  )),
                              onChanged: (value) {
                                comment = value;
                                final lines = textLines(value);
                                setState(() {
                                  if (comment != "" || _image != null) {
                                    isSubmittable = true;
                                  } else {
                                    isSubmittable = false;
                                  }
                                  _visibleLines = lines;
                                  // 최대 4줄까지만 입력 가능하도록 설정
                                  _maxLines = (_visibleLines > 4 ? 4 : null);
                                });
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            print(selectedParent);
                            if (isSubmittable) {
                              postAnswer();
                              setState(() {
                                FocusScope.of(context).unfocus();
                                fetchIeduAnswerData();
                              });
                            }
                          },
                          child: SizedBox(
                            height: 24,
                            child: Center(
                              child: T5_14px(
                                text: '등록',
                                color: isSubmittable == false
                                    ? PeeroreumColor.gray[500]
                                    : PeeroreumColor.primaryPuple[400],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_image == null) {
                          showImagePickerSheet();
                        } else {
                          PeeroreumToast.show(
                              context, "댓글은 파일 최대 1개까지만 첨부 가능해요.");
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            child: SvgPicture.asset(
                              'assets/icons/camera3.svg',
                              color: PeeroreumColor.gray[500],
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          T4_16px(
                            text: '사진 첨부',
                            color: PeeroreumColor.gray[500],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_image == null) {
                          final dynamic whiteboardImage =
                              await Get.to(() => const WhiteboardIedu());
                          setState(() {
                            _image = whiteboardImage;
                            isSubmittable = true;
                          });
                        } else {
                          PeeroreumToast.show(
                              context, "댓글은 파일 최대 1개까지만 첨부 가능해요.");
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            child: SvgPicture.asset(
                              'assets/icons/notepad.svg',
                              color: PeeroreumColor.gray[500],
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          T4_16px(
                            text: '화이트 보드',
                            color: PeeroreumColor.gray[500],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom > 20 ? MediaQuery.of(context).viewPadding.bottom : 20.0,
                )
              ]),
            ),
          ],
        ),
    );
  }

  void showImagePickerSheet() async {
    final selected = await showCustomImagePicker(context, multiple: false);
    if (selected != null && selected.isNotEmpty) {
      setState(() {
        _image = selected.first;
        isSubmittable = true;
      });
    }
  }

  deleteQuestionBottomSheet(writerName) {
    var isMyQuestion = writerName == nickname;
    return Container(
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: isMyQuestion
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                await confirmQuestionDeleteMessage();
              },
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 16, 0, MediaQuery.of(context).viewPadding.bottom > 20 ? MediaQuery.of(context).viewPadding.bottom : 20.0),
                  height: 56,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '삭제하기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: PeeroreumColor.error,
                      ),
                    ),
                  )),
            )
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Get.to(() => Report(
                      data: "[내가해냄] 내가 해냄 질문 신고\n" +
                          "날짜 : $date\n" +
                          "질문 아이디 : $id\n" +
                          "업로드한 사람 : $name\n",
                    ));
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 16, 0, MediaQuery.of(context).viewPadding.bottom > 20 ? MediaQuery.of(context).viewPadding.bottom : 20.0),
                height: 56,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: const Text('신고하기',
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

  confirmQuestionDeleteMessage() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "질문을 삭제하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          int count = 0;
                          Get.until((route) {
                            if (count >= 2) {
                              return true;
                            }
                            count++;
                            return false;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          deleteQuestion();
                          Get.offAllNamed('/home/iedu');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
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

  Future<void> postAnswer() async {
    var formData = dio.FormData();

    var IeduAnswerMap = <String, dynamic>{
      'content': _textController.text,
      'questionId': '$id',
      'parentAnswerId': '$selectedParent'
    };

    formData = dio.FormData.fromMap(IeduAnswerMap);

    if (_image != null) {
      var file = await dio.MultipartFile.fromFile(_image!.path);
      formData.files.add(MapEntry('files', file));
    }

    try {
      var response = await ApiClient().postForm('/answer', formData);

      if (response.statusCode == 200) {
        fetchData();
        setState(() {
          _image = null;
          _textController.clear();
          _maxLines = null;
          isSubmittable = false;
          selectedParent = -1;
        });
      } else {
        PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
      }
    } catch (e) {
      print('Unexpected error: $e');
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
    }
  }

  int textLines(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
            height: 1.0,
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(minWidth: 0, maxWidth: MediaQuery.of(context).size.width - 108);

    List<LineMetrics> countLines = textPainter.computeLineMetrics();
    return countLines.length;
  }

  Future<void> postBookmark() async {
    try {
      if (isBookmarked == false) {
        var response = await ApiClient().post('/bookmark/question/$id');
        if (response.statusCode == 200) {
          print('북마크 요청이 성공했습니다.');
          fetchData();
        } else if (response.statusCode == 404) {
          PeeroreumToast.show(context, '존재하지 않는 질문이에요.', isError: true);
        } else {
          print('북마크 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
        }
      } else if (isBookmarked == true) {
        var response = await ApiClient().delete('/bookmark/question/$id');
        if (response.statusCode == 200) {
          print('북마크 삭제 요청이 성공했습니다.');
          fetchData();
        } else if (response.statusCode == 404) {
          PeeroreumToast.show(context, '존재하지 않는 질문이에요.', isError: true);
        } else {
          print('북마크 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<void> postQLike() async {
    try {
      if (isLiked == false) {
        var response = await ApiClient().post('/like/question/$id');
        if (response.statusCode == 200) {
          print('질문 좋아요 요청이 성공했습니다.');
          fetchData();
        } else if (response.statusCode == 404) {
          PeeroreumToast.show(context, '존재하지 않는 질문이에요.', isError: true);
        } else {
          print('질문 좋아요 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
        }
      } else if (isLiked == true) {
        var response = await ApiClient().delete('/like/question/$id');
        if (response.statusCode == 200) {
          print('질문 좋아요 삭제 요청이 성공했습니다.');
          fetchData();
        } else if (response.statusCode == 404) {
          PeeroreumToast.show(context, '존재하지 않는 질문이에요.', isError: true);
        } else {
          print('질문 좋아요 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
    fetchIeduQuestionData();
  }

  Future<void> deleteQuestion() async {
    try {
      var response = await ApiClient().delete('/question/$id');
      if (response.statusCode == 200) {
        print('질문 삭제 요청이 성공했습니다.');
      } else if (response.statusCode == 404) {
        PeeroreumToast.show(context, '존재하지 않는 질문이에요.');
      } else {
        PeeroreumToast.show(context, '채택 완료 질문은 삭제할 수 없어요.', isError: true);
        print('질문 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }
}

class MakeComment extends StatefulWidget {
  final dynamic index;
  final dynamic id;
  final dynamic hasParent;
  final dynamic grade;
  final dynamic profileImage;
  final dynamic name;
  final dynamic isQwselected;
  final dynamic isChosen;
  final dynamic comment;
  final List<dynamic>? commentImage;
  final dynamic createdTime;
  final dynamic isLiked;
  final dynamic likesNum;
  final dynamic commentsNum;
  final dynamic isDeleted;
  final VoidCallback updateData;
  final dynamic qWriter;

  const MakeComment({
    Key? key,
    required this.index,
    required this.id,
    required this.hasParent,
    required this.grade,
    this.profileImage,
    required this.name,
    required this.isQwselected,
    required this.isChosen,
    required this.comment,
    this.commentImage,
    this.createdTime,
    this.isLiked,
    this.likesNum,
    this.commentsNum,
    this.isDeleted = false,
    required this.updateData,
    required this.qWriter,
  }) : super(key: key);

  @override
  State<MakeComment> createState() => _MakeCommentState();
}

class _MakeCommentState extends State<MakeComment> {
  String createdTime = DateTime.now().toString();
  var nickname;

  @override
  void initState() {
    super.initState();
    createdTime = widget.createdTime ?? DateTime.now().toString();
    getData();
  }

  Future<void> getData() async {
    nickname = await const FlutterSecureStorage().read(key: "nickname");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: widget.hasParent == -1
          ? const EdgeInsets.symmetric(vertical: 16)
          : const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      margin:
          widget.hasParent == -1 ? const EdgeInsets.symmetric(horizontal: 20) : null,
      decoration: widget.hasParent == -1 && widget.index != 0
          ? BoxDecoration(
              border: Border(
                  top: BorderSide(
                color: PeeroreumColor.gray[100]!,
                width: 1.0,
              )),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.hasParent != -1,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: SvgPicture.asset(
                'assets/icons/forward.svg',
                color: PeeroreumColor.gray[600],
              ),
            ),
          ),
          Container(
            padding: widget.hasParent == -1
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            margin: widget.hasParent == -1
                ? EdgeInsets.zero
                : const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: widget.hasParent == -1
                  ? Colors.transparent
                  : PeeroreumColor.gray[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: widget.hasParent == -1
                      ? MediaQuery.of(context).size.width - 40
                      : MediaQuery.of(context).size.width - 112,
                  child: Visibility(
                    visible: widget.isDeleted == false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: widget.hasParent == -1
                              ? MediaQuery.of(context).size.width - 40 - 34
                              : MediaQuery.of(context).size.width - 112 - 34,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (widget.isDeleted == false) {
                                    Get.to(() => MyPageProfile(
                                        widget.name, nickname == widget.name));
                                  }
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 1,
                                        color: widget.grade != null
                                            ? PeeroreumColor
                                                .gradeColor[widget.grade]!
                                            : const Color.fromARGB(
                                                255, 186, 188, 189)),
                                  ),
                                  child: Container(
                                    height: 26,
                                    width: 26,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 2,
                                          color: PeeroreumColor.white
                                              .withOpacity(0.0),
                                        )),
                                    child: Container(
                                      height: 24,
                                      width: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: widget.profileImage != null
                                            ? DecorationImage(
                                                image: Image.network(
                                                        widget.profileImage)
                                                    .image,
                                                fit: BoxFit.cover)
                                            : const DecorationImage(
                                                image: AssetImage(
                                                'assets/images/user.jpg',
                                              )),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Flexible(
                                  child: B4_14px_M(
                                text: widget.name,
                              )),
                              if (nickname == widget.name &&
                                  widget.isDeleted == false)
                                const Text(
                                  ' (나)',
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              const SizedBox(
                                width: 12,
                              ),
                              Visibility(
                                visible: (widget.isQwselected == false) &&
                                    (nickname == widget.qWriter) &&
                                    (widget.qWriter != widget.name),
                                child: GestureDetector(
                                  onTap: () async {
                                    final _dState =
                                        context.findAncestorStateOfType<
                                            _DetailIeduState>();
                                    if (await checkSelect()) {
                                      if (_dState != null) {
                                        _dState.setState(() {
                                          _dState.isQselected = true;
                                        });
                                      }
                                      selectAnswer();
                                      widget.updateData();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: PeeroreumColor.primaryPuple[400],
                                        borderRadius: BorderRadius.circular(4)),
                                    width: 57,
                                    height: 24,
                                    child: const Center(
                                        child: C1_12px_Sb(
                                      text: '채택하기',
                                      color: PeeroreumColor.white,
                                    )),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: widget.isQwselected == true &&
                                    widget.isChosen == true,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: PeeroreumColor.primaryPuple[400],
                                      borderRadius: BorderRadius.circular(4)),
                                  width: 57,
                                  height: 24,
                                  child: const Center(
                                      child: C1_12px_Sb(
                                    text: '채택완료',
                                    color: PeeroreumColor.white,
                                  )),
                                ),
                              ),
                              Visibility(
                                visible: widget.isQwselected == true &&
                                    widget.isChosen == false &&
                                    nickname == widget.qWriter,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: PeeroreumColor.gray[300],
                                      borderRadius: BorderRadius.circular(4)),
                                  width: 57,
                                  height: 24,
                                  child: const Center(
                                      child: C1_12px_Sb(
                                    text: '채택하기',
                                    color: PeeroreumColor.white,
                                  )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Visibility(
                          visible: widget.isDeleted == false,
                          child: GestureDetector(
                            onTap: () async {
                              await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return deleteAnswerBottomSheet(
                                        widget.name, widget.id);
                                  });
                            },
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: SvgPicture.asset(
                                  'assets/icons/icon_dots_mono.svg'),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: widget.hasParent == -1
                      ? MediaQuery.of(context).size.width - 40
                      : MediaQuery.of(context).size.width - 112,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: widget.isDeleted ||
                            (!widget.isDeleted &&
                                widget.comment.toString().isNotEmpty),
                        child: B4_14px_R(
                          text:
                              widget.isDeleted ? '삭제된 댓글입니다.' : widget.comment,
                          color: widget.isDeleted
                              ? PeeroreumColor.gray[500]
                              : null,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                if (widget.commentImage != null &&
                    widget.commentImage!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Get.to(
                          () => ImageDetail(imageList: widget.commentImage!));
                    },
                    child: Container(
                      width: widget.hasParent == -1
                          ? MediaQuery.of(context).size.width - 40
                          : MediaQuery.of(context).size.width - 112,
                      height: 180,
                      decoration: widget.commentImage != null &&
                              widget.commentImage!.isNotEmpty
                          ? BoxDecoration(
                              border:
                                  Border.all(color: PeeroreumColor.gray[100]!),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: Image.network(widget.commentImage!.first)
                                    .image,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                    ),
                  ),
                const SizedBox(
                  height: 8,
                ),
                Visibility(
                  visible: widget.isDeleted == false,
                  child: Row(
                    children: [
                      Visibility(
                          visible: createdTime.toString().substring(0, 4) !=
                              DateTime.now().toString().substring(0, 4),
                          child: Row(
                            children: [
                              C1_12px_M(
                                text: createdTime.toString().substring(0, 4),
                                color: PeeroreumColor.gray[400],
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              C1_12px_M(
                                  text: '/', color: PeeroreumColor.gray[400]),
                              const SizedBox(
                                width: 2,
                              )
                            ],
                          )),
                      C1_12px_M(
                          text: createdTime.toString().substring(5, 7),
                          color: PeeroreumColor.gray[400]),
                      const SizedBox(
                        width: 2,
                      ),
                      C1_12px_M(text: '/', color: PeeroreumColor.gray[400]),
                      const SizedBox(
                        width: 2,
                      ),
                      C1_12px_M(
                          text: createdTime.toString().substring(8, 10),
                          color: PeeroreumColor.gray[400]),
                      const SizedBox(
                        width: 4,
                      ),
                      C1_12px_M(
                          text: createdTime.toString().substring(11, 13),
                          color: PeeroreumColor.gray[400]),
                      const SizedBox(
                        width: 2,
                      ),
                      C1_12px_M(text: ':', color: PeeroreumColor.gray[400]),
                      const SizedBox(
                        width: 2,
                      ),
                      C1_12px_M(
                          text: createdTime.toString().substring(14, 16),
                          color: PeeroreumColor.gray[400]),
                      const SizedBox(
                        width: 8,
                      ),
                      C1_12px_M(text: '|', color: PeeroreumColor.gray[200]),
                      const SizedBox(
                        width: 8,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          postALike(widget.id, widget.isLiked);
                          print('${widget.id}, ${widget.isLiked}');
                          widget.updateData();
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: widget.isLiked
                                  ? SvgPicture.asset(
                                      'assets/icons/thumbs_up_fill.svg')
                                  : SvgPicture.asset(
                                      'assets/icons/thumbs_up.svg'),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Container(
                                constraints:
                                    const BoxConstraints(minWidth: 17, minHeight: 16),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: C1_12px_M(
                                        text: '${widget.likesNum}',
                                        color: PeeroreumColor.gray[600]))),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: widget.hasParent == -1,
                        child: GestureDetector(
                          onTap: () {
                            final dState = context
                                .findAncestorStateOfType<_DetailIeduState>();
                            if (dState != null) {
                              dState.setState(() {
                                dState.selectedParent = widget.id;
                                FocusScope.of(context)
                                    .requestFocus(dState._focusNode);
                                print(widget.id);
                              });
                            }
                          },
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              C1_12px_M(
                                  text: '|', color: PeeroreumColor.gray[200]),
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                height: 18,
                                width: 18,
                                child: SvgPicture.asset(
                                    'assets/icons/chat_drop_dots.svg'),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 17, minHeight: 16),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: C1_12px_M(
                                          text: '${widget.commentsNum}',
                                          color: PeeroreumColor.gray[600]))),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  deleteAnswerBottomSheet(writerName, commentID) {
    var isMyAnswer = writerName == nickname;
    return Container(
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: isMyAnswer
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                await confirmCommentDeleteMessage(commentID);
              },
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 16, 0, MediaQuery.of(context).viewPadding.bottom > 20 ? MediaQuery.of(context).viewPadding.bottom : 20.0),
                  height: 56,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '삭제하기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: PeeroreumColor.error,
                      ),
                    ),
                  )),
            )
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Get.to(() => Report(
                      data: "[내가해냄] 내가 해냄 답변 신고\n" +
                          "날짜 : ${widget.createdTime}\n" +
                          "답변 아이디 : ${widget.id}\n" +
                          "업로드한 사람 : ${widget.name}\n",
                    ));
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 16, 0, MediaQuery.of(context).viewPadding.bottom > 20 ? MediaQuery.of(context).viewPadding.bottom : 20.0),
                height: 56,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: const Text('신고하기',
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

  confirmCommentDeleteMessage(commentID) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "댓글을 삭제하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          int count = 0;
                          Get.until((route) {
                            if (count >= 2) {
                              return true;
                            }
                            count++;
                            return false;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          deleteAnswer(commentID);
                          widget.updateData();
                          int count = 0;
                          Get.until((route) {
                            if (count >= 2) {
                              return true;
                            }
                            count++;
                            return false;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
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

  Future<void> postALike(answerID, answerLike) async {
    try {
      if (answerLike == false) {
        var response = await ApiClient().post('/like/answer/$answerID');
        if (response.statusCode == 200) {
          print('답변 좋아요 요청이 성공했습니다.');
          setState(() {});
        } else if (response.statusCode == 404) {
          PeeroreumToast.show(context, '존재하지 않는 질문이에요.', isError: true);
        } else {
          print('답변 좋아요 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
        }
      } else if (answerLike == true) {
        var response = await ApiClient().delete('/like/answer/$answerID');
        if (response.statusCode == 200) {
          print('답변 좋아요 삭제 요청이 성공했습니다.');
          setState(() {});
        } else if (response.statusCode == 404) {
          PeeroreumToast.show(context, '존재하지 않는 질문이에요.', isError: true);
        } else {
          print('답변 좋아요 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<void> deleteAnswer(answerID) async {
    try {
      var response = await ApiClient().delete('/answer/$answerID');
      if (response.statusCode == 200) {
        print('답변 삭제 요청이 성공했습니다.');
        setState(() {});
      } else {
        print('답변 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<void> selectAnswer() async {
    print(widget.id);
    try {
      var response = await ApiClient().put('/answer/${widget.id}/select');
      if (response.statusCode == 200) {
        print('답변 채택 요청이 성공했습니다.');
      } else {
        print('답변 채택 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  checkSelect() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "해당 댓글을 채택하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "추가 채택 및 취소가 불가능합니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back(result: true);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.primaryPuple[400],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '채택',
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
}
