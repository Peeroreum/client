// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';

/// wedu_home.dart / wedu_search_result_screen.dart / 딥링크 진입 모두에서
/// 재사용하는 같이방 참여 바텀시트.
///
/// roomData 키 규격 (wedu_home.dart 포맷 그대로 사용):
///   imagePath, dday, locked, title, grade, subject, attendingPeopleNum, id, password
/// inviData 키:
///   invitationUrl, challenge
class WeduRoomInfoSheet extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final Map<String, dynamic> inviData;
  final List<dynamic> hashTagsList;
  final bool isAlreadyJoined;

  /// 참여하기 버튼 콜백 (null 이면 버튼 비활성)
  final VoidCallback? onEnroll;

  /// 닫기 버튼 콜백 (null 이면 Get.back())
  final VoidCallback? onClose;

  /// 공유 버튼 콜백 (null 이면 공유 버튼 숨김)
  final VoidCallback? onShare;

  static const List<String> _gradeList = [
    '전체', '중1', '중2', '중3', '고1', '고2', '고3', '대학'
  ];
  static const List<String> _subjectList = [
    '전체', '국어', '영어', '수학', '사회', '과학', '기타', '대학'
  ];

  const WeduRoomInfoSheet({
    super.key,
    required this.roomData,
    required this.inviData,
    this.hashTagsList = const [],
    required this.isAlreadyJoined,
    this.onEnroll,
    this.onClose,
    this.onShare,
  });

  // ──────────────────────────────────────────────────────────────
  // Static show helpers
  // ──────────────────────────────────────────────────────────────

  /// wedu_home / wedu_search_result 처럼 데이터를 이미 갖고 있을 때 사용
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> roomData,
    required Map<String, dynamic> inviData,
    List<dynamic> hashTagsList = const [],
    required bool isAlreadyJoined,
    VoidCallback? onEnroll,
    VoidCallback? onClose,
    VoidCallback? onShare,
  }) {
    // Get.bottomSheet()를 사용해 GetX가 직접 overlay context를 관리하게 함.
    // cold start 시 showModalBottomSheet가 GetX Navigator 초기화 타이밍과 충돌해
    // GlobalKey<NavigatorState>가 Navigator와 _FocusInheritedScope 두 곳에
    // 동시 등록되는 문제를 방지한다.
    return Get.bottomSheet(
      WeduRoomInfoSheet(
        roomData: roomData,
        inviData: inviData,
        hashTagsList: hashTagsList,
        isAlreadyJoined: isAlreadyJoined,
        onEnroll: onEnroll,
        onClose: onClose,
        onShare: onShare,
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 공통 데이터 fetch (딥링크 / 새로고침 등 어디서든 재사용 가능)
  // ──────────────────────────────────────────────────────────────

  /// roomId 하나로 바텀시트에 필요한 모든 데이터를 받아온다.
  ///
  /// 반환 구조:
  /// ```
  /// {
  ///   'roomData':       Map<String, dynamic>,  // imagePath·dday 등 정규화된 키
  ///   'inviData':       Map<String, dynamic>,
  ///   'hashTagsList':   List<dynamic>,
  ///   'isAlreadyJoined': bool,
  ///   'roomId':         String,
  ///   'headers':        Map<String, String>,   // 이후 enroll 등에 재사용
  /// }
  /// ```
  /// 실패 시 null 반환.
  static Future<Map<String, dynamic>?> fetchData(String roomId) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final nickname = await storage.read(key: 'nickname');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final d = dio.Dio();

    try {
      final results = await Future.wait([
        d.get('${API.hostConnect}/wedu/$roomId',
            options: dio.Options(headers: headers)),
        d.get('${API.hostConnect}/wedu/$roomId/invitation',
            options: dio.Options(headers: headers)),
        d.get('${API.hostConnect}/wedu/in?nickname=$nickname',
            options: dio.Options(headers: headers)),
      ]);

      final roomRaw = results[0].data['data'] as Map<String, dynamic>? ?? {};
      final inviData = results[1].data['data'] as Map<String, dynamic>? ?? {};
      final inList = results[2].data['data'] as List<dynamic>? ?? [];
      final isAlreadyJoined = inList.any((r) => r['id'].toString() == roomId);

      // WeduReadDto(imageUrl, dDay) → 공통 포맷(imagePath, dday) 으로 정규화
      // wedu_home 리스트 API 는 이미 imagePath·dday 를 쓰므로 일치함
      final roomData = <String, dynamic>{
        ...roomRaw,
        'imagePath': roomRaw['imageUrl'] ?? roomRaw['imagePath'],
        'dday': roomRaw['dDay'] ?? roomRaw['dday'],
      };
      final hashTagsList = (roomRaw['hashTags'] as List<dynamic>?) ?? [];

      return {
        'roomData': roomData,
        'inviData': inviData,
        'hashTagsList': hashTagsList,
        'isAlreadyJoined': isAlreadyJoined,
        'roomId': roomId,
        'headers': headers,
      };
    } on dio.DioException catch (e) {
      print('[WeduRoomInfoSheet] fetchData DioException: ${e.response?.statusCode}');
      return null;
    } catch (e) {
      print('[WeduRoomInfoSheet] fetchData error: $e');
      return null;
    }
  }

  /// 딥링크 진입용: fetchData() 로 데이터를 미리 받아온 뒤 바텀시트 표시.
  /// 바텀시트를 열기 전에 fetch 를 완료하므로 로딩 상태가 없어
  /// isScrollControlled: true 에서도 올바른 높이로 표시됨.
  static Future<void> showFromLink(BuildContext context, String roomId) async {
    final data = await fetchData(roomId);

    if (data == null) {
      if (context.mounted) {
        PeeroreumToast.show(context, '같이방 정보를 불러올 수 없어요.');
      }
      return;
    }

    if (!context.mounted) return;

    final roomData = data['roomData'] as Map<String, dynamic>;
    final headers = data['headers'] as Map<String, String>;

    await show(
      context,
      roomData: roomData,
      inviData: data['inviData'] as Map<String, dynamic>,
      hashTagsList: data['hashTagsList'] as List<dynamic>,
      isAlreadyJoined: data['isAlreadyJoined'] as bool,
      onEnroll: () {
        final locked = roomData['locked'] == true;
        if (locked) {
          _showPasswordDialog(context, roomData, roomId, headers);
        } else {
          _doEnroll(roomId, headers);
        }
      },
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────────

  static void _showPasswordDialog(
    BuildContext context,
    Map<String, dynamic> roomData,
    String roomId,
    Map<String, String> headers,
  ) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: PeeroreumColor.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        title: const Text(
          '비밀번호 입력',
          style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: '비밀번호를 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('취소',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: PeeroreumColor.gray[600])),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text == roomData['password']) {
                Get.back();
                _doEnroll(roomId, headers);
              } else {
                PeeroreumToast.show(ctx, '비밀번호가 일치하지 않아요.',
                    isError: true);
              }
            },
            child: Text('확인',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: PeeroreumColor.primaryPuple[400])),
          ),
        ],
      ),
    );
  }

  static Future<void> _doEnroll(
      String roomId, Map<String, String> headers) async {
    final d = dio.Dio();
    try {
      final res = await d.post(
        '${API.hostConnect}/wedu/$roomId/enroll',
        options: dio.Options(headers: headers),
      );
      if (res.statusCode == 200) {
        Get.back();
        final ctx = Get.context;
        if (ctx != null) PeeroreumToast.show(ctx, '같이방에 참여했어요!');
      }
    } on dio.DioException catch (e) {
      final ctx = Get.context;
      if (ctx == null) return;
      if (e.response?.statusCode == 409) {
        PeeroreumToast.show(ctx, '이미 참여 중인 같이방이에요.');
      } else if (e.response?.statusCode == 404) {
        PeeroreumToast.show(ctx, '존재하지 않는 같이방입니다.');
      } else {
        PeeroreumToast.show(ctx, '잠시 후에 다시 시도해 주세요.');
      }
    }
  }

  // ──────────────────────────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────────────────────────

  Widget _buildHashTags() {
    if (hashTagsList.isEmpty) return Container();
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 26,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: hashTagsList.length,
          separatorBuilder: (_, __) => SizedBox(width: 4),
          itemBuilder: (context, i) => Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 1, color: PeeroreumColor.primaryPuple[400]!),
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('#',
                    style: TextStyle(
                        color: PeeroreumColor.primaryPuple[200],
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                SizedBox(width: 2),
                Text(hashTagsList[i].toString(),
                    style: TextStyle(
                        color: PeeroreumColor.primaryPuple[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = roomData['imagePath'] as String?;
    final subject = roomData['subject'];
    final locked = roomData['locked'].toString() == 'true';
    final title = roomData['title'] as String? ?? '';
    final grade = roomData['grade'];
    final attendingPeopleNum = roomData['attendingPeopleNum'] ?? 0;
    final dday = roomData['dday'];

    final gradeText =
        (grade != null) ? _gradeList[(grade as num).toInt()] : '';
    final subjectText =
        (subject != null) ? _subjectList[(subject as num).toInt()] : '';

    final challenge = inviData['challenge'] as String?;
    final invitationUrl = inviData['invitationUrl'] as String?;

    return SafeArea(
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: PeeroreumColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 상단: 썸네일 + 제목/정보 + 공유버튼 ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // 썸네일
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: PeeroreumColor.gray[50],
                          border: Border.all(
                              width: 1, color: PeeroreumColor.gray[200]!),
                          borderRadius:
                              BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: imagePath != null
                              ? Image.network(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      SvgPicture.asset(
                                          'assets/images/default.svg',
                                          fit: BoxFit.cover),
                                )
                              : SvgPicture.asset(
                                  'assets/images/default.svg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      // 제목 + 학년/인원/D-day
                      Container(
                        height: 72,
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 과목 태그
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                color: PeeroreumColor
                                    .subjectColor[subjectText]?[0],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  subjectText,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    height: 1.6,
                                    fontFamily: 'Pretendard',
                                    color: PeeroreumColor
                                        .subjectColor[subjectText]?[1],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            // 제목
                            Row(
                              children: [
                                if (locked)
                                  SvgPicture.asset('assets/icons/lock.svg',
                                      color: PeeroreumColor.gray[400]),
                                if (locked) SizedBox(width: 4),
                                SizedBox(
                                  width: locked
                                      ? MediaQuery.of(context).size.width *
                                          0.42
                                      : MediaQuery.of(context).size.width *
                                          0.48,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: PeeroreumColor.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 학년 · 인원 · D-day
                            Row(
                              children: [
                                Text(gradeText,
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: PeeroreumColor.gray[600])),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/dot.svg',
                                    color: PeeroreumColor.gray[600],
                                  ),
                                ),
                                Text('${attendingPeopleNum}명',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: PeeroreumColor.gray[600])),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/dot.svg',
                                    color: PeeroreumColor.gray[600],
                                  ),
                                ),
                                dday != null && (dday as num) > 0
                                    ? Text('D-$dday',
                                        style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: PeeroreumColor.gray[600]))
                                    : Text(
                                        'D+${dday.toString().replaceAll('-', '')}',
                                        style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: PeeroreumColor.gray[600])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 공유 버튼 (onShare 가 있을 때만)
                  if (onShare != null)
                    Container(
                      width: 48,
                      height: 48,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: PeeroreumColor.gray[200]!),
                        color: PeeroreumColor.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: onShare,
                        icon: SvgPicture.asset('assets/icons/share.svg'),
                      ),
                    ),
                ],
              ),

              // ── 해시태그 ──
              _buildHashTags(),
              SizedBox(height: 8),

              // ── 챌린지 ──
              if (challenge != null && challenge.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    challenge,
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  decoration: BoxDecoration(
                      color: PeeroreumColor.gray[100],
                      borderRadius: BorderRadius.circular(8)),
                ),

              SizedBox(height: 16),

              // ── 초대장 이미지 ──
              if (invitationUrl != null)
                Container(
                  height: 162,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(invitationUrl), fit: BoxFit.cover),
                    color: PeeroreumColor.primaryPuple[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

              // ── 버튼 영역 ──
              Container(
                margin: EdgeInsets.fromLTRB(0, 8, 0, 32),
                width: double.maxFinite,
                child: isAlreadyJoined
                    ? SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            '이미 참여 중인 같이방이에요.',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PeeroreumColor.gray[600],
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                PeeroreumColor.gray[300]),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(vertical: 12)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: onClose ?? () => Get.back(),
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
                                backgroundColor: MaterialStateProperty.all(
                                    PeeroreumColor.gray[300]),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(vertical: 12)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextButton(
                              onPressed: onEnroll,
                              child: Text(
                                '참여하기',
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
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
