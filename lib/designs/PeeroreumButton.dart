import 'package:flutter/material.dart';

class PeeroreumButton<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final void Function(T?) onChanged;
  final String hintText;

  PeeroreumButton({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text(hintText),
      underline: SizedBox.shrink(), // 밑줄 숨기기
    );
  }
}
