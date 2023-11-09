import 'package:flutter/material.dart';

final class PeeroreumColor extends Color {
  PeeroreumColor(super.value);

  static const Color black = Colors.black;
  static const Color white = Colors.white;
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
    300: Color.fromARGB(255, 183, 115, 251),
    400: Color.fromARGB(255, 171, 94, 249),
    500: Color.fromARGB(255, 164, 81, 247),
    600: Color.fromARGB(255, 150, 83, 217),
    700: Color.fromARGB(255, 130, 86, 174),
    800: Color.fromARGB(255, 110, 87, 132),
    900: Color.fromARGB(255, 101, 76, 126)
  };
}