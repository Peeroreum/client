import 'package:flutter/material.dart';
import 'package:peeroreum_client/screens/signin_screen.dart';

void main() => runApp(PeeroreumApp());

class PeeroreumApp extends StatelessWidget {
  const PeeroreumApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peeroreum',
      initialRoute: '/',
      routes: {
        '/': (context) => SignIn()
      },
      // debugShowCheckedModeBanner: false,
    );
  }
}


