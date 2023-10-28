import 'package:flutter/material.dart';

class SignUpSubject extends StatefulWidget {
  @override
  State<SignUpSubject> createState() => _SignUpSubjectState();
}

class _SignUpSubjectState extends State<SignUpSubject> {
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