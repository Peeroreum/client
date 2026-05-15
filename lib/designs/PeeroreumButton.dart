import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'PeeroreumColor.dart';
import 'package:dropdown_button2/dropdown_button2.dart';


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
        child: DropdownButton2<T>(
          isExpanded: true,
          buttonStyleData: const ButtonStyleData(
                                      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                                      height: 40,
                                      width: double.infinity,
                                    ),
          value: value,
          iconStyleData: IconStyleData(
                                      icon: SvgPicture.asset('assets/icons/down.svg',
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
          dropdownStyleData: DropdownStyleData(
                                      elevation: 0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: PeeroreumColor.gray[200]!),
                                        color: PeeroreumColor.white,
                                      )),
                                      menuItemStyleData: MenuItemStyleData(
                                      height: 44,
                                    ),
        ),
      ),
    );
  }
}
