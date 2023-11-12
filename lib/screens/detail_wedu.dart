import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

class DetailWedu extends StatefulWidget {
  const DetailWedu({super.key});

  @override
  State<DetailWedu> createState() => _DetailWeduState();
}

class _DetailWeduState extends State<DetailWedu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeeroreumColor.white,
      appBar: AppBar(
        backgroundColor: PeeroreumColor.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: PeeroreumColor.gray[800],
          ),
          onPressed: () {
            Navigator.pop(context);
            },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '9월모고 1등급 만들기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: PeeroreumColor.black
              ),
            ),
            Icon(
              Icons.lock,
              color: PeeroreumColor.gray[400],
              size: 14,
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                  Icons.more_vert_outlined,
                color: PeeroreumColor.gray[800],
              )
          )
        ],
      ),
    );
  }
}