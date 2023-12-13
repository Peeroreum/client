import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/screens/compliment_list_screen.dart';
import 'package:peeroreum_client/screens/create_wedu_invitation.dart';
import 'package:peeroreum_client/screens/email_signin_screen.dart';
import 'package:peeroreum_client/screens/email_signup_screen.dart';
import 'package:peeroreum_client/screens/encouragement_list_screen.dart';
import 'package:peeroreum_client/screens/home_wedu.dart';
import 'package:peeroreum_client/screens/in_wedu.dart';
import 'package:peeroreum_client/screens/signin_screen.dart';
import 'package:peeroreum_client/screens/signup_nickname_screen.dart';

void main() {
  final native_app_key = "a6ab4f390d7270d5fee060c7305c8784";
  KakaoSdk.init(nativeAppKey: native_app_key);
  runApp(PeeroreumApp());
}

class PeeroreumApp extends StatelessWidget {
  const PeeroreumApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: PeeroreumColor.white,
                statusBarIconBrightness: Brightness.dark
              )
          )
      ),
      title: 'Peeroreum',
      initialRoute: '/signIn',
      routes: {
        '/signIn': (context) => SignIn(),
        '/signIn/email': (context) => EmailSignIn(),
        '/signUp/email': (context) => EmailSignUp(),
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


