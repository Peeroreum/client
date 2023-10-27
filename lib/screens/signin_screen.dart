import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment(0.0, 0.0),
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 234.0,
                ),
                Image.asset(
                  'assets/images/splash_logo.png',
                  height: 236.0,
                  width: 170.0,
                ),
                SizedBox(
                  height: 134.0,
                )
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
              child: Column(
                children: [
                  Container(
                    width: 350.0,
                    height: 48.0,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        '카카오 로그인',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: Colors.black87
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 8.0)),
                  Container(
                    width: 350.0,
                    height: 48.0,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        '구글 로그인',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Colors.black87
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 8.0)),
                  Container(
                    width: 350.0,
                    height: 48.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signIn/email');
                      },
                      child: Text(
                        '이메일 로그인',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Colors.black87
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}