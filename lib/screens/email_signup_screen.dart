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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey[800],
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
            ),
            Text(
              '이메일',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(1, 234, 235, 236)
                      )
                  ),
                  hintText: 'peer@mail.com'
              ),
            ),
            SizedBox(
              height: 40.0,
            ),
            Text(
              '비밀번호',
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 14
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(1, 234, 235, 236)
                      )
                  ),
                  hintText: '비밀번호를 입력하세요'
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '영문, 숫자, 특수문자 포함 8자~12자',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 12
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              '비밀번호 확인',
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 14
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(1, 234, 235, 236)
                      )
                  ),
                  hintText: '비밀번호를 재입력하세요'
              ),
            ),
            SizedBox(
              height: 305,
            ),
            Container(
              width: 350.0,
              height: 48.0,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  '다음',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      color: Colors.white
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}