import 'package:flutter/material.dart';
import 'package:peeroreum_client/screens/email_signin_screen.dart';
import 'package:peeroreum_client/screens/email_signup_screen.dart';
import 'package:peeroreum_client/screens/signin_screen.dart';
import 'package:peeroreum_client/screens/signup_grade_screen.dart';
import 'package:peeroreum_client/screens/signup_nickname_screen.dart';
import 'package:peeroreum_client/screens/signup_school_screen.dart';
import 'package:peeroreum_client/screens/signup_subject_screen.dart';

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
        '/signIn/email': (context) => EmailSignIn(),
        '/signUp/email': (context) => EmailSignUp(),
        // '/signUp/profile/nickname': (context) => SignUpNickname(),
        // '/signUp/profile/subject': (context) => SignUpSubject(),
        // '/signUp/profile/grade': (context) => SignUpGrade(),
        // '/signUp/profile/school': (context) => SignUpSchool()
      },
      // debugShowCheckedModeBanner: false,
    );
  }
}


