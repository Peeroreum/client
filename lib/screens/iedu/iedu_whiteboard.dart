// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class WhiteboardIedu extends StatefulWidget {
  const WhiteboardIedu({super.key});

  @override
  State<WhiteboardIedu> createState() => _WhiteboardIeduState();
}

class _WhiteboardIeduState extends State<WhiteboardIedu> {
  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _drawingController.setStyle(color: _color, strokeWidth: _strokeWidth);
    super.initState();
  }

  longpressCheck() {
    if (isLongPressed[0]) {
      penDetailTool();
    } else if (isLongPressed[1]) {
      highlighterDetailTool();
    } else if (isLongPressed[2]) {
      eraserDetailTool();
    }
  }

  final DrawingController _drawingController = DrawingController();
  final WidgetsToImageController _imageController = WidgetsToImageController();
  Uint8List? bytes;
  XFile? whiteboardImage;

  late Color _color = colorSelect[0];
  List<bool> isColorSelected = [true, false, false];
  List<bool> isPenSelected = [true, false, false];
  List<Color> colorSelect = [
    PeeroreumColor.primaryPuple[400]!,
    PeeroreumColor.black,
    PeeroreumColor.white,
  ];
  Color? _savedColor;
  double _opacity = 1.0;
  double _strokeWidth = 8;

  List<bool> isLongPressed = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        isLongPressed = [false, false, false];
      },
      child: Scaffold(
        backgroundColor: PeeroreumColor.white,
        appBar: appbarWidget(),
        body: bodyWidget(),
      ),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      shape: Border(
        bottom: BorderSide(
          color: PeeroreumColor.gray[100]!,
          width: 1,
        ),
      ),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        color: PeeroreumColor.black,
        icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () async {
            postWhiteboard();
          },
          child: Text(
            '완료',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: PeeroreumColor.gray[500],
            ),
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return WidgetsToImage(
              controller: _imageController,
              child: DrawingBoard(
                controller: _drawingController,
                background: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: PeeroreumColor.white,
                ),
                boardBoundaryMargin: EdgeInsets.zero,
                showDefaultActions: false,
                showDefaultTools: false,
              ),
            );
          },
        ),
        bottomWidget(),
      ],
    );
  }

  Widget bottomWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 다음 업데이트 때 작업-길게 눌렀을 때 펜의 추가기능
        // if (isLongPressed[0])
        //   Padding(
        //       padding: EdgeInsets.fromLTRB(34, 0, 0, 0),
        //       child: penDetailTool()),
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(34, 8, 34, 24),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: PeeroreumColor.gray[50],
              border: Border.all(
                color: PeeroreumColor.gray[100]!,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                penTool(),
                SizedBox(
                  width: 20,
                ),
                colorTool(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  penTool() {
    return SizedBox(
      height: 32,
      width: 112,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 0;
                }
                _opacity = 1.0;
              });
              _drawingController.setPaintContent(SimpleLine());
              _drawingController.setStyle(
                  strokeWidth: _strokeWidth,
                  blendMode: BlendMode.srcOver,
                  color: _color.withOpacity(1));
            },
            // 다음 업데이트 때 작업-길게 눌렀을 때 추가기능
            // onLongPress: () {
            //   setState(() {
            //     isLongPressed = [true, false, false];
            //     longpressCheck();
            //   });
            // },
            child: Container(
              margin: const EdgeInsets.all(4.0),
              width: 24,
              child: SvgPicture.asset(
                'assets/icons/pen_nib_straight.svg',
                color: isPenSelected[0]
                    ? PeeroreumColor.black
                    : PeeroreumColor.gray[600],
                width: isPenSelected[0]? 24 : null,
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 1;
                }
                _opacity = 0.2;
              });
              _drawingController.setPaintContent(SimpleLine());
              _drawingController.setStyle(
                  strokeWidth: 20,
                  blendMode: BlendMode.srcOver,
                  color: _color.withOpacity(_opacity));
            },
            // 다음 업데이트 때 작업-길게 눌렀을 때 추가기능
            // onLongPress: () {
            //   setState(() {
            //     isLongPressed = [false, true, false];
            //     longpressCheck();
            //   });
            // },
            child: Container(
              margin: EdgeInsets.all(4.0),
              width: 24,
              child: SvgPicture.asset(
                'assets/icons/highlighter.svg',
                color: isPenSelected[1]
                    ? PeeroreumColor.black
                    : PeeroreumColor.gray[600],
                width: isPenSelected[1]? 24 : null,
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 2;
                }
                _opacity = 1.0;
              });
              _drawingController.setPaintContent(Eraser(color: Colors.white));
              _drawingController.setStyle(
                  strokeWidth: 20,
                  blendMode: BlendMode.srcOver,
                  color: _color.withOpacity(1));
            },
            // 다음 업데이트 때 작업-길게 눌렀을 때 추가기능
            // onLongPress: () {
            //   setState(() {
            //     isLongPressed = [false, false, true];
            //     longpressCheck();
            //   });
            // },
            child: Container(
              margin: isPenSelected[2]? const EdgeInsets.all(2.0) : const EdgeInsets.all(4.0),
              width: isPenSelected[2]? 26 : null,
              child: SvgPicture.asset(
                'assets/icons/eraser.svg',
                color: isPenSelected[2]
                    ? PeeroreumColor.black
                    : PeeroreumColor.gray[600],
                width: isPenSelected[2]? 26 : null
              ),
            ),
          ),
        ],
      ),
    );
  }

  penDetailTool() {
    //다음 업데이트 때 작업-길게 눌렀을 때 펜의 추가기능
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: PeeroreumColor.gray[50],
        border: Border.all(
          color: PeeroreumColor.gray[100]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          colorTool(),
          Container(
            height: 1,
            width: 112,
            margin: EdgeInsets.symmetric(vertical: 8),
            color: PeeroreumColor.gray[100],
          ),
          colorTool(),
        ],
      ),
    );
  }

  highlighterDetailTool() {
    Fluttertoast.showToast(msg: 'highlighterDetailTool');
  }

  eraserDetailTool() {
    Fluttertoast.showToast(msg: 'eraserDetailTool');
  }

  colorTool() {
    return SizedBox(
      height: 32,
      width: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                for (int i = 0; i < isColorSelected.length; i++) {
                  isColorSelected[i] = i == index;
                }
                switch (index) {
                  case 0:
                    _color = colorSelect[0];
                    _drawingController.setStyle(
                        color: colorSelect[0].withOpacity(_opacity));
                    _savedColor = null;
                    break;
                  case 1:
                    _color = colorSelect[1];
                    _drawingController.setStyle(
                        color: colorSelect[1].withOpacity(_opacity));
                    _savedColor = null;
                    break;
                }
                if (index == 2) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: PeeroreumColor.white,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ColorPicker(
                                  pickerAreaHeightPercent: 0.7,
                                  pickerAreaBorderRadius:
                                      BorderRadius.circular(10),
                                  showLabel: false,
                                  enableAlpha: false,
                                  pickerColor: _color,
                                  onColorChanged: (Color color) {
                                    setState(() {
                                      _savedColor = color;
                                    });
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        '취소',
                                        style: TextStyle(
                                            color: PeeroreumColor.gray[600],
                                            fontFamily: 'Pretendard'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _color = _savedColor!;
                                          _drawingController.setStyle(
                                              color:
                                                  _color.withOpacity(_opacity));
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        '확인',
                                        style: TextStyle(
                                            color: PeeroreumColor
                                                .primaryPuple[400],
                                            fontFamily: 'Pretendard'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    )
                                  ],
                                )
                              ],
                            )),
                      );
                    },
                  );
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index != 2 ? colorSelect[index] : _color,
                border: Border.all(
                  color: PeeroreumColor.gray[100]!,
                  width: 2,
                ),
                image: index == 2
                    ? _savedColor != _color
                        ? DecorationImage(
                            image: AssetImage(
                                'assets/images/colorpicker_background.png'),
                          )
                        : null
                    : null,
              ),
              child: index == 2
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgPicture.asset(
                        'assets/icons/spoid.svg',
                        color: PeeroreumColor.white,
                      ))
                  : isColorSelected[index]
                      ? Padding(
                          padding: EdgeInsets.all(4.0),
                          child: SvgPicture.asset(
                            'assets/icons/check2.svg',
                            color: PeeroreumColor.white,
                          ),
                        )
                      : null,
            ),
          );
        },
      ),
    );
  }

  postWhiteboard() async {
    bytes = await _imageController.capture();

    Directory? tempDir = await getTemporaryDirectory();
    File? file = File(
        '${tempDir.path}/whiteboard${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes!);
    whiteboardImage = (XFile(file.path));

    Navigator.pop(context, whiteboardImage);
  }
}
