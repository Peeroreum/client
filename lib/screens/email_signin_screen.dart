import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmailSignIn extends StatefulWidget {
  const EmailSignIn({super.key});

  @override
  State<EmailSignIn> createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
    );
  }
}