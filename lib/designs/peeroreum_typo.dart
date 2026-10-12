import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';

//--------------Title Sb--------------

class T1 extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const T1({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class T2 extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const T2({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class T3 extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const T3({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class T4 extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const T4({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class T5 extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const T5({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

//--------------Body M--------------

class B1m extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const B1m({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class B2m extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const B2m({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class B3m extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const B3m({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class B4m extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const B4m({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

//--------------Body R--------------

class B1r extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const B1r({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class B2r extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const B2r({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class B3r extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const B3r({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class B4r extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const B4r({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      ),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

//--------------Caption R--------------

class C1sb extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const C1sb({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class C1m extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const C1m({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class C1r extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const C1r({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class C2sb extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const C2sb({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class C2m extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const C2m({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class C2r extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const C2r({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
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
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
