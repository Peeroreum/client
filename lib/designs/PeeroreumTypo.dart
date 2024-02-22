import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

//--------------Title Sb--------------

class T1_24px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const T1_24px({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 24,
          fontWeight: FontWeight.w600),
    );
  }
}

class T2_20px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const T2_20px({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w600),
    );
  }
}

class T3_18px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const T3_18px({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w600),
    );
  }
}

class T4_16px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const T4_16px({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w600),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class T5_14px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const T5_14px({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w600),
    );
  }
}

//--------------Body M--------------

class B1_24px_M extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const B1_24px_M({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 24,
          fontWeight: FontWeight.w500),
    );
  }
}

class B2_20px_M extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const B2_20px_M({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w500),
    );
  }
}

class B3_18px_M extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const B3_18px_M({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w500),
    );
  }
}

class B4_14px_M extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const B4_14px_M({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w500),
      overflow: TextOverflow.ellipsis,
    );
  }
}

//--------------Body R--------------

class B1_24px_R extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const B1_24px_R({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 24,
          fontWeight: FontWeight.w400),
    );
  }
}

class B2_20px_R extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const B2_20px_R({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w400),
    );
  }
}

class B3_18px_R extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const B3_18px_R({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w400),
    );
  }
}

class B4_14px_R extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const B4_14px_R({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 24 / 14),
    );
  }
}

//--------------Caption R--------------

class C1_12px_Sb extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const C1_12px_Sb({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w600),
    );
  }
}

class C1_12px_M extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const C1_12px_M({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w500),
    );
  }
}

class C1_12px_R extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const C1_12px_R({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w400),
    );
  }
}

class C2_10px_Sb extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const C2_10px_Sb({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 10,
          fontWeight: FontWeight.w600),
    );
  }
}

class C2_10px_M extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const C2_10px_M({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 10,
          fontWeight: FontWeight.w500),
    );
  }
}

class C2_10px_R extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;

  const C2_10px_R({
    Key? key,
    required this.text,
    this.color,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? PeeroreumColor.black,
          fontFamily: 'Pretendard',
          fontSize: 10,
          fontWeight: FontWeight.w400),
    );
  }
}
