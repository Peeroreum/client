import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/widgets/error_retry_view.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/widgets/custom_image_picker.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/designs/peeroreum_typo.dart';
import 'package:peeroreum_client/model/member.dart';
import 'package:peeroreum_client/screens/report.dart';
import 'package:peeroreum_client/screens/wedu/wedu_detail_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:peeroreum_client/screens/mypage/profile_friend/mypage_profile_friend.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyPageProfile extends StatefulWidget {
  final String nickname;
  final bool amI;

  const MyPageProfile(this.nickname, this.amI, {super.key});

  @override
  State<MyPageProfile> createState() => _MyPageProfileState();
}

class _MyPageProfileState extends State<MyPageProfile> {
  late String nickname;
  late bool amI;

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
  int? grade;
  String? profileImage;
  String? backgroundImage;
  int followerNumber = 0;
  int followingNumber = 0;
  int withPeerDay = 0;
  Member member = Member();
  final changeNicknameController = TextEditingController();
  final GlobalKey _shareButtonKey = GlobalKey();

  // 커버가 상단 바 뒤까지 깔리므로, 스크롤로 커버를 지나면 상단 바를 흰색으로 전환
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _appBarSolid = ValueNotifier<bool>(false);
  late Future<void> _initFuture;

  // 상단 아이콘·상태바를 어둡게 표시할지 (로딩 중·밝은 배경 이미지일 때 true)
  final ValueNotifier<bool> _darkHeader = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    nickname = widget.nickname;
    amI = widget.amI;
    _scrollController.addListener(() {
      _appBarSolid.value = _scrollController.offset > _coverHeight - 8;
    });
    _initFuture = fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _appBarSolid.dispose();
    _darkHeader.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      var inWeduResult = await ApiClient().get('/wedu/in?nickname=$nickname');
      if (inWeduResult.statusCode == 200) {
        inRoomData = inWeduResult.data['data'];
      } else {
        if (kDebugMode) {
          print("내 같이방 에러 ${inWeduResult.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
    }

    // 프로필 정보가 없으면 화면을 그릴 수 없으므로 실패 시 에러로 넘김
    var profileInfo =
        await ApiClient().get('/member/profile?nickname=$nickname');
    if (profileInfo.statusCode != 200) {
      throw Exception('프로필 조회 실패 ${profileInfo.statusCode}');
    }
    var data = profileInfo.data['data'];
    grade = data["grade"];
    followerNumber = data["followerNumber"];
    followingNumber = data["followingNumber"];
    profileImage = data["profileImage"];
    backgroundImage = data["backgroundImage"];
    isFriend = data['following'];
    withPeerDay = data['activeDaysCount'];
    // 첫 화면부터 아이콘 색이 맞도록 배경 이미지를 미리 받아 밝기 계산 (최대 2초)
    _darkHeader.value = await _isCoverLight(backgroundImage)
        .timeout(const Duration(seconds: 2), onTimeout: () => false);
  }

  Future<void> _updateCoverBrightness() async {
    final url = backgroundImage;
    final light = await _isCoverLight(url);
    if (!mounted || backgroundImage != url) return;
    _darkHeader.value = light;
  }

  // 커버와 같은 NetworkImage로 받아 캐시를 공유 (화면에서 다시 받지 않음)
  // 상단 절반을 듬성듬성 샘플링해 평균 밝기 계산
  Future<bool> _isCoverLight(String? url) async {
    if (url == null) return false;
    try {
      final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
      final completer = Completer<ui.Image>();
      late final ImageStreamListener listener;
      listener = ImageStreamListener((info, _) {
        if (!completer.isCompleted) completer.complete(info.image.clone());
        stream.removeListener(listener);
      }, onError: (error, _) {
        if (!completer.isCompleted) completer.completeError(error);
        stream.removeListener(listener);
      });
      stream.addListener(listener);

      final image = await completer.future;
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = image.width;
      final rows = (image.height * 0.5).ceil();
      image.dispose();
      if (bytes == null) return false;

      final step = max(1, width ~/ 32);
      double sum = 0;
      int count = 0;
      for (int y = 0; y < rows; y += step) {
        for (int x = 0; x < width; x += step) {
          final k = (y * width + x) * 4;
          sum += 0.299 * bytes.getUint8(k) +
              0.587 * bytes.getUint8(k + 1) +
              0.114 * bytes.getUint8(k + 2);
          count++;
        }
      }
      return count > 0 && sum / count / 255 > 0.65;
    } catch (e) {
      if (kDebugMode) {
        print('배경 밝기 계산 실패 $e');
      }
      return false;
    }
  }

  void _retry() {
    _darkHeader.value = true;
    setState(() {
      _initFuture = fetchData();
    });
  }

  // 로딩 화면 없이 숫자·목록만 다시 불러옴
  Future<void> _refreshSilently() async {
    try {
      await fetchData();
    } catch (e) {
      if (kDebugMode) {
        print('프로필 갱신 실패 $e');
      }
    }
    if (mounted) setState(() {});
  }

  profileImageAPI(var image) async {
    var image0 = await dio.MultipartFile.fromFile(image!.path);
    var imageMap = <String, dynamic>{'profileImage': image0};
    dio.FormData imageData = dio.FormData.fromMap(imageMap);

    try {
      var profileChange =
          await ApiClient().putForm('/member/change/profileImage', imageData);
      if (profileChange.statusCode == 200) {
        if (kDebugMode) {
          print("프로필 이미지 성공 ${profileChange.statusMessage}");
        }
        var data = profileChange.data['data'];
        setState(() {
          profileImage = data;
        });
        if (amI) {
          await storage.write(key: 'profileImage', value: profileImage);
        }
        if (!mounted) return;
        PeeroreumToast.show(context, "프로필 이미지가 변경되었어요.");
      } else {
        if (kDebugMode) {
          print("프로필 이미지 ${profileChange.statusMessage}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
    }
  }

  deleteProfileImageAPI() async {
    try {
      var result = await ApiClient().put('/member/delete/profileImage');
      if (result.statusCode == 200) {
        setState(() {
          profileImage = null;
        });
        await storage.delete(key: 'profileImage');
        if (!mounted) return;
        PeeroreumToast.show(context, "프로필 이미지가 삭제되었어요.");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
    }
  }

  deleteBackgroundImageAPI() async {
    try {
      var result = await ApiClient().put('/member/delete/backgroundImage');
      if (result.statusCode == 200) {
        setState(() {
          backgroundImage = null;
        });
        _updateCoverBrightness();
        if (!mounted) return;
        PeeroreumToast.show(context, "배경 이미지가 삭제되었어요.");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
    }
  }

  backgroundImageAPI(var image) async {
    var image0 = await dio.MultipartFile.fromFile(image!.path);
    var imageMap1 = <String, dynamic>{'profileImage': image0};
    dio.FormData imageData = dio.FormData.fromMap(imageMap1);

    try {
      var backgroundChange = await ApiClient()
          .putForm('/member/change/backgroundImage', imageData);
      if (backgroundChange.statusCode == 200) {
        if (kDebugMode) {
          print("배경 이미지 성공 ${backgroundChange.statusMessage}");
        }
        var data = backgroundChange.data['data'];
        setState(() {
          backgroundImage = data;
        });
        _updateCoverBrightness();
        if (!mounted) return;
        PeeroreumToast.show(context, "배경 이미지가 변경되었어요.");
      } else {
        if (kDebugMode) {
          print("배경 이미지 ${backgroundChange.statusMessage}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
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
        if (!mounted) return;
        Get.back();
        PeeroreumToast.show(context, "닉네임이 변경되었어요.");
      } else {
        if (kDebugMode) {
          print("닉네임변경 에러${changeMyNickname.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
    }
  }

  follow() async {
    try {
      var friendName =
          await ApiClient().post('/member/friend/follow?nickname=$nickname');
      if (!mounted) return;
      if (friendName.statusCode == 200) {
        setState(() {
          isFriend = true;
          followerNumber++;
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
        if (kDebugMode) {
          print("친구팔로 에러${friendName.statusCode}");
        }
      }
    } catch (e) {
      if (!mounted) return;
      PeeroreumToast.show(context, "잠시 후에 다시 시도해 주세요.", isError: true);
    }
    if (mounted) setState(() {});
  }

  unfollow() async {
    try {
      var friendName = await ApiClient()
          .delete('/member/friend/unfollow?nickname=$nickname');
      if (!mounted) return;
      if (friendName.statusCode == 200) {
        setState(() {
          isFriend = false;
          if (followerNumber > 0) followerNumber--;
        });

        PeeroreumToast.show(context, "친구 삭제를 완료했어요.");
      } else {
        setState(() {
          isFriend = true;
        });
        if (kDebugMode) {
          print("친구언팔 에러${friendName.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      setState(() {
        isFriend = true;
      });
    }
  }

  searchFriend() async {
    final target = nicknameController.text.trim();
    if (target.isEmpty) return;
    if (target == nickname) {
      PeeroreumToast.show(context, "자신은 영원한 친구예요.", isError: true);
      return;
    }
    try {
      final result =
          await ApiClient().get('/member/profile?nickname=$target');
      if (!mounted) return;
      if (result.statusCode == 200) {
        Get.back();
        Get.to(() => MyPageProfile(target, false), preventDuplicates: false)
            ?.then((value) {
          _refreshSilently();
          nicknameController.clear();
        });
      } else if (result.statusCode == 404) {
        PeeroreumToast.show(context, "존재하지 않는 회원이에요.", isError: true);
      } else {
        PeeroreumToast.show(context, "잠시 후에 다시 시도해 주세요.", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      PeeroreumToast.show(context, "잠시 후에 다시 시도해 주세요.", isError: true);
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
        if (kDebugMode) {
          print("친구체크 에러${myFriend.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      setState(() {
        isFriend = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedBuilder(
          animation: Listenable.merge([_appBarSolid, _darkHeader]),
          builder: (context, _) => appbarWidget(_appBarSolid.value),
        ),
      ),
      body: FutureBuilder<void>(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 로딩 중에는 흰 화면 + 어두운 아이콘 (색 블록이 깜빡이지 않도록)
              return Container(color: PeeroreumColor.white);
            } else if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(top: _topInset),
                child: ErrorRetryView(onRetry: _retry),
              );
            } else {
              return bodyWidget();
            }
          }),
    );
  }

  PreferredSizeWidget appbarWidget(bool solid) {
    final bool darkIcons = solid || _darkHeader.value;
    final Color iconColor =
        darkIcons ? PeeroreumColor.gray[800]! : PeeroreumColor.white;
    return AppBar(
      backgroundColor: solid ? PeeroreumColor.white : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: solid ? 0.5 : 0,
      systemOverlayStyle:
          darkIcons ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        onPressed: () {
          Get.back();
        },
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
                      colorFilter:
                          ColorFilter.mode(iconColor, BlendMode.srcIn)),
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
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
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
                    B3r(text: '프로필 변경'),
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
                child: const SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      B3r(text: '프로필 삭제', color: PeeroreumColor.error),
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
                    B3r(text: '닉네임 변경'),
                  ],
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: PeeroreumColor.gray[100],
              onTap: () async {
                final selected =
                    await showCustomImagePicker(context, multiple: false);
                if (selected == null || selected.isEmpty) return;
                if (!mounted) return;
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
                    B3r(text: '배경 변경'),
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
                child: const SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      B3r(text: '배경 삭제', color: PeeroreumColor.error),
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
                        final selected = await showCustomImagePicker(context,
                            multiple: false);
                        if (selected == null || selected.isEmpty) return;
                        if (!mounted) return;
                        final cropped = await cropImage(
                            context, // ignore: use_build_context_synchronously
                            selected.first);
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
                                        image: NetworkImage(profileImage!),
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
                                  ? PeeroreumColor.primaryPurple[400]
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
                if (kDebugMode) {
                  print("Unexpected error: $e");
                }
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
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9_ㄱ-ㅎㅏ-ㅣ가-힣ᆞᆢㆍᄀ-ᄒ]'))
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
                                            PeeroreumColor.primaryPurple[400]!),
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
                                    ? PeeroreumColor.primaryPurple[400]
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
                                        ? PeeroreumColor.primaryPurple[400]
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
                Get.to(
                    () => Report(data: "[프로필] 유저 신고\n" "유저 아이디 : $nickname\n"));
              },
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    B3r(
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
                          backgroundColor: PeeroreumColor.primaryPurple[400],
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
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileHeader(),
            Container(height: 8, color: PeeroreumColor.gray[100]),
            myWedu(),
          ],
        ),
      ),
    );
  }

  static const double _coverHeight = 140;

  // 상태바 + 상단 바 높이. 커버를 이 영역까지 깔기 위해 더함
  // (Scaffold 바깥 context 기준이라 상태바 높이만 들어 있음)
  double get _topInset =>
      MediaQuery.of(context).padding.top + kToolbarHeight;
  static const double _avatarSize = 88;

  /// 커버(배경 이미지 또는 기본 그라데이션) + 겹쳐진 프로필 사진 + 이름·통계
  Widget profileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            cover(),
            Positioned(
              left: 20,
              bottom: -_avatarSize / 2,
              child: avatar(),
            ),
          ],
        ),
        // 커버 아래로 내려온 프로필 사진 높이만큼 비움
        const SizedBox(height: _avatarSize / 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nickname,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: PeeroreumColor.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                        if (grade != null &&
                            grade! > 0 &&
                            grade! < dropdownGradeList.length &&
                            PeeroreumColor.gradeColor[grade] != null) ...[
                          const SizedBox(width: 6),
                          gradeChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset('assets/images/color_logo.png', height: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+$withPeerDay',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: PeeroreumColor.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        friendStat(followerNumber, '팔로워', 0),
                        const SizedBox(width: 12),
                        friendStat(followingNumber, '팔로잉', 1),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 이름·통계 블록 옆 세로 가운데
              primaryButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget cover() {
    final double topInset = _topInset;
    return SizedBox(
      width: double.infinity,
      height: topInset + _coverHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          backgroundImage != null
              ? Image.network(backgroundImage!, fit: BoxFit.cover)
              : DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        PeeroreumColor.primaryPurple[200]!,
                        PeeroreumColor.primaryPurple[400]!,
                        PeeroreumColor.primaryPurple[600]!,
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget avatar() {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PeeroreumColor.white,
        border: Border.all(
            width: 3,
            color: grade != null && PeeroreumColor.gradeColor[grade] != null
                ? PeeroreumColor.gradeColor[grade]!
                : PeeroreumColor.gray[400]!),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: profileImage != null
              ? DecorationImage(
                  image: NetworkImage(profileImage!), fit: BoxFit.cover)
              : const DecorationImage(
                  image: AssetImage('assets/images/user.jpg'),
                  fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget gradeChip() {
    final color = PeeroreumColor.gradeColor[grade]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        dropdownGradeList[grade!],
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget friendStat(int count, String label, int tabIndex) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await Get.to(() => MyPageProfileFriend(nickname, index: tabIndex));
        _refreshSilently();
      },
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14),
          children: [
            TextSpan(
              text: '$count',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: PeeroreumColor.black),
            ),
            TextSpan(
              text: ' $label',
              style: TextStyle(
                  fontWeight: FontWeight.w400, color: PeeroreumColor.gray[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// 내 프로필이면 공유, 다른 사람이면 친구 추가/끊기
  Widget primaryButton() {
    final bool muted = !amI && isFriend;
    final Color fg = muted ? PeeroreumColor.gray[600]! : PeeroreumColor.white;
    return TextButton(
      key: _shareButtonKey,
      onPressed: onPrimaryButtonPressed,
      style: TextButton.styleFrom(
        backgroundColor:
            muted ? PeeroreumColor.gray[200] : PeeroreumColor.primaryPurple[400],
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(0, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            amI ? 'assets/icons/share.svg' : 'assets/icons/plus_user.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
          ),
          const SizedBox(width: 6),
          Text(
            amI ? '공유' : (isFriend ? '친구 끊기' : '친구 추가'),
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onPrimaryButtonPressed() async {
    if ((isFriend == true) && (amI == false)) {
      unfollow();
    } else if ((isFriend == false) && (amI == false)) {
      follow();
    } else if ((isFriend == false) && (amI == true)) {
      final available =
          await ShareClient.instance.isKakaoTalkSharingAvailable();
      if (available) {
        try {
          final uri = await ShareClient.instance.shareCustom(
            templateId: 102993,
            templateArgs: {'UserName': nickname},
          );
          await ShareClient.instance.launchKakaoTalk(uri);
        } catch (error) {
          if (kDebugMode) {
            print('카카오톡 공유 실패 $error');
          }
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
      if (kDebugMode) {
        print('error');
      }
    }
    setState(() {});
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        roomBody(),
        if (inRoomData.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Text(
              '참여 중인 같이방이 없어요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: PeeroreumColor.gray[500],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                for (int i = inRoomData.length - 1; i >= 0; i--)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: roomRow(i),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// 같이해냄 목록과 같은 가로형 카드 + 진행률 바
  Widget roomRow(int roomIndex) {
    final room = inRoomData[roomIndex];
    final String subjectName = dropdownSubjectList[room['subject']];
    final num progress = (room['progress'] ?? 0) as num;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (amI) Get.to(() => DetailWedu(room["id"]));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: PeeroreumColor.gray[50],
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: room['imagePath'] != null
                    ? Image.network(room['imagePath'], fit: BoxFit.cover)
                    : SvgPicture.asset('assets/images/default.svg',
                        fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          color: PeeroreumColor.subjectColor[subjectName]?[0],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 6),
                          child: Text(
                            subjectName,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              color:
                                  PeeroreumColor.subjectColor[subjectName]?[1],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          room["title"] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: PeeroreumColor.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${dropdownGradeList[room["grade"]]} · ${room["attendingPeopleNum"]}명 · D-${room["dday"]}',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: PeeroreumColor.gray[600],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 남은 폭을 모두 채워 진행률을 읽기 쉽게
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (progress / 100).clamp(0, 1).toDouble(),
                            minHeight: 4,
                            backgroundColor: PeeroreumColor.gray[100],
                            valueColor: AlwaysStoppedAnimation(
                                PeeroreumColor.primaryPurple[400]!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: PeeroreumColor.primaryPurple[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
}
