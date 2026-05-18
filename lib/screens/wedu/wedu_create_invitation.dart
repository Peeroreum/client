import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:peeroreum_client/designs/PeeroreumToast.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peeroreum_client/widgets/custom_image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import 'package:get/get.dart';

class CreateInvitation extends StatefulWidget {
  const CreateInvitation({super.key});

  @override
  State<CreateInvitation> createState() => _CreateInvitationState();
}

class _CreateInvitationState extends State<CreateInvitation> {
  final maxContext = 30;
  String contextValue = "";
  bool isImagePickerActive = false;
  List<bool> isBackgroundSelected = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<bool> isFontColorSelected = [false, false, false];
  List<dynamic> backgroundColorSelect = [
    PeeroreumColor.primaryPuple[400],
    PeeroreumColor.primaryPuple[200],
    PeeroreumColor.primaryPuple[50],
    PeeroreumColor.white,
    PeeroreumColor.black,
    const Color(0xffCACACA),
    const Color(0xffCACACA)
  ];
  List<dynamic> fontColorSelect = [
    PeeroreumColor.white,
    PeeroreumColor.black,
    const Color(0xffCACACA)
  ];
  bool nextButton = false;

  Color _backgroundColor = PeeroreumColor.primaryPuple[400]!;
  Color _fontColor = PeeroreumColor.white;
  Color? _savedBackgroundColor;
  Color? _savedFontColor;
  String _inviText = "같이방에서 같이 공부해요~ ☆";

  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;

  Map<String, String> iconMap = {
    '♡': '★',
    '♥': '☆',
    '☆': '♥',
    '★': '♡',
  };

  checkColors() {
    if (_backgroundColor == PeeroreumColor.primaryPuple[400]) {
      isBackgroundSelected = [true, false, false, false, false, false, false];
    } else if (_backgroundColor == PeeroreumColor.primaryPuple[200]) {
      isBackgroundSelected = [false, true, false, false, false, false, false];
    } else if (_backgroundColor == PeeroreumColor.primaryPuple[50]) {
      isBackgroundSelected = [false, false, true, false, false, false, false];
    } else if (_backgroundColor == PeeroreumColor.white) {
      isBackgroundSelected = [false, false, false, true, false, false, false];
    } else if (_backgroundColor == PeeroreumColor.black) {
      isBackgroundSelected = [false, false, false, false, true, false, false];
    } else {
      isBackgroundSelected = [false, false, false, false, false, false, false];
    }
    if (_fontColor == PeeroreumColor.white) {
      isFontColorSelected = [true, false, false];
    } else if (_fontColor == PeeroreumColor.black) {
      isFontColorSelected = [false, true, false];
    } else {
      isFontColorSelected = [false, false, false];
    }
  }

  updateColor() {
    setState(() {
      checkColors();
    });
  }

  Color? pickerColor;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  XFile? _image;

  Future getImage() async {
    if (isImagePickerActive) return;
    isImagePickerActive = true;
    final selected = await showCustomImagePicker(context, multiple: false);
    if (selected != null && selected.isNotEmpty) {
      final cropped = await cropImage(context, selected.first);
      if (cropped != null) {
        setState(() {
          _image = cropped;
        });
      }
    }
    isImagePickerActive = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkColors();
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
          shape: Border(
            bottom: BorderSide(
              color: PeeroreumColor.gray[100]!,
              width: 1,
            ),
          ),
          backgroundColor: PeeroreumColor.white,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            color: PeeroreumColor.black,
            icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
            onPressed: () {
              Get.back();
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
            Container(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  if (nextButton) {
                    postWeduAndInvitation(weduMap);
                  } else {
                    PeeroreumToast.show(context, '초대장 문구를 넣어주세요.');
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '만들기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: nextButton
                          ? PeeroreumColor.primaryPuple[400]
                          : PeeroreumColor.gray[400],
                    ),
                  ),
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
                                  Colors.black.withOpacity(0.2),
                                  BlendMode.darken),
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
                            _inviText = value.replaceAllMapped(
                              RegExp(r'[♡♥☆★]'),
                              (match) => iconMap[match.group(0)]!,
                            );
                            if (value.isEmpty) {
                              nextButton = false;
                            }
                            if (value.isNotEmpty) {
                              for (int i = 1; i < value.length + 1; i++) {
                                if (value == ' ' * i) {
                                  nextButton = false;
                                  PeeroreumToast.show(
                                      context, '공백으로 만들 수 없어요.');
                                }
                                if (value != ' ' * i) {
                                  nextButton = true;
                                }
                              }
                            }
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
                        SizedBox(
                          height: 32,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 7,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    for (int i = 0;
                                        i < isBackgroundSelected.length;
                                        i++) {
                                      isBackgroundSelected[i] = i == index;
                                    }
                                  });
                                  if (index == 5) {
                                    isFontColorSelected = [false, false, false];
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: PeeroreumColor.white,
                                          shadowColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ColorPicker(
                                                    pickerAreaHeightPercent:
                                                        0.7,
                                                    pickerAreaBorderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    showLabel: false,
                                                    enableAlpha: false,
                                                    pickerColor:
                                                        _backgroundColor,
                                                    onColorChanged:
                                                        (Color color) {
                                                      setState(() {
                                                        _savedBackgroundColor =
                                                            color;
                                                        int red = color.red;
                                                        int blue = color.blue;
                                                        int green = color.green;
                                                        _savedFontColor =
                                                            Color.fromRGBO(
                                                                255 - red,
                                                                255 - green,
                                                                255 - blue,
                                                                1);
                                                        //checkColors();
                                                      });
                                                    },
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Get.back();
                                                          updateColor();
                                                        },
                                                        child: Text(
                                                          '취소',
                                                          style: TextStyle(
                                                              color:
                                                                  PeeroreumColor
                                                                          .gray[
                                                                      600],
                                                              fontFamily:
                                                                  'Pretendard'),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _image = null;
                                                            _backgroundColor =
                                                                _savedBackgroundColor!;
                                                            _fontColor =
                                                                _savedFontColor!;
                                                          });
                                                          Get.back();
                                                          updateColor();
                                                        },
                                                        child: Text(
                                                          '확인',
                                                          style: TextStyle(
                                                              color: PeeroreumColor
                                                                      .primaryPuple[
                                                                  400],
                                                              fontFamily:
                                                                  'Pretendard'),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 4,
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )),
                                        );
                                      },
                                    );
                                  } else if (index == 6) {
                                    await getImage();
                                    if (_image != null) {
                                      _backgroundColor =
                                          const Color(0xfffffffe);
                                      _fontColor = PeeroreumColor.white;
                                      isFontColorSelected = [
                                        true,
                                        false,
                                        false
                                      ];
                                    } else {
                                      setState(() {
                                        checkColors();
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      switch (index) {
                                        case 0:
                                          _backgroundColor =
                                              PeeroreumColor.primaryPuple[400]!;
                                          _fontColor = PeeroreumColor.white;
                                          _image = null;
                                          isFontColorSelected = [
                                            true,
                                            false,
                                            false
                                          ];
                                          break;
                                        case 1:
                                          _backgroundColor =
                                              PeeroreumColor.primaryPuple[200]!;
                                          _fontColor = PeeroreumColor.white;
                                          _image = null;
                                          isFontColorSelected = [
                                            true,
                                            false,
                                            false
                                          ];
                                          break;
                                        case 2:
                                          _backgroundColor =
                                              PeeroreumColor.primaryPuple[50]!;
                                          _fontColor = PeeroreumColor.black;
                                          _image = null;
                                          isFontColorSelected = [
                                            false,
                                            true,
                                            false
                                          ];
                                          break;
                                        case 3:
                                          _backgroundColor =
                                              PeeroreumColor.white;
                                          _fontColor = PeeroreumColor.black;
                                          _image = null;
                                          isFontColorSelected = [
                                            false,
                                            true,
                                            false
                                          ];
                                          break;
                                        case 4:
                                          _backgroundColor =
                                              PeeroreumColor.black;
                                          _fontColor = PeeroreumColor.white;
                                          _image = null;
                                          isFontColorSelected = [
                                            true,
                                            false,
                                            false
                                          ];
                                          break;
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: backgroundColorSelect[index],
                                    border: Border.all(
                                      color: Colors.grey[100]!,
                                      width: 2,
                                    ),
                                    image: index == 5
                                        ? const DecorationImage(
                                            image: AssetImage(
                                                'assets/images/colorpicker_background.png'),
                                          )
                                        : null,
                                  ),
                                  child: index == 5 || index == 6
                                      ? (index == 6
                                          ? Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: SvgPicture.asset(
                                                'assets/icons/camera2.svg',
                                                color: PeeroreumColor.white,
                                              ))
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: SvgPicture.asset(
                                                'assets/icons/spoid.svg',
                                                color: PeeroreumColor.white,
                                              )))
                                      : (isBackgroundSelected[index]
                                          ? SvgPicture.asset(
                                              'assets/icons/check2.svg',
                                              color: ((index == 2 || index == 3)
                                                  ? PeeroreumColor.gray[600]
                                                  : PeeroreumColor.white),
                                            )
                                          : null),
                                ),
                              );
                            },
                          ),
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
                        SizedBox(
                          height: 32,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    for (int i = 0;
                                        i < isFontColorSelected.length;
                                        i++) {
                                      isFontColorSelected[i] = i == index;
                                    }
                                  });

                                  if (index == 2) {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: PeeroreumColor.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ColorPicker(
                                                    pickerAreaHeightPercent:
                                                        0.7,
                                                    pickerAreaBorderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    showLabel: false,
                                                    enableAlpha: false,
                                                    pickerColor: _fontColor,
                                                    onColorChanged:
                                                        (Color color) {
                                                      setState(() {
                                                        _savedFontColor = color;
                                                      });
                                                    },
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Get.back();
                                                          updateColor();
                                                        },
                                                        child: Text(
                                                          '취소',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  PeeroreumColor
                                                                          .gray[
                                                                      600],
                                                              fontFamily:
                                                                  'Pretendard'),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _fontColor =
                                                                _savedFontColor!;
                                                          });
                                                          Get.back();
                                                          updateColor();
                                                        },
                                                        child: Text(
                                                          '확인',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: PeeroreumColor
                                                                      .primaryPuple[
                                                                  400],
                                                              fontFamily:
                                                                  'Pretendard'),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 4,
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )),
                                        );
                                      },
                                    );
                                  } else {
                                    setState(() {
                                      switch (index) {
                                        case 0:
                                          _fontColor = PeeroreumColor.white;
                                          break;
                                        case 1:
                                          _fontColor = PeeroreumColor.black;
                                          break;
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: fontColorSelect[index],
                                    border: Border.all(
                                      color: Colors.grey[100]!,
                                      width: 2,
                                    ),
                                    image: index == 2
                                        ? const DecorationImage(
                                            image: AssetImage(
                                                'assets/images/colorpicker_background.png'),
                                          )
                                        : null,
                                  ),
                                  child: index == 2
                                      ? Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: SvgPicture.asset(
                                            'assets/icons/spoid.svg',
                                            color: PeeroreumColor.white,
                                          ))
                                      : (isFontColorSelected[index]
                                          ? SvgPicture.asset(
                                              'assets/icons/check2.svg',
                                              color: ((index == 0)
                                                  ? PeeroreumColor.gray[600]
                                                  : PeeroreumColor.white),
                                            )
                                          : null),
                                ),
                              );
                            },
                          ),
                        ),
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
    bytes = await controller.capture();
    var byteList = bytes?.toList();
    weduMap.addAll({
      "inviFile":
          dio.MultipartFile.fromBytes(byteList!, filename: "invitation.jpg")
    });
    dio.FormData formData = dio.FormData.fromMap(weduMap);
    try {
      var inviResult = await ApiClient().postForm('/wedu', formData);
      if (inviResult.statusCode == 200) {
        Get.offAllNamed('/home');
      } else {
        PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
    } catch (e) {
      print('Unexpected error: $e');
      PeeroreumToast.show(context, '잠시 후에 다시 시도해 주세요.', isError: true);
    }
  }
}
