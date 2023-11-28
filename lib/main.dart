import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/screens/email_signin_screen.dart';
import 'package:peeroreum_client/screens/email_signup_screen.dart';
import 'package:peeroreum_client/screens/home_wedu.dart';
import 'package:peeroreum_client/screens/signin_screen.dart';

void main() => runApp(PeeroreumApp());

class PeeroreumApp extends StatelessWidget {
  const PeeroreumApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final storage = FlutterSecureStorage();
    dynamic memberInfo = storage.read(key:'memberInfo');

    return MaterialApp(
      title: 'Peeroreum',
      initialRoute: (memberInfo == null)? '/signIn' : '/wedu',
      routes: {
        '/signIn': (context) => SignIn(),
        '/signIn/email': (context) => EmailSignIn(),
        '/signUp/email': (context) => EmailSignUp(),
        '/wedu': (context) => HomeWedu()
      },
      // debugShowCheckedModeBanner: false,
    );
  }
}


