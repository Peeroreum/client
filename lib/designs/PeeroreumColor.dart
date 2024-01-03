import 'dart:core';
import 'package:flutter/material.dart';

final class PeeroreumColor extends Color {
  PeeroreumColor(super.value);

  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color error = Color.fromARGB(255, 240, 58, 46);
  static const Map<int, Color> gray = <int, Color> {
    50: Color.fromARGB(255, 251, 251, 251),
    100: Color.fromARGB(255, 241, 242, 243),
    200: Color.fromARGB(255, 234, 235, 236),
    300: Color.fromARGB(255, 219, 220, 221),
    400: Color.fromARGB(255, 186, 188, 189),
    500: Color.fromARGB(255, 141, 142, 143),
    600: Color.fromARGB(255, 108, 109, 109),
    700: Color.fromARGB(255, 77, 78, 79),
    800: Color.fromARGB(255, 54, 54, 54),
    900: Color.fromARGB(255, 32, 33, 35)
  };
  static const Map<int, Color> primaryPuple = <int, Color> {
    50: Color.fromARGB(255, 236, 233, 255),
    100: Color.fromARGB(255, 206, 200, 253),
    200: Color.fromARGB(255, 173, 165, 252),
    300: Color.fromARGB(255, 139, 128, 251),
    400: Color.fromARGB(255, 114, 96, 248),
    500: Color.fromARGB(255, 97, 64, 233),
    600: Color.fromARGB(255, 92, 54, 221),
    700: Color.fromARGB(255, 84, 41, 207),
    800: Color.fromARGB(255, 78, 25, 193),
    900: Color.fromARGB(255, 68, 0, 169)
  };
  static const Map<String, List<Color>> subjectColor = <String, List<Color>> {
    "국어": [Color.fromARGB(255, 255, 242, 233), Color.fromARGB(255, 248, 123, 96)],
    "수학": [Color.fromARGB(255, 233, 246, 255), Color.fromARGB(255, 96, 148, 248)],
    "영어": [Color.fromARGB(255, 240, 255, 233), Color.fromARGB(255, 129, 219, 87)],
    "사회": [Color.fromARGB(255, 255, 250, 233), Color.fromARGB(255, 248, 205, 96)],
    "과학": [Color.fromARGB(255, 255, 233, 249), Color.fromARGB(255, 248, 96, 169)],
    "전체": [Color.fromARGB(255, 236, 233, 255), Color.fromARGB(255, 114, 96, 248)],
    "기타": [Color.fromARGB(255, 234, 235, 236), Color.fromARGB(255, 108, 109, 109)]
  };
  static const Map<int, Color> gradeColor = <int, Color> {
    1: Color.fromARGB(255, 224, 0, 0),
    2: Color.fromARGB(255, 253, 121, 0),
    3: Color.fromARGB(255, 10, 168, 64),
    4: Color.fromARGB(255, 0, 181, 238),
    5: Color.fromARGB(255, 0, 89, 167),
    6: Color.fromARGB(255, 186, 188, 189)
  };
}