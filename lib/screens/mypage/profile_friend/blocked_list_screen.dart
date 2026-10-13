import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/api/api_client.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/widgets/block_user.dart';

/// 차단한 회원 목록 및 차단 해제
class BlockedListScreen extends StatefulWidget {
  const BlockedListScreen({super.key});

  @override
  State<BlockedListScreen> createState() => _BlockedListScreenState();
}

class _BlockedListScreenState extends State<BlockedListScreen> {
  List<dynamic> blockedMembers = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchBlockedMembers();
  }

  Future<void> fetchBlockedMembers() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final response = await ApiClient().get('/member/block');
      if (!mounted) return;
      if (response.statusCode == 200) {
        blockedMembers = List<dynamic>.from(response.data['data'] ?? []);
      } else {
        hasError = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('차단 목록 조회 에러: $e');
      }
      hasError = true;
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> unblock(String nickname) async {
    if (await unblockUser(context, nickname)) {
      if (!mounted) return;
      setState(() {
        blockedMembers.removeWhere((member) => member['nickname'] == nickname);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: AppBar(
        backgroundColor: PeeroreumColor.white,
        surfaceTintColor: PeeroreumColor.white,
        shadowColor: PeeroreumColor.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            colorFilter:
                ColorFilter.mode(PeeroreumColor.gray[800]!, BlendMode.srcIn),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '차단 목록',
          style: TextStyle(
              color: PeeroreumColor.black,
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(height: 1, color: PeeroreumColor.gray[100]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: bodyWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyWidget() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return Center(
        child: GestureDetector(
          onTap: fetchBlockedMembers,
          child: Text('목록을 불러오지 못했어요. 다시 시도하려면 눌러 주세요.',
              style: TextStyle(color: PeeroreumColor.gray[600])),
        ),
      );
    }
    if (blockedMembers.isEmpty) {
      return const Center(child: Text('차단한 회원이 없어요.'));
    }

    final countStyle = TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: PeeroreumColor.gray[500]);

    return Column(
      children: [
        Row(
          children: [
            Text('전체 차단', style: countStyle),
            const SizedBox(width: 4),
            Text('${blockedMembers.length}', style: countStyle),
            const SizedBox(width: 2),
            Text('명', style: countStyle),
          ],
        ),
        Divider(color: PeeroreumColor.gray[100], thickness: 1, height: 8),
        Flexible(
          child: ListView.separated(
            itemCount: blockedMembers.length,
            separatorBuilder: (context, index) =>
                Divider(color: PeeroreumColor.gray[100], thickness: 1, height: 8),
            itemBuilder: (context, index) =>
                blockedMemberItem(blockedMembers[index]),
          ),
        ),
      ],
    );
  }

  Widget blockedMemberItem(dynamic member) {
    final String nickname = member['nickname'] ?? '';
    final String? profileImage = member['profileImage'];
    final grade = member['grade'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  width: 2,
                  color: PeeroreumColor.gradeColor[grade] ??
                      PeeroreumColor.gray[200]!),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: PeeroreumColor.white),
                image: profileImage != null
                    ? DecorationImage(
                        image: NetworkImage(profileImage), fit: BoxFit.cover)
                    : const DecorationImage(
                        image: AssetImage('assets/images/user.jpg')),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nickname,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: PeeroreumColor.gray[800]),
            ),
          ),
          OutlinedButton(
            onPressed: () => unblock(nickname),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              side: BorderSide(color: PeeroreumColor.gray[200]!),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              '차단 해제',
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: PeeroreumColor.gray[600]),
            ),
          ),
        ],
      ),
    );
  }
}
