import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/bottomNaviBar.dart';
import 'package:peeroreum_client/screens/sign/signin_email_screen.dart';
import 'package:peeroreum_client/screens/sign/signin_screen.dart';
import 'package:peeroreum_client/screens/sign/signup_email_screen.dart';
import 'package:peeroreum_client/screens/wedu/compliment_list_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_create_invitation.dart';
import 'package:peeroreum_client/screens/wedu/encouragement_list_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_home.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final native_app_key = "a17f729816582e161afaae9395c1f1b5";
  KakaoSdk.init(nativeAppKey: native_app_key);
  runApp(PeeroreumApp());
}

class PeeroreumApp extends StatelessWidget {
  const PeeroreumApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
      const Locale('ko', 'KR'),
        const Locale('en')
      ],
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: PeeroreumColor.white,
                statusBarIconBrightness: Brightness.dark
              )
          )
      ),
      title: 'Peeroreum',
      initialRoute: '/signIn/email',
      routes: {
        '/signIn': (context) => SignIn(),
        '/signIn/email': (context) => EmailSignIn(),
        '/signUp/email': (context) => EmailSignUp(),
        '/home': (context) => bottomNaviBar(),
        '/wedu': (context) => HomeWedu(),
        '/wedu/create_invitaion': (context) => CreateInvitation(),
        'wedu/my': (context) => InWedu(),
        '/wedu/challenge/ok': (context) => ComplimentList(),
        '/wedu/challenge/notok': (context) => EncouragementList()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


