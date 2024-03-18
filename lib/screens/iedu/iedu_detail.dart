import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/screens/bottomNaviBar.dart';
import 'package:peeroreum_client/screens/iedu/iedu_detail_image.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/screens/iedu/iedu_whiteboard.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';
import 'package:peeroreum_client/screens/report.dart';

class DetailIedu extends StatefulWidget {
  final int id;
  final bool isQselected;
  const DetailIedu(
    this.id,
    this.isQselected
  );

  @override
  State<DetailIedu> createState() => _DetailIeduState(id, isQselected);
}

class _DetailIeduState extends State<DetailIedu> {
  _DetailIeduState(this.id, this.isQselected);
  
  var id, token, nickname;
  TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  late Future initFuture;
  int page = 0;
  bool _isLoading = false;

  int? _maxLines = 1; // 현재 줄 수
  int _visibleLines = 1; // 화면에 보이는 줄 수

  dynamic selectedDatas ;
  dynamic sltProfileDatas;
  dynamic questionDatas='';
  dynamic profileDatas ='';

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

  final ImagePicker picker = ImagePicker();
  XFile? _image;
  //----------------
  List<dynamic> commentDatas = [];

  void updateData(){
    setState(() {
    });
  }
  
  Future<void>fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    nickname = await FlutterSecureStorage().read(key: "nickname");

    await fetchIeduQuestionData();
    await fetchIeduAnswerData();
    await fetchSelectedQuestion(isQselected);
  }

  fetchSelectedQuestion(bool selectExist) async{
    if(selectExist == true){
      var selectedQuestionResult = await http.get(
      Uri.parse('${API.hostConnect}/answer/$id/selected'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      if (selectedQuestionResult.statusCode == 200){
        selectedDatas = jsonDecode(utf8.decode(selectedQuestionResult.bodyBytes))['data'];
        sltProfileDatas = selectedDatas['memberProfileDto'];
      } else{
        print("fetchIeduQuestionData에러${selectedQuestionResult.statusCode}");
      }
    }
    setState(() {
      
    });
  }

  fetchIeduQuestionData() async{
    var inIeduQuestionResult = await http.get(
      Uri.parse('${API.hostConnect}/question/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
    if (inIeduQuestionResult.statusCode == 200){
      questionDatas = jsonDecode(utf8.decode(inIeduQuestionResult.bodyBytes))['data'];
      profileDatas = questionDatas['memberProfileDto'];
      profileImage = profileDatas['profileImage'];
      grade = profileDatas['grade'];
      name = profileDatas['nickname'];
      date = questionDatas['createdTime'];
      title = questionDatas['title'];
      contents = questionDatas['content'];
      questionImage = questionDatas['imageUrls'];
      isLiked = questionDatas['liked'];
      isBookmarked = questionDatas['bookmarked'];
      likesNum = questionDatas['likes'];
      commentsNum = questionDatas['comments'];
      print(questionImage);
    } else if(inIeduQuestionResult.statusCode == 404){
      // profileImage = null;
      // grade = null;
      // name = "(삭제)";
      // title = "작성자에 의해 삭제된 질문입니다";
      // contents = "(삭제)";
      // questionImage = [];
      Navigator.pushNamedAndRemoveUntil(
          context, '/home/iedu', (route) => false);
      //Fluttertoast.showToast(msg: "존재하지 않는 질문입니다.");
      print("fetchIeduQuestionData ${inIeduQuestionResult.statusCode}");
    }
    else{
      print("fetchIeduQuestionData에러${inIeduQuestionResult.statusCode}");
    }
    setState(() {
      
    });
  }

  fetchIeduAnswerData() async {
    page = 0;
    print(page);
    var inIeduAnswerResult = await http.get(
        Uri.parse('${API.hostConnect}/answer?questionId=$id&page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (inIeduAnswerResult.statusCode == 200) {
      commentDatas = jsonDecode(utf8.decode(inIeduAnswerResult.bodyBytes))['data'];
      print(commentDatas);
      setState(() {
        
      });
    } else {
      print("fetchIeduAnswerData에러${inIeduAnswerResult.statusCode}");
    }
    setState(() {
      
    });
  }


  @override
  void initState() {
    super.initState();
    initFuture = fetchDatas();
    _textController= TextEditingController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        loadmoreData();
      }}
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      loadmoreData
      );
    _scrollController.dispose();
    _textController.dispose();
    page = 0;
    super.dispose();
  }

  void loadmoreData() async{
      setState(() {
        _isLoading = true;
      });

      List<dynamic> addedDatas = [];
      page++;
      var inIeduAnswerResult = await http.get(
        Uri.parse('${API.hostConnect}/answer?questionId=$id&page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
      if (inIeduAnswerResult.statusCode == 200) {
        addedDatas = jsonDecode(utf8.decode(inIeduAnswerResult.bodyBytes))['data'];
        setState(() {
          commentDatas.addAll(addedDatas);
          _isLoading = false;
        });
      } else {
        print("에러${inIeduAnswerResult.statusCode}");
      }
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
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
            builder: (context, snapshot){
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
         // Navigator.pushNamedAndRemoveUntil(context, '/home/iedu', (route) => false);
         Navigator.pop(context);
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
                  margin: EdgeInsets.only(right: 4),
                  constraints: BoxConstraints(),
                  child: isBookmarked != null && isBookmarked 
                      ?SvgPicture.asset('assets/icons/bookmark_fill.svg',
                          color: PeeroreumColor.primaryPuple[400])
                      :SvgPicture.asset('assets/icons/bookmark.svg',
                          color: PeeroreumColor.black),
                ),
                onTap: () {
                  // setState(() {
                  //   isBookmarked = !isBookmarked;
                  // });
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
                  constraints: BoxConstraints(),
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
  bodyWidget(){
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 16,),
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
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          MyPageProfile(name, nickname == name)));
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
                                        : Color.fromARGB(255, 186, 188, 189)),
                              ),
                              child: Container(
                                height: 26,
                                width: 26,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: PeeroreumColor.white.withOpacity(0.0),
                                    )),
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: profileImage != null
                                        ? DecorationImage(
                                            image: Image.network(profileImage).image,
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) {
                                        print('Error loading image: $exception');
                                      },)
                                        : DecorationImage(
                                            image: AssetImage(
                                            'assets/images/user.jpg',
                                          )),
                                  ),
                                ),
                              ),
                                                      ),
                            ),
                          const SizedBox(width: 8,),
                          Text(name,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                          ),),
                          if (nickname == name)
                            Text(' (나)',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                          ),),
                          
                          ],
                        ),
                        Row(
                          children: [
                            Visibility(
                              visible: DateTime.now().year.toString() != date.substring(0,4),
                              child: Row(
                              children: [
                                C1_12px_M(text: date.substring(0,4), color: PeeroreumColor.gray[400]),
                                SizedBox(width: 2,),
                                C1_12px_M(text: '/', color: PeeroreumColor.gray[400]),
                                SizedBox(width: 2,),
                              ],
                            )),
                            C1_12px_M(text: date.substring(5,7), color: PeeroreumColor.gray[400]),
                            SizedBox(width: 2,),
                            C1_12px_M(text: '/', color: PeeroreumColor.gray[400]),
                            SizedBox(width: 2,),
                            C1_12px_M(text: date.substring(8,10), color: PeeroreumColor.gray[400]),
                            SizedBox(width: 4,),
                            C1_12px_M(text: date.substring(11,13), color: PeeroreumColor.gray[400]),
                            SizedBox(width: 2,),
                            C1_12px_M(text: ':', color: PeeroreumColor.gray[400]),
                            SizedBox(width: 2,),
                            C1_12px_M(text: date.substring(14,16), color: PeeroreumColor.gray[400]),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 16,),
                    Column(
                      children: [
                        B4_14px_R(text: contents)
                      ],
                    ),
                    SizedBox(height: 16,),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ImageDetailIedu(imageList: questionImage, initialPage: selectedIndex,),
                                  ));
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: PeeroreumColor.gray[100],
                                    image: imageUrl != null
                                      ?DecorationImage(
                                              image: Image.network(imageUrl).image,
                                              fit: BoxFit.cover)
                                      :null),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                      margin: EdgeInsets.all(12),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Color.fromARGB(60, 0, 0, 0),
                                      ),
                                      child: Text(
                                        '${currentPage} / ${questionImage.length}',
                                        style: TextStyle(
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
                            // setState(() {
                            //   if (isLiked) {
                            //     likesNum -= 1;
                            //   } else {
                            //     likesNum += 1;
                            //   }
                            //   isLiked = !isLiked;
                            // });
                            postQLike();
                            setState(() {
                              
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 24,
                                width: 24,
                                child: isLiked
                                          ? SvgPicture.asset('assets/icons/thumbs_up_fill.svg')
                                          : SvgPicture.asset('assets/icons/thumbs_up.svg'),
                              ),
                              SizedBox(width: 4,),
                              Container(
                                constraints: BoxConstraints(minWidth: 17, minHeight: 16),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: C1_12px_M(text: '$likesNum',color: PeeroreumColor.gray[600])
                                  )
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8,),
                        Row(
                          children: [
                            Container(
                              height: 24,
                              width: 24,
                              child: SvgPicture.asset('assets/icons/chat_drop_dots.svg'),
                            ),
                            SizedBox(width: 4,),
                            Container(
                              constraints: BoxConstraints(minWidth: 17, minHeight: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: C1_12px_M(text: '$commentsNum',color: PeeroreumColor.gray[600])
                                )
                            ),
                        ],)
                      ],
                    ),
                    SizedBox(height: 16,)
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
                child: selectedDatas != null ?
                  Container(
                    color: PeeroreumColor.primaryPuple[50]!,
                    child: MakeComment(
                    index: 0,
                    id: selectedDatas["id"],
                    hasParent: -1,
                    grade: selectedDatas['memberProfileDto']['grade'], 
                    profileImage: selectedDatas['memberProfileDto']['profileImage'],
                    name: selectedDatas['memberProfileDto']['nickname'], 
                    isQwselected: isQselected, 
                    isChosen: selectedDatas["isSelected"], 
                    comment: selectedDatas["content"],
                    commentImage: selectedDatas["images"],
                    createdTime: selectedDatas["createdTime"],
                    isLiked: selectedDatas["isLiked"],
                    likesNum: selectedDatas["likes"],
                    commentsNum: selectedDatas["comments"],
                    isDeleted: selectedDatas["isDeleted"],
                    updateData: fetchDatas,
                    qWriter: name,),
                  )
                  :Container(),
              ),
              //--대안--
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: (commentDatas ?? <dynamic>[]) // commentDatas가 null이면 빈 리스트를 사용합니다.
                    .map<Widget>((commentData) {
                      return MakeComment(
                        index: commentDatas.indexOf(commentData),
                        id: commentData["id"],
                        hasParent: commentData["parentId"],
                        grade: commentData['memberProfileDto']['grade'], 
                        profileImage: commentData['memberProfileDto']['profileImage'],
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
                        updateData: fetchDatas,
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    margin: EdgeInsets.only(top: 8, right: 8),
                    width: 24,
                    height: 24,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _image = null;
                          if(comment == ""){
                            isSubmittable = false;
                          }
                        });
                      },
                      child: Opacity(
                        opacity: 0.4,
                        child: SvgPicture.asset('assets/icons/x_circle.svg')
                        ),
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
                )
              )
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(
                        minHeight: 48
                      ),
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
                              width: MediaQuery.of(context).size.width-108,
                              child: TextFormField(
                                      focusNode: _focusNode,
                                      controller: _textController,
                                      style: TextStyle(
                                        //height: 1.0,
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400
                                      ),
                                      maxLines: _maxLines,
                                      cursorColor: PeeroreumColor.gray[600],
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        hintText: (selectedParent == -1) ?"댓글을 입력하세요" :"대댓글을 입력하세요",
                                        hintStyle: TextStyle(
                                          color: PeeroreumColor.gray[600],
                                          fontFamily: 'Pretendard',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          //height: 24/14,
                                        )
                                      ),
                                      onChanged: (value) {
                                        comment = value;
                                        final lines = textlines(value);
                                        setState(() {
                                          if (comment != "" || _image != null){
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
                              if(isSubmittable){
                                postAnswer();
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  fetchIeduAnswerData();
                                });
                              }
                            },
                            child: Container(
                              height: 24,
                              child: Center(
                                child: T5_14px(text: '등록',
                                color: isSubmittable==false ? PeeroreumColor.gray[500] :PeeroreumColor.primaryPuple[400],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                ),
                SizedBox(height: 8,),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if(_image == null){
                          showImagePickerSheet();
                        } else{
                          Fluttertoast.showToast(msg: "댓글은 파일 최대 1개까지만 첨부 가능합니다.");
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            child: SvgPicture.asset('assets/icons/camera3.svg',
                            color: PeeroreumColor.gray[500],),
                          ),
                          SizedBox(width: 4,),
                          T4_16px(text: '사진 첨부', color: PeeroreumColor.gray[500],)
                        ],
                      ),
                    ),
                    SizedBox(width: 16,),
                    GestureDetector(
                      onTap: () async{
                        if(_image == null){
                          final dynamic whiteboardImage = await Navigator.push(context, MaterialPageRoute(builder: (context){
                            return WhiteboardIedu();
                          }));
                          setState(() {
                            _image = whiteboardImage;
                            isSubmittable = true;
                          });
                        } else{
                          Fluttertoast.showToast(msg: "댓글은 파일 최대 1개까지만 첨부 가능합니다.");
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            child: SvgPicture.asset('assets/icons/notepad.svg',
                            color: PeeroreumColor.gray[500],),
                          ),
                          SizedBox(width: 4,),
                          T4_16px(text: '화이트 보드', color: PeeroreumColor.gray[500],)
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 21,)
            ]),
          ),
        ],
      ),
    );
  }

  void takeFromCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
        isSubmittable = true;
      });
    } else {
      // 이미지 선택이 취소되었을 때의 처리
      print('Image selection cancelled');
    }
  }

  void takeFromGallery() async {
    final XFile? image  = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        print("리스트에 이미지 저장");
        _image = image;
        isSubmittable = true;
      });
    }
  }

  void showImagePickerSheet() {
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
                              backgroundColor: MaterialStateProperty.all(
                                  PeeroreumColor.primaryPuple[400]),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(12)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
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
                              backgroundColor: MaterialStateProperty.all(
                                  PeeroreumColor.primaryPuple[400]),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(12)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
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
  deleteQuestionBottomSheet(writerName) {
      var isMyQuestion = writerName == nickname;
      return Container(
      decoration: BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
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
                  margin: const EdgeInsets.fromLTRB(0, 16, 0, 41),
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
                //Fluttertoast.showToast(msg: '준비 중입니다.');
                Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => 
                      Report(data: "[내가해냄] 내가 해냄 질문 신고\n"
                                    +"날짜 : $date\n"
                                    +"질문 아이디 : $id\n"
                                    +"업로드한 사람 : $name\n",)));
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 16, 0, 41),
                height: 56,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
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

  confirmQuestionDeleteMessage() {
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
                  "질문을 삭제하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(
                  height: 4,
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
                          int count = 0;
                          Navigator.of(context).popUntil((route) {
                            // pop할 경로의 개수를 count 변수를 사용하여 관리
                            bool shouldPop = count == 2;
                            count++;
                            return shouldPop;
                          });
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
                          deleteQuestion();
                           Navigator.pushNamedAndRemoveUntil(context, '/home/iedu', (route) => false);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
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

  Future<void> postAnswer() async {
    var dio = Dio();
    var formData = FormData();

    var IeduAnswerMap = <String, dynamic>{
      'content': _textController.text,
      'questionId': '$id',
      'parentAnswerId': '$selectedParent'
    };

    formData = FormData.fromMap(IeduAnswerMap);

    if(_image != null){
      var file = await MultipartFile.fromFile(_image!.path);
      formData.files.add(MapEntry('files', file));
    }

    dio.options.contentType = 'multipart/form-data';
    dio.options.headers = {'Authorization': 'Bearer $token'};

    var response = await dio.post('${API.hostConnect}/answer', data: formData);

    if (response.statusCode == 200) {
      fetchDatas();
      setState(() {
        _image = null; 
        _textController.clear();
        _maxLines = null;
        isSubmittable=false;
        selectedParent = -1;
      });
    } else {
      Fluttertoast.showToast(msg: '잠시 후에 다시 시도해 주세요.');
    }
  }

  int textlines(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
                                  height: 1.0,
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400
                                ),),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(minWidth: 0, maxWidth: MediaQuery.of(context).size.width-108);

    List<LineMetrics> countLines = textPainter.computeLineMetrics();
    return countLines.length;
  }

  Future<void> postBookmark() async{
    if(isBookmarked == false){
      http.post(
        Uri.parse('${API.hostConnect}/bookmark/question/$id'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        ).then((response) {
      if (response.statusCode == 200) {
          print('북마크 요청이 성공했습니다.');
          print('응답: ${response.body}');
        
          fetchDatas();
      } else if(response.statusCode == 404){
        Fluttertoast.showToast(msg: '존재하지 않는 질문입니다.');
        print(response.body);
      }else {
        print('북마크 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      // 요청 과정에서 오류가 발생한 경우 처리
      print('오류 발생: $error');
    });
    }
    else if(isBookmarked == true){
      http.delete(
        Uri.parse('${API.hostConnect}/bookmark/question/$id'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        ).then((response) {
      if (response.statusCode == 200) {
          print('북마크 삭제 요청이 성공했습니다.');
          print('응답: ${response.body}');
      
          fetchDatas();
      } else if(response.statusCode == 404){
        Fluttertoast.showToast(msg: '존재하지 않는 질문입니다.');
        print(response.body);
      }else {
        print('북마크 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      // 요청 과정에서 오류가 발생한 경우 처리
      print('오류 발생: $error');
    });
    }
  }

  Future<void> postQLike() async{
    if(isLiked == false){
      http.post(
        Uri.parse('${API.hostConnect}/like/question/$id'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        ).then((response) {
      if (response.statusCode == 200) {
          print('질문 좋아요 요청이 성공했습니다.');
          print('응답: ${response.body}');
          
          fetchDatas();
      } else if(response.statusCode == 404){
        Fluttertoast.showToast(msg: '존재하지 않는 질문입니다.');
        print(response.body);
      }else {
        print('질문 좋아요 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      // 요청 과정에서 오류가 발생한 경우 처리
      print('오류 발생: $error');
    });
    }
    else if(isLiked == true){
      http.delete(
        Uri.parse('${API.hostConnect}/like/question/$id'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        ).then((response) {
      if (response.statusCode == 200) {
          print('질문 좋아요 삭제 요청이 성공했습니다.');
          print('응답: ${response.body}');
          
          fetchDatas();
      } else if(response.statusCode == 404){
        Fluttertoast.showToast(msg: '존재하지 않는 질문입니다.');
        print(response.body);
      }else {
        print('질문 좋아요 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      // 요청 과정에서 오류가 발생한 경우 처리
      print('오류 발생: $error');
    });
    }
    fetchIeduQuestionData();
  }
  Future<void> deleteQuestion() async{
    http.delete(
        Uri.parse('${API.hostConnect}/question/$id'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        ).then((response) {
      if (response.statusCode == 200) {
          print('질문 삭제 요청이 성공했습니다.');
          print('응답: ${response.body}');

          fetchDatas();
      } else if(response.statusCode == 404){
        Fluttertoast.showToast(msg: '존재하지 않는 질문입니다.');
        print(response.body);
      }else {
        print('질문 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      // 요청 과정에서 오류가 발생한 경우 처리
      print('오류 발생: $error');
    });
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
    var nickname, token;

    @override
    void initState() {
      super.initState();
      createdTime =  widget.createdTime ?? DateTime.now().toString();
      getData();
    }
    Future<void>getData() async{
      nickname = await FlutterSecureStorage().read(key: "nickname");
      token = await FlutterSecureStorage().read(key: "accessToken");
      setState(() {
      });
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: widget.hasParent == -1
        ?EdgeInsets.symmetric(vertical: 16)
        :EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        margin: widget.hasParent == -1
        ?EdgeInsets.symmetric(horizontal: 20)
        :null,
        decoration: widget.hasParent == -1 && widget.index != 0
        ?BoxDecoration(
          border: Border(
                    top: BorderSide(
                      color: PeeroreumColor.gray[100]!,
                      width: 1.0,
                    )
                  ),
        )
        :null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.hasParent != -1,
              child: Container(
                margin: EdgeInsets.only(right: 8),
                child: SvgPicture.asset('assets/icons/forward.svg',
                color: PeeroreumColor.gray[600],),
              ),
            ),
            Container(
              padding: widget.hasParent == -1
              ?EdgeInsets.zero
              :EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              margin: widget.hasParent == -1
              ?EdgeInsets.zero
              :EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: widget.hasParent == -1
                ?Colors.transparent
                :PeeroreumColor.gray[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: widget.hasParent == -1
                    ?MediaQuery.of(context).size.width -40
                    :MediaQuery.of(context).size.width -112,
                    child: Visibility(
                      visible: widget.isDeleted == false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: widget.hasParent == -1
                            ?MediaQuery.of(context).size.width -40 -34
                            :MediaQuery.of(context).size.width -112 -34,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if(widget.isDeleted == false){
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            MyPageProfile(widget.name, nickname == widget.name)));
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
                                              ? PeeroreumColor.gradeColor[widget.grade]!
                                              : Color.fromARGB(255, 186, 188, 189)),
                                    ),
                                    child: Container(
                                      height: 26,
                                      width: 26,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 2,
                                            color: PeeroreumColor.white.withOpacity(0.0),
                                          )),
                                      child: Container(
                                        height: 24,
                                        width: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: widget.profileImage != null
                                              ? DecorationImage(
                                                  image: Image.network(widget.profileImage).image,
                                                  fit: BoxFit.cover)
                                              : DecorationImage(
                                                  image: AssetImage(
                                                  'assets/images/user.jpg',
                                                )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8,),
                                Flexible(
                                  child: B4_14px_M(
                                    text: widget.name,
                                    )),
                                    if (nickname == widget.name && widget.isDeleted == false)
                                      Text(' (나)',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                    ),),
                                SizedBox(width: 12,),
                                Visibility(
                                  visible: (widget.isQwselected == false) && (nickname == widget.qWriter) && (widget.qWriter != widget.name),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final _dState = context.findAncestorStateOfType<_DetailIeduState>();
                                      if(await checkSelect()) {
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
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      width: 57,
                                      height: 24,
                                      child: Center(child: C1_12px_Sb(text: '채택하기', color: PeeroreumColor.white,)),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: widget.isQwselected == true && widget.isChosen == true,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: PeeroreumColor.primaryPuple[400],
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      width: 57,
                                      height: 24,
                                      child: Center(child: C1_12px_Sb(text: '채택완료', color: PeeroreumColor.white,)),
                                    ),
                                ),
                                Visibility(
                                  visible: widget.isQwselected == true && widget.isChosen == false && nickname == widget.qWriter,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: PeeroreumColor.gray[300],
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      width: 57,
                                      height: 24,
                                      child: Center(child: C1_12px_Sb(text: '채택하기', color: PeeroreumColor.white,)),
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
                                      return deleteAnswerBottomSheet(widget.name, widget.id);
                                    });
                              },
                              child: Container(
                                width: 18,
                                height: 18,
                                child: SvgPicture.asset('assets/icons/icon_dots_mono.svg'),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Container(
                    width: widget.hasParent == -1
                    ?MediaQuery.of(context).size.width -40
                    :MediaQuery.of(context).size.width -112,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: widget.isDeleted || (!widget.isDeleted && widget.comment.toString().isNotEmpty),
                          child: B4_14px_R(text: widget.isDeleted
                          ? '삭제된 댓글입니다.'
                          : widget.comment,
                          color: widget.isDeleted
                                    ? PeeroreumColor.gray[500]
                                    : null,),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 4,),
                  if(widget.commentImage != null && widget.commentImage!.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImageDetailIedu(imageList: widget.commentImage!),
                          ));
                      },
                      child: Container(
                        width: widget.hasParent == -1
                        ?MediaQuery.of(context).size.width -40
                        :MediaQuery.of(context).size.width -112,
                        height: 180,
                        decoration: widget.commentImage != null && widget.commentImage!.isNotEmpty
                        ?BoxDecoration(
                          border: Border.all(color: PeeroreumColor.gray[100]!),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                                    image: Image.network(widget.commentImage!.first).image,
                                    fit: BoxFit.cover,
                                  ),
                        )
                        :null,
                      ),
                    ),
                  SizedBox(height: 8,),
                  Visibility(
                    visible: widget.isDeleted == false,
                    child: Row(
                      children: [
                        Visibility(
                          visible: createdTime.toString().substring(0,4) != DateTime.now().toString().substring(0,4),
                          child: Row(
                            children: [
                              C1_12px_M(text: createdTime.toString().substring(0,4),color: PeeroreumColor.gray[400],),
                              SizedBox(width: 2,),
                              C1_12px_M(text: '/',color: PeeroreumColor.gray[400]),
                              SizedBox(width: 2,)
                            ],
                        )),
                        C1_12px_M(text: createdTime.toString().substring(5,7),color: PeeroreumColor.gray[400]),
                        SizedBox(width: 2,),
                        C1_12px_M(text: '/',color: PeeroreumColor.gray[400]),
                        SizedBox(width: 2,),
                        C1_12px_M(text: createdTime.toString().substring(8,10),color: PeeroreumColor.gray[400]),
                        SizedBox(width: 4,),
                        C1_12px_M(text: createdTime.toString().substring(11,13),color: PeeroreumColor.gray[400]),
                        SizedBox(width: 2,),
                        C1_12px_M(text: ':',color: PeeroreumColor.gray[400]),
                        SizedBox(width: 2,),
                        C1_12px_M(text: createdTime.toString().substring(14,16),color: PeeroreumColor.gray[400]),
                              
                        SizedBox(width: 8,),
                        C1_12px_M(text: '|',color: PeeroreumColor.gray[200]),
                        SizedBox(width: 8,),
                              
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            postALike(widget.id, widget.isLiked);
                            print('${widget.id}, ${widget.isLiked}');
                            widget.updateData();
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 18,
                                width: 18,
                                child: widget.isLiked
                                          ? SvgPicture.asset('assets/icons/thumbs_up_fill.svg')
                                          : SvgPicture.asset('assets/icons/thumbs_up.svg'),
                              ),
                              SizedBox(width: 4,),
                              Container(
                                constraints: BoxConstraints(minWidth: 17, minHeight: 16),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: C1_12px_M(text: '${widget.likesNum}',color: PeeroreumColor.gray[600])
                                  )
                              ),
                            ],
                          ),
                        ),
                              
                        Visibility(
                          visible: widget.hasParent == -1,
                          child: GestureDetector(
                            onTap: () {
                            final _dState = context.findAncestorStateOfType<_DetailIeduState>();
                            if(_dState != null){
                              _dState.setState(() {
                                _dState.selectedParent = widget.id;
                                FocusScope.of(context).requestFocus(_dState._focusNode);
                                print(widget.id);
                              });
                            }
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8,),
                                C1_12px_M(text: '|',color: PeeroreumColor.gray[200]),
                                SizedBox(width: 8,),
                                Container(
                                  height: 18,
                                  width: 18,
                                  child: SvgPicture.asset('assets/icons/chat_drop_dots.svg'),
                                ),
                                SizedBox(width: 4,),
                                Container(
                                  constraints: BoxConstraints(minWidth: 17, minHeight: 16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: C1_12px_M(text: '${widget.commentsNum}',color: PeeroreumColor.gray[600])
                                    )
                                ),
                            ],),
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
      decoration: BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
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
                  margin: const EdgeInsets.fromLTRB(0, 16, 0, 41),
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
                //Fluttertoast.showToast(msg: '준비 중입니다.');
                Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => 
                      Report(data: "[내가해냄] 내가 해냄 답변 신고\n"
                                    +"날짜 : ${widget.createdTime}\n"
                                    +"답변 아이디 : ${widget.id}\n"
                                    +"업로드한 사람 : ${widget.name}\n",)));
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 16, 0, 41),
                height: 56,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
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

    confirmCommentDeleteMessage(commentID) {
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
                  "댓글을 삭제하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(
                  height: 4,
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
                          int count = 0;
                          Navigator.of(context).popUntil((route) {
                            // pop할 경로의 개수를 count 변수를 사용하여 관리
                            bool shouldPop = count == 2;
                            count++;
                            return shouldPop;
                          });
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
                          deleteAnswer(commentID);
                          widget.updateData();
                          int count = 0;
                          Navigator.of(context).popUntil((route) {
                            // pop할 경로의 개수를 count 변수를 사용하여 관리
                            bool shouldPop = count == 2;
                            count++;
                            return shouldPop;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.error,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
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

    Future<void> postALike(answerID, answerLike) async{
    if(answerLike== false){
      http.post(
        Uri.parse('${API.hostConnect}/like/answer/$answerID'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        ).then((response) {
      if (response.statusCode == 200) {
          print('답변 좋아요 요청이 성공했습니다.');
          print('응답: ${response.body}');
          setState(() {
          });
      } else if(response.statusCode == 404){
        Fluttertoast.showToast(msg: '존재하지 않는 질문입니다.');
        print(response.body);
      }else {
        print('답변 좋아요 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      // 요청 과정에서 오류가 발생한 경우 처리
      print('오류 발생: $error');
    });
    }
    else if(answerLike == true){
      http.delete(
        Uri.parse('${API.hostConnect}/like/answer/$answerID'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        ).then((response) {
      if (response.statusCode == 200) {
          print('답변 좋아요 삭제 요청이 성공했습니다.');
          print('응답: ${response.body}');
          setState(() {
          });
      } else if(response.statusCode == 404){
        Fluttertoast.showToast(msg: '존재하지 않는 질문입니다.');
        print(response.body);
      }else {
        print('답변 좋아요 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      // 요청 과정에서 오류가 발생한 경우 처리
      print('오류 발생: $error');
    });
    }
  }

  Future<void> deleteAnswer(answerID) async{
    http.delete(
        Uri.parse('${API.hostConnect}/answer/$answerID'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        ).then((response) {
      if (response.statusCode == 200) {
          print('답변 삭제 요청이 성공했습니다.');
          print('응답: ${response.body}');
          setState(() {
          });
          
      } else if (response.statusCode == 403) {
        var code403 = jsonDecode(utf8.decode(response.bodyBytes))['data'];
        if(code403 == "채택된 답변은 삭제할 수 없습니다."){
          Fluttertoast.showToast(msg: '채택된 답변은 삭제할 수 없습니다.');
        } else{
          Fluttertoast.showToast(msg: '권한이 없습니다.');
        }
        
          print('응답: ${response.body}');
          setState(() {
          });}
      else if(response.statusCode == 404){
        Fluttertoast.showToast(msg: '존재하지 않는 질문입니다.');
        print(response.body);
      }else {
        print('답변 삭제 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      // 요청 과정에서 오류가 발생한 경우 처리
      print('오류 발생: $error');
    });
  }

  Future<void> selectAnswer() async{
    print(widget.id);
    http.put(
      
      Uri.parse('${API.hostConnect}/answer/${widget.id}/select'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
    ).then((response) {
    // 서버로부터 받은 응답 처리
    if (response.statusCode == 200) {
      print('답변 채택 요청이 성공했습니다.');
      print('응답: ${response.body}');
    } else {
      print('답변 채택 요청이 실패했습니다. 오류 코드: ${response.statusCode}');
    }
  }).catchError((error) {
    // 요청 과정에서 오류가 발생한 경우 처리
    print('오류 발생: $error');
  });

  }

  checkSelect() async {
    return await showDialog(
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
                  "해당 댓글을 채택하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(
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
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
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
                          Navigator.pop(context, true);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.primaryPuple[400],
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '채택',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.white
                          ),
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
