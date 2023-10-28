import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpSchool extends StatefulWidget {
  @override
  State<SignUpSchool> createState() => _SignUpSchoolState();
}

class _SignUpSchoolState extends State<SignUpSchool> {
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