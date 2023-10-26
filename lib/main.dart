import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peeroreum',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(171, 94, 249, 1.0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '쉽게 시작하는 공부 습관'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 301.0,
            ),
            Column(
              children: [
                Stack(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 28,
                          height: 65,
                        ),
                        Container(
                          width: 97,
                          height: 93,
                        )
                      ],
                    )
                  ],
                ),
                Text(
                    "피어오름",
                    style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                    )
                ),
                Text(
                    "peer와 함께 피어오르다",
                    style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )
                )
              ],
            )
          ],
        )
        ),
      );
  }
}

