import 'package:flutter/material.dart';
import 'package:peeroreum_client/screens/email_signin_screen.dart';
import 'package:peeroreum_client/screens/signin_screen.dart';

void main() => runApp(PeeroreumApp());

class PeeroreumApp extends StatelessWidget {
  const PeeroreumApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peeroreum',
      initialRoute: '/signIn',
      routes: {
        '/signIn': (context) => SignIn(),
        '/signIn/email': (context) => EmailSignIn()
      },
      // debugShowCheckedModeBanner: false,
    );
  }
}


