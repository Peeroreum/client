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
      backgroundColor: Colors.white,
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
      body: Container(
        alignment: Alignment(0.0, 0.0),
        child: Column(
          children: [
            SizedBox(
              height: 35.0,
            ),
            Image.asset(
              'assets/images/splash_logo.png',
              height: 236.0,
              width: 170.0,
            ),
            SizedBox(
              height: 116.0,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(1, 234, 235, 236)
                          )
                      ),
                      hintText: '이메일을 입력하세요.'
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
                      hintText: '비밀번호를 입력하세요.',
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) {
                          activate();
                        },
                        checkColor: Colors.white,
                        fillColor: MaterialStateProperty.all(Color.fromARGB(1, 114, 96, 248)),
                        activeColor: Color.fromARGB(1, 114, 96, 248),
                      ),
                      Text(
                        '로그인 상태 유지'
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Container(
                    width: 350.0,
                    height: 48.0,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        '로그인',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Colors.white
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {},
                    child: Text(
                      '이메일 찾기',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          color: Colors.grey[600]
                      ),
                    )
                ),
                Text(
                  '|',
                  style: TextStyle(
                    color: Colors.grey[200]
                  ),
                ),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          color: Colors.grey[600]
                      ),
                    )
                ),
                Text(
                  '|',
                  style: TextStyle(
                      color: Colors.grey[200]
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signUp/email');
                    },
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          color: Colors.grey[600]
                      ),
                    )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}