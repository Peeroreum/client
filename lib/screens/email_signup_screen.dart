import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmailSignUp extends StatefulWidget {
  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          '회원가입',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {  },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}