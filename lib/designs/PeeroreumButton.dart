import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'PeeroreumColor.dart';

class PeeroreumButton<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final void Function(T?) onChanged;
  final String hintText;
  final double width;

  PeeroreumButton(
      {required this.items,
      required this.value,
      required this.onChanged,
      required this.hintText,
      this.width = 78});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: PeeroreumColor.gray[200]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 40,
        width: width,
        child: DropdownButton<T>(
          isExpanded: true,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          value: value,
          iconSize: 18,
          icon: Container(
            margin: EdgeInsets.only(left: 7),
            child: SvgPicture.asset('assets/icons/down.svg',
                color: PeeroreumColor.gray[600]),
          ),
          items: items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: Text(
                e.toString(),
                style: TextStyle(
                  color: PeeroreumColor.black,
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          hint: Text(
            hintText,
            style: TextStyle(
              color: PeeroreumColor.gray[600],
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          underline: SizedBox.shrink(), // 밑줄 숨기기
        ),
      ),
    );
  }
}
