import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';


class SignUpComplete extends StatefulWidget {
  @override
  State<SignUpComplete> createState() => _SignUpCompleteState();
}

class _SignUpCompleteState extends State<SignUpComplete> {
  var nickname;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNickname();
  }
  
  Future<void> getNickname() async {
    var storageNickname = await const FlutterSecureStorage().read(key: "nickname");
    setState(() {
      nickname = storageNickname!;
    });

  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void> (
      future: getNickname(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: PeeroreumColor.white,
          body: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/signup_complete.png')
                      ),
                    ),
                  ),
                  SizedBox(height: 79,),
                  Text('$nickname님, 가입을 환영해요!',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PeeroreumColor.black,
                  ),),
                  Text('피어오름 사용을 위한 준비가 완료되었어요.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[700]
                  ),
                  ),
              ],
              ),
          ),

          bottomNavigationBar: Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
                  width: double.maxFinite,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    child: Text(
                      '피어오름 사용하러 가기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PeeroreumColor.white,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(PeeroreumColor.primaryPuple[400]),
                      padding:
                          MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      }
    );
  }
}