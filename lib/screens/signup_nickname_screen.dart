import 'package:flutter/material.dart';

class SignUpNickname extends StatefulWidget {
  @override
  State<SignUpNickname> createState() => _SignUpNicknameState();
}

class _SignUpNicknameState extends State<SignUpNickname> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey[800],
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}