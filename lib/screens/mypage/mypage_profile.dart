// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, deprecated_member_use, non_constant_identifier_names, avoid_print, sized_box_for_whitespace, must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:custom_widget_marquee/custom_widget_marquee.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/data/VisitCount.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/mypage/mypage.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile_friend.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyPageProfile extends StatefulWidget {
  String nickname;
  bool am_i;
  MyPageProfile(this.nickname, this.am_i);

  @override
  State<MyPageProfile> createState() => _MyPageProfileState(nickname, am_i);
}

class _MyPageProfileState extends State<MyPageProfile> {
  String nickname;
  bool am_i;
  _MyPageProfileState(this.nickname, this.am_i);
  FlutterSecureStorage storage = FlutterSecureStorage();
  var token;
  final nickname_controller = TextEditingController();
  List<dynamic> inroom_datas = [];
  List<String> dropdownGradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> dropdownSubjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];
  late bool is_friend;
  List<dynamic> badges = [];
  var grade;
  var profileImage;
  var backgroundImage;
  var friendNumber;
  var withPeerDay = 0;
  Member member = Member();
  final change_nickname_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDatas();
    is_friend = false;
  }

  Future<void> fetchDatas() async {
    token = await storage.read(key: "accessToken");
    withPeerDay = await VisitCount.getVisitCount();
    var inWeduResult = await http.get(
        Uri.parse('${API.hostConnect}/wedu/in?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (inWeduResult.statusCode == 200) {
      inroom_datas = jsonDecode(utf8.decode(inWeduResult.bodyBytes))['data'];
      //print("내같이방 성공 ${inWeduResult.statusCode}");
    } else {
      print("내같이방 에러 ${inWeduResult.statusCode}");
    }

    var profileinfo = await http.get(
        Uri.parse('${API.hostConnect}/member/profile?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (profileinfo.statusCode == 200) {
      var data = jsonDecode(utf8.decode(profileinfo.bodyBytes))['data'];
      grade = data["grade"];
      friendNumber = data["friendNumber"];
      profileImage = data["profileImage"];
      backgroundImage = data["backgroundImage"];
      is_friend = data['following'];
    }
  }

  profileImageAPI(var _image) async {
    var image = await MultipartFile.fromFile(_image!.path);
    var imageMap = <String, dynamic>{'profileImage': image};
    var dio = Dio();
    dio.options.contentType = 'multipart/form-data';
    dio.options.headers = {'Authorization': 'Bearer $token'};
    FormData imageData = FormData.fromMap(imageMap);
    var profileChange = await dio
        .put('${API.hostConnect}/member/change/profileImage', data: imageData);
    if (profileChange.statusCode == 200) {
      print("프로필이미지 성공 ${profileChange.statusMessage}");
      var data = profileChange.data['data'];
      setState(() {
        profileImage = data;
      });
      if(am_i) {
        await storage.write(key: 'profileImage', value: profileImage);
      }
      Fluttertoast.showToast(msg: "프로필 이미지가 성공적으로 변경되었습니다.");
    } else {
      print("프로필이미지 ${profileChange.statusMessage}");
    }
  }

  backgroundImageAPI(var _image1) async {
    var image1 = await MultipartFile.fromFile(_image1!.path);
    var imageMap1 = <String, dynamic>{'profileImage': image1};
    var dio = Dio();
    dio.options.contentType = 'multipart/form-data';
    dio.options.headers = {'Authorization': 'Bearer $token'};
    FormData imageData = FormData.fromMap(imageMap1);
    var backgroundChange = await dio.put(
        '${API.hostConnect}/member/change/backgroundImage',
        data: imageData);
    if (backgroundChange.statusCode == 200) {
      print("배경이미지 성공 ${backgroundChange.statusMessage}");
      var data = backgroundChange.data['data'];
      setState(() {
        backgroundImage = data;
      });
      Fluttertoast.showToast(msg: "배경이미지가 성공적으로 변경되었습니다.");
    } else {
      print("배경이미지 ${backgroundChange.statusMessage}");
    }
  }

  nicknameAPI() async {
    var change_my_nickname = await http.put(
        Uri.parse(
            '${API.hostConnect}/member/change/nickname?nickname=${change_nickname_controller.text}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (change_my_nickname.statusCode == 200) {
      var data = jsonDecode(utf8.decode(change_my_nickname.bodyBytes))["data"];
      setState(() {
        nickname = data;
      });
      if(am_i) {
        await storage.write(key: 'nickname', value: nickname);
      }
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: "닉네임이 성공적으로 변경되었습니다.");
    } else {
      print("닉네임변경 에러${change_my_nickname.statusCode}");
    }
  }

  follow() async {
    //친구 팔로우
    var friendName = await http.post(
        Uri.parse('${API.hostConnect}/member/friend/follow?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (friendName.statusCode == 200) {
      is_friend = true;
      Fluttertoast.showToast(msg: "친구 추가를 완료했어요!");
    } else if (friendName.statusCode == 404) {
      Fluttertoast.showToast(msg: "존재하지 않는 회원입니다.");
    } else if (friendName.statusCode == 400) {
      Fluttertoast.showToast(msg: "본인은 팔로우할 수 없습니다.");
    } else if (friendName.statusCode == 409) {
      Fluttertoast.showToast(msg: "이미 팔로우 중인 회원입니다.");
    } else {
      is_friend = false;
      print("친구팔로 에러${friendName.statusCode}");
    }
    setState(() {

    });
  }

  unfollow() async {
    //친구 언팔로우
    var friendName = await http.delete(
        Uri.parse(
            '${API.hostConnect}/member/friend/unfollow?nickname=$nickname'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (friendName.statusCode == 200) {
      is_friend = false;
      Fluttertoast.showToast(msg: "친구 삭제를 완료했어요!");
    } else {
      is_friend = true;
      print("친구언팔 에러${friendName.statusCode}");
    }
  }

  searchfriend() async {
    var friendName = await http.get(
        Uri.parse(
            '${API.hostConnect}/member/profile?nickname=${nickname_controller.text}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (friendName.statusCode == 200) {
      //check_friend(nickname_controller.text);
      if (nickname_controller.text == nickname) {
        Fluttertoast.showToast(msg: "자신은 영원한 친구입니다.");
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                MyPageProfile(nickname_controller.text, false)));
      }
    } else if (friendName.statusCode == 404) {
      Fluttertoast.showToast(msg: "존재하지 않는 회원입니다.");
    } else {
      print("친구찾기 에러${friendName.statusCode}");
    }
  }

  void check_friend(nickname) async {
    var myfriend = await http
        .get(Uri.parse('${API.hostConnect}/member/friend=$nickname'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (myfriend.statusCode == 200) {
      is_friend = true;
    } else {
      is_friend = false;
      print("친구체크 에러${myfriend.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchDatas(),
          builder: (context, snapshot) {
            return bodyWidget();
          }),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      backgroundColor: PeeroreumColor.white,
      surfaceTintColor: PeeroreumColor.white,
      shadowColor: PeeroreumColor.white,
      elevation: 0.5,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          color: PeeroreumColor.gray[800],
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "프로필",
        style: TextStyle(
            color: PeeroreumColor.black,
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  width: 24,
                  margin: EdgeInsets.only(right: 4),
                  constraints: BoxConstraints(),
                  child: SvgPicture.asset('assets/icons/search.svg',
                      color: PeeroreumColor.black),
                ),
                onTap: () {
                  search_friend();
                },
              ),
              GestureDetector(
                child: Container(
                  width: 24,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  child: SvgPicture.asset(
                    'assets/icons/icon_dots_mono.svg',
                    color: PeeroreumColor.black,
                  ),
                ),
                onTap: () {
                  am_i
                      ? showModalBottomSheet(
                    //'나'일 경우 프로필 수정
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return changeMe();
                    },
                  )
                      : showModalBottomSheet(
                    //다른 사람일 경우 신고하기
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return reportUser();
                    },
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget changeMe() {
    return Flexible(
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: PeeroreumColor.white, // 여기에 색상 지정
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 16, top: 4),
                child: Text(
                  '프로필 관리',
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
                  profileImage_change(context);
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.fromHeight(40),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(0),
                ),
                child: Text(
                  '프로필 사진 변경',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.black,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  nickname_change();
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.fromHeight(40),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(0),
                ),
                child: Text(
                  '닉네임 변경',
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
                  XFile? _image1;
                  final ImagePicker picker1 = ImagePicker();
                  final XFile? pickedFile1 =
                      await picker1.pickImage(source: ImageSource.gallery);
                  if (pickedFile1 != null) {
                    setState(() {
                      _image1 = XFile(pickedFile1.path);
                      if (_image1 != null) {
                        setState(() {
                          backgroundImageAPI(_image1);
                          Navigator.of(context).pop();
                        });
                      }
                    });
                  }
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.fromHeight(40),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(0),
                ),
                child: Text(
                  '배경 사진 변경',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///프로필 사진 변경///
  profileImage_change(BuildContext context) {
    XFile? _image;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(20),
            iconPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: PeeroreumColor.white,
            surfaceTintColor: Colors.transparent,
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "프로필 사진 변경",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.black,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
                        });
                      }
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 2,
                            color: grade != null
                                ? PeeroreumColor.gradeColor[grade]!
                                : Color.fromARGB(255, 186, 188, 189)),
                      ),
                      child: Container(
                        height: 84,
                        width: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: PeeroreumColor.white,
                          ),
                          image: profileImage != null
                              ? (_image != null
                                  ? DecorationImage(
                                      image: FileImage(File(_image!.path)),
                                      //fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: NetworkImage(profileImage),
                                      //fit: BoxFit.cover,
                                    ))
                              : (_image != null
                                  ? DecorationImage(
                                      image: FileImage(File(_image!.path)),
                                      //fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: AssetImage(
                                      'assets/images/user.jpg',
                                    ))),
                        ),
                        child: Align(
                          alignment: Alignment(1.2, 1.2),
                          child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: PeeroreumColor.gray[200],
                                border: Border.all(
                                  color: PeeroreumColor.gray[100]!,
                                  width: 1,
                                ),
                              ),
                              child: SvgPicture.asset('assets/icons/camera.svg')),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
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
                            '닫기',
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
                            if (_image != null) {
                              setState(() {
                                profileImageAPI(_image);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _image != null
                                ? PeeroreumColor.primaryPuple[400]
                                : PeeroreumColor.gray[300],
                            padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '적용하기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: _image != null
                                  ? PeeroreumColor.white
                                  : PeeroreumColor.gray[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          );
        });
      },
    );
  }

  ///////////////////닉네임 변경///////////////////
  bool checkNickname = false;
  bool isDuplicateNickname = false;

  checkDuplicateNickname(String value) async {
    var result = await http.get(
        Uri.parse('${API.hostConnect}/signup/nickname/$value'),
        headers: {'Content-Type': 'application/json'});
    if (result.statusCode == 409) {
      setState(() {
        isDuplicateNickname = true;
      });
    } else {
      isDuplicateNickname = false;
    }
  }

  checkError() {
    if (!checkNickname && change_nickname_controller.text.isNotEmpty) {
      return "한글 2자, 영문/숫자 4자 이상 적어주세요.";
    }
    if (isDuplicateNickname) {
      return "이미 사용 중인 닉네임입니다.";
    }
    return null;
  }

  nickname_change() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
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
                      "닉네임 변경",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: PeeroreumColor.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 72,
                      child: TextFormField(
                        controller: change_nickname_controller,
                        onChanged: (value) {
                          if (change_nickname_controller.text.isNotEmpty) {
                            setState(() {
                              if (change_nickname_controller.text.length >= 2 &&
                                  change_nickname_controller.text.length <= 12) {
                                checkNickname = true;
                              } else {
                                checkNickname = false;
                              }
                            });
                          } else {
                            setState(() {
                              checkNickname = false;
                              isDuplicateNickname = false;
                            });
                          }
                          checkDuplicateNickname(value);
                        },
                        decoration: InputDecoration(
                          hintText: '닉네임은 30일마다 1회만 변경 가능해요.',
                          hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          focusedBorder: checkNickname && !isDuplicateNickname
                              ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: PeeroreumColor.primaryPuple[400]!),
                          )
                              : OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: PeeroreumColor.black,
                            ),
                          ),
                          helperText: checkNickname && !isDuplicateNickname
                              ? "사용 가능한 닉네임입니다."
                              : "언더바(_)를 제외한 특수문자는 사용할 수 없어요.",
                          helperStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: checkNickname && !isDuplicateNickname
                                  ? PeeroreumColor.primaryPuple[400]
                                  : PeeroreumColor.gray[600]),
                          errorText: checkError(),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: PeeroreumColor.error,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: PeeroreumColor.error,
                              )),
                          counterText:
                          '${change_nickname_controller.text.length} / 12',
                          counterStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.gray[600]!),
                        ),
                        cursorColor: PeeroreumColor.gray[600],
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
                              if (checkNickname && !isDuplicateNickname) {
                                checkError();
                                setState(() {
                                  nicknameAPI();
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: checkNickname && !isDuplicateNickname
                                  ? PeeroreumColor.primaryPuple[400]
                                  : PeeroreumColor.gray[300],
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '변경하기',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: checkNickname && !isDuplicateNickname
                                      ? PeeroreumColor.white
                                      : PeeroreumColor.gray[600]),
                            ),
                          ),
                        ),
                      ],
                    )
                      ],
                    )
                ),
            );
          });
        });
  }

  ///유저 신고하기
  Widget reportUser() {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.25 - 26,
      decoration: BoxDecoration(
        color: PeeroreumColor.white, // 여기에 색상 지정
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '신고하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: PeeroreumColor.gray[200],
                height: 1,
              ),
              TextButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "준비 중입니다.");
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.fromHeight(40),
                ),
                child: Text(
                  '${nickname} 신고하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void search_friend() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          iconPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "친구찾기",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                    color: PeeroreumColor.black,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 48,
                  child: TextFormField(
                    controller: nickname_controller,
                    decoration: InputDecoration(
                      hintText: '닉네임을 정확하게 입력해 주세요.',
                      hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: PeeroreumColor.gray[600],
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PeeroreumColor.gray[200]!),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    cursorColor: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(height: 16),
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
                          setState(() {
                            searchfriend();
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.primaryPuple[400],
                          padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '확인',
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

  Widget bodyWidget() {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            myProfile(),
            myWedu(),
          ],
        ),
      ),
    );
  }

  Widget myProfile() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          myinfo(),
          SizedBox(
            height: 16,
          ),
          friends(),
        ],
      ),
    );
  }

  Widget myinfo() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: backgroundImage != null
          ? BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.5), BlendMode.lighten),
                image: NetworkImage(backgroundImage),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)))
          : BoxDecoration(
              color: PeeroreumColor.gray[200],
              borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/color_logo.png', height: 24,),
                  Container(width: 4),
                  Text(
                    '+',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(width: 2),
                  Text(
                    "$withPeerDay",
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 2,
                      color: grade != null
                          ? PeeroreumColor.gradeColor[grade]!
                          : Color.fromARGB(255, 186, 188, 189)),
                ),
                child: Container(
                  height: 84,
                  width: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: PeeroreumColor.white,
                    ),
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
              SizedBox(
                height: 8,
              ),
              Text(
                nickname,
                style: TextStyle(
                  color: PeeroreumColor.gray[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () {
                  if ((is_friend == true) && (am_i == false)) {
                    unfollow();
                    print('친구 언팔로우 프린트 메세지입니다');
                  } else if ((is_friend == false) && (am_i == false)) {
                    follow();
                    print('친구 팔로우 프린트 메세지 입니다');
                  } else if ((is_friend == false) && (am_i == true)) {
                    print('프로필 공유');
                    Fluttertoast.showToast(msg: "복사되었습니다");
                  } else {
                    print('error');
                  }
                  setState(() {

                  });
              },
              style: ButtonStyle(
                  maximumSize: am_i
                      ? MaterialStateProperty.all<Size>(Size(138, 40))
                      : MaterialStateProperty.all<Size>(Size(124, 40)),
                  backgroundColor: am_i
                      ? MaterialStateProperty.all(
                          PeeroreumColor.primaryPuple[400])
                      : (is_friend
                          ? MaterialStateProperty.all(PeeroreumColor.gray[300])
                          : MaterialStateProperty.all(
                              PeeroreumColor.primaryPuple[400])),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  am_i
                      ? SvgPicture.asset(
                          'assets/icons/share.svg',
                          color: PeeroreumColor.white,
                        )
                      : SvgPicture.asset(
                          'assets/icons/plus_user.svg',
                          color: is_friend
                              ? PeeroreumColor.gray[600]
                              : PeeroreumColor.white,
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    am_i ? '프로필 공유' : (is_friend ? '친구 끊기' : '친구 추가'),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: am_i
                          ? PeeroreumColor.white
                          : (is_friend
                              ? PeeroreumColor.gray[600]
                              : PeeroreumColor.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget friends() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MyPageProfileFriend(nickname)));
          },
          child: Container(
            width: 87,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '친구',
                    style: TextStyle(
                      color: PeeroreumColor.gray[800],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    '$friendNumber',
                    style: TextStyle(
                      color: PeeroreumColor.gray[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Fluttertoast.showToast(msg: "준비 중입니다.");
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                  border:
                      Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Row(
                children: [
                  Row(
                    children: [
                      Text(
                        '배지',
                        style: TextStyle(
                          color: PeeroreumColor.gray[800],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${badges.length}개',
                        style: TextStyle(
                          color: PeeroreumColor.gray[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 20),
                      height: 52,
                      child: Badge(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget Badge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
        width: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PeeroreumColor.gray[100],
        ),
    ),
        SizedBox(width: 8,),
        Container(
          width: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PeeroreumColor.gray[100],
          ),
        )
      ],
    );
  }

  Widget myWedu() {
    return Column(
      children: [
        room_body(),
        (inroom_datas.isNotEmpty)
            ? SizedBox(height: 180, child: in_room_body())
            : SizedBox(height: 0),
      ],
    );
  }

  Widget room_body() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "참여 중인 같이방",
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  '${inroom_datas.length}',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                if (am_i == true) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => InWedu()));
                }
              },
              child: Text(
                am_i ? '전체 보기' : "",
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: PeeroreumColor.gray[500],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget in_room_body() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      // shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: inroom_datas.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        int rindex = inroom_datas.length - 1 - index;
        return GestureDetector(
          child: Container(
            width: 150,
            padding: EdgeInsets.fromLTRB(8, 20, 8, 16),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1, color: PeeroreumColor.gray[200]!),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        image: (inroom_datas[rindex]['imagePath'] != null)
                            ? DecorationImage(
                            image: NetworkImage(
                                inroom_datas[rindex]['imagePath']),
                            fit: BoxFit.cover)
                            : DecorationImage(
                            image: AssetImage(
                                'assets/images/example_logo.png')))),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: PeeroreumColor.subjectColor[dropdownSubjectList[
                        inroom_datas[rindex]['subject']]]?[0],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 8),
                        child: Text(
                          dropdownSubjectList[inroom_datas[rindex]['subject']],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: PeeroreumColor.subjectColor[
                            dropdownSubjectList[inroom_datas[rindex]
                            ['subject']]]?[1],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      child: CustomWidgetMarquee(
                        animationDuration: Duration(seconds: 5),
                        pauseDuration: Duration(seconds: 1),
                        directionOption: DirectionOption.oneDirection,
                        child: Text(
                          inroom_datas[rindex]["title"]!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PeeroreumColor.black),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dropdownGradeList[inroom_datas[rindex]["grade"]],
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SvgPicture.asset('assets/icons/dot.svg', color: PeeroreumColor.gray[600],),
                    ),
                    Text('${inroom_datas[rindex]["attendingPeopleNum"]!}명',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SvgPicture.asset('assets/icons/dot.svg', color: PeeroreumColor.gray[600],),
                    ),
                    Text('D-${inroom_datas[rindex]["dday"]!}',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '${inroom_datas[rindex]["progress"]}% 달성', //이후 퍼센티지 수정
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.primaryPuple[400]),
                )
              ],
            ),
          ),
          onTap: () {
            am_i? Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailWedu(inroom_datas[rindex]["id"]))) : null;
          },
        );
      },
    );
  }
}
