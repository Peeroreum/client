import 'package:flutter/material.dart';

class SignUpGrade extends StatefulWidget {
  @override
  State<SignUpGrade> createState() => _SignUpGradeState();
}

class _SignUpGradeState extends State<SignUpGrade> {
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