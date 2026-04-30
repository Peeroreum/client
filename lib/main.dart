import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:peeroreum_client/data/Onboarding_check.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/fcmSetting.dart';
import 'package:peeroreum_client/screens/alert/alert_view.dart';
import 'package:peeroreum_client/screens/bottomNaviBar.dart';
import 'package:peeroreum_client/screens/iedu/iedu_home.dart';
import 'package:peeroreum_client/screens/report.dart';
import 'package:peeroreum_client/screens/sign/signUp_complete.dart';
import 'package:peeroreum_client/screens/sign/sign_onboarding_screen.dart';
import 'package:peeroreum_client/screens/sign/signin_email_screen.dart';
import 'package:peeroreum_client/screens/sign/signin_screen.dart';
import 'package:peeroreum_client/screens/sign/signup_email_screen.dart';
import 'package:peeroreum_client/screens/wedu/compliment_checklist_screen.dart';
import 'package:peeroreum_client/screens/wedu/compliment_list_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_create_invitation.dart';
import 'package:peeroreum_client/screens/wedu/encouragement_checklist_screen.dart';
import 'package:peeroreum_client/screens/wedu/encouragement_list_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_home.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:peeroreum_client/data/pending_deep_link.dart';
import 'package:peeroreum_client/screens/sign/signin_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_join_from_link.dart';
import 'package:peeroreum_client/screens/mypage/mypage_profile.dart';
import 'firebase_options.dart';

// 네이티브 딥링크 채널 (Kakao 인텐트 처리용)
const _deepLinkChannel = MethodChannel('com.peeroreum/deeplink');

bool _appReady = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // 네이티브에서 이미 자동 초기화된 경우 무시
  }

  const nativeAppKey = "a17f729816582e161afaae9395c1f1b5";
  KakaoSdk.init(nativeAppKey: nativeAppKey);
  bool isLoggedIn = await checkLogIn();
  String? firebaseToken = await fcmSetting();
  bool? isNewUser = await checkUser();

  // 앱이 실행 중일 때 네이티브로부터 딥링크 수신 (onNewIntent)
  _deepLinkChannel.setMethodCallHandler((call) async {
    if (call.method == 'onDeepLink') {
      // 같이방 딥링크
      final roomId = call.arguments as String?;
      print('[DeepLink] onDeepLink from native: $roomId');
      if (roomId == null) return;
      final loggedIn = await checkLogIn();
      if (loggedIn) {
        final ctx = Get.context;
        if (ctx != null) WeduJoinFromLink.show(ctx, roomId);
      } else {
        PendingDeepLink.roomId = roomId;
        Get.offAll(() => EmailSignIn());
      }
    } else if (call.method == 'onDeepLinkProfile') {
      // 프로필 딥링크
      final nickname = call.arguments as String?;
      print('[DeepLink] onDeepLinkProfile from native: $nickname');
      if (nickname == null) return;
      final loggedIn = await checkLogIn();
      if (loggedIn) {
        Get.to(() => MyPageProfile(nickname, false));
      } else {
        PendingDeepLink.profileNickname = nickname;
        Get.offAll(() => EmailSignIn());
      }
    }
  });

  // 콜드 스타트: roomId
  try {
    final roomId = await _deepLinkChannel
        .invokeMethod<String>('getInitialRoomId')
        .timeout(const Duration(seconds: 3), onTimeout: () => null);
    print('[DeepLink] getInitialRoomId from native: $roomId');
    if (roomId != null) PendingDeepLink.roomId = roomId;
  } catch (e) {
    print('[DeepLink] getInitialRoomId error: $e');
  }

  // 콜드 스타트: nickname
  try {
    final nickname = await _deepLinkChannel
        .invokeMethod<String>('getInitialNickname')
        .timeout(const Duration(seconds: 3), onTimeout: () => null);
    print('[DeepLink] getInitialNickname from native: $nickname');
    if (nickname != null) PendingDeepLink.profileNickname = nickname;
  } catch (e) {
    print('[DeepLink] getInitialNickname error: $e');
  }

  // app_links: iOS 전용 (Android는 MethodChannel로 cold/warm start 모두 처리하므로 중복 방지)
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) async {
    print('[DeepLink] uriLinkStream: $uri');
    if (Platform.isAndroid) return; // Android는 MethodChannel이 모두 처리

    // 같이방
    final roomId = extractRoomId(uri);
    if (roomId != null) {
      final loggedIn = await checkLogIn();
      if (!_appReady) { PendingDeepLink.roomId = roomId; return; }
      if (loggedIn) {
        final ctx = Get.context;
        if (ctx != null) WeduJoinFromLink.show(ctx, roomId);
      } else {
        PendingDeepLink.roomId = roomId;
        Get.offAll(() => EmailSignIn());
      }
      return;
    }

    // 프로필
    final nickname = extractNickname(uri);
    if (nickname != null) {
      final loggedIn = await checkLogIn();
      if (!_appReady) { PendingDeepLink.profileNickname = nickname; return; }
      if (loggedIn) {
        Get.to(() => MyPageProfile(nickname, false));
      } else {
        PendingDeepLink.profileNickname = nickname;
        Get.offAll(() => EmailSignIn());
      }
    }
  });

  runApp(PeeroreumApp(isLoggedIn, firebaseToken ?? '', isNewUser ?? true));
  // 첫 프레임 완료 후 앱 준비 완료 플래그 설정
  WidgetsBinding.instance.addPostFrameCallback((_) => _appReady = true);
}

Future<bool> checkUser() async {
  bool? isnewhere = await OnboardingCheck.getUserType();
  if (isnewhere != false) {
    isnewhere = true;
  }
  return isnewhere!;
}

Future<bool> checkLogIn() async {
  final secureStorage = FlutterSecureStorage();
  String? token = await secureStorage.read(key: 'accessToken');
  return token != null;
}

/// peeroreum://wedu/{roomId} 또는 카카오 스킴?roomId=... 에서 roomId 추출
String? extractRoomId(Uri uri) {
  // 1) peeroreum://wedu/{roomId}
  if (uri.scheme == 'peeroreum' && uri.host == 'wedu') {
    final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    return (id != null && id.isNotEmpty) ? id : null;
  }
  // 2) 카카오 스킴: kakaoa{key}://kakaolink?roomId={roomId}
  if (uri.scheme.startsWith('kakaoa') && uri.host == 'kakaolink') {
    print('[DeepLink] Kakao URI queryParams=${uri.queryParameters}');
    final roomId = uri.queryParameters['roomId'];
    if (roomId != null && roomId.isNotEmpty) return roomId;
    // 구버전 호환
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first.isNotEmpty) {
      return uri.pathSegments.first;
    }
    final raw = uri.query.isNotEmpty ? Uri.decodeFull(uri.query) : '';
    if (raw.startsWith('peeroreum://wedu/')) {
      return raw.replaceFirst('peeroreum://wedu/', '').split('/').first;
    }
    if (raw.isNotEmpty) return raw.split('/').first;
  }
  return null;
}

/// peeroreum://profile/{nickname} 또는 카카오 스킴?nickname=... 에서 nickname 추출
String? extractNickname(Uri uri) {
  // 1) peeroreum://profile/{nickname}
  if (uri.scheme == 'peeroreum' && uri.host == 'profile') {
    final nick = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    return (nick != null && nick.isNotEmpty) ? nick : null;
  }
  // 2) 카카오 스킴: kakaoa{key}://kakaolink?nickname={nickname}
  if (uri.scheme.startsWith('kakaoa') && uri.host == 'kakaolink') {
    final nickname = uri.queryParameters['nickname'];
    if (nickname != null && nickname.isNotEmpty) return nickname;
  }
  return null;
}

class PeeroreumApp extends StatelessWidget {
  bool isLoggedIn;
  bool isNewUser;
  String firebaseToken;
  PeeroreumApp(this.isLoggedIn, this.firebaseToken, this.isNewUser,
      {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!);
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: PeeroreumColor.white,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: PeeroreumColor.white,
                  systemNavigationBarIconBrightness: Brightness.dark))),
      title: 'Peeroreum',
      home: isNewUser
          ? OnBoarding()
          : (isLoggedIn ? bottomNaviBar(firebaseToken, 0) : EmailSignIn()),
      // initialRoute: isLoggedIn? '/home' : '/signIn/email',
      // routes: {
      //   '/signIn': (context) => SignIn(),
      //   '/signIn/email': (context) => EmailSignIn(),
      //   '/signUp/email': (context) => EmailSignUp(),
      //   '/home': (context) => bottomNaviBar(firebaseToken, 1),
      //   '/wedu': (context) => HomeWedu(),
      //   '/wedu/create_invitaion': (context) => CreateInvitation(),
      //   'wedu/my': (context) => InWedu(),
      //   '/wedu/challenge/ok': (context) => ComplimentList(),
      //   '/wedu/challenge/notok': (context) => EncouragementList(),
      //   //'/wedu/challenge/ok/compliment':(context) => ComplimentCheckList(),
      //   //'/wedu/challenge/notok/encouragement':(context) => EncouragementCheckList(),
      //   'signUp/onBoarding': (context) => OnBoarding(),
      //   'signUp/Complete': (context) => SignUpComplete(),
      //   '/report': (context) => Report(data: "상세 data 아직 추가 안 됨",),
      //   '/home/iedu': (context) => bottomNaviBar(firebaseToken, 2),
      // },
      getPages: [
        GetPage(
          name: '/signIn',
          page: () => SignIn(),
        ),
        GetPage(
          name: '/signIn/email',
          page: () => EmailSignIn(),
        ),
        GetPage(
          name: '/signUp/email',
          page: () => EmailSignUp(),
        ),
        GetPage(
          name: '/home',
          page: () => bottomNaviBar(firebaseToken, 0),
        ),
        GetPage(
          name: '/wedu',
          page: () => HomeWedu(),
        ),
        GetPage(
          name: '/wedu/create_invitaion',
          page: () => CreateInvitation(),
        ),
        GetPage(
          name: '/wedu/my',
          page: () => InWedu(),
        ),
        GetPage(
          name: '/wedu/challenge/ok',
          page: () => ComplimentList(),
        ),
        GetPage(
          name: '/wedu/challenge/notok',
          page: () => EncouragementList(),
        ),
        GetPage(
          name: '/signUp/onBoarding',
          page: () => OnBoarding(),
        ),
        GetPage(
          name: '/signUp/Complete',
          page: () => SignUpComplete(),
        ),
        GetPage(
          name: '/report',
          page: () => Report(
            data: "상세 data 아직 추가 안 됨",
          ),
        ),
        GetPage(
          name: '/home/iedu',
          page: () => bottomNaviBar(firebaseToken, 1),
        ),
        GetPage(
          name: '/home/alert',
          page: () => Alert(),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
