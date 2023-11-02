import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

DateTime date = DateTime.now();
const List<String> list = <String>['전체', '국어', '영어', '수학', '탐구'];

class CreateWedu extends StatefulWidget {
  CreateWedu({super.key});

  @override
  State<CreateWedu> createState() => _CreateWeduState();
}

class _CreateWeduState extends State<CreateWedu> {
  String dropdownValue = list.first;
  XFile? _image; //이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('같이방 만들기'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              '다음',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 25,
            ),
            Container(
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxHeight: 120,
                maxWidth: 120,
              ),
              decoration: _image != null
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(_image!.path)),
                        fit: BoxFit.cover,
                      ),
                    )
                  : BoxDecoration(
                      color: Colors.grey,
                    ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  getImage(ImageSource.gallery);
                },
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.camera_alt,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment(0.0, 0.0),
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    Row(children: [
                      const Text(
                        '같이방 이름',
                      ),
                    ]),
                    TextFormField(
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color.fromARGB(1, 234, 235, 236),
                        )),
                        hintText: '같이방 이름을 입력하세요',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('목표 과목'),
                              DropdownButtonFormField(
                                value: dropdownValue,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(10),
                                  border: OutlineInputBorder(),
                                ),
                                items: list.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    dropdownValue = value!;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('목표 종료일'),
                                OutlinedButton.icon(
                                  style: ButtonStyle(
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.all(10.5)),
                                  ),
                                  onPressed: () async {
                                    final selectedDate = await showDatePicker(
                                      context:
                                          context, // 팝업으로 띄우기 때문에 context 전달
                                      initialDate:
                                          date, // 달력을 띄웠을 때 선택된 날짜. 위에서 date 변수에 오늘 날짜를 넣었으므로 오늘 날짜가 선택돼서 나옴
                                      firstDate: DateTime(1950), // 시작 년도
                                      lastDate: DateTime
                                          .now(), // 마지막 년도. 오늘로 지정하면 미래의 날짜는 선택할 수 없음
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        date =
                                            selectedDate; // 선택한 날짜는 date 변수에 저장
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.calendar_month),
                                  label: Text('$date'.substring(0, 10)),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
