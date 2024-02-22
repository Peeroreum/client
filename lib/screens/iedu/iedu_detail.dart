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
import 'package:peeroreum_client/screens/iedu/iedu_detail_image.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/screens/iedu/iedu_whiteboard.dart';

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

  int? _maxLines = 1; // 현재 줄 수
  int _visibleLines = 1; // 화면에 보이는 줄 수


  dynamic questionDatas='';
  dynamic profileDatas ='';

  dynamic profileImage = '';
  dynamic grade;
  dynamic name = '';
  dynamic date = DateTime.now().toString();
  dynamic title = '';
  dynamic contents = '';
  List<dynamic> questionImage = [];
  int currentPage = 1;
  dynamic isLiked = false;
  dynamic isBookmarked = false;
  dynamic likesNum = 0;
  dynamic commentsNum = 0;
  dynamic isQselected;

  int selectedParent = -1;

  //----------------
  String comment = "";
  bool isSubmittable = false;

  final ImagePicker picker = ImagePicker();
  XFile? _image;
  //----------------
  dynamic commentDatas;
  
  Future<void>fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    nickname = await FlutterSecureStorage().read(key: "nickname");

    await fetchIeduQuestionData();
    await fetchIeduAnswerData();
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
    } else if(inIeduQuestionResult.statusCode == 404){
      // profileImage = null;
      // grade = null;
      // name = "(삭제)";
      // title = "작성자에 의해 삭제된 질문입니다";
      // contents = "(삭제)";
      // questionImage = [];
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: "존재하지 않는 질문입니다.");
    }
    else{
      print("에러${inIeduQuestionResult.statusCode}");
    }
  }

  fetchIeduAnswerData() async {
    var inIeduAnswerResult = await http.get(
        Uri.parse('${API.hostConnect}/answer?questionId=$id&page'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (inIeduAnswerResult.statusCode == 200) {
      commentDatas = jsonDecode(utf8.decode(inIeduAnswerResult.bodyBytes))['data'];
    } else {
      print("에러${inIeduAnswerResult.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    _textController= TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
        child: Scaffold(
          appBar: appbarWidget(),
          body: FutureBuilder(
            future: fetchDatas(), 
            builder: (context, snapshot){
              // if (snapshot.connectionState == ConnectionState.waiting) {
              // return Center(child: CircularProgressIndicator());
              // } else if (snapshot.hasError) {
              //   // 에러 발생 시
              //   return Center(child: Text('Error: ${snapshot.error}'));
              // } else {
              //   return RefreshIndicator(
              //     onRefresh: () => fetchDatas(),
              //     color: PeeroreumColor.primaryPuple[400],
              //     child: bodyWidget(),
              //   );
              // }
              return bodyWidget();
            }),
        ),
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
          Navigator.of(context).pop();
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
                  child: isBookmarked 
                      ?SvgPicture.asset('assets/icons/bookmark_fill.svg',
                          color: PeeroreumColor.black)
                      :SvgPicture.asset('assets/icons/bookmark.svg',
                          color: PeeroreumColor.black),
                ),
                onTap: () {
                  setState(() {
                    isBookmarked = !isBookmarked;
                  });
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
                onTap: () {
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
                            Container(
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
                                          image: NetworkImage(profileImage),
                                          fit: BoxFit.cover)
                                      : DecorationImage(
                                          image: AssetImage(
                                          'assets/images/user.jpg',
                                        )),
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
                          ],
                        ),
                        Row(
                          children: [
                            Visibility(
                              visible: false,
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
                        var imageUrl = i.toString();
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
                            setState(() {
                              if (isLiked) {
                                likesNum -= 1;
                              } else {
                                likesNum += 1;
                              }
                              isLiked = !isLiked;
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
                                  child: C1_12px_M(text: '$likesNum',)
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
                                child: C1_12px_M(text: '$commentsNum',)
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
                        commentsNum: commentData["comments"]
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width-108,
                              child: TextFormField(
                                      controller: _textController,
                                      style: TextStyle(
                                        height: 24/14,
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
                                          height: 24/14
                                        )
                                      ),
                                      onChanged: (value) {
                                        comment = value;
                                        final lines = textlines(value);
                                        setState(() {
                                          if (comment != ""){
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
                              postAnswer();
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
                                  height: 24/14,
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
      this.isDeleted,
    }) : super(key: key);
  
    @override
    State<MakeComment> createState() => _MakeCommentState();
  }
  
  class _MakeCommentState extends State<MakeComment> {
    String createdTime = DateTime.now().toString();
    bool isLiked = false;
    int likesNum = 0;
    int commentsNum = 0;
  
    @override
    void initState() {
      super.initState();
      createdTime =  widget.createdTime ?? DateTime.now().toString();
      isLiked = widget.isLiked ?? false;
      likesNum = widget.likesNum ?? 0;
      commentsNum = widget.commentsNum ?? 0;
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
                              Container(
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
                                              image: NetworkImage(widget.profileImage),
                                              fit: BoxFit.cover)
                                          : DecorationImage(
                                              image: AssetImage(
                                              'assets/images/user.jpg',
                                            )),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8,),
                              Flexible(
                                child: B4_14px_M(text: widget.name)),
                              SizedBox(width: 12,),
                              Visibility(
                                visible: widget.isQwselected == false,
                                child: GestureDetector(
                                  onTap: () {
                                    print('눌림');
                                    final _dState = context.findAncestorStateOfType<_DetailIeduState>();
                                    if(_dState != null){
                                      _dState.setState(() {
                                        _dState.isQselected = true;
                                        print('작동 하는 거였나');
                                      });
                                    } else{
                                      print('왜 작동 안하냐');
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
                            ],
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          child: SvgPicture.asset('assets/icons/icon_dots_mono.svg'),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8,),
                  Column(
                    children: [
                      B4_14px_R(text: widget.comment)
                    ],
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
                        decoration: BoxDecoration(
                          border: Border.all(color: PeeroreumColor.gray[100]!),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                                    image: NetworkImage(widget.commentImage!.first),
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),
                  SizedBox(height: 8,),
                  Row(
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
                          setState(() {
                            if (isLiked) {
                              likesNum -= 1;
                            } else {
                              likesNum += 1;
                            }
                            isLiked = !isLiked;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 18,
                              width: 18,
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
            
                      Visibility(
                        visible: widget.hasParent == -1,
                        child: GestureDetector(
                          onTap: () {
                          final _dState = context.findAncestorStateOfType<_DetailIeduState>();
                          if(_dState != null){
                            _dState.setState(() {
                              _dState.selectedParent = widget.id;
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
                                  child: C1_12px_M(text: '$commentsNum',color: PeeroreumColor.gray[600])
                                  )
                              ),
                          ],),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
