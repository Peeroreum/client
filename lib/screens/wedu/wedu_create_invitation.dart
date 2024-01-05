import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import '../../api/PeeroreumApi.dart';

class CreateInvitation extends StatefulWidget {
  const CreateInvitation({super.key});

  @override
  State<CreateInvitation> createState() => _CreateInvitationState();
}

class _CreateInvitationState extends State<CreateInvitation> {
  final maxContext = 30;
  String contextValue = "";

  Color _backgroundColor = PeeroreumColor.primaryPuple[400]!;
  Color _fontColor = PeeroreumColor.white;
  String _inviText = "같이방에서 같이 공부해요~ ☆";

  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;

  Map<String, String> iconMap = {
    '♡': '★',
    '♥': '☆',
    '☆': '♥',
    '★': '♡',
  };

  Color? pickerColor;
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

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
    var weduMap = ModalRoute.of(context)!.settings.arguments;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: PeeroreumColor.white,
        appBar: AppBar(
          elevation: 0.7,
          backgroundColor: PeeroreumColor.white,
          leading: IconButton(
            color: PeeroreumColor.black,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            '초대장 만들기',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              color: PeeroreumColor.black,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                postWeduAndInvitation(weduMap);
              },
              child: Text(
                '만들기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: PeeroreumColor.primaryPuple[400],
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                WidgetsToImage(
                  controller: controller,
                  child: Container(
                    width: 350,
                    height: 162,
                    padding: const EdgeInsets.all(16),
                    decoration: _image != null
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.2), BlendMode.darken),
                              image: FileImage(File(_image!.path)),
                              fit: BoxFit.cover,
                            ),
                          )
                        : BoxDecoration(
                            color: _backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                    child: Center(
                      child: Text(
                        _inviText,
                        style: TextStyle(
                          fontFamily: 'UhBeeRami',
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: _fontColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text(
                  '초대장 내용',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: PeeroreumColor.black,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    // onFieldSubmitted: (value) {

                    //   setState(() {
                    //     _inviText=value.replaceAllMapped(
                    //       RegExp(r'[♡♥☆★]'),
                    //       (match) => iconMap[match.group(0)]!,
                    //     );
                    //   });
                    // },
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: PeeroreumColor.black,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: PeeroreumColor.gray[200]!,
                            )),
                        hintText: "같이방에서 같이 공부해요~ ♥",
                        helperText: "초대장은 만든 후에 변경할 수 없어요.",
                        helperStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          color: PeeroreumColor.gray[600]!,
                        ),
                        counterText: '${contextValue.length} / $maxContext',
                        counterStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: PeeroreumColor.gray[600]!)),
                    maxLength: maxContext,
                    onChanged: (value) {
                      setState(() {
                        contextValue = value;
                        _inviText=value.replaceAllMapped(
                          RegExp(r'[♡♥☆★]'),
                          (match) => iconMap[match.group(0)]!,);
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "배경색",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: PeeroreumColor.black,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _backgroundColor =
                                  PeeroreumColor.primaryPuple[400]!;
                              _fontColor = PeeroreumColor.white;
                              _image = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PeeroreumColor.primaryPuple[400],
                              border: Border.all(
                                color: PeeroreumColor.gray[100]!,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _backgroundColor =
                                  PeeroreumColor.primaryPuple[200]!;
                              _fontColor = PeeroreumColor.white;
                              _image = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PeeroreumColor.primaryPuple[200],
                              border: Border.all(
                                color: PeeroreumColor.gray[100]!,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _backgroundColor =
                                  PeeroreumColor.primaryPuple[50]!;
                              _fontColor = PeeroreumColor.black;
                              _image = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PeeroreumColor.primaryPuple[50],
                              border: Border.all(
                                color: PeeroreumColor.gray[100]!,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _backgroundColor = PeeroreumColor.white;
                              _fontColor = PeeroreumColor.black;
                              _image = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PeeroreumColor.white,
                              border: Border.all(
                                color: PeeroreumColor.gray[100]!,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _backgroundColor = PeeroreumColor.black;
                              _fontColor = PeeroreumColor.white;
                              _image = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PeeroreumColor.black,
                              border: Border.all(
                                color: PeeroreumColor.gray[100]!,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            final selectedColor = await showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0), // 테두리의 둥근 정도 조절
                                    ),
                                  child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ColorPicker(
                                            showLabel: false,
                                            enableAlpha: false,
                                            pickerColor: _backgroundColor,
                                            onColorChanged: (Color color) {
                                              setState(() {
                                                _backgroundColor = color;
                                                int red = color.red;
                                                int blue = color.blue;
                                                int green = color.green;
                                                _fontColor = Color.fromRGBO(
                                                    255 - red,
                                                    255 - green,
                                                    255 - blue,
                                                    1);
                                              });
                                            },
                                          ),

                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('확인',
                                            style: TextStyle(
                                              color: PeeroreumColor.black,
                                              fontFamily: 'Pretendard'
                                            ),),
                                          )
                                        ],
                                      )),
                                );
                              },
                            );
                            if (selectedColor != null) {
                              changeColor(selectedColor);
                            }
                          },
                          child: const Image(image: AssetImage('assets/icons/color_picker.png')),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            getImage(ImageSource.gallery);
                            _fontColor = PeeroreumColor.white;
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xffCACACA),
                              border: Border.all(
                                color: PeeroreumColor.gray[100]!,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: PeeroreumColor.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "글씨색",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: PeeroreumColor.black,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _fontColor = PeeroreumColor.white;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PeeroreumColor.white,
                              border: Border.all(
                                color: PeeroreumColor.gray[100]!,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _fontColor = PeeroreumColor.black;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PeeroreumColor.black,
                              border: Border.all(
                                color: PeeroreumColor.gray[100]!,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            final selectedColor = await showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ColorPicker(
                                            pickerColor: _fontColor,
                                            onColorChanged: (Color color) {
                                              setState(() {
                                                _fontColor = color;
                                              });
                                            },
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('확인'),
                                          )
                                        ],
                                      )),
                                );
                              },
                            );
                            if (selectedColor != null) {
                              changeColor(selectedColor);
                            }
                          },
                          child: const Image(image: AssetImage('assets/icons/color_picker.png')),
                        ),
                      ],
                    )
                  ],
                ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  postWeduAndInvitation(weduMap) async {
    var dio = Dio();
    final token = await const FlutterSecureStorage().read(key: "accessToken");
    bytes = await controller.capture();
    var byteList = bytes?.toList();
    weduMap.addAll({"inviFile": MultipartFile.fromBytes(byteList!, filename: "invitation.jpg")});
    FormData formData = FormData.fromMap(weduMap);
    dio.options.contentType = 'multipart/form-data';
    dio.options.headers = {'Authorization': 'Bearer $token'};
    var inviResult = await dio.post('${API.hostConnect}/wedu', data: formData);
    if(inviResult.statusCode == 200) {
      Navigator.pushNamedAndRemoveUntil(context, '/wedu', (route) => false);
    } else {
      print("초대장 ${inviResult.statusMessage}");
    }
  }
}
