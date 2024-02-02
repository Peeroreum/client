import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:peeroreum_client/data/Onboarding_check.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:peeroreum_client/fcmSetting.dart';
import 'package:peeroreum_client/screens/bottomNaviBar.dart';
import 'package:peeroreum_client/screens/report.dart';
import 'package:peeroreum_client/screens/sign/signUp_complete.dart';
import 'package:peeroreum_client/screens/sign/sign_onboarding_screen.dart';
import 'package:peeroreum_client/screens/sign/signin_email_screen.dart';
import 'package:peeroreum_client/screens/sign/signin_screen.dart';
import 'package:peeroreum_client/screens/sign/signup_email_screen.dart';
import 'package:peeroreum_client/screens/wedu/compliment_checklist_screen.dart';
import 'package:peeroreum_client/screens/wedu/compliment_list_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_create_invitation.dart';
import 'package:peeroreum_client/screens/wedu/encouragement_checklist_screen.dart';
import 'package:peeroreum_client/screens/wedu/encouragement_list_screen.dart';
import 'package:peeroreum_client/screens/wedu/wedu_home.dart';
import 'package:peeroreum_client/screens/wedu/wedu_in.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:uni_links/uni_links.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if you received the link via `getInitialLink` first
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    // Example of using the dynamic link to push the user to a different screen
    //Navigator.pushNamed(context, deepLink.path);
  }

  FirebaseDynamicLinks.instance.onLink.listen(
        (pendingDynamicLinkData) {
          // Set up the `onLink` event listener next as it may be received here
          if (pendingDynamicLinkData != null) {
            final Uri deepLink = pendingDynamicLinkData.link;
            // Example of using the dynamic link to push the user to a different screen
            //Navigator.pushNamed(context, deepLink.path);
          }
        },
      );
  //await DynamicLink().setup();
  const nativeAppKey = "a17f729816582e161afaae9395c1f1b5";
  KakaoSdk.init(nativeAppKey: nativeAppKey);
  bool isLoggedIn = await checkLogIn();
  String? firebaseToken = await fcmSetting();
  //await OnboardingCheck.setUserType(true); // 처음에 값 설정
  bool? isNewUser = await checkUser();
  runApp(PeeroreumApp(isLoggedIn, firebaseToken!,isNewUser!));
}

Future<bool> checkUser() async{
  bool? isnewhere = await OnboardingCheck.getUserType();
  if (isnewhere != false){
    isnewhere = true;
  }
  return isnewhere!;
}

Future<bool> checkLogIn() async {
  final secureStorage = FlutterSecureStorage();
  String? token = await secureStorage.read(key: 'accessToken');
  return token != null;
}

class PeeroreumApp extends StatelessWidget {
  bool isLoggedIn;
  bool isNewUser;
  String firebaseToken;
  PeeroreumApp(this.isLoggedIn, this.firebaseToken,this.isNewUser, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: PeeroreumColor.white,
                statusBarIconBrightness: Brightness.dark
              )
          )
      ),
      title: 'Peeroreum',
      home: isNewUser
      ? OnBoarding()
      : (isLoggedIn? bottomNaviBar(firebaseToken) : EmailSignIn()),
      // initialRoute: isLoggedIn? '/home' : '/signIn/email',
      routes: {
        '/signIn': (context) => SignIn(),
        '/signIn/email': (context) => EmailSignIn(),
        '/signUp/email': (context) => EmailSignUp(),
        '/home': (context) => bottomNaviBar(firebaseToken),
        '/wedu': (context) => HomeWedu(),
        '/wedu/create_invitaion': (context) => CreateInvitation(),
        'wedu/my': (context) => InWedu(),
        '/wedu/challenge/ok': (context) => ComplimentList(),
        '/wedu/challenge/notok': (context) => EncouragementList(),
        //'/wedu/challenge/ok/compliment':(context) => ComplimentCheckList(),
        //'/wedu/challenge/notok/encouragement':(context) => EncouragementCheckList(),
        'signUp/onBoarding':(context) => OnBoarding(),
        'signUp/Complete':(context) => SignUpComplete(),
        '/report':(context) => Report(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}