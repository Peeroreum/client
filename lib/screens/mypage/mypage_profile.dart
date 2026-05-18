import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peeroreum_client/widgets/custom_image_picker.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:peeroreum_client/model/Member.dart';
import 'package:peeroreum_client/screens/report.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/mypage_profile_friend.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyPageProfile extends StatefulWidget {
  String nickname;
  bool amI;

  MyPageProfile(this.nickname, this.amI, {super.key});

  @override
  State<MyPageProfile> createState() => _MyPageProfileState(nickname, amI);
}

class _MyPageProfileState extends State<MyPageProfile> {
  String nickname;
  bool amI;

  _MyPageProfileState(this.nickname, this.amI);

  FlutterSecureStorage storage = const FlutterSecureStorage();
  final nicknameController = TextEditingController();
  List<dynamic> inRoomData = [];
  List<String> dropdownGradeList = [
    '전체',
    '중1',
    '중2',
    '중3',
    '고1',
    '고2',
    '고3',
    '대학'
  ];
  List<String> dropdownSubjectList = [
    '전체',
    '국어',
    '영어',
    '수학',
    '사회',
    '과학',
    '기타',
    '대학'
  ];
  bool isFriend = false;
  List<dynamic> badges = [];
  var grade;
  var profileImage;
  var backgroundImage;
  var followerNumber;
  var followingNumber;
  var withPeerDay;
  Member member = Member();
  final changeNicknameController = TextEditingController();
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var inWeduResult = await ApiClient().get('/wedu/in?nickname=$nickname');
      if (inWeduResult.statusCode == 200) {
        inRoomData = inWeduResult.data['data'];
      } else {
        print("내같이방 에러 ${inWeduResult.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }

    try {
      var profileInfo =
          await ApiClient().get('/member/profile?nickname=$nickname');
      if (profileInfo.statusCode == 200) {
        var data = profileInfo.data['data'];
        grade = data["grade"];
        followerNumber = data["followerNumber"];
        followingNumber = data["followingNumber"];
        profileImage = data["profileImage"];
        backgroundImage = data["backgroundImage"];
        isFriend = data['following'];
        withPeerDay = data['activeDaysCount'];
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  profileImageAPI(var _image) async {
    var image = await dio.MultipartFile.fromFile(_image!.path);
    var imageMap = <String, dynamic>{'profileImage': image};
    dio.FormData imageData = dio.FormData.fromMap(imageMap);

    try {
      var profileChange =
          await ApiClient().putForm('/member/change/profileImage', imageData);
      if (profileChange.statusCode == 200) {
        print("프로필이미지 성공 ${profileChange.statusMessage}");
        var data = profileChange.data['data'];
        setState(() {
          profileImage = data;
        });
        if (amI) {
          await storage.write(key: 'profileImage', value: profileImage);
        }
        PeeroreumToast.show(context, "프로필 이미지가 변경되었어요.");
      } else {
        print("프로필이미지 ${profileChange.statusMessage}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  deleteProfileImageAPI() async {
    try {
      var result = await ApiClient().put('/member/delete/profileImage');
      if (result.statusCode == 200) {
        setState(() { profileImage = null; });
        await storage.delete(key: 'profileImage');
        PeeroreumToast.show(context, "프로필 이미지가 삭제되었어요.");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  deleteBackgroundImageAPI() async {
    try {
      var result = await ApiClient().put('/member/delete/backgroundImage');
      if (result.statusCode == 200) {
        setState(() { backgroundImage = null; });
        PeeroreumToast.show(context, "배경 이미지가 삭제되었어요.");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  backgroundImageAPI(var _image1) async {
    var image1 = await dio.MultipartFile.fromFile(_image1!.path);
    var imageMap1 = <String, dynamic>{'profileImage': image1};
    dio.FormData imageData = dio.FormData.fromMap(imageMap1);

    try {
      var backgroundChange = await ApiClient()
          .putForm('/member/change/backgroundImage', imageData);
      if (backgroundChange.statusCode == 200) {
        print("배경이미지 성공 ${backgroundChange.statusMessage}");
        var data = backgroundChange.data['data'];
        setState(() {
          backgroundImage = data;
        });
        PeeroreumToast.show(context, "배경 이미지가 변경되었어요.");
      } else {
        print("배경이미지 ${backgroundChange.statusMessage}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  nicknameAPI() async {
    try {
      var changeMyNickname = await ApiClient().put(
          '/member/change/nickname?nickname=${changeNicknameController.text}');
      if (changeMyNickname.statusCode == 200) {
        var data = changeMyNickname.data["data"];
        setState(() {
          nickname = data;
        });
        if (amI) {
          await storage.write(key: 'nickname', value: nickname);
        }
        Get.back();
        PeeroreumToast.show(context, "닉네임이 변경되었어요.");
      } else {
        print("닉네임변경 에러${changeMyNickname.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  follow() async {
    try {
      var friendName =
          await ApiClient().post('/member/friend/follow?nickname=$nickname');
      if (friendName.statusCode == 200) {
        setState(() {
          isFriend = true;
        });
        PeeroreumToast.show(context, "친구 추가를 완료했어요.");
      } else if (friendName.statusCode == 404) {
        PeeroreumToast.show(context, "존재하지 않는 회원이에요.", isError: true);
      } else if (friendName.statusCode == 400) {
        PeeroreumToast.show(context, "자신은 영원한 친구예요.", isError: true);
      } else if (friendName.statusCode == 409) {
        PeeroreumToast.show(context, "이미 팔로우 중인 회원이에요.", isError: true);
      } else {
        setState(() {
          isFriend = false;
        });
        print("친구팔로 에러${friendName.statusCode}");
      }
    } catch (e) {
      PeeroreumToast.show(context, "잠시 후에 다시 시도해 주세요.", isError: true);
    }
    setState(() {});
  }

  unfollow() async {
    try {
      var friendName = await ApiClient()
          .delete('/member/friend/unfollow?nickname=$nickname');
      if (friendName.statusCode == 200) {
        setState(() {
          isFriend = false;
        });

        PeeroreumToast.show(context, "친구 삭제를 완료했어요.");
      } else {
        setState(() {
          isFriend = true;
        });
        print("친구언팔 에러${friendName.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        isFriend = true;
      });
    }
  }

  searchFriend() async {
    try {
      var friendName = await ApiClient()
          .get('/member/profile?nickname=${nicknameController.text}');
      if (friendName.statusCode == 200) {
        //check_friend(nickname_controller.text);
        if (nicknameController.text == nickname) {
          PeeroreumToast.show(context, "자신은 영원한 친구예요.", isError: true);
        } else {
          Get.back();
          Get.to(() => MyPageProfile(nicknameController.text, false),
                  preventDuplicates: false)
              ?.then((value) {
            setState(() {});
            nicknameController.clear();
          });
        }
      } else if (friendName.statusCode == 404) {
        PeeroreumToast.show(context, "존재하지 않는 회원이에요.");
      } else {
        print("친구찾기 에러${friendName.statusCode}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }
  }

  void checkFriend(nickname) async {
    try {
      var myFriend = await ApiClient().get('/member/friend=$nickname');
      if (myFriend.statusCode == 200) {
        setState(() {
          isFriend = true;
        });
      } else {
        setState(() {
          isFriend = false;
        });
        print("친구체크 에러${myFriend.statusCode}");
      }
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        isFriend = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(),
      body: FutureBuilder<void>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(color: PeeroreumColor.white);
            } else if (snapshot.hasError) {
              // 에러 발생 시
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return bodyWidget();
            }
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
          Get.back();
        },
      ),
      title: const Text(
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
                behavior: HitTestBehavior.translucent,
                child: Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  margin: const EdgeInsets.only(right: 4),
                  constraints: const BoxConstraints(),
                  child: SvgPicture.asset('assets/icons/search.svg',
                      color: PeeroreumColor.black),
                ),
                onTap: () {
                  showSearchFriendDialog();
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
                onTap: () {
                  amI
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
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewPadding.bottom > 20
                ? MediaQuery.of(context).viewPadding.bottom
                : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: PeeroreumColor.gray[100],
              onTap: () {
                profileImageChange(context);
              },
              child: const SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    B3_18px_R(text: '프로필 변경'),
                  ],
                ),
              ),
            ),
            if (profileImage != null)
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: PeeroreumColor.gray[100],
                onTap: () async {
                  Get.back();
                  await deleteProfileImageAPI();
                },
                child: SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      B3_18px_R(text: '프로필 삭제', color: PeeroreumColor.error),
                    ],
                  ),
                ),
              ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: PeeroreumColor.gray[100],
              onTap: () {
                setState(() {
                  nicknameChange();
                });
              },
              child: const SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    B3_18px_R(text: '닉네임 변경'),
                  ],
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: PeeroreumColor.gray[100],
              onTap: () async {
                final selected = await showCustomImagePicker(context, multiple: false);
                if (selected == null || selected.isEmpty) return;
                final cropped = await cropImage(context, selected.first);
                if (cropped != null) {
                  backgroundImageAPI(cropped);
                  Get.back();
                }
              },
              child: const SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    B3_18px_R(text: '배경 변경'),
                  ],
                ),
              ),
            ),
            if (backgroundImage != null)
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: PeeroreumColor.gray[100],
                onTap: () async {
                  Get.back();
                  await deleteBackgroundImageAPI();
                },
                child: SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      B3_18px_R(text: '배경 삭제', color: PeeroreumColor.error),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ///프로필 사진 변경///
  profileImageChange(BuildContext context) {
    XFile? image;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              insetPadding: const EdgeInsets.all(20),
              iconPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              backgroundColor: PeeroreumColor.white,
              surfaceTintColor: Colors.transparent,
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "프로필 사진 변경",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: PeeroreumColor.black,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final selected = await showCustomImagePicker(context, multiple: false);
                        if (selected == null || selected.isEmpty) return;
                        final cropped = await cropImage(context, selected.first);
                        if (cropped != null) {
                          setState(() {
                            image = cropped;
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
                                  : const Color.fromARGB(255, 186, 188, 189)),
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
                                ? (image != null
                                    ? DecorationImage(
                                        image: FileImage(File(image!.path)),
                                        //fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: NetworkImage(profileImage),
                                        //fit: BoxFit.cover,
                                      ))
                                : (image != null
                                    ? DecorationImage(
                                        image: FileImage(File(image!.path)),
                                        //fit: BoxFit.cover,
                                      )
                                    : const DecorationImage(
                                        image: AssetImage(
                                        'assets/images/user.jpg',
                                      ))),
                          ),
                          child: Align(
                            alignment: const Alignment(1.2, 1.2),
                            child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: PeeroreumColor.gray[200],
                                  border: Border.all(
                                    color: PeeroreumColor.gray[100]!,
                                    width: 1,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                    'assets/icons/camera.svg')),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Get.back();
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
                              '닫기',
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
                              if (image != null) {
                                setState(() {
                                  profileImageAPI(image);
                                  Get.back();
                                  Get.back();
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: image != null
                                  ? PeeroreumColor.primaryPuple[400]
                                  : PeeroreumColor.gray[300],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
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
                                color: image != null
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
              ));
        });
      },
    );
  }

  ///////////////////닉네임 변경///////////////////
  bool checkNickname = false;
  bool isDuplicateNickname = false;

  nicknameChange() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            checkDuplicateNickname(String value) async {
              try {
                var result = await ApiClient().get('/signup/nickname/$value');
                if (result.statusCode == 200) {
                  setState(() {
                    isDuplicateNickname = false;
                  });
                } else {
                  setState(() {
                    isDuplicateNickname = true;
                  });
                }
              } catch (e) {
                print("Unexpected error: $e");
              }
            }

            checkError() {
              if (!checkNickname && changeNicknameController.text.isNotEmpty) {
                return "한글 2자, 영문/숫자 4자 이상 적어주세요.";
              }
              if (isDuplicateNickname) {
                return "이미 사용 중인 닉네임입니다.";
              }
              return null;
            }

            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              contentPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              backgroundColor: PeeroreumColor.white,
              surfaceTintColor: Colors.transparent,
              content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "닉네임 변경",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 72,
                        child: TextFormField(
                          controller: changeNicknameController,
                          onChanged: (value) {
                            checkDuplicateNickname(value);
                            if (value.isNotEmpty) {
                              setState(() {
                                if (value.length >= 2 && value.length <= 12) {
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
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[a-z|A-Z|0-9|_|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ㆍ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ]'))
                          ],
                          decoration: InputDecoration(
                            hintText: '닉네임은 30일마다 1회만 변경 가능해요.',
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: PeeroreumColor.gray[600],
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: PeeroreumColor.gray[200]!),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                            ),
                            focusedBorder: checkNickname && !isDuplicateNickname
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color:
                                            PeeroreumColor.primaryPuple[400]!),
                                  )
                                : OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
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
                              borderSide: const BorderSide(
                                color: PeeroreumColor.error,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: PeeroreumColor.error,
                                )),
                            counterText:
                                '${changeNicknameController.text.length} / 12',
                            counterStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: PeeroreumColor.gray[600]!),
                          ),
                          cursorColor: PeeroreumColor.gray[600],
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
                                Get.back();
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
                                if (checkNickname && !isDuplicateNickname) {
                                  setState(() {
                                    nicknameAPI();
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    checkNickname && !isDuplicateNickname
                                        ? PeeroreumColor.primaryPuple[400]
                                        : PeeroreumColor.gray[300],
                                padding: const EdgeInsets.symmetric(
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
                  )),
            );
          });
        });
  }

  ///유저 신고하기
  Widget reportUser() {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: PeeroreumColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewPadding.bottom > 20
                ? MediaQuery.of(context).viewPadding.bottom
                : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: PeeroreumColor.gray[100],
              onTap: () {
                Get.to(() =>
                    Report(data: "[프로필] 유저 신고\n" + "유저 아이디 : $nickname\n"));
              },
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    B3_18px_R(
                      text: '$nickname 신고하기',
                      color: PeeroreumColor.error,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSearchFriendDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          iconPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "친구찾기",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                    color: PeeroreumColor.black,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 48,
                  child: TextFormField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      hintText: '닉네임을 정확하게 입력해 주세요.',
                      hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: PeeroreumColor.gray[600],
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: PeeroreumColor.gray[200]!),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: PeeroreumColor.gray[200]!),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    cursorColor: PeeroreumColor.gray[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back();
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
                          setState(() {
                            searchFriend();
                          });
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          myInfo(),
          const SizedBox(
            height: 16,
          ),
          friends(),
        ],
      ),
    );
  }

  Widget myInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: backgroundImage != null
          ? BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    PeeroreumColor.black.withOpacity(0.2), BlendMode.darken),
                image: NetworkImage(backgroundImage),
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(16)))
          : BoxDecoration(
              color: PeeroreumColor.gray[200],
              borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/color_logo.png',
                    height: 24,
                  ),
                  Container(width: 4),
                  Text(
                    '+',
                    style: TextStyle(
                        color: backgroundImage != null
                            ? PeeroreumColor.white
                            : PeeroreumColor.black,
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(width: 2),
                  withPeerDay == null
                      ? Container()
                      : Text(
                          "$withPeerDay",
                          style: TextStyle(
                              color: backgroundImage != null
                                  ? PeeroreumColor.white
                                  : PeeroreumColor.black,
                              fontFamily: 'Pretendard',
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 3,
                      color: grade != null
                          ? PeeroreumColor.gradeColor[grade]!
                          : const Color.fromARGB(255, 186, 188, 189)),
                ),
                child: Container(
                  height: 84,
                  width: 84,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: PeeroreumColor.white.withOpacity(0.0),
                      )),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: profileImage != null
                          ? DecorationImage(
                              image: NetworkImage(profileImage),
                              fit: BoxFit.cover)
                          : const DecorationImage(
                              image: AssetImage(
                              'assets/images/user.jpg',
                            )),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                nickname,
                style: TextStyle(
                  color: backgroundImage != null
                      ? PeeroreumColor.white
                      : PeeroreumColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              key: _shareButtonKey,
              onPressed: () async {
                if ((isFriend == true) && (amI == false)) {
                  unfollow();
                  print('친구 언팔로우 프린트 메세지입니다');
                } else if ((isFriend == false) && (amI == false)) {
                  follow();
                  print('친구 팔로우 프린트 메세지 입니다');
                } else if ((isFriend == false) && (amI == true)) {
                  print('프로필 공유');
                  final available =
                      await ShareClient.instance.isKakaoTalkSharingAvailable();
                  if (available) {
                    try {
                      final uri = await ShareClient.instance.shareCustom(
                        templateId: 102993,
                        templateArgs: {'UserName': nickname},
                      );
                      await ShareClient.instance.launchKakaoTalk(uri);
                      print('카카오톡 공유 완료');
                    } catch (error) {
                      print('카카오톡 공유 실패 $error');
                      final box = _shareButtonKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      final rect = box == null
                          ? null
                          : box.localToGlobal(Offset.zero) & box.size;
                      Share.share(
                        '$nickname 님의 피어오름 프로필\npeeroreum://profile/$nickname',
                        sharePositionOrigin: rect,
                      );
                    }
                  } else {
                    final box = _shareButtonKey.currentContext
                        ?.findRenderObject() as RenderBox?;
                    final rect = box == null
                        ? null
                        : box.localToGlobal(Offset.zero) & box.size;
                    Share.share(
                      '$nickname 님의 피어오름 프로필\npeeroreum://profile/$nickname',
                      sharePositionOrigin: rect,
                    );
                  }
                } else {
                  print('error');
                }
                setState(() {});
              },
              style: ButtonStyle(
                  maximumSize: amI
                      ? MaterialStateProperty.all<Size>(const Size(138, 40))
                      : MaterialStateProperty.all<Size>(const Size(124, 40)),
                  backgroundColor: amI
                      ? MaterialStateProperty.all(
                          PeeroreumColor.primaryPuple[400])
                      : (isFriend
                          ? MaterialStateProperty.all(PeeroreumColor.gray[300])
                          : MaterialStateProperty.all(
                              PeeroreumColor.primaryPuple[400])),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  amI
                      ? SvgPicture.asset(
                          'assets/icons/share.svg',
                          color: PeeroreumColor.white,
                        )
                      : SvgPicture.asset(
                          'assets/icons/plus_user.svg',
                          color: isFriend
                              ? PeeroreumColor.gray[600]
                              : PeeroreumColor.white,
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    amI ? '프로필 공유' : (isFriend ? '친구 끊기' : '친구 추가'),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: amI
                          ? PeeroreumColor.white
                          : (isFriend
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
      children: [
        Expanded(
          child: InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Get.to(() => MyPageProfileFriend(
                    nickname,
                    index: 0,
                  ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                  border:
                      Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: SizedBox(
                height: 25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    T3_18px(
                      text: '팔로워',
                      color: PeeroreumColor.gray[800],
                    ),
                    B3_18px_M(
                      text: followerNumber != null ? '$followerNumber' : '0',
                      color: PeeroreumColor.gray[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Get.to(() => MyPageProfileFriend(
                    nickname,
                    index: 1,
                  ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                  border:
                      Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: SizedBox(
                height: 25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    T3_18px(
                      text: '팔로잉',
                      color: PeeroreumColor.gray[800],
                    ),
                    B3_18px_M(
                      text: followingNumber != null ? '$followingNumber' : '0',
                      color: PeeroreumColor.gray[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 뱃지
        // SizedBox(
        //   width: 8,
        // ),
        // GestureDetector(
        //   onTap: () {
        //     // PeeroreumToast.show(context, "준비 중입니다.");
        //   },
        //   child: Container(
        //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        //     decoration: BoxDecoration(
        //         border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
        //         borderRadius: BorderRadius.all(Radius.circular(8))),
        //     child: Row(
        //       children: [
        //         Column(
        //           children: [
        //             Text(
        //               '배지',
        //               style: TextStyle(
        //                 color: PeeroreumColor.gray[800],
        //                 fontSize: 18,
        //                 fontWeight: FontWeight.w600,
        //                 fontFamily: 'Pretendard',
        //               ),
        //             ),
        //             SizedBox(
        //               height: 4,
        //             ),
        //             Text(
        //               '${badges.length}개',
        //               style: TextStyle(
        //                 color: PeeroreumColor.gray[600],
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w500,
        //                 fontFamily: 'Pretendard',
        //               ),
        //             ),
        //           ],
        //         ),
        //         Container(
        //           padding: EdgeInsets.only(left: 16),
        //           height: 52,
        //           child: Badge(),
        //         )
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget badge() {
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
        const SizedBox(
          width: 8,
        ),
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
        roomBody(),
        (inRoomData.isNotEmpty)
            ? SizedBox(height: 180, child: inRoomBody())
            : const SizedBox(height: 0),
      ],
    );
  }

  Widget roomBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "참여 중인 같이방",
                style: TextStyle(
                    color: PeeroreumColor.gray[800],
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                '${inRoomData.length}',
                style: TextStyle(
                    color: PeeroreumColor.gray[600],
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              if (amI == true) {
                Get.to(const InWedu());
              }
            },
            child: Text(
              amI ? '전체 보기' : "",
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
    );
  }

  Widget inRoomBody() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      // shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: inRoomData.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        int roomIndex = inRoomData.length - 1 - index;
        return GestureDetector(
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: PeeroreumColor.gray[50],
                    border:
                        Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: (inRoomData[roomIndex]['imagePath'] != null)
                        ? Image.network(
                            inRoomData[roomIndex]['imagePath'],
                            fit: BoxFit.cover,
                          )
                        : SvgPicture.asset(
                            'assets/images/default.svg',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        color: PeeroreumColor.subjectColor[dropdownSubjectList[
                            inRoomData[roomIndex]['subject']]]?[0],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 8),
                        child: Text(
                          dropdownSubjectList[inRoomData[roomIndex]['subject']],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: PeeroreumColor.subjectColor[
                                dropdownSubjectList[inRoomData[roomIndex]
                                    ['subject']]]?[1],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    SizedBox(
                      width: 90,
                      height: 24,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          inRoomData[roomIndex]["title"]!,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dropdownGradeList[inRoomData[roomIndex]["grade"]],
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SvgPicture.asset(
                        'assets/icons/dot.svg',
                        color: PeeroreumColor.gray[600],
                      ),
                    ),
                    Text('${inRoomData[roomIndex]["attendingPeopleNum"]!}명',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SvgPicture.asset(
                        'assets/icons/dot.svg',
                        color: PeeroreumColor.gray[600],
                      ),
                    ),
                    Text('D-${inRoomData[roomIndex]["dday"]!}',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PeeroreumColor.gray[600])),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '${inRoomData[roomIndex]["progress"]}% 달성',
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
            amI ? Get.to(() => DetailWedu(inRoomData[roomIndex]["id"])) : null;
          },
        );
      },
    );
  }
}
